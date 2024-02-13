defmodule Mushcalc.Flames.Scores do
  @moduledoc """
  Module for calculating the probability density function of the scores

  Handles the memoization and symmetry
  """
  import Mushcalc.Flames.StatSelection
  import Mushcalc.Flames.Tiers
  import Mushcalc.Flames.Utils
  import Ecto.Query

  alias Mushcalc.Flames.Pdf
  alias Mushcalc.Repo

  def gen_score_pdf(item, char_eqs, method) do
    stat_combinations(item.type, item.advantage)
    |> expand_selection_with_tiers(item, method)
    |> Stream.map(fn %{stats: stats, prob: prob} ->
      {calc_score(char_eqs, stats), prob}
    end)
    |> Enum.reduce(%{}, fn {score, prob}, acc ->
      Map.update(acc, score, prob, &(&1 + prob))
    end)
    |> Enum.map(fn {score, prob} ->
      Pdf.map_attrs(%{
        item_type: item.type,
        item_level: item.level,
        item_advantage: item.advantage,
        char_eqs: char_eqs,
        method: method,
        score: score,
        probability: prob
      })
    end)
  end

  def get_score_pdf_q(item, char_eqs, method) do
    if 0 ==
         Pdf.query(item, char_eqs, method)
         |> select([f], count(1))
         |> Repo.one() do
      Repo.insert_all(Pdf, gen_score_pdf(item, char_eqs, method))
    end

    Pdf.query(item, char_eqs, method)
  end

  def get_improvement_stats(item, char_eqs, method) do
    get_score_pdf_q(item, char_eqs, method)
    |> group_by([f], [f.item_advantage, f.item_type, f.item_level, f.char_eqs, f.method])
    |> where([f], f.score > ^item.score)
    |> select([f], %{
      expected_score: sum(f.score * f.probability) / sum(f.probability),
      probability: sum(f.probability),
      roi: sum(f.probability * (f.score - ^item.score))
    })
    |> Repo.one()
  end
end
