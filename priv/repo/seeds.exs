# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Muistin.Repo.insert!(%Muistin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Muistin.Repo
alias Muistin.Accounts

# Create a test user
user =
  Accounts.register_user(%{username: "demo", password: "demodemo1234"})
  |> case do
    {:ok, user} -> user
    {:error, _} -> Repo.get_by!(Muistin.Accounts.User, username: "demo")
  end

# Create some sample entries for the user
Date.range(~D[2026-09-01], ~D[2026-09-10])
|> Enum.with_index(1)
|> Enum.each(fn {date, i} ->
  attrs = %{
    content: "This is my entry for day #{i}",
    entry_date: date,
    timezone: "Europe/Helsinki"
  }

  %Muistin.Entries.Entry{user_id: user.id}
  |> Muistin.Entries.Entry.changeset(attrs)
  |> Muistin.Repo.insert!()
end)

IO.puts("Seed data created!")
