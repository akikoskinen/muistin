defmodule MuistinWeb.UserLive.Login do
  use MuistinWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>{gettext("Log in")}</p>
            <:subtitle>
              <%= if @current_scope do %>
                {gettext("You need to reauthenticate to perform sensitive actions on your account.")}
              <% else %>
                {gettext("Don't have an account?")} <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                ><%= gettext("Sign up") %></.link> {gettext("for an account now.")}
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <.form
          :let={f}
          for={@form}
          id="login_form"
          action={~p"/users/log-in"}
          phx-submit="submit"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            readonly={!!@current_scope}
            field={f[:username]}
            type="text"
            label={gettext("Username")}
            autocomplete="username"
            spellcheck="false"
            required
            phx-mounted={JS.focus()}
          />
          <.input
            field={f[:password]}
            type="password"
            label={gettext("Password")}
            autocomplete="current-password"
            spellcheck="false"
            required
          />
          <.button class="btn btn-primary w-full" name={f[:remember_me].name} value="true">
            {gettext("Log in and stay logged in")} <span aria-hidden="true">→</span>
          </.button>
          <.button class="btn btn-primary btn-soft w-full mt-2">
            {gettext("Log in only this time")}
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    username =
      Phoenix.Flash.get(socket.assigns.flash, :username) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:username)])

    form = to_form(%{"username" => username, "password" => ""}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
