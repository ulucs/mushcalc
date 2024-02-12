defmodule Mushcalc.Repo.Migrations.AddPersistenceTable do
  use Ecto.Migration

  def change do
    create table(:page_data) do
      add :user_id, :uuid
      add :page_name, :string
      add :data, :map

      timestamps()
    end

    create unique_index(:page_data, [:user_id, :page_name])
  end
end
