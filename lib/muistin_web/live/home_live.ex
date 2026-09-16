defmodule MuistinWeb.HomeLive do
  use MuistinWeb, :live_view
  import MuistinWeb.Layouts

  alias Muistin.Accounts
  alias Muistin.Entries

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> Phoenix.Component.assign_new(:current_scope, fn ->
        {user, _} =
          if user_token = session["user_token"] do
            Accounts.get_user_by_session_token(user_token)
          end || {nil, nil}

        Accounts.Scope.for_user(user)
      end)

    # Fetch entries if logged in
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      entries = Entries.list_entries(socket.assigns.current_scope.user.id)
      {:ok, assign(socket, :entries, entries)}
    else
      {:ok, assign(socket, :entries, [])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.app flash={@flash} current_scope={@current_scope}>
      <%= if @current_scope && @current_scope.user do %>
        <div class="max-w-5xl mx-auto">
          <h1 class="text-2xl font-bold mb-6">{gettext("Your Entries")}</h1>

          <div class="space-y-4">
            <%= for entry <- @entries do %>
              <div class="p-4 border border-gray-200 rounded-lg">
                <div class="font-medium text-gray-500">
                  {entry.entry_date}
                  <span class="text-sm ml-2">{entry.timezone}</span>
                </div>
                <div class="mt-2 whitespace-pre-wrap">
                  {entry.content}
                </div>
              </div>
            <% end %>

            <%= if length(@entries) == 0 do %>
              <p class="text-gray-500 text-center py-8">
                {gettext("No entries yet. Create your first one!")}
              </p>
            <% end %>
          </div>
        </div>
      <% else %>
        <div class="min-h-screen flex flex-col items-center justify-center">
          <h1 class="text-4xl font-bold">{gettext("Your helpful memory app")}</h1>
        </div>
      <% end %>
    </.app>
    """
  end
end
