defmodule Runit do
  @cmd ~S"""
  docker pull cantino/huginn
  """

  def init do
    port = Port.open({:spawn, @cmd}, [:binary, :exit_status])
    loop(port)
  end

  def loop(port) do
    receive do
      {^port, {:data, result}} ->
        IO.puts("Elixir got: #{inspect result}")
        loop(port)
      {^port, {:exit_status, status} } ->
        IO.inspect(status)
      {:input, data} ->
        IO.inspect(data)
      {:signal, sig} ->
        IO.inspect(sig)
      {:stop, from, ref} ->
        IO.inspect(from, ref)
    end
  end

end


Runit.init