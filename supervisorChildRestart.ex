defmodule Parent do
  def spawn_link(xlimits, _) do
    limits = Enum.to_list(1..xlimits)
    spawn_link(__MODULE__, :init, [limits])
  end

  def init(xlimits, size) do
    limits = Enum.to_list(1..10)
    Process.flag :trap_exit, true

    children_pids = Enum.map(limits, fn(limit_num) ->
      pid = run_child(limit_num, size)
      {pid, limit_num}
    end) |> Enum.into(%{})

    loop(children_pids, Enum.to_list(6..xlimits), size)
  end

  def loop(_, [], _), do: :parentLoopExit
  def loop(children_pids, [head | tail], size) do
    receive do
      {:EXIT, pid, _} = _->
        #IO.puts "Parent got message: #{inspect msg}"

        {limit, children_pids} = pop_in children_pids[pid]
        new_pid = run_child(head, size)

        children_pids = put_in children_pids[new_pid], head

        #IO.puts "Restart children #{inspect pid}(limit #{limit}) with new pid #{inspect new_pid}"

        loop(children_pids, tail, size)
    end
  end

  def run_child(limit, size) do
    spawn_link(Child, :init, [limit, size])
  end
end

defmodule Child do
  def init(limit, size) do
    #IO.puts "Start child with limit #{limit} pid #{inspect self()}"
    loop(limit, size)
  end

  def loop(0, _), do: :ok
  def loop(n, size) when n > 0 do
    #IO.puts "Process #{inspect self()} list #{n} to #{n + 25}"
    MathWork.parent(n, size)
    Process.sleep 500
    #loop(n-1)
  end
end

defmodule MathWork do
  def main do
    IO.puts("Welcome :)")
  end

  #def parent(start_num, end_num, _) when end_num > start_num do
  #  :parentExit
  #end

  def parent(start_num, recur_level) do
    ans = loop(start_num, recur_level)
    #IO.puts("The answer is :#{ans}")
    #if ans is perfect square, exit. else continue
    temp = is_sqrt_natural?(ans)
    #if (temp == true) do
    IO.puts("Temp: #{temp}, #{start_num}, value :#{ans}")
    #end
  end

  def is_sqrt_natural?(n) when is_integer(n) do
    :math.sqrt(n) |> :erlang.trunc |> :math.pow(2) == n
  end

  def loop(num, recur_level) when recur_level == 1 do
    #IO.puts "The number is :#{num} end"
    num*num
  end

  #not really required
  #def loop(num, _) when num <= 1 do
    #IO.puts "The number is :#{num} end"
  #  num
  #end

  def loop(num, recur_level) do
    #IO.puts "The number is :#{num}"
    num*num + loop(num + 1, recur_level - 1)
  end
end

Parent.init(15, 24)

Process.sleep 10_00
