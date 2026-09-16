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
      {:ok, assign(socket, entries: entries, selected_entry: nil)}
    else
      {:ok, assign(socket, entries: [], selected_entry: nil)}
    end
  end

  @impl true
  def handle_event("select_entry", %{"id" => id}, socket) do
    entries = socket.assigns.entries
    selected = Enum.find(entries, fn e -> e.id == String.to_integer(id) end)

    if selected do
      {:noreply, assign(socket, selected_entry: selected)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected_entry: nil)}
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
              <div
                class="p-4 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50"
                phx-click="select_entry"
                phx-value-id={entry.id}
              >
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

        <%= if @selected_entry do %>
          <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 overflow-y-auto">
            <div class="bg-white rounded-lg shadow-xl w-full max-w-5xl max-h-[calc(100vh-2rem)] overflow-y-auto p-6 relative">
              <button
                class="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
                phx-click="close_modal"
                aria-label="Close"
              >
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>

              <h2 class="text-xl font-bold mb-4">{gettext("Entry")}</h2>

              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Date")}</label>
                  <div class="text-lg">{@selected_entry.entry_date}</div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Timezone")}</label>
                  <div class="text-lg">{@selected_entry.timezone}</div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Content")}</label>
                  <div class="whitespace-pre-wrap text-gray-800">{@selected_entry.content}</div>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      <% else %>
        <div class="min-h-screen flex flex-col items-center justify-center">
          <h1 class="text-4xl font-bold">{gettext("Your helpful memory app")}</h1>
        </div>
      <% end %>
    </.app>
    """
  end
end
