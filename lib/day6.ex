defmodule Day6 do
  @path "lib/input6.txt"

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def load do
    @path
    |> File.stream!()
    |> Enum.map(&string_to_loc/1)
  end

  defp string_to_loc(s) do
    [x, y] = String.split(s, [", ", "\n"], trim: true) |> Enum.map(&String.to_integer/1)
    {x, y}
  end

  def edges(locs) do
    {{x1, _}, {x2, _}} = Enum.min_max_by(locs, fn {x, _y} -> x end)
    {{_, y1}, {_, y2}} = Enum.min_max_by(locs, fn {_x, y} -> y end)
    {x1, x2, y1, y2}
  end

  def run do
    sources = load()
    {x1, x2, y1, y2} = edges(sources)

    for x <- x1..x2, y <- y1..y2 do
      for s <- sources do
        {distance(s, {x, y}), s}
      end
      |> Enum.sort()
      |> final_state({x, y})
    end
    |> Enum.group_by(fn {_, s} -> s end, fn {loc, _} -> loc end)
    |> Map.delete(:mid)
    |> Enum.reject(fn {_, v} ->
      Enum.any?(v, fn {x, y} -> x == x1 or x == x2 or y == y1 or y == y2 end)
    end)
    |> Enum.max_by(fn {_, c} -> length(c) end)
    |> area_size()
  end

  def run2 do
    sources = load()
    {x1, x2, y1, y2} = edges(sources)

    for x <- x1..x2, y <- y1..y2 do
      for s <- sources do
        distance(s, {x, y})
      end
      |> Enum.sum()
    end
    |> Enum.filter(fn x -> x < 10000 end)
    |> length()
  end

  defp area_size({_source, follows}), do: length(follows)

  def final_state([{d, _}, {d, _} | _], loc) do
    {loc, :mid}
  end

  def final_state([{_, s} | _], loc) do
    {loc, s}
  end
end
