defmodule GameHub.Games.CoCaNgua.Board do
  @moduledoc """
  Pure game logic for Cờ cá ngựa (Vietnamese Ludo), classic rules: 4 horses per
  player, 2-4 players, one die per turn, played on a single device (pass-and-play).

  Rules implemented:
  - A horse leaves chuồng (yard) when the die shows 1 or 6, and only if the
    start square isn't already occupied by another of that player's horses.
  - Rolling a 6 grants an extra turn.
  - Rolling three 6s in a row forfeits that turn (no move is made).
  - A horse must land on the exact final square to finish (overshoot is illegal).
  - Landing exactly on an opponent's horse sends it back to chuồng, except on safe
    squares (each color's own start square).
  - A player's own horses may never occupy the same square, nor hop over one
    another — a die roll that would land on or pass an own horse is illegal.
  - A horse may not hop clean over an opposing horse either. It can still land
    exactly on one (a normal capture), or stop short of it, but a roll that
    would carry it past an enemy's square without landing there is illegal.
  - First player to get all 4 horses to the finish wins; game ends immediately.
  """

  @color_names %{red: "Đỏ", green: "Xanh lá", yellow: "Vàng", blue: "Xanh dương"}
  @track_length 56
  @arm_length div(@track_length, 4)

  # One start per arm: every cell of the loop is walkable, including the four
  # corner cells where the arms meet, so the arms are 14 long, not 13.
  @starts %{
    red: 0,
    green: @arm_length,
    yellow: 2 * @arm_length,
    blue: 3 * @arm_length
  }
  @safe_cells Map.values(@starts)
  @home_stretch 6
  @finish @track_length + @home_stretch
  @pieces_per_player 4

  @color_selection %{
    2 => [:red, :yellow],
    3 => [:red, :green, :yellow],
    4 => [:red, :green, :yellow, :blue]
  }

  defstruct players: [],
            current_player: 0,
            pieces: %{},
            die: nil,
            consecutive_sixes: 0,
            winner: nil,
            status: :rolling,
            log: []

  def track_length, do: @track_length
  def home_stretch, do: @home_stretch
  def finish_position, do: @finish
  def safe_cells, do: @safe_cells
  def pieces_per_player, do: @pieces_per_player
  def color_name(color), do: Map.fetch!(@color_names, color)
  def start_cell(color), do: Map.fetch!(@starts, color)

  @doc "Builds a fresh game for 2-4 players."
  def new(num_players, names \\ nil) when num_players in 2..4 do
    colors = Map.fetch!(@color_selection, num_players)

    players =
      colors
      |> Enum.with_index()
      |> Enum.map(fn {color, i} ->
        %{color: color, name: player_name(names, i, color)}
      end)

    pieces =
      for color <- colors, idx <- 0..(@pieces_per_player - 1), into: %{} do
        {{color, idx}, :home}
      end

    %__MODULE__{players: players, pieces: pieces}
  end

  defp player_name(nil, i, color), do: "Người chơi #{i + 1} (#{color_name(color)})"

  defp player_name(names, i, color) do
    case Enum.at(names, i) do
      nil -> "Người chơi #{i + 1} (#{color_name(color)})"
      "" -> "Người chơi #{i + 1} (#{color_name(color)})"
      name -> name
    end
  end

  def current_player(%__MODULE__{} = board) do
    Enum.at(board.players, board.current_player)
  end

  def current_color(%__MODULE__{} = board), do: current_player(board).color

  @doc "Rolls the die for the current player. Handles the triple-six penalty."
  def roll(%__MODULE__{winner: w}) when not is_nil(w), do: {:error, :game_over}
  def roll(%__MODULE__{status: :moving}), do: {:error, :already_rolled}
  def roll(%__MODULE__{} = board), do: roll_with(board, Enum.random(1..6))

  @doc "Same as roll/1 but with an explicit die value (used for deterministic tests)."
  def roll_with(%__MODULE__{winner: w}, _die) when not is_nil(w), do: {:error, :game_over}
  def roll_with(%__MODULE__{status: :moving}, _die), do: {:error, :already_rolled}

  def roll_with(%__MODULE__{} = board, die) do
    consecutive = if die == 6, do: board.consecutive_sixes + 1, else: 0
    board = %{board | die: die}

    if consecutive >= 3 do
      board = %{board | consecutive_sixes: 0}
      board = log(board, "#{color_name(current_color(board))}: 3 lần 6 liên tiếp, mất lượt.")
      board = advance_to_next_player(board)
      {:ok, board, :triple_six_penalty}
    else
      board = %{board | consecutive_sixes: consecutive, status: :moving}

      if legal_moves(board) == [] do
        board = resolve_end_of_turn(board, die)
        {:ok, board, :no_legal_moves}
      else
        {:ok, board, :ok}
      end
    end
  end

  @doc """
  Lists legal moves for the current player given the die just rolled.
  Each entry: %{piece: {color, idx}, new_pos: integer, action: :release | :move | :finish}
  """
  def legal_moves(%__MODULE__{status: :moving} = board) do
    color = current_color(board)
    die = board.die

    own_pieces =
      for idx <- 0..(@pieces_per_player - 1) do
        {{color, idx}, Map.fetch!(board.pieces, {color, idx})}
      end

    for {piece_key, pos} <- own_pieces,
        move = candidate_move(board, color, piece_key, pos, die),
        not is_nil(move) do
      move
    end
  end

  def legal_moves(_board), do: []

  defp candidate_move(board, color, piece_key, :home, die) do
    if die in [1, 6] and not occupied_by_own_piece?(board, color, piece_key, 0) do
      %{piece: piece_key, new_pos: 0, action: :release}
    else
      nil
    end
  end

  defp candidate_move(board, color, piece_key, pos, die) when is_integer(pos) do
    new_pos = pos + die

    cond do
      new_pos > @finish ->
        nil

      path_blocked_by_own_piece?(board, color, piece_key, pos, new_pos) ->
        nil

      path_blocked_by_enemy_piece?(board, color, pos, die) ->
        nil

      new_pos == @finish ->
        %{piece: piece_key, new_pos: new_pos, action: :finish}

      true ->
        %{piece: piece_key, new_pos: new_pos, action: :move}
    end
  end

  defp occupied_by_own_piece?(_board, _color, _piece_key, @finish), do: false

  defp occupied_by_own_piece?(board, color, {_, idx}, pos) do
    Enum.any?(0..(@pieces_per_player - 1), fn other_idx ->
      other_idx != idx and Map.get(board.pieces, {color, other_idx}) == pos
    end)
  end

  # A horse may not land on, nor hop over, another of your own horses that's
  # still travelling (only the shared finish cell allows several of your own
  # horses to stack together).
  defp path_blocked_by_own_piece?(board, color, {_, idx}, from, to) do
    Enum.any?(0..(@pieces_per_player - 1), fn other_idx ->
      if other_idx == idx do
        false
      else
        case Map.get(board.pieces, {color, other_idx}) do
          other_pos when is_integer(other_pos) ->
            (other_pos == to and to != @finish) or (other_pos > from and other_pos < to)

          _ ->
            false
        end
      end
    end)
  end

  # An enemy horse ahead of us on the shared main loop can't be hopped clean
  # over — it can only be landed on exactly (a normal capture) or left short
  # of. Doesn't apply once we've already turned off the loop onto our own
  # private home stretch (no other color's horse can be there).
  defp path_blocked_by_enemy_piece?(_board, _color, from, _die) when from > @track_length - 1,
    do: false

  defp path_blocked_by_enemy_piece?(board, color, from, die) do
    own_start = Map.fetch!(@starts, color)

    Enum.any?(board.pieces, fn
      {{other_color, _idx}, other_pos}
      when other_color != color and is_integer(other_pos) and other_pos <= @track_length - 1 ->
        other_rel =
          rem(absolute_cell(other_color, other_pos) - own_start + @track_length, @track_length)

        other_rel > from and die > other_rel - from

      _ ->
        false
    end)
  end

  @doc "Moves the given piece using the currently rolled die."
  def apply_move(%__MODULE__{status: :moving} = board, piece_key) do
    die = board.die
    move = Enum.find(legal_moves(board), &(&1.piece == piece_key))

    case move do
      nil ->
        {:error, :illegal_move}

      %{new_pos: new_pos, action: action} = move ->
        {color, _idx} = piece_key
        board = %{board | pieces: Map.put(board.pieces, piece_key, new_pos)}

        # Entering play always claims your own start square, even if an
        # opponent is camped there — unlike passing through a safe cell.
        board = capture_at(board, color, new_pos, ignore_safe?: action == :release)
        board = log_move(board, color, move)

        if all_home?(board, color) do
          {:ok, %{board | winner: color, status: :game_over}}
        else
          {:ok, resolve_end_of_turn(board, die)}
        end
    end
  end

  defp capture_at(board, _color, new_pos, _opts) when new_pos > @track_length - 1, do: board

  defp capture_at(board, color, new_pos, opts) do
    ignore_safe? = Keyword.fetch!(opts, :ignore_safe?)

    if new_pos in @safe_cells and not ignore_safe? do
      board
    else
      abs_cell = absolute_cell(color, new_pos)

      pieces =
        Enum.reduce(board.pieces, board.pieces, fn
          {{other_color, _idx} = key, pos}, acc when other_color != color and is_integer(pos) ->
            if pos <= @track_length - 1 and absolute_cell(other_color, pos) == abs_cell do
              Map.put(acc, key, :home)
            else
              acc
            end

          _, acc ->
            acc
        end)

      %{board | pieces: pieces}
    end
  end

  def absolute_cell(color, pos) when is_integer(pos) and pos <= @track_length - 1 do
    rem(Map.fetch!(@starts, color) + pos, @track_length)
  end

  defp all_home?(board, color) do
    Enum.all?(0..(@pieces_per_player - 1), fn idx ->
      Map.get(board.pieces, {color, idx}) == @finish
    end)
  end

  # `die` is intentionally left set (not nil'd) after the turn resolves, so the
  # UI can keep showing the last rolled value until the next roll overwrites it.
  # It is inert here: legal_moves/1 only reads it while status is :moving.
  defp resolve_end_of_turn(board, die) do
    extra_turn? = die == 6
    board = %{board | status: :rolling}

    if extra_turn? do
      board
    else
      advance_to_next_player(%{board | consecutive_sixes: 0})
    end
  end

  defp advance_to_next_player(board) do
    next = rem(board.current_player + 1, length(board.players))
    %{board | current_player: next, status: :rolling}
  end

  defp log_move(board, color, %{action: :release}) do
    log(board, "#{color_name(color)} đưa một quân ra khỏi chuồng.")
  end

  defp log_move(board, color, %{action: :finish}) do
    log(board, "#{color_name(color)} đưa một quân về đích!")
  end

  defp log_move(board, color, %{action: :move}) do
    log(board, "#{color_name(color)} di chuyển một quân.")
  end

  defp log(board, message) do
    %{board | log: Enum.take([message | board.log], 20)}
  end
end
