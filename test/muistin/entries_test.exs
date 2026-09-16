defmodule Muistin.EntriesTest do
  use Muistin.DataCase

  alias Muistin.Entries
  alias Muistin.AccountsFixtures

  describe "create_entry/2" do
    test "requires content" do
      user = AccountsFixtures.user_fixture()
      {:error, changeset} = Entries.create_entry(%{content: nil}, user)
      assert %{content: ["can't be blank"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "creates entry with valid data" do
      user = AccountsFixtures.user_fixture()
      entry_date = ~D[2024-01-15]

      {:ok, entry} =
        Entries.create_entry(
          %{content: "My first entry", entry_date: entry_date, timezone: "Europe/Helsinki"},
          user
        )

      assert entry.content == "My first entry"
      assert entry.entry_date == entry_date
      assert entry.timezone == "Europe/Helsinki"
      assert entry.user_id == user.id
      assert entry.id != nil
      assert entry.inserted_at != nil
      assert entry.updated_at != nil
    end

    test "prevents duplicate entries for same user and date" do
      user = AccountsFixtures.user_fixture()
      entry_date = ~D[2024-01-15]

      {:ok, _entry} =
        Entries.create_entry(
          %{content: "First entry", entry_date: entry_date, timezone: "Europe/Helsinki"},
          user
        )

      {:error, changeset} =
        Entries.create_entry(
          %{content: "Second entry", entry_date: entry_date, timezone: "Europe/Helsinki"},
          user
        )

      assert changeset.errors[:entry_date] || changeset.errors[:user_id]
    end
  end

  describe "list_entries/1" do
    test "returns empty list for user with no entries" do
      user = AccountsFixtures.user_fixture()
      assert [] = Entries.list_entries(user.id)
    end

    test "returns entries for a user, sorted newest first" do
      user = AccountsFixtures.user_fixture()

      earlier_entry =
        Muistin.EntriesFixtures.entry_fixture(%{user: user, entry_date: ~D[2024-01-01]})

      later_entry =
        Muistin.EntriesFixtures.entry_fixture(%{user: user, entry_date: ~D[2024-01-15]})

      entries = Entries.list_entries(user.id)

      assert length(entries) == 2
      assert Enum.at(entries, 0).id == later_entry.id
      assert Enum.at(entries, 1).id == earlier_entry.id
    end

    test "does not return entries from other users" do
      user_with_entry = AccountsFixtures.user_fixture()
      user_without_entries = AccountsFixtures.user_fixture()
      _entry = Muistin.EntriesFixtures.entry_fixture(%{user: user_with_entry})

      assert [] = Entries.list_entries(user_without_entries.id)
    end
  end

  describe "get_entry/2" do
    test "returns nil for non-existent entry" do
      user = AccountsFixtures.user_fixture()
      refute Entries.get_entry(user.id, 999)
    end

    test "returns entry by id for the user" do
      user = AccountsFixtures.user_fixture()
      entry = Muistin.EntriesFixtures.entry_fixture(%{user: user})

      result = Entries.get_entry(user.id, entry.id)
      assert result.id == entry.id
    end

    test "does not return entry from another user" do
      user_with_entry = AccountsFixtures.user_fixture()
      user_without_entries = AccountsFixtures.user_fixture()
      entry = Muistin.EntriesFixtures.entry_fixture(%{user: user_with_entry})

      refute Entries.get_entry(user_without_entries.id, entry.id)
    end
  end
end
