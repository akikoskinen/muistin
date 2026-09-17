defmodule MuistinWeb.HomeLive do
  use MuistinWeb, :live_view
  import MuistinWeb.Layouts

  alias Muistin.Accounts
  alias Muistin.Entries

  defp set_entries(socket, entries) do
    assign(socket, entries: entries)
  end

  defp set_selected_entry(socket, entry) do
    socket
    |> assign(selected_entry: entry, draft_content: entry.content)
    |> assign(new_entry_date: nil, new_entry_timezone: nil)
  end

  defp clear_modal(socket) do
    assign(socket,
      selected_entry: nil,
      draft_content: "",
      new_entry_date: nil,
      new_entry_timezone: nil
    )
  end

  defp set_new_entry_date(socket, date, timezone) do
    assign(socket, new_entry_date: date, new_entry_timezone: timezone)
  end

  defp open_new_entry_modal(socket) do
    assign(socket,
      selected_entry: nil,
      draft_content: "",
      new_entry_date: "--",
      new_entry_timezone: "--"
    )
  end

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
      {:ok, socket |> set_entries(entries) |> clear_modal()}
    else
      {:ok, socket |> set_entries([]) |> clear_modal()}
    end
  end

  @impl true
  def handle_event("new_entry", _params, socket) do
    {:noreply, open_new_entry_modal(socket)}
  end

  @impl true
  def handle_event("new_entry_date", %{"date" => date, "timezone" => timezone}, socket) do
    target_date = Date.from_iso8601!(date)

    if existing = Enum.find(socket.assigns.entries, &(&1.entry_date == target_date)) do
      {:noreply, set_selected_entry(socket, existing)}
    else
      {:noreply, set_new_entry_date(socket, date, timezone)}
    end
  end

  @impl true
  def handle_event("select_entry", %{"id" => id}, socket) do
    entries = socket.assigns.entries
    selected = Enum.find(entries, fn e -> e.id == String.to_integer(id) end)

    if selected do
      {:noreply, set_selected_entry(socket, selected)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update_draft", %{"content" => content}, socket) do
    {:noreply, assign(socket, draft_content: content)}
  end

  @impl true
  def handle_event("save_entry", _params, socket) do
    user = socket.assigns.current_scope.user

    if socket.assigns.selected_entry do
      entry = socket.assigns.selected_entry

      changeset =
        Entries.Entry.changeset(entry, %{
          content: socket.assigns.draft_content
        })

      case Muistin.Repo.update(changeset) do
        {:ok, _} ->
          entries = Entries.list_entries(user.id)
          {:noreply, socket |> set_entries(entries) |> clear_modal()}

        {:error, _} ->
          {:noreply, socket}
      end
    else
      attrs = %{
        content: socket.assigns.draft_content,
        entry_date: socket.assigns.new_entry_date,
        timezone: socket.assigns.new_entry_timezone
      }

      case Entries.create_entry(attrs, user) do
        {:ok, _} ->
          entries = Entries.list_entries(user.id)
          {:noreply, socket |> set_entries(entries) |> clear_modal()}

        {:error, _} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, clear_modal(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.app flash={@flash} current_scope={@current_scope}>
      <%= if @current_scope && @current_scope.user do %>
        <div class="max-w-5xl mx-auto">
          <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">{gettext("Your Entries")}</h1>

            <button
              phx-click="new_entry"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              {gettext("New Entry")}
            </button>
          </div>

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

        <%= if @selected_entry || @new_entry_date do %>
          <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 overflow-y-auto">
            <div
              class="bg-white rounded-lg shadow-xl w-full max-w-5xl max-h-[calc(100vh-2rem)] overflow-y-auto p-6 relative"
              id="entry-modal"
              phx-hook=".NewEntryHook"
            >
              <button
                class="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
                phx-click="close_modal"
                aria-label="Close"
              >
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>

              <h2 class="text-xl font-bold mb-4">
                <%= if @selected_entry do %>
                  {gettext("Edit Entry")}
                <% else %>
                  {gettext("New Entry")}
                <% end %>
              </h2>

              <form class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Date")}</label>
                  <div class="text-lg">
                    <%= if @selected_entry do %>
                      {@selected_entry.entry_date}
                    <% else %>
                      {@new_entry_date}
                    <% end %>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Timezone")}</label>
                  <div class="text-lg">
                    <%= if @selected_entry do %>
                      {@selected_entry.timezone}
                    <% else %>
                      {@new_entry_timezone}
                    <% end %>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-500 mb-1">{gettext("Content")}</label>
                  <textarea
                    class="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    phx-change="update_draft"
                    phx-debounce="500"
                    name="content"
                    rows="10"
                  >{@draft_content}</textarea>
                </div>

                <div class="flex justify-end gap-2">
                  <button
                    type="button"
                    phx-click="close_modal"
                    class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
                  >
                    {gettext("Cancel")}
                  </button>
                  <button
                    type="button"
                    phx-click="save_entry"
                    class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    {gettext("Save")}
                  </button>
                </div>
              </form>
            </div>
          </div>
        <% end %>
      <% else %>
        <div class="min-h-screen flex flex-col items-center justify-center">
          <h1 class="text-4xl font-bold">{gettext("Your helpful memory app")}</h1>
        </div>
      <% end %>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".NewEntryHook">
        export default {
          mounted() {
            const now = new Date();
            const date = now.toISOString().split('T')[0];
            const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
            this.pushEvent("new_entry_date", {date: date, timezone: timezone});
          }
        }
      </script>
    </.app>
    """
  end
end
