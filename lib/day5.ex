defmodule Day5 do
  def load_file do
    File.read!("lib/input5.txt")
  end

  def run do
    load_file()
    |> String.trim()
    |> String.codepoints()
    |> react()
    |> Enum.count()
  end

  def run2 do
    result =
      load_file()
      |> String.trim()
      |> String.codepoints()
      |> react()
    for x <- result |> Enum.map(&String.downcase/1) |> Enum.uniq() do
      result |> remove_x(x) |> react()
    end
    |> Enum.min_by(&length/1)
    |> length()
  end

  def react(polymer), do: react(polymer, [], false)
  def react([h1, h2 | t], remain, triggered) do
    if trigger?(h1, h2) do
      react(t, remain, true)
    else
      react([h2|t], [h1|remain], triggered)
    end
  end
  def react(polymer, remain, triggered) do
    if triggered do
      react(Enum.reverse(polymer ++ remain), [], false)
    else
      Enum.reverse(polymer ++ remain)
    end
  end

  def trigger?(a, b) do
    a != b and (String.upcase(a) == b or String.upcase(b) == a)
  end

  def test do
    result =
      "dabAcCaCBAcCcaDA"
        |> String.codepoints()
        |> react([], false)
    10 = Enum.count(result)
    6 = remove_x(result, "a") |> react() |> Enum.count()
    8 = remove_x(result, "b") |> react() |> Enum.count()
    4 = remove_x(result, "c") |> react() |> Enum.count()
    6 = remove_x(result, "d") |> react() |> Enum.count()
  end

  def remove_x(result, x) do
    Enum.reject(result, fn a -> a == x or a == String.upcase(x) end)
  end
end
