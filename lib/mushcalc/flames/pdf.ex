defmodule Mushcalc.Flames.Pdf do
  import Mushcalc.Flames.StatSelection
  import Mushcalc.Flames.Utils

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "flame_pdf" do
    field :item_advantage, :boolean, default: true
    field :item_type, Ecto.Enum, values: ~w(weapon armor)a
    field :item_level, :integer
    field :char_eqs, {:array, :float}
    field :method, Ecto.Enum, values: ~w(powerful eternal)a

    field :score, :float
    field :probability, :float
  end

  @required_fields ~w(item_type item_level char_eqs method score probability)a
  @fields @required_fields ++ ~w(item_advantage)a

  def scoring_equiv_class(item_type, char_eqs) do
    symmetric_rolls(item_type)
    |> Enum.flat_map(fn keys ->
      get_keys(char_eqs, keys, 0) |> Enum.map(&(&1 / 1)) |> Enum.sort(:desc)
    end)
  end

  def map_attrs(attrs) do
    attrs
    |> Map.put(:char_eqs, scoring_equiv_class(attrs.item_type, attrs.char_eqs))
    |> Map.put(:score, attrs.score / 1)
  end

  def changeset(flame_pdf, attrs) do
    flame_pdf
    |> cast(map_attrs(attrs), @fields)
    |> validate_required(@required_fields)
  end

  def query(item_type, item_level, char_eqs, method) do
    __MODULE__
    |> where([f], f.item_type == ^item_type and f.item_level == ^item_level)
    |> where([f], f.char_eqs == ^scoring_equiv_class(item_type, char_eqs) and f.method == ^method)
  end
end
