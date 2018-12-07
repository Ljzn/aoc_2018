defmodule Day4 do
  @input "lib/input4.txt"

  def load_file do
    @input |> File.stream!()
  end

  # [1518-03-21 00:30] falls asleep
  def parse("[1518-" <> str) do
    {date, " " <> str} = String.split_at(str, 5)
    {time, "] " <> str} = String.split_at(str, 5)
    event = parse_event(str)

    %{
      date: int_tuple(date, "-"),
      time: int_tuple(time, ":"),
      event: event
    }
  end

  defp int_tuple(str, s) do
    [a, b] = String.split(str, s)
    {String.to_integer(a), String.to_integer(b)}
  end

  def parse_event("falls asleep" <> _), do: :sleep
  def parse_event("wakes up" <> _), do: :wake

  def parse_event("Guard #" <> str) do
    [n | _] = String.split(str)
    {:shift, String.to_integer(n)}
  end

  def test do
    parse("[1518-10-07 23:58] Guard #239 begins shift")
  end

  def sort_by(log), do: {log.date, log.time}

  # in sleep table, {1, 2} presents sleep 2 minutes
  # (logs, id, last_sleep, result)
  def count_sleep([%{event: {:shift, id}} | logs], _, nil, result) do
    count_sleep(logs, id, nil, result)
  end

  def count_sleep([%{event: :sleep, time: {_, begin}} | logs], id, _, result) do
    count_sleep(logs, id, begin, result)
  end

  def count_sleep([%{event: :wake, time: {_, tend}} | logs], id, begin, result)
      when begin != nil do
    count_sleep(
      logs,
      id,
      nil,
      Map.update(result, id, [{begin, tend - 1}], fn v -> [{begin, tend - 1} | v] end)
    )
  end

  def count_sleep([%{event: {:shift, id}} | logs], old_id, begin, result) when begin != nil do
    count_sleep(
      logs,
      id,
      nil,
      Map.update(result, old_id, [{begin, 59}], fn v -> [{begin, 59} | v] end)
    )
  end

  def count_sleep([], _, _, result), do: result

  def find_laziest(table) do
    table
    |> Enum.map(fn {id, times} ->
      {id, Enum.reduce(times, 0, fn {a, z}, acc -> acc + z - a + 1 end)}
    end)
    |> Enum.max_by(fn {_, sum} -> sum end)
  end

  # %{minute => times}
  def sleep_frequency(list) do
    Enum.reduce(list, %{}, fn {a, z}, acc ->
      Enum.reduce(a..z, acc, fn m, acc -> Map.update(acc, m, 1, &(&1 + 1)) end)
    end)
  end

  # %{id => list_of_sleep_time}
  def get_sleep_table do
    logs =
      load_file()
      |> Stream.map(&parse/1)
      |> Enum.sort_by(&sort_by/1)

    count_sleep(logs, nil, nil, %{})
  end

  def run do
    sleep_table = get_sleep_table()
    {id, _} = find_laziest(sleep_table)
    {m, _} = sleep_frequency(sleep_table[id]) |> Enum.max_by(fn {_, v} -> v end)
    id * m
  end

  def run2 do
    {id, {m, _}} =
      get_sleep_table()
      |> Stream.map(fn {id, list} -> {id, sleep_frequency(list)} end)
      |> Stream.map(fn {id, freq} -> {id, Enum.max_by(freq, fn {_, v} -> v end)} end)
      |> Enum.max_by(fn {_, {_, t}} -> t end)

    id * m
  end
end
