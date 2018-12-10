defmodule Day9 do
  # 465 players; last marble is worth 71940 points

  def players(n), do: {:array.new(n, {:default, 0}), 0}

  def settle({board, player}, point) do
    size = :array.size(board)
    value = :array.get(player, board)
    {:array.set(player, value + point, board), rem(player + 1, size)}
  end

  def place_marble(marbles, new) do
    marbles |> rotate_marbles(2) |> insert_marble(new)
  end

  def rotate_marbles({map, current}, n) when n < 0 do
   {left, _right} = map[current]
   rotate_marbles({map, left}, n + 1)
  end
  def rotate_marbles(marbles, 0), do: marbles
  def rotate_marbles({map, current}, n) do
    {_left, right} = map[current]
    rotate_marbles({map, right}, n-1)
  end

  # insert new marble at the left of current
  def insert_marble({map, c}, new) do
    {cl, _} = map[c]
    map =
      map
      |> Map.update!(c, fn {_, right} -> {new, right} end)
      |> Map.update!(cl, fn {left, _} -> {left, new} end)
      |> Map.put(new, {cl, c})
    {map, new}
  end

  def play(p, last), do: play({ %{0 => {0, 0}}, 0}, players(p), 1, last)
  def play(marbles, players, new, last)
  def play(_marbles, {board, _}, new, last) when new > last do
    # IO.inspect marbles
    board |> :array.to_list() |> Enum.max()
  end
  def play(marbles, players, new, last) when rem(new, 23) == 0 do
    # IO.inspect marbles
    {map, seven} = rotate_marbles(marbles, -7)
    {left, right} = map[seven]
    map =
      map
      |> Map.delete(seven)
      |> Map.update!(left, fn {l, _} -> {l, right} end)
      |> Map.update!(right, fn {_, r} -> {left, r} end)
    play({map, right}, settle(players, (seven + new)), new + 1, last)
  end
  def play(marbles, players, new, last) do
    # IO.inspect marbles
    play(place_marble(marbles, new), settle(players, 0), new + 1, last)
  end


  def test do
    32 = play 9, 25
    8317 = play 10, 1618
    146373 = play 13, 7999
    2764 = play 17, 1104
    54718 = play 21, 6111
    37305 = play 30, 5807
    IO.puts "test pass"
  end

  def run(), do: play 465, 71940
  def run2(), do: play 465, 7194000
end
