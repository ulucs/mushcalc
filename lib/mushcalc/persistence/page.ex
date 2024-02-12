defmodule Mushcalc.Persistence.Page do
  use Ecto.Schema

  schema "page_data" do
    field :page_name, :string
    field :user_id, Ecto.UUID
    field :data, :map

    timestamps()
  end
end
