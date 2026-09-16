defmodule Muistin.Entries.EntryTest do
  use Muistin.DataCase

  alias Muistin.Entries.Entry

  @valid_attrs %{
    content: "valid",
    entry_date: ~D[2024-01-01],
    user_id: 1,
    timezone: "Europe/Helsinki"
  }

  describe "changeset/2" do
    test "accepts valid data" do
      changeset = Entry.changeset(%Entry{}, @valid_attrs)
      assert changeset.valid?
    end

    test "requires content" do
      attrs = @valid_attrs |> Map.delete(:content)
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{content: ["can't be blank"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "requires entry_date" do
      attrs = @valid_attrs |> Map.delete(:entry_date)
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{entry_date: ["can't be blank"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "requires user_id" do
      attrs = @valid_attrs |> Map.delete(:user_id)
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{user_id: ["can't be blank"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "validates content is a string" do
      attrs = @valid_attrs |> Map.put(:content, 123)
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{content: ["is invalid"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "validates entry_date is a date" do
      attrs = @valid_attrs |> Map.put(:entry_date, "not a date")
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{entry_date: ["is invalid"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "requires timezone" do
      attrs = @valid_attrs |> Map.delete(:timezone)
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{timezone: ["can't be blank"]} = Muistin.DataCase.errors_on(changeset)
    end

    test "validates timezone is valid" do
      attrs = @valid_attrs |> Map.put(:timezone, "Invalid/Timezone")
      changeset = Entry.changeset(%Entry{}, attrs)
      refute changeset.valid?
      assert %{timezone: ["is not a valid time zone"]} = Muistin.DataCase.errors_on(changeset)
    end
  end
end
