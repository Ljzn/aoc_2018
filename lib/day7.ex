defmodule Day7 do
  @path "lib/input7.txt"

  def load do
    @path
    |> File.stream!()
    |> Enum.map(&parse/1)
  end

  # Step E must be finished before step M can begin.
  def parse(
        "Step " <>
          <<a::binary-size(1)>> <>
          " must be finished before step " <> <<b::binary-size(1)>> <> " can begin." <> _
      ) do
    {a, b}
  end

  def prerequisites(table) do
    Enum.reduce(table, %{}, fn {a, b}, acc -> Map.update(acc, b, [a], fn x -> [a | x] end) end)
  end

  def satisfied?(requires, done) do
    requires |> Enum.all?(fn x -> x in done end)
  end

  def entry_group(table) do
    for {a, _} <- table, not Enum.any?(table, fn {_, b} -> a == b end) do
      a
    end
    |> Enum.uniq()
  end

  def loop(map, done) when map == %{} do
    Enum.reverse(done) |> Enum.join()
  end

  def loop(map, done) do
    next =
      ready_steps(map, done)
      |> List.first()

    loop(Map.delete(map, next), [next | done])
  end

  def ready_steps(map, done) do
    Enum.filter(map, fn {_, v} -> satisfied?(v, done) end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.sort()
  end

  def requires_map(table) do
    entries = entry_group(table)
    Enum.reduce(entries, prerequisites(table), fn x, acc -> Map.put(acc, x, []) end)
  end

  def time(step) do
    [x] = String.to_charlist(step)
    x - 4
  end

  def run do
    loop(requires_map(load()), [])
  end

  def run2 do
    loop2(requires_map(load()))
  end

  @init_workers List.duplicate(:idle, 5)

  def loop2(map), do: loop2(map, 0, @init_workers, [])

  def loop2(map, second, workers, done) do
    {workers1, done1} = do_work(workers, map, done) |> IO.inspect()

    case workers1 do
      @init_workers ->
        second

      _ ->
        map1 = Enum.reduce(done1, map, fn x, acc -> Map.delete(acc, x) end)
        loop2(map1, second + 1, workers1, done1)
    end
  end

  def test do
    """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    |> requires_map()
    |> loop2()
  end

  def do_work(workers, map, done) do
    working_steps = get_working_steps(workers)
    jobs = ready_steps(map, done) -- working_steps
    assign_jobs(workers, jobs, done)
  end

  defp assign_jobs(workers, jobs, done), do: assign_jobs(workers, jobs, done, [])
  defp assign_jobs([], _jobs, done, new_workers), do: {new_workers |> Enum.reverse(), done}

  defp assign_jobs([:idle | workers], [j | jobs], done, new_workers) do
    if time(j) == 1 do
      assign_jobs(workers, jobs, [j | done], [{j, 0} | new_workers])
    else
      assign_jobs(workers, jobs, done, [{j, 0} | new_workers])
    end
  end

  defp assign_jobs([:idle | workers], [], done, new_workers) do
    assign_jobs(workers, [], done, [:idle | new_workers])
  end

  defp assign_jobs([{cj, t} | workers], jobs, done, new_workers) do
    t1 = t + 1

    cond do
      t1 > time(cj) - 1 ->
        case jobs do
          [j | jt] ->
            if time(j) == 1 do
              assign_jobs(workers, jt, [j | done], [{j, 0} | new_workers])
            else
              assign_jobs(workers, jt, done, [{j, 0} | new_workers])
            end

          [] ->
            assign_jobs(workers, [], done, [:idle | new_workers])
        end

      t1 == time(cj) - 1 ->
        assign_jobs(workers, jobs, [cj | done], [{cj, t1} | new_workers])

      true ->
        assign_jobs(workers, jobs, done, [{cj, t1} | new_workers])
    end
  end

  defp get_working_steps(workers) do
    Enum.reduce(workers, [], fn x, acc ->
      case x do
        :idle ->
          acc

        {step, _t} ->
          [step | acc]
      end
    end)
  end
end
