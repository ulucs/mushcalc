defmodule Mushcalc.Flames.Utils do
  def calc_score(char_eqs, flame_stats) do
    Enum.reduce(char_eqs, 0, fn {stat, mult}, acc ->
      acc + (Map.get(flame_stats, stat, 0) || 0) * (mult || 0)
    end)
  end

  def get_keys(map, keys, default) do
    Enum.map(keys, fn key -> Map.get(map, key, default) end)
  end
end
