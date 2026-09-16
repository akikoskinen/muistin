defmodule Muistin.EntriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Muistin.Entries` context.
  """

  alias Muistin.Entries

  def entry_fixture(attrs \\ %{}) do
    attrs = attrs |> Enum.into(%{})
    user = attrs[:user] || Muistin.AccountsFixtures.user_fixture()

    entry_attrs = %{
      content: attrs[:content] || "Test entry content",
      entry_date: attrs[:entry_date] || Date.utc_today(),
      timezone: attrs[:timezone] || "Europe/Helsinki"
    }

    {:ok, entry} = Entries.create_entry(entry_attrs, user)
    entry
  end
end
