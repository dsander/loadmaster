defmodule Huginnbuilder.Runner do

  def run(repository) do
    for cmd <- String.split(repository.build_commands, "\r\n") do
      Huginnbuilder.Endpoint.broadcast("repository:#{3}", "build", %{body: "Running: " <> cmd})
      Task.async(fn ->
        Porcelain.spawn_shell(cmd,
                                in: :receive, out: {:send, self()}, err: {:send, self()})
        |> loop
      end)
      |> Task.await(1200_000)
    end
  end

  def loop(%Porcelain.Process{pid: pid} = proc) do
    receive do
      {^pid, :data, _, data} ->
        data
        |> String.split("\n")
        |> Enum.each(fn(row) -> Huginnbuilder.Endpoint.broadcast("repository:#{3}", "build", %{body: row}) end)
        loop(proc)
      {^pid, :result, %Porcelain.Result{status: status}} ->
        IO.inspect("res:" <> Integer.to_string(status))
    end
  end
end