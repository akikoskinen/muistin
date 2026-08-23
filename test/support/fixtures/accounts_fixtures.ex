defmodule Muistin.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Muistin.Accounts` context.
  """

  import Ecto.Query

  alias Muistin.Accounts
  alias Muistin.Accounts.Scope

  def unique_username do
    "user" <> to_string(System.unique_integer([:positive]))
  end

  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs) do
    attrs = attrs || []
    username = attrs[:username] || unique_username()
    password = attrs[:password] || valid_user_password()

    %{
      username: username,
      password: password,
      password_confirmation: attrs[:password_confirmation] || password
    }
  end

  def user_fixture(attrs \\ %{}) do
    attrs_list = if attrs == %{}, do: [], else: Enum.into(attrs, [])

    {:ok, user} =
      attrs_list
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    Muistin.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    Muistin.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end
