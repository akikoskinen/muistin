defmodule Muistin.Entries do
  import Ecto.Query
  alias Muistin.Repo
  alias Muistin.Entries.Entry

  def create_entry(attrs, user) do
    %Entry{user_id: user.id}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  def list_entries(user_id) do
    Entry
    |> where([e], e.user_id == ^user_id)
    |> order_by([e], desc: e.entry_date)
    |> Repo.all()
  end

  def get_entry(user_id, id) do
    Entry
    |> where([e], e.user_id == ^user_id and e.id == ^id)
    |> Repo.one()
  end
end
