defmodule Muistin.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :content, :string
    field :entry_date, :date
    field :timezone, :string
    belongs_to :user, Muistin.Accounts.User
    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:content, :entry_date, :user_id, :timezone])
    |> validate_required([:content, :entry_date, :user_id, :timezone])
    |> TzExtra.Changeset.validate_time_zone_id(:timezone)
    |> unique_constraint([:user_id, :entry_date], name: :entries_user_id_entry_date_index)
  end
end
