defmodule Loadmaster.CommandRunner do
  alias Loadmaster.BuildRunner.StepState
  alias Loadmaster.Endpoint

  def run_command(step_state = %StepState{status: :ok}, name, cmd) do
    unless step_state.no_cmd_echo do
      step_state = %{ step_state | output: "Running: " <> cmd }
      Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: "Running: " <> cmd})
    end
    Task.async(fn ->
      Porcelain.spawn_shell("cd builds;" <> cmd <> " 2>&1",
                              in: :receive, out: {:send, self()}, err: {:send, self()})
      |> loop(name, step_state)
    end)
    |> Task.await(1200_000)
  end

  def run_command(step_state = %StepState{status: :error}, _, _) do
    step_state
  end

  defp loop(%Porcelain.Process{pid: pid} = proc, name, step_state, output \\ "") do
    receive do
      {^pid, :data, _, data} ->
        data
        |> String.split("\n")
        |> Enum.each(fn(row) -> Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: row}) end)
        loop(proc, name, step_state, output <> data)
      {^pid, :result, %Porcelain.Result{status: 0}} ->
        %StepState{ step_state | status: :ok, output: step_state.output <> output }
      {^pid, :result, %Porcelain.Result{status: _}} ->
        %StepState{ step_state | status: :error, output: step_state.output <> output }
    end
  end
end
