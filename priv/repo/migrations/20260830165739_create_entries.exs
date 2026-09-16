defmodule Muistin.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :content, :text, null: false
      add :entry_date, :date, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :timezone, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:entries, [:user_id])
    create index(:entries, [:entry_date])
    create unique_index(:entries, [:user_id, :entry_date])
  end
end
