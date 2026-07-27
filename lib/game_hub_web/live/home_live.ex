defmodule GameHubWeb.HomeLive do
  use GameHubWeb, :live_view

  @games [
    %{
      slug: "co-ca-ngua",
      name: "Cờ cá ngựa",
      description: "Ludo Việt Nam — 2 đến 4 người chơi, 4 con ngựa mỗi người, chơi trên 1 thiết bị.",
      emoji: "🐴",
      path: "/games/co-ca-ngua"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "GameHub", games: @games)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl px-4 py-16">
      <h1 class="text-4xl font-bold tracking-tight" style="color: var(--toy-ink);">🎲 GameHub</h1>
      <p class="mt-2 text-base" style="color: var(--toy-ink-soft);">Các trò chơi cờ bàn chơi trên 1 thiết bị.</p>

      <div class="mt-8 grid gap-4 sm:grid-cols-2">
        <.link
          :for={game <- @games}
          navigate={game.path}
          class="group flex flex-col gap-2 rounded-[28px] border-2 bg-white p-5 shadow-md transition hover:-translate-y-1 hover:shadow-xl"
          style="border-color: var(--cream-deep);"
        >
          <span class="text-5xl">{game.emoji}</span>
          <span class="text-lg font-bold" style="color: var(--toy-ink);">{game.name}</span>
          <span class="text-sm" style="color: var(--toy-ink-soft);">{game.description}</span>
        </.link>
      </div>
    </div>
    """
  end
end
