defmodule GameHubWeb.CoCaNgua.GameLive do
  use GameHubWeb, :live_view

  alias GameHub.Games.CoCaNgua.Board
  alias GameHub.Games.CoCaNgua.Layout
  alias Phoenix.LiveView.JS

  @finish_position Board.finish_position()

  @impl true
  def mount(params, _session, socket) do
    num_players =
      params
      |> Map.get("players", "4")
      |> parse_int(4)
      |> max(2)
      |> min(4)

    names = for i <- 0..(num_players - 1), do: Map.get(params, "name#{i}", "")
    board = Board.new(num_players, names)

    {:ok,
     socket
     |> assign(page_title: "Cờ cá ngựa")
     |> assign(
       board: board,
       message: nil,
       roll_seq: 0,
       pending_move: nil,
       history: [],
       show_settings: false
     )
     |> refresh_legal_moves()}
  end

  defp parse_int(str, default) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> default
    end
  end

  @impl true
  def handle_event("roll", _params, socket) do
    case Board.roll(socket.assigns.board) do
      {:ok, board, result} ->
        {:noreply,
         socket
         |> push_history()
         |> assign(
           board: board,
           message: roll_message(result),
           roll_seq: socket.assigns.roll_seq + 1
         )
         |> refresh_legal_moves()}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("select_piece", %{"color" => color_str, "idx" => idx_str}, socket) do
    color = parse_color(color_str)
    idx = String.to_integer(idx_str)
    board = socket.assigns.board
    move = color && Enum.find(socket.assigns.legal_moves, &(&1.piece == {color, idx}))

    case move do
      nil ->
        {:noreply, socket}

      %{piece: piece_key, action: action} ->
        from = Map.fetch!(board.pieces, piece_key)
        path = build_path(color, idx, from, board.die)
        pending = %{piece: piece_key, action: action, path: path}
        {:noreply, assign(socket, pending_move: pending)}
    end
  end

  def handle_event("confirm_move", _params, socket) do
    case socket.assigns.pending_move do
      %{piece: piece_key} ->
        case Board.apply_move(socket.assigns.board, piece_key) do
          {:ok, board} ->
            {:noreply,
             socket
             |> push_history()
             |> assign(board: board, message: nil, pending_move: nil)
             |> refresh_legal_moves()}

          _ ->
            {:noreply, assign(socket, pending_move: nil)}
        end

      nil ->
        {:noreply, socket}
    end
  end

  def handle_event("cancel_move", _params, socket) do
    {:noreply, assign(socket, pending_move: nil)}
  end

  def handle_event("undo", _params, socket) do
    case socket.assigns.history do
      [prev | rest] ->
        {:noreply,
         socket
         |> assign(board: prev, history: rest, pending_move: nil, message: nil)
         |> refresh_legal_moves()}

      [] ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle_settings", _params, socket) do
    {:noreply, update(socket, :show_settings, &(not &1))}
  end

  defp push_history(socket) do
    assign(socket, history: Enum.take([socket.assigns.board | socket.assigns.history], 5))
  end

  defp build_path(color, idx, :home, _die) do
    [{1, Layout.cell_coord(color, 0, idx)}]
  end

  defp build_path(color, idx, pos, die) when is_integer(pos) do
    for step <- 1..die, do: {step, Layout.cell_coord(color, pos + step, idx)}
  end

  defp parse_color("red"), do: :red
  defp parse_color("green"), do: :green
  defp parse_color("yellow"), do: :yellow
  defp parse_color("blue"), do: :blue
  defp parse_color(_), do: nil

  defp refresh_legal_moves(socket) do
    board = socket.assigns.board
    legal = if board.status == :moving, do: Board.legal_moves(board), else: []
    assign(socket, legal_moves: legal)
  end

  defp roll_message(:ok), do: nil
  defp roll_message(:no_legal_moves), do: "Không có nước đi hợp lệ — chuyển lượt."
  defp roll_message(:triple_six_penalty), do: "Ba lần 6 liên tiếp! Mất lượt."

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="toybox-screen relative mx-auto flex max-w-[1900px] items-stretch gap-2 overflow-hidden px-2 py-2 sm:gap-4 sm:px-4"
      style="height: 100dvh;"
    >
      <div
        :if={@board.die}
        id={"dice-popup-#{@roll_seq}"}
        class="pointer-events-none fixed inset-0 z-50 flex items-center justify-center"
      >
        <img
          src={die_src(@board.die)}
          alt={"Xúc xắc #{@board.die}"}
          class="h-40 w-40 animate-dice-center-pop drop-shadow-2xl sm:h-56 sm:w-56"
        />
      </div>

      <div class="relative flex w-32 shrink-0 flex-col gap-2 py-2 sm:w-40 sm:gap-3 lg:w-48">
        <div class="flex items-center justify-between">
          <button
            type="button"
            phx-click="toggle_settings"
            class="toy-icon-btn !h-10 !w-10 sm:!h-12 sm:!w-12"
            aria-label="Cài đặt"
          >
            <.toy_icon name="settings" class="h-5 w-5 sm:h-6 sm:w-6" />
          </button>
          <.toy_icon name="horse" class="h-6 w-6 sm:h-7 sm:w-7" />
        </div>

        <div
          :if={@show_settings}
          class="absolute left-0 top-14 z-40 w-56 rounded-2xl border-2 p-2 shadow-xl sm:top-16 bg-white border-cream-deep"
        >
          <.link
            navigate={~p"/games/co-ca-ngua"}
            class="flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm font-bold text-ink hover:bg-cream"
          >
            <.toy_icon name="restart" class="h-5 w-5" /> Chơi lại ván mới
          </.link>
          <.link
            navigate={~p"/"}
            class="flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm font-bold text-ink hover:bg-cream"
          >
            <.toy_icon name="home" class="h-5 w-5" /> Về trang chủ
          </.link>
        </div>

        <div class="flex flex-1 flex-col justify-center gap-2 sm:gap-3">
          <.player_panel
            :for={{player, i} <- left_players(@board)}
            player={player}
            active={i == @board.current_player}
            finished={finished_count(@board, player.color)}
          />
        </div>
      </div>

      <div class="flex min-w-0 flex-1 items-center justify-center">
        <div class="relative aspect-square h-full max-h-full max-w-full shrink-0">
          <div
            class="relative h-full w-full overflow-hidden rounded-[28px] border-[6px] bg-white shadow-2xl"
            style="border-color: white; box-shadow: 0 12px 0 rgba(0,0,0,0.08), 0 20px 40px rgba(74,59,50,0.18);"
          >
            <div style="display: grid; grid-template-columns: repeat(15, minmax(0, 1fr)); grid-template-rows: repeat(15, minmax(0, 1fr)); width: 100%; height: 100%;">
              <div
                :for={color <- Layout.colors()}
                style={yard_style(color, current_player_color(@board))}
                class={[
                  "relative m-1.5 flex items-start justify-center rounded-3xl pt-1 transition-all",
                  yard_bg(color),
                  color == current_player_color(@board) && "animate-current-yard"
                ]}
              >
                <span
                  :if={!@board.winner && color == current_player_color(@board)}
                  class="rounded-full bg-white px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide shadow sm:text-xs"
                  style={"color: #{yard_ink(color)};"}
                >
                  ▶ Đang chơi
                </span>
              </div>

              <!-- Center hub is a plus-shape (5 cells), not a solid 3x3 — the 4
                   diagonal corners belong to the main track (they bridge each
                   arm's horizontal segment to its vertical one) and are
                   rendered below as track cells, not covered by the hub. -->
              <div
                style="grid-row: 7 / span 3; grid-column: 8 / span 1; background: var(--cream);"
                class="m-0.5 rounded-2xl"
              >
              </div>
              <div
                style="grid-row: 8; grid-column: 7 / span 3; background: var(--cream);"
                class="m-0.5 rounded-2xl"
              >
              </div>
              <div style="grid-row: 8; grid-column: 8;" class="z-10 flex items-center justify-center">
                <img
                  src={trophy_src()}
                  alt=""
                  class="h-full w-full scale-150 object-contain opacity-70"
                />
              </div>

              <div
                :for={idx <- 0..(Board.track_length() - 1)}
                style={style_at(Layout.main_track_coord(idx))}
                class="flex items-center justify-center border border-zinc-200"
              >
                <span class={["rounded-full", track_circle_class(idx)]}></span>
              </div>

              <div
                :for={{color, i} <- home_stretch_cells()}
                style={style_at(Layout.home_stretch_bg_coord(color, i))}
                class={["flex items-center justify-center border border-black/10", color_bg(color)]}
              >
                <span class="text-xs font-bold text-white drop-shadow sm:text-sm">{i + 1}</span>
              </div>

              <button
                :for={p <- piece_views(@board)}
                type="button"
                phx-click="select_piece"
                phx-value-color={p.color}
                phx-value-idx={p.idx}
                disabled={not selectable?(@legal_moves, @pending_move, p.color, p.idx)}
                style={piece_style(p)}
                class={[
                  "z-10 flex items-center justify-center rounded-full p-0.5 shadow transition",
                  piece_size(p.pos),
                  piece_backing(p.color),
                  selectable?(@legal_moves, @pending_move, p.color, p.idx) &&
                    "z-30 cursor-pointer animate-movable",
                  not selectable?(@legal_moves, @pending_move, p.color, p.idx) && "cursor-default"
                ]}
              >
                <img
                  src={horse_src(p.color)}
                  alt={Board.color_name(p.color)}
                  class="h-full w-full object-contain drop-shadow"
                />
              </button>

              <div
                :for={{step, coord} <- path_steps(@pending_move)}
                style={style_at(coord)}
                class="z-20 flex items-center justify-center"
              >
                <span class="flex h-3/5 w-3/5 animate-piece-pop items-center justify-center rounded-full text-[10px] font-bold text-white shadow-lg ring-2 ring-white sm:text-xs bg-toy-blue-dark">
                  {step}
                </span>
              </div>
            </div>
          </div>

          <div
            :if={@board.winner}
            class="absolute inset-0 z-20 flex flex-col items-center justify-center gap-3 overflow-hidden rounded-[28px]"
            style="background: rgba(255,248,238,0.96);"
          >
            <div :for={c <- confetti_particles()} class="confetti-piece" style={confetti_style(c)}>
            </div>
            <img
              src={trophy_src()}
              alt=""
              class="h-24 w-24 animate-trophy-pop object-contain drop-shadow-xl sm:h-32 sm:w-32"
            />
            <p
              class="flex items-center justify-center gap-2 text-2xl font-bold sm:text-3xl"
              style={"color: #{yard_ink(@board.winner)};"}
            >
              <.toy_icon name="party" class="h-8 w-8" /> {Board.color_name(@board.winner)} thắng rồi!
            </p>
            <.link navigate={~p"/games/co-ca-ngua"} class="toy-btn toy-btn--red">
              Chơi lại
            </.link>
          </div>
        </div>
      </div>

      <div class="flex w-32 shrink-0 flex-col gap-2 py-2 sm:w-40 sm:gap-3 lg:w-48">
        <div class="flex items-center justify-end gap-2">
          <.fullscreen_button class="!h-10 !w-10 sm:!h-12 sm:!w-12" />
          <.link
            navigate={~p"/games/co-ca-ngua"}
            class="toy-icon-btn !h-10 !w-10 sm:!h-12 sm:!w-12"
            aria-label="Thoát"
          >
            <.toy_icon name="exit" class="h-5 w-5 sm:h-6 sm:w-6" />
          </.link>
        </div>

        <div class="flex flex-1 flex-col justify-center gap-2 sm:gap-3">
          <.player_panel
            :for={{player, i} <- right_players(@board)}
            player={player}
            active={i == @board.current_player}
            finished={finished_count(@board, player.color)}
          />
        </div>

        <div class="flex flex-col items-stretch gap-1.5">
          <div
            :if={@pending_move}
            class="rounded-2xl border-2 p-2 text-center bg-white border-toy-blue"
          >
            <p class="text-xs font-bold text-ink">
              Di chuyển {move_description(@pending_move)}?
            </p>
            <p class="mt-0.5 text-[10px] text-ink-soft">
              Đi {length(@pending_move.path)} bước.
            </p>
            <div class="mt-1.5 flex flex-col gap-1.5">
              <button
                type="button"
                phx-click="confirm_move"
                class="toy-btn toy-btn--blue w-full !min-h-0 !py-1.5 !text-sm"
              >
                Xác nhận
              </button>
              <button
                type="button"
                phx-click="cancel_move"
                class="toy-btn toy-btn--neutral w-full !min-h-0 !py-1.5 !text-sm"
              >
                Hủy
              </button>
            </div>
          </div>

          <div :if={!@pending_move} class="flex flex-col items-stretch gap-1.5">
            <button
              :if={!@board.winner && @board.status == :rolling}
              type="button"
              phx-click={
                JS.push("roll")
                |> JS.transition({"ease-out duration-150", "scale-100", "scale-90"}, time: 150)
              }
              class="toy-btn toy-btn--red w-full !min-h-[52px] !text-sm sm:!min-h-[60px] sm:!text-lg"
            >
              <.toy_icon name="dice" class="h-6 w-6" /> Đổ xúc xắc
            </button>

            <div
              :if={@board.status == :moving}
              id={"die-#{@roll_seq}"}
              class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl border-2 p-1 animate-dice-pop sm:h-14 sm:w-14 sm:p-1.5 bg-white border-toy-blue"
            >
              <img
                src={die_src(@board.die)}
                alt={"Xúc xắc #{@board.die}"}
                class="h-full w-full object-contain"
              />
            </div>

            <button
              type="button"
              phx-click="undo"
              disabled={@history == []}
              class="toy-btn toy-btn--neutral w-full !min-h-[40px] !text-xs sm:!min-h-[44px] sm:!text-sm"
            >
              <.toy_icon name="undo" class="h-5 w-5" /> Hoàn tác
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="rotate-prompt fixed inset-0 z-[100] flex-col items-center justify-center gap-4 text-center bg-cream">
      <.toy_icon name="phone" class="animate-phone-rotate h-24 w-24" />
      <p class="text-xl font-bold text-ink">Xoay ngang thiết bị để chơi nhé!</p>
      <p class="text-sm text-ink-soft">
        Cờ Cá Ngựa chơi đẹp nhất ở chế độ ngang
      </p>
    </div>
    """
  end

  # `left` is always a prefix of `board.players`, so its local index already
  # matches the player's global (turn-order) index.
  defp left_players(board) do
    {left, _right} = split_players(board.players)
    Enum.with_index(left)
  end

  defp right_players(board) do
    {left, right} = split_players(board.players)
    offset = length(left)
    right |> Enum.with_index() |> Enum.map(fn {p, i} -> {p, i + offset} end)
  end

  defp split_players(players) do
    left_count = if length(players) <= 2, do: 1, else: 2
    Enum.split(players, left_count)
  end

  defp player_panel(assigns) do
    ~H"""
    <div
      class={[
        "player-panel flex items-center gap-2 rounded-2xl border-2 bg-white p-2 shadow-md sm:gap-3 sm:p-3",
        if(@active, do: "player-panel--active", else: "player-panel--inactive")
      ]}
      style={"border-color: #{panel_border(@player.color)};"}
    >
      <div class={[
        "relative flex h-10 w-10 shrink-0 items-center justify-center rounded-full sm:h-14 sm:w-14",
        piece_backing(@player.color)
      ]}>
        <img
          src={horse_src(@player.color)}
          alt=""
          class={["h-8 w-8 object-contain sm:h-11 sm:w-11", @active && "animate-avatar-bounce"]}
        />
      </div>
      <div class="min-w-0 flex-1">
        <p class="break-words text-xs font-bold leading-tight sm:text-sm text-ink">
          {@player.name}
        </p>
        <p class="flex items-center gap-1 text-[10px] text-ink-soft sm:text-xs">
          {@finished}/4 <.toy_icon name="trophy" class="h-3.5 w-3.5" />
        </p>
      </div>
    </div>
    """
  end

  defp piece_views(board) do
    for player <- board.players, idx <- 0..(Board.pieces_per_player() - 1) do
      color = player.color
      pos = Map.fetch!(board.pieces, {color, idx})
      %{color: color, idx: idx, pos: pos, coord: Layout.cell_coord(color, pos, idx)}
    end
  end

  defp selectable?(legal_moves, pending_move, color, idx) do
    is_nil(pending_move) and Enum.any?(legal_moves, &(&1.piece == {color, idx}))
  end

  defp path_steps(nil), do: []
  defp path_steps(%{path: path}), do: path

  defp move_description(%{piece: {color, idx}, action: :release}) do
    "quân #{Board.color_name(color)} ##{idx + 1} ra khỏi chuồng"
  end

  defp move_description(%{piece: {color, idx}, action: :finish}) do
    "quân #{Board.color_name(color)} ##{idx + 1} về đích"
  end

  defp move_description(%{piece: {color, idx}, action: :move}) do
    "quân #{Board.color_name(color)} ##{idx + 1}"
  end

  defp finished_count(board, color) do
    Enum.count(0..(Board.pieces_per_player() - 1), fn idx ->
      Map.get(board.pieces, {color, idx}) == Board.finish_position()
    end)
  end

  defp home_stretch_cells do
    for color <- Layout.colors(), i <- 0..5, do: {color, i}
  end

  defp style_at({row, col}), do: "grid-row: #{row}; grid-column: #{col};"

  # Finished horses share one cell per color, so fan them out into a tiny 2x2
  # cluster with a translate offset instead of stacking exactly on top of each other.
  defp piece_style(%{pos: @finish_position, coord: {row, col}, idx: idx}) do
    {dx, dy} = finish_offset(idx)
    "grid-row: #{row}; grid-column: #{col}; transform: translate(#{dx}%, #{dy}%);"
  end

  defp piece_style(%{coord: {row, col}}) do
    "grid-row: #{row}; grid-column: #{col};"
  end

  defp finish_offset(0), do: {-45, -45}
  defp finish_offset(1), do: {45, -45}
  defp finish_offset(2), do: {-45, 45}
  defp finish_offset(3), do: {45, 45}

  defp piece_size(@finish_position), do: "m-0 h-[45%] w-[45%]"
  defp piece_size(:home), do: "m-0 scale-150"
  defp piece_size(_pos), do: "m-0.5"

  defp yard_style(color, current_color) do
    {row, col} = Layout.yard_bounds(color)
    base = "grid-row: #{row} / span 6; grid-column: #{col} / span 6;"

    if color == current_color,
      do: base <> " --yard-glow-color: #{yard_glow_color(color)};",
      else: base
  end

  defp current_player_color(board), do: Board.current_player(board).color

  defp yard_glow_color(:red), do: "rgba(255, 90, 95, 0.7)"
  defp yard_glow_color(:green), do: "rgba(61, 220, 132, 0.7)"
  defp yard_glow_color(:yellow), do: "rgba(255, 201, 60, 0.8)"
  defp yard_glow_color(:blue), do: "rgba(77, 163, 255, 0.7)"

  defp yard_ink(:red), do: "var(--toy-red-dark)"
  defp yard_ink(:green), do: "var(--toy-green-dark)"
  defp yard_ink(:yellow), do: "var(--toy-yellow-dark)"
  defp yard_ink(:blue), do: "var(--toy-blue-dark)"

  defp panel_border(:red), do: "var(--toy-red)"
  defp panel_border(:green), do: "var(--toy-green)"
  defp panel_border(:yellow), do: "var(--toy-yellow)"
  defp panel_border(:blue), do: "var(--toy-blue)"

  defp track_circle_class(idx) do
    case safe_cell_owner(idx) do
      nil ->
        ["h-3/5 w-3/5 bg-white ring-2 ring-inset", arm_ring_color(arm_color(idx))]

      color ->
        ["h-4/5 w-4/5 ring-2 ring-inset shadow-inner", safe_circle_color(color)]
    end
  end

  defp safe_cell_owner(idx), do: Enum.find(Layout.colors(), &(Board.start_cell(&1) == idx))

  # Each arm of the loop is tinted with the color whose start it begins at.
  defp arm_color(idx), do: Enum.at(Layout.colors(), div(idx, div(Board.track_length(), 4)))

  defp arm_ring_color(:red), do: "ring-red-300"
  defp arm_ring_color(:green), do: "ring-emerald-300"
  defp arm_ring_color(:yellow), do: "ring-yellow-300"
  defp arm_ring_color(:blue), do: "ring-blue-300"

  defp safe_circle_color(:red), do: "bg-red-300 ring-red-500"
  defp safe_circle_color(:green), do: "bg-emerald-300 ring-emerald-500"
  defp safe_circle_color(:yellow), do: "bg-yellow-300 ring-yellow-500"
  defp safe_circle_color(:blue), do: "bg-blue-300 ring-blue-500"

  defp horse_src(color), do: "/images/assets/horse_#{color}.webp"
  defp die_src(value), do: "/images/assets/die_#{value}.webp"
  defp trophy_src, do: "/images/assets/trophy_gold.webp"

  defp piece_backing(:red), do: "bg-red-100 ring-2 ring-red-400"
  defp piece_backing(:green), do: "bg-emerald-100 ring-2 ring-emerald-400"
  defp piece_backing(:yellow), do: "bg-yellow-100 ring-2 ring-yellow-400"
  defp piece_backing(:blue), do: "bg-blue-100 ring-2 ring-blue-400"

  defp color_bg(:red), do: "bg-red-500"
  defp color_bg(:green), do: "bg-emerald-500"
  defp color_bg(:yellow), do: "bg-yellow-400"
  defp color_bg(:blue), do: "bg-blue-500"

  defp yard_bg(:red), do: "bg-red-200/60"
  defp yard_bg(:green), do: "bg-emerald-200/60"
  defp yard_bg(:yellow), do: "bg-yellow-200/60"
  defp yard_bg(:blue), do: "bg-blue-200/60"

  defp confetti_particles do
    colors = ["var(--toy-red)", "var(--toy-blue)", "var(--toy-yellow)", "var(--toy-green)"]

    for i <- 0..29 do
      %{
        left: rem(i * 37, 100),
        color: Enum.at(colors, rem(i, 4)),
        delay: rem(i * 53, 900) / 1000,
        drift: rem(i * 29, 160) - 80
      }
    end
  end

  defp confetti_style(c) do
    "left: #{c.left}%; background: #{c.color}; animation-delay: #{c.delay}s; --drift: #{c.drift}px;"
  end
end
