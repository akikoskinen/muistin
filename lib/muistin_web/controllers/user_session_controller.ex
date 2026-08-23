defmodule MuistinWeb.UserSessionController do
  use MuistinWeb, :controller

  alias Muistin.Accounts
  alias MuistinWeb.UserAuth

  def create(conn, %{"_action" => "password"} = params) do
    create(conn, params)
  end

  def create(conn, params) do
    create(conn, params, gettext("Welcome back!"))
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"username" => username, "password" => password} = user_params

    if user = Accounts.get_user_by_username_and_password(username, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the username is registered.
      conn
      |> put_flash(:error, gettext("Invalid username or password"))
      |> put_flash(:username, String.slice(username, 0, 50))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  def update_password(conn, %{"user" => user_params}) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {updated_user, _expired_tokens}} = Accounts.update_user_password(user, user_params)

    # disconnect all existing LiveViews with old sessions
    # UserAuth.disconnect_sessions(expired_tokens)
    # Note: We don't disconnect because we're about to create a new session

    conn
    |> put_flash(:info, gettext("Password updated successfully!"))
    |> UserAuth.log_in_user(updated_user, user_params)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext("Logged out successfully."))
    |> UserAuth.log_out_user()
  end
end
