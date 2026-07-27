defmodule GameHub.Games.CoCaNgua.BoardTest do
  use ExUnit.Case, async: true

  alias GameHub.Games.CoCaNgua.Board

  # Relative position `color` must hold to stand on absolute loop cell `abs_cell`.
  # Derived from the engine so these tests keep meaning if the loop is resized.
  defp rel(color, abs_cell) do
    Integer.mod(abs_cell - Board.start_cell(color), Board.track_length())
  end

  describe "new/1" do
    test "creates the right colors for 2, 3, and 4 players" do
      assert Enum.map(Board.new(2).players, & &1.color) == [:red, :yellow]
      assert Enum.map(Board.new(3).players, & &1.color) == [:red, :green, :yellow]
      assert Enum.map(Board.new(4).players, & &1.color) == [:red, :green, :yellow, :blue]
    end

    test "all pieces start in chuồng, 4 per player" do
      board = Board.new(4)
      assert Enum.all?(board.pieces, fn {_key, pos} -> pos == :home end)
      assert map_size(board.pieces) == 4 * 4
    end
  end

  describe "leaving chuồng" do
    test "cannot leave chuồng without a 1 or a 6" do
      board = %{Board.new(2) | die: 4, status: :moving}
      assert Board.legal_moves(board) == []
    end

    test "a 6 allows any piece in chuồng to leave" do
      board = %{Board.new(2) | die: 6, status: :moving}
      moves = Board.legal_moves(board)
      assert length(moves) == 4
      assert Enum.all?(moves, &(&1.action == :release and &1.new_pos == 0))
    end

    test "a 1 also allows any piece in chuồng to leave" do
      board = %{Board.new(2) | die: 1, status: :moving}
      moves = Board.legal_moves(board)
      assert length(moves) == 4
      assert Enum.all?(moves, &(&1.action == :release and &1.new_pos == 0))
    end

    test "apply_move releases the piece to position 0" do
      board = %{Board.new(2) | die: 6, status: :moving}
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == 0
    end

    test "cannot release another piece while the start square is already occupied by own piece" do
      board = %{Board.new(2) | die: 6, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 0)
      moves = Board.legal_moves(board)
      refute Enum.any?(moves, &(&1.action == :release))
      assert {:error, :illegal_move} = Board.apply_move(board, {:red, 1})
    end
  end

  describe "movement" do
    test "moving forward advances the piece by the die value" do
      board = %{Board.new(2) | die: 5, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 10)
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == 15
    end

    test "cannot overshoot the finish" do
      board = %{Board.new(2) | die: 6, status: :moving}
      # three short of the finish, so a 6 would sail past it
      board = put_in(board.pieces[{:red, 0}], Board.finish_position() - 3)
      refute Enum.any?(Board.legal_moves(board), &(&1.piece == {:red, 0}))
    end

    test "landing exactly on finish position is legal and wins if all pieces home" do
      board = %{Board.new(2) | die: 3, status: :moving}
      board = put_in(board.pieces[{:red, 0}], Board.finish_position() - 3)
      board = put_in(board.pieces[{:red, 1}], Board.finish_position())
      board = put_in(board.pieces[{:red, 2}], Board.finish_position())
      board = put_in(board.pieces[{:red, 3}], Board.finish_position())
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == Board.finish_position()
      assert board.winner == :red
      assert board.status == :game_over
    end

    test "own pieces cannot stack on the same cell" do
      board = %{Board.new(2) | die: 3, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 10)
      board = put_in(board.pieces[{:red, 1}], 7)
      refute Enum.any?(Board.legal_moves(board), &(&1.piece == {:red, 1} and &1.new_pos == 10))
    end

    test "own pieces cannot hop clean over each other either" do
      board = %{Board.new(2) | die: 5, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 7)
      board = put_in(board.pieces[{:red, 1}], 9)
      refute Enum.any?(Board.legal_moves(board), &(&1.piece == {:red, 0}))
    end

    test "cannot hop clean over an enemy piece ahead on the shared loop" do
      board = %{Board.new(2) | die: 5, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 12)
      # yellow parked on absolute cell 15: 3 cells ahead of red's 12, closer than
      # the die of 5, so red would have to hop clean over it.
      board = put_in(board.pieces[{:yellow, 0}], rel(:yellow, 15))
      refute Enum.any?(Board.legal_moves(board), &(&1.piece == {:red, 0}))
    end

    test "landing exactly on an enemy piece ahead is still a legal capture" do
      board = %{Board.new(2) | die: 3, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 15)
      # yellow on absolute cell 18: exactly 3 ahead of red's 15, and not a safe cell
      board = put_in(board.pieces[{:yellow, 0}], rel(:yellow, 18))
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == 18
      assert board.pieces[{:yellow, 0}] == :home
    end

    test "a die not reaching the enemy piece is unaffected by it" do
      board = %{Board.new(2) | die: 2, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 12)
      board = put_in(board.pieces[{:yellow, 0}], rel(:yellow, 15))
      assert Enum.any?(Board.legal_moves(board), &(&1.piece == {:red, 0} and &1.new_pos == 14))
    end
  end

  describe "capture" do
    test "landing on an opponent sends it back to chuồng" do
      board = %{Board.new(2) | die: 5, status: :moving}
      board = put_in(board.pieces[{:red, 0}], 10)
      # yellow sits on absolute cell 15, exactly where red's die of 5 lands it
      board = put_in(board.pieces[{:yellow, 0}], rel(:yellow, 15))
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == 15
      assert board.pieces[{:yellow, 0}] == :home
    end

    test "safe cells (start squares) protect opponents from capture" do
      board = %{Board.new(2) | die: 6, status: :moving}
      # yellow's own start square is safe; park yellow on it (relative pos 0)
      board = put_in(board.pieces[{:yellow, 0}], 0)
      # red six steps short of that same square
      landing = rel(:red, Board.start_cell(:yellow))
      board = put_in(board.pieces[{:red, 0}], landing - 6)
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == landing
      assert board.pieces[{:yellow, 0}] == 0
    end

    test "releasing a piece captures an opponent camped on your own start square" do
      board = %{Board.new(2) | die: 6, status: :moving}
      # yellow parked on red's start square (absolute cell 0)
      board = put_in(board.pieces[{:yellow, 0}], rel(:yellow, Board.start_cell(:red)))
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.pieces[{:red, 0}] == 0
      assert board.pieces[{:yellow, 0}] == :home
    end
  end

  describe "extra turns and triple-six penalty" do
    test "rolling a 6 with no legal moves at all still keeps the same player's turn" do
      board = Board.new(2)
      # one step short of the finish: a 6 overshoots and nothing else can move
      board = put_in(board.pieces[{:red, 0}], Board.finish_position() - 1)
      board = put_in(board.pieces[{:red, 1}], Board.finish_position())
      board = put_in(board.pieces[{:red, 2}], Board.finish_position())
      board = put_in(board.pieces[{:red, 3}], Board.finish_position())
      {:ok, board, :no_legal_moves} = Board.roll_with(board, 6)
      assert board.current_player == 0
      assert board.status == :rolling
      # die is intentionally left set so the UI can still show what was rolled.
      assert board.die == 6
    end

    test "a normal roll passes the turn after the move is applied" do
      board = Board.new(2)
      board = put_in(board.pieces[{:red, 0}], 5)
      {:ok, board, :ok} = Board.roll_with(board, 3)
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.current_player == 1
      assert board.status == :rolling
      assert board.consecutive_sixes == 0
    end

    test "rolling a 6 still grants an extra turn after the move is applied" do
      board = Board.new(2)
      board = put_in(board.pieces[{:red, 0}], 5)
      {:ok, board, :ok} = Board.roll_with(board, 6)
      {:ok, board} = Board.apply_move(board, {:red, 0})
      assert board.current_player == 0
      assert board.status == :rolling
      assert board.consecutive_sixes == 1
    end

    test "three consecutive sixes forfeits the turn with no move made" do
      board = Board.new(2)
      board = put_in(board.pieces[{:red, 0}], 10)
      board = %{board | consecutive_sixes: 2}

      {:ok, board, result} = Board.roll_with(board, 6)

      assert result == :triple_six_penalty
      assert board.pieces[{:red, 0}] == 10
      assert board.current_player == 1
      assert board.consecutive_sixes == 0
    end
  end
end
