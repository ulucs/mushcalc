defmodule Mushcalc.Persistence do
  import Ecto.Query
  alias Mushcalc.Repo
  alias Mushcalc.Persistence.Page

  def get_page_data(user_id, page_name) do
    Page
    |> where([p], p.user_id == ^user_id and p.page_name == ^page_name)
    |> select([p], p.data)
    |> Repo.one()
  end

  def save_page_data(user_id, page_name, data) do
    %Page{user_id: user_id, page_name: page_name, data: data}
    |> Repo.insert(
      on_conflict: {:replace, [:data, :updated_at]},
      conflict_target: [:user_id, :page_name]
    )
  end
end
