defmodule MuistinWeb.HomeLiveTest do
  use MuistinWeb.ConnCase
  import Phoenix.LiveViewTest

  test "displays Muistin heading", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view) =~ "Muistin"
  end
end
