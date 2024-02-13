defmodule Mushcalc.Flames.Tiers do
  import Mushcalc.StreamFuns, only: [cross_product: 3]

  def get_by_level(level, map) do
    Enum.find(map, fn {range, _} -> level in range end) |> elem(1)
  end

  @stat_per_tier [
    {120..139, 7},
    {140..159, 8},
    {160..179, 9},
    {180..199, 10},
    {200..229, 11},
    {230..300, 12}
  ]

  defp stat_per_tier(level), do: get_by_level(level, @stat_per_tier)

  @combo_stat_per_tier [
    {120..159, 4},
    {160..199, 5},
    {200..249, 6},
    {250..300, 7}
  ]

  defp combo_stat_per_tier(level), do: get_by_level(level, @combo_stat_per_tier)

  @hp_stat_per_tier [
    {120..129, 360},
    {130..139, 390},
    {140..149, 420},
    {150..159, 450},
    {160..169, 480},
    {170..179, 510},
    {180..189, 540},
    {190..199, 570},
    {200..209, 600},
    {210..219, 620},
    {220..229, 640},
    {230..239, 660},
    {240..249, 680},
    {250..300, 700}
  ]

  defp hp_stat_per_tier(level), do: get_by_level(level, @hp_stat_per_tier)

  @tier_probabilities %{
    drop: %{3 => 0.25, 4 => 0.3, 5 => 0.3, 6 => 0.14, 7 => 0.01},
    powerful: %{3 => 0.2, 4 => 0.3, 5 => 0.36, 6 => 0.14, 7 => 0},
    eternal: %{3 => 0, 4 => 0.29, 5 => 0.45, 6 => 0.25, 7 => 0.01},
    fusion: %{3 => 0.5, 4 => 0.4, 5 => 0.1, 6 => 0, 7 => 0},
    master_fusion: %{3 => 0.25, 4 => 0.35, 5 => 0.3, 6 => 0.1, 7 => 0},
    meister_fusion: %{3 => 0, 4 => 0.4, 5 => 0.45, 6 => 0.14, 7 => 0.01}
  }

  def tier_probability(method, tier),
    do: @tier_probabilities[method][tier]

  def tier_to_stat(stat, %{advantage: false} = item, tier) do
    tier_to_stat(stat, %{item | advantage: true}, tier - 2)
  end

  def tier_to_stat(stat, item, tier) when stat in ~w(str dex int luk) do
    %{stat => stat_per_tier(item.level) * tier}
  end

  def tier_to_stat(stat, item, tier)
      when stat in ~w(str_int str_dex str_luk dex_int dex_luk int_luk) do
    [s1, s2] = String.split(stat, "_")
    amount = combo_stat_per_tier(item.level) * tier

    %{s1 => amount, s2 => amount}
  end

  def tier_to_stat(stat, item, tier) when stat in ~w(hp mp) do
    %{stat => hp_stat_per_tier(item.level) * tier}
  end

  def tier_to_stat(stat, _, tier) do
    %{stat => tier}
  end

  def expand_selection_with_tiers(selected, item, method) do
    Stream.flat_map(selected, fn %{stats: stats, prob: pr} ->
      stats
      |> Enum.map(fn stat ->
        Enum.map(3..7, fn t ->
          %{stats: tier_to_stat(stat, item, t), prob: tier_probability(method, t)}
        end)
      end)
      |> Enum.reduce(fn s1, s2 ->
        cross_product(s1, s2, fn x, y ->
          %{
            stats: Map.merge(x.stats, y.stats, fn _, a, b -> a + b end),
            prob: x.prob * y.prob
          }
        end)
      end)
      |> Stream.map(fn %{stats: stats, prob: prob} ->
        %{stats: stats, prob: prob * pr}
      end)
    end)
  end
end
