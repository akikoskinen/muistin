defmodule MuistinWeb.PageController do
  use MuistinWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
