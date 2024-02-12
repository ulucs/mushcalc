defmodule Mushcalc.Characters.Item do
  import Mushcalc.Flames.Utils, only: [calc_score: 2]
  defstruct [:type, :level, :flame, :score]

  def new(type, level, flame, score) when is_number(score) do
    %Mushcalc.Characters.Item{type: type, level: level, flame: flame, score: score}
  end

  def new(type, level, flame, eqs) when is_map(eqs) do
    %Mushcalc.Characters.Item{
      type: type,
      level: level,
      flame: flame,
      score: calc_score(eqs, flame)
    }
  end
end
