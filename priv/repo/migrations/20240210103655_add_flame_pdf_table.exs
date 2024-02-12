defmodule Mushcalc.Repo.Migrations.AddFlamePdfTable do
  use Ecto.Migration

  def change do
    create table(:flame_pdf) do
      add :item_advantage, :boolean, default: true
      add :item_type, :string
      add :item_level, :integer
      add :char_eqs, {:array, :float}
      add :method, :string

      add :score, :float
      add :probability, :float
    end

    create unique_index(:flame_pdf, [
             :item_advantage,
             :item_type,
             :item_level,
             :char_eqs,
             :method,
             :score
           ])
  end
end
