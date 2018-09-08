defmodule ABC do
  def main do
    IO.puts("Welcome :)")
    #parent(40, 24)
  end

  def parent(start_num, end_num, _) when end_num > start_num do
    :parentExit
  end

  def parent(start_num, end_num, done_pid) do
    ans = loop(start_num, end_num)
    #IO.puts("The answer is :#{ans}")
    #if ans is perfect square, exit. else continue
    temp = is_sqrt_natural?(ans)
    if (temp == true) do
      IO.puts("Temp: #{temp}, #{end_num}, value :#{ans}")
    end
    send(done_pid, {:done, self()})
  end

  def is_sqrt_natural?(n) when is_integer(n) do
    :math.sqrt(n) |> :erlang.trunc |> :math.pow(2) == n
  end

  def loop(num, n) when num == n do
    #IO.puts "The number is :#{num} end"
    num*num
  end

  def loop(num, _) when num <= 1 do
    #IO.puts "The number is :#{num} end"
    num
  end

  def loop(num, n) do
    #IO.puts "The number is :#{num}"
    num*num + loop(num - 1, n)
  end
end
