defmodule Huginnbuilder.Builder do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def build(build, git_remote) do
    GenServer.call(__MODULE__, {:build, build, git_remote})
  end

  def handle_call({:build, build, git_remote}, _from, state) do
    {:ok, pid} = Task.start_link(fn ->
      Huginnbuilder.BuildRunner.run(build, git_remote)
    end)
    {:reply, pid, state}
  end
end
