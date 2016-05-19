defmodule Loadmaster.CommandRunner do
  alias Loadmaster.BuildRunner.StepState
  alias Loadmaster.Endpoint

  @executor Application.get_env(:loadmaster, :command_executor) || Porcelain

  @lint {Credo.Check.Refactor.PipeChainStart, false}
  def run_command(step_state = %StepState{status: :ok}, name, cmd, options \\ %{}) do
    if Map.get(options, :echo_cmd, true) do
      step_state = %{step_state | output: "Running: " <> cmd}
      Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: "Running: " <> cmd})
    end
    Task.async(fn ->
      if Map.get(options, :in_docker, true) do
        cmd = "docker exec #{container_name(step_state)} sh -c \"#{cmd}\""
      end
      @executor.spawn_shell(cmd <> " 2>&1",
                              in: :receive, out: {:send, self()}, err: {:send, self()})
      |> loop(name, step_state)
    end)
    |> await
  end

  def run_command(step_state = %StepState{status: :error}, _, _, _) do
    step_state
  end

  def container_name(step_state) do
    "loadmaster-job-#{step_state.job.id}"
  end

  defp loop(%Porcelain.Process{pid: pid} = proc, name, step_state, output \\ "") do
    receive do
      {^pid, :data, _, data} ->
        data
        |> String.split("\n")
        |> Enum.reject(fn(string) -> String.strip(string) == "" end)
        |> Enum.each(fn(row) -> Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: row}) end)
        loop(proc, name, step_state, output <> data)
      {^pid, :result, %Porcelain.Result{status: 0}} ->
        %StepState{step_state | status: :ok, output: step_state.output <> output}
      {^pid, :result, %Porcelain.Result{status: _}} ->
        %StepState{step_state | status: :error, output: step_state.output <> output}
    end
  end

  defp await(task) do
    if @executor == Porcelain do
      Task.await(task, 1200_000)
    else
      task
    end
  end
end
