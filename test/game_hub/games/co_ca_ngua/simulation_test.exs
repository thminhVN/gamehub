defmodule GameHub.Games.CoCaNgua.SimulationTest do
  @moduledoc """
  Plays full random 2-player games to completion and independently re-derives
  the expected outcome of every roll from the board state *before* the engine
  touches it, then cross-checks the engine's actual result against it. This is
  deliberately not just "call the same function and check it agrees with
  itself" — capture, safety, blocking, and turn-advance are all recomputed
  from scratch here using raw position arithmetic.
  """
  use ExUnit.Case, async: true

  alias GameHub.Games.CoCaNgua.Board

  @max_rolls 20_000
  @finish Board.finish_position()
  @track_length Board.track_length()
  @pieces_per_player Board.pieces_per_player()

  test "a full random 2-player game reaches a winner while obeying every rule" do
    for seed <- 1..5 do
      :rand.seed(:exsplus, {seed, seed * 7 + 1, seed * 13 + 3})
      board = Board.new(2, ["An", "Binh"])
      stats = %{rolls: 0, releases: 0, captures: 0, finishes: 0, sixes: 0, triple_six: 0}
      final_stats = run_game(board, stats)

      assert final_stats.rolls > 0
      # The winner finished all 4; the loser may have finished some too before
      # the game ended, so this is a lower bound, not an exact count.
      assert final_stats.finishes >= @pieces_per_player

      IO.puts(
        "seed=#{seed} rolls=#{final_stats.rolls} releases=#{final_stats.releases} " <>
          "captures=#{final_stats.captures} sixes=#{final_stats.sixes} " <>
          "triple_six_penalties=#{final_stats.triple_six}"
      )
    end
  end

  defp run_game(%Board{winner: winner} = board, stats) when not is_nil(winner) do
    assert board.status == :game_over

    assert Enum.all?(0..(@pieces_per_player - 1), fn idx ->
             Map.get(board.pieces, {winner, idx}) == @finish
           end),
           "winner #{winner} declared without all pieces finished: #{inspect(board.pieces)}"

    stats
  end

  defp run_game(_board, stats) when stats.rolls > @max_rolls do
    flunk("game did not finish within #{@max_rolls} rolls")
  end

  defp run_game(board, stats) do
    num_players = length(board.players)
    prev_player_idx = board.current_player

    {:ok, rolled, result} = Board.roll(board)
    die = rolled.die

    assert die in 1..6

    stats = %{stats | rolls: stats.rolls + 1}
    stats = if die == 6, do: %{stats | sixes: stats.sixes + 1}, else: stats

    case result do
      :triple_six_penalty ->
        assert rolled.pieces == board.pieces,
               "triple-six penalty must not move any piece"

        assert rolled.consecutive_sixes == 0
        assert rolled.current_player == rem(prev_player_idx + 1, num_players)
        assert rolled.status == :rolling

        run_game(rolled, %{stats | triple_six: stats.triple_six + 1})

      :no_legal_moves ->
        verify_no_legal_moves!(board, Board.current_player(board).color, die)
        verify_turn_advance!(rolled, prev_player_idx, num_players, die)
        run_game(rolled, stats)

      :ok ->
        legal = Board.legal_moves(rolled)
        assert legal != []
        move = Enum.random(legal)

        verify_move_preconditions!(rolled, move)

        {:ok, moved} = Board.apply_move(rolled, move.piece)

        stats = verify_move_effects!(rolled, moved, move, stats)

        if moved.winner do
          run_game(moved, stats)
        else
          verify_turn_advance!(moved, prev_player_idx, num_players, die)
          run_game(moved, stats)
        end
    end
  end

  defp verify_turn_advance!(board, prev_player_idx, num_players, die) do
    if die == 6 do
      assert board.current_player == prev_player_idx,
             "rolling a 6 must grant an extra turn (same player stays)"
    else
      assert board.current_player == rem(prev_player_idx + 1, num_players),
             "a non-six roll must advance to the next player"
    end
  end

  # Independently recompute, from raw positions, that no piece of `color` has
  # any legal move for `die` — without calling Board.legal_moves/1.
  defp verify_no_legal_moves!(board, color, die) do
    refute Enum.any?(0..(@pieces_per_player - 1), fn idx ->
             case Map.fetch!(board.pieces, {color, idx}) do
               :home ->
                 die == 6 and
                   not Enum.any?(0..(@pieces_per_player - 1), fn other ->
                     other != idx and Map.get(board.pieces, {color, other}) == 0
                   end)

               pos when is_integer(pos) ->
                 new_pos = pos + die

                 new_pos <= @finish and
                   not Enum.any?(0..(@pieces_per_player - 1), fn other ->
                     other != idx and Map.get(board.pieces, {color, other}) == new_pos and
                       new_pos != @finish
                   end)
             end
           end),
           "engine reported no legal moves but a raw recomputation found one"
  end

  # Re-derive legality from raw board state, independent of Board.legal_moves/1.
  defp verify_move_preconditions!(board, %{piece: {color, idx} = piece_key, action: :release}) do
    assert Map.fetch!(board.pieces, piece_key) == :home
    assert board.die == 6

    refute Enum.any?(0..(@pieces_per_player - 1), fn other ->
             other != idx and Map.get(board.pieces, {color, other}) == 0
           end),
           "released onto a start square already occupied by an own piece"
  end

  defp verify_move_preconditions!(board, %{piece: piece_key, new_pos: new_pos, action: action})
       when action in [:move, :finish] do
    pos = Map.fetch!(board.pieces, piece_key)
    assert is_integer(pos)
    assert pos + board.die == new_pos
    assert new_pos <= @finish

    {color, idx} = piece_key

    refute Enum.any?(0..(@pieces_per_player - 1), fn other ->
             other != idx and Map.get(board.pieces, {color, other}) == new_pos and new_pos != @finish
           end),
           "landed on a square already occupied by another own piece"
  end

  # Cross-check capture/safety/win effects against a from-scratch recomputation.
  defp verify_move_effects!(before_board, after_board, move, stats) do
    {color, _idx} = move.piece

    assert Map.fetch!(after_board.pieces, move.piece) == move.new_pos

    # No other piece of any color should have moved, except a captured opponent
    # sent home.
    captured =
      for {{other_color, other_idx} = key, pos} <- before_board.pieces,
          key != move.piece,
          Map.fetch!(after_board.pieces, key) != pos do
        {other_color, other_idx, pos}
      end

    stats =
      case move.action do
        :release ->
          # Entering play always captures an opponent camped on your own start
          # square, unlike a safe cell reached by normal movement.
          abs_cell = Board.absolute_cell(color, 0)

          expected_captured =
            for {{other_color, other_idx}, pos} <- before_board.pieces,
                other_color != color,
                is_integer(pos),
                pos <= @track_length - 1,
                Board.absolute_cell(other_color, pos) == abs_cell do
              {other_color, other_idx, pos}
            end

          assert MapSet.new(captured) == MapSet.new(expected_captured),
                 "release-capture mismatch: expected #{inspect(expected_captured)}, got #{inspect(captured)}"

          assert Enum.all?(captured, fn {c, i, _} -> Map.fetch!(after_board.pieces, {c, i}) == :home end)

          stats = if captured != [], do: %{stats | captures: stats.captures + length(captured)}, else: stats
          %{stats | releases: stats.releases + 1}

        action when action in [:move, :finish] and move.new_pos <= @track_length - 1 ->
          abs_cell = Board.absolute_cell(color, move.new_pos)
          safe? = move.new_pos in Board.safe_cells()

          expected_captured =
            for {{other_color, other_idx}, pos} <- before_board.pieces,
                other_color != color,
                is_integer(pos),
                pos <= @track_length - 1,
                Board.absolute_cell(other_color, pos) == abs_cell do
              {other_color, other_idx, pos}
            end

          if safe? do
            assert expected_captured == [] or captured == [],
                   "a piece was captured while landing on a safe cell"
          else
            assert MapSet.new(captured) == MapSet.new(expected_captured),
                   "capture mismatch: expected #{inspect(expected_captured)}, got #{inspect(captured)}"

            assert Enum.all?(captured, fn {c, i, _} -> Map.fetch!(after_board.pieces, {c, i}) == :home end)
          end

          stats = if captured != [], do: %{stats | captures: stats.captures + length(captured)}, else: stats
          if move.action == :finish, do: %{stats | finishes: stats.finishes + 1}, else: stats

        _ ->
          # home-stretch move: no captures possible there.
          assert captured == []
          if move.action == :finish, do: %{stats | finishes: stats.finishes + 1}, else: stats
      end

    stats
  end
end
