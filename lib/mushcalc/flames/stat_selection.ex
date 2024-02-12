defmodule Mushcalc.Flames.StatSelection do
  import Mushcalc.StreamFuns

  def flame_stats(:weapon) do
    ~w(
      str dex int luk
      str_int str_dex str_luk
      dex_int dex_luk int_luk
      hp mp def lv_red
      atk matk as
      boss dmg
    )
  end

  def flame_stats(:armor) do
    ~w(
      str dex int luk
      str_int str_dex str_luk
      dex_int dex_luk int_luk
      hp mp def lv_red
      atk matk as
      speed jump
    )
  end

  def symmetric_rolls(:armor) do
    [
      ~w(str dex int luk),
      ~w(hp mp),
      ~w(atk matk as)
    ]
  end

  def symmetric_rolls(:weapon) do
    [
      ~w(str dex int luk),
      ~w(hp mp def lv_red),
      ~w(atk matk),
      ~w(as dmg),
      ~w(boss)
    ]
  end

  def stat_combinations(type) do
    stats = flame_stats(type)
    count = comb_length(4, stats)

    comb(4, stats)
    |> Stream.map(fn s -> %{stats: s, prob: 1 / count} end)
  end
end
