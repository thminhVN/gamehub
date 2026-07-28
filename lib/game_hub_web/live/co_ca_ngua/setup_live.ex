defmodule GameHubWeb.CoCaNgua.SetupLive do
  use GameHubWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Cờ cá ngựa — Chọn số người chơi",
       num_players: 4,
       names: default_names(4)
     )}
  end

  @impl true
  def handle_event("set_num_players", %{"num_players" => n}, socket) do
    n = String.to_integer(n)
    {:noreply, assign(socket, num_players: n, names: default_names(n, socket.assigns.names))}
  end

  def handle_event("update_name", %{"index" => index, "value" => value}, socket) do
    index = String.to_integer(index)
    names = List.replace_at(socket.assigns.names, index, value)
    {:noreply, assign(socket, names: names)}
  end

  def handle_event("start_game", _params, socket) do
    names = Enum.take(socket.assigns.names, socket.assigns.num_players)

    name_params =
      names
      |> Enum.with_index()
      |> Map.new(fn {name, i} -> {"name#{i}", name} end)

    query = Map.put(name_params, "players", socket.assigns.num_players)
    {:noreply, push_navigate(socket, to: ~p"/games/co-ca-ngua/play?#{query}")}
  end

  defp default_names(n, existing \\ []) do
    for i <- 0..(n - 1), do: Enum.at(existing, i) || ""
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto flex h-[100dvh] max-w-xl flex-col justify-center gap-6 overflow-y-auto px-4 py-8 short:max-w-4xl short:justify-between short:gap-2 short:overflow-hidden short:py-2">
      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0">
          <.link
            navigate={~p"/"}
            class="text-sm font-semibold hover:underline text-ink-soft"
          >
            &larr; Bé vui học
          </.link>

          <h1 class="mt-1 flex items-center gap-2 text-4xl font-bold tracking-tight text-ink short:mt-0 short:gap-1.5 short:text-2xl">
            <.toy_icon name="horse" class="h-10 w-10 short:h-7 short:w-7" /> Cờ cá ngựa
          </h1>
          <p class="mt-1 text-sm text-ink-soft short:hidden">
            Chơi trên 1 thiết bị, lần lượt từng người. Mỗi người 4 con ngựa.
          </p>
        </div>
        <.fullscreen_button id="setup-fullscreen" />
      </div>

      <div class="flex flex-col gap-4 short:grid short:min-h-0 short:flex-1 short:grid-cols-2 short:items-center short:gap-3 short:overflow-y-auto">
        <div class="toy-card p-5 short:p-3">
          <h2 class="text-sm font-bold text-ink">Số người chơi</h2>
          <div class="mt-2 flex gap-2 short:mt-1.5">
            <button
              :for={n <- 2..4}
              type="button"
              phx-click="set_num_players"
              phx-value-num_players={n}
              class={[
                "toy-btn flex-1 !text-xl short:!min-h-[40px] short:!py-1.5 short:!text-lg",
                if(n == @num_players, do: "toy-btn--red", else: "toy-btn--neutral")
              ]}
            >
              {n}
            </button>
          </div>
        </div>

        <div class="toy-card p-5 short:p-3">
          <h2 class="text-sm font-bold text-ink">Tên người chơi (tùy chọn)</h2>
          <div class="mt-2 space-y-2 short:mt-1.5 short:space-y-1">
            <div
              :for={{color, i} <- Enum.with_index(colors_for(@num_players))}
              class="flex items-center gap-2"
            >
              <span class={[
                "h-5 w-5 shrink-0 rounded-full shadow short:h-4 short:w-4",
                color_bg(color)
              ]}></span>
              <input
                type="text"
                value={Enum.at(@names, i)}
                phx-blur="update_name"
                phx-value-index={i}
                placeholder={"Người chơi #{i + 1} (#{color_label(color)})"}
                class="toy-input w-full short:!py-1 short:!text-xs"
              />
            </div>
          </div>
        </div>
      </div>

      <button
        type="button"
        phx-click="start_game"
        class="toy-btn toy-btn--red w-full !text-xl short:!min-h-[42px] short:!py-1.5 short:!text-base"
      >
        Bắt đầu chơi <.toy_icon name="party" class="h-7 w-7 short:h-5 short:w-5" />
      </button>
    </div>
    """
  end

  defp colors_for(2), do: [:red, :yellow]
  defp colors_for(3), do: [:red, :green, :yellow]
  defp colors_for(4), do: [:red, :green, :yellow, :blue]

  defp color_label(:red), do: "Đỏ"
  defp color_label(:green), do: "Xanh lá"
  defp color_label(:yellow), do: "Vàng"
  defp color_label(:blue), do: "Xanh dương"

  defp color_bg(:red), do: "bg-toy-red"
  defp color_bg(:green), do: "bg-toy-green"
  defp color_bg(:yellow), do: "bg-toy-yellow"
  defp color_bg(:blue), do: "bg-toy-blue"
end
