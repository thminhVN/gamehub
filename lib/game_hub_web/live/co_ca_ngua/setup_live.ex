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
    <div class="mx-auto max-w-xl px-4 py-16">
      <.link navigate={~p"/"} class="text-sm font-semibold hover:underline" style="color: var(--toy-ink-soft);">
        &larr; GameHub
      </.link>

      <h1 class="mt-2 text-4xl font-bold tracking-tight" style="color: var(--toy-ink);">🐴 Cờ cá ngựa</h1>
      <p class="mt-1 text-sm" style="color: var(--toy-ink-soft);">
        Chơi trên 1 thiết bị, lần lượt từng người. Mỗi người 4 con ngựa.
      </p>

      <div class="mt-8 rounded-[28px] border-2 bg-white p-5 shadow-md" style="border-color: var(--cream-deep);">
        <h2 class="text-sm font-bold" style="color: var(--toy-ink);">Số người chơi</h2>
        <div class="mt-2 flex gap-2">
          <button
            :for={n <- 2..4}
            type="button"
            phx-click="set_num_players"
            phx-value-num_players={n}
            class={[
              "toy-btn flex-1 !text-xl",
              if(n == @num_players, do: "toy-btn--red", else: "toy-btn--neutral")
            ]}
          >
            {n}
          </button>
        </div>
      </div>

      <div class="mt-4 rounded-[28px] border-2 bg-white p-5 shadow-md" style="border-color: var(--cream-deep);">
        <h2 class="text-sm font-bold" style="color: var(--toy-ink);">Tên người chơi (tùy chọn)</h2>
        <div class="mt-2 space-y-2">
          <div :for={{color, i} <- Enum.with_index(colors_for(@num_players))} class="flex items-center gap-2">
            <span class={["h-5 w-5 shrink-0 rounded-full shadow", color_bg(color)]}></span>
            <input
              type="text"
              value={Enum.at(@names, i)}
              phx-blur="update_name"
              phx-value-index={i}
              placeholder={"Người chơi #{i + 1} (#{color_label(color)})"}
              class="w-full rounded-xl border-2 px-3 py-2.5 text-sm focus:outline-none"
              style="border-color: var(--cream-deep); color: var(--toy-ink);"
            />
          </div>
        </div>
      </div>

      <button type="button" phx-click="start_game" class="toy-btn toy-btn--red mt-6 w-full !text-xl">
        Bắt đầu chơi 🎉
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

  defp color_bg(:red), do: "bg-red-500"
  defp color_bg(:green), do: "bg-emerald-500"
  defp color_bg(:yellow), do: "bg-yellow-400"
  defp color_bg(:blue), do: "bg-blue-500"
end
