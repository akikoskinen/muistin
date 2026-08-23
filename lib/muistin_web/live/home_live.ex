defmodule MuistinWeb.HomeLive do
  use MuistinWeb, :live_view
  import MuistinWeb.Layouts

  def render(assigns) do
    ~H"""
    <.app flash={@flash}>
      <div class="min-h-screen flex flex-col items-center justify-center">
        <h1 class="text-4xl font-bold">{gettext("Your helpful memory app")}</h1>
      </div>
    </.app>
    """
  end
end
