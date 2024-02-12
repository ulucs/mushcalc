defmodule Mushcalc.StreamFuns do
  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    comb(m - 1, t)
    |> Stream.map(fn l -> [h | l] end)
    |> Stream.concat(comb(m, t))
  end

  def comb_length(m, items) do
    l = length(items)
    Enum.product(l..(l - m + 1)) / Enum.product(1..m)
  end

  def cross_product(a, b, f \\ fn x, y -> {x, y} end) do
    Stream.flat_map(a, fn x -> Stream.map(b, fn y -> f.(x, y) end) end)
  end
end
