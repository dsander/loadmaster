defmodule Loadmaster.Builder do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def build(build_id) do
    GenServer.call(__MODULE__, {:build, build_id})
  end

  def handle_call({:build, build_id}, _from, state) do
    {:ok, pid} = Task.start_link(fn ->
      Loadmaster.BuildRunner.run(build_id)
    end)
    {:reply, pid, state}
  end
end
