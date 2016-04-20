defmodule Huginnbuilder.Runner do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def build(cmd) do
    GenServer.call(__MODULE__, {:build, cmd})
  end

  def handle_call({:build, cmd}, _from, state) do
    {:ok, pid} = Task.start_link(fn ->
      port = Port.open({:spawn, cmd}, [:binary, :exit_status])
      loop(port)
    end)
    {:reply, pid, state}
  end

  def loop(port) do
    receive do
      {^port, {:data, result}} ->
        result
        |> String.split("\n")
        |> Enum.each fn(row) -> Huginnbuilder.Endpoint.broadcast("repository:#{3}", "build", %{body: row}) end
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
