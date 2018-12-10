defmodule Day9 do
  # 465 players; last marble is worth 71940 points

  def players(n), do: List.duplicate(0, n)

  def place_marble(marbles, new), do: [new| rotate_marbles(marbles, 2)]

  def rotate_marbles(marbles, n) when n < 0 do
    Enum.reverse(marbles) |> rotate_marbles(-n) |> Enum.reverse()
  end
  def rotate_marbles(marbles, 0), do: marbles
  def rotate_marbles([h|t], n), do: rotate_marbles(t++[h], n-1)

  def play(p, last), do: play([0], players(p), 1, last)
  def play(marbles, players, new, last)
  def play(_marbles, players, new, last) when new > last do
    # IO.inspect marbles
    players |> Enum.max()
  end
  def play(marbles, [ph|pt], new, last) when rem(new, 23) == 0 do
    # IO.inspect marbles
    [seven| marbles] = rotate_marbles(marbles, -7)
    # IO.inspect seven
    play(marbles, pt ++ [ph + new + seven], new + 1, last)
  end
  def play(marbles, [ph|pt], new, last) do
    # IO.inspect marbles
    play(place_marble(marbles, new), pt ++ [ph], new + 1, last)
  end


  def test do
    32 = play 9, 25
    8317 = play 10, 1618
    146373 = play 13, 7999
    2764 = play 17, 1104
    54718 = play 21, 6111
    37305 = play 30, 5807
  end

  def run(), do: play 465, 71940
  def run2(), do: play 465, 7194000
end
