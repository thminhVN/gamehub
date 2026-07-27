defmodule GameHubWeb.HomeLiveTest do
  use GameHubWeb.ConnCase

  import Phoenix.LiveViewTest

  test "landing page sells the one-device pitch and links to the playable game", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")

    assert html =~ "chơi cờ chung 1 máy"
    assert html =~ "Cờ cá ngựa"
    assert html =~ ~s|href="/games/co-ca-ngua"|
  end

  test "landing page lists the upcoming board games as coming soon", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/")

    for name <- ["Cờ vua", "Cờ tướng", "Cờ vây"] do
      assert live |> element("h3", name) |> render() =~ name
    end

    assert live |> render() |> String.split("Sắp ra mắt") |> length() == 4
  end
end
