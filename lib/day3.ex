defmodule Day3 do
  @input "lib/input3.txt"

  def load_file(path) do
    path |> File.stream!()
  end

  def parse(r) do
    ["#" <> id, "@", edge, size] = String.split(r)
    [left, top] = edge |> String.trim_trailing(":") |> String.split(",")
    [wide, tall] = String.split(size, "x")

    %{
      id: String.to_integer(id),
      left: String.to_integer(left),
      top: String.to_integer(top),
      wide: String.to_integer(wide),
      tall: String.to_integer(tall)
    }
  end

  def blocks(c) do
    for x <- c.left..(c.left + c.wide - 1), y <- c.top..(c.top + c.tall - 1) do
      {x, y}
    end
  end

  def occupy(bs, m) do
    Enum.reduce(bs, m, fn c, m1 -> Map.update(m1, c, 1, &(&1 + 1)) end)
  end

  def test do
    p = %{id: 5, left: 140, top: 218, wide: 18, tall: 12} = parse("#5 @ 140,218: 18x12")
    occupy(%{}, p)
  end

  def run do
    @input
    |> load_file()
    |> Stream.map(&parse/1)
    |> Enum.reduce(%{}, fn c, m -> c |> blocks() |> occupy(m) end)
    |> Enum.count(fn {_, v} -> v > 1 end)
  end

  def run2 do
    block_info =
      @input
      |> load_file()
      |> Stream.map(&parse/1)
      |> Enum.map(fn x -> {x.id, blocks(x)} end)

    uniq_blocks =
      block_info
      |> Enum.reduce(%{}, fn {_, b}, m -> occupy(b, m) end)
      |> Stream.filter(fn {_, v} -> v == 1 end)
      |> Enum.map(fn {b, _} -> b end)

    {id, _} = Enum.find(block_info, fn {_, bs} -> Enum.all?(bs, fn b -> b in uniq_blocks end) end)
    id
  end
end
