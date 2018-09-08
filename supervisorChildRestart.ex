defmodule Parent do
  def spawn_link(xlimits, size) do
    limits = Enum.to_list(1..xlimits)
    spawn_link(__MODULE__, :init, [limits])
  end

  def init(xlimits, size) do
    limits = Enum.to_list(1..5)
    Process.flag :trap_exit, true

    children_pids = Enum.map(limits, fn(limit_num) ->
      pid = run_child(limit_num)
      {pid, limit_num}
    end) |> Enum.into(%{})

    loop(children_pids, Enum.to_list(6..xlimits))
  end

  def loop(_, []), do: :parentLoopExit
  def loop(children_pids, [head | tail]) do
    receive do
      {:EXIT, pid, _} = msg->
        #IO.puts "Parent got message: #{inspect msg}"

        {limit, children_pids} = pop_in children_pids[pid]
        new_pid = run_child(head)

        children_pids = put_in children_pids[new_pid], head

        IO.puts "Restart children #{inspect pid}(limit #{limit}) with new pid #{inspect new_pid}"

        loop(children_pids, tail)
    end
  end

  def run_child(limit) do
    spawn_link(Child, :init, [limit])
  end
end

defmodule Child do
  def init(limit) do
    IO.puts "Start child with limit #{limit} pid #{inspect self()}"
    loop(limit)
  end

  def loop(0), do: :ok
  def loop(n) when n > 0 do
    IO.puts "Process #{inspect self()} list #{n} to #{n + 25}"
    Process.sleep 500
    #loop(n-1)
  end
end

Parent.init(100, 25)

Process.sleep 10_000
