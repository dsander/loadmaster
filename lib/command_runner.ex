defmodule Loadmaster.CommandRunner do
  alias Loadmaster.BuildRunner.StepState
  alias Loadmaster.Endpoint

  @executor Application.get_env(:loadmaster, :command_executor) || Porcelain

  # credo:disable-for-lines:16 Credo.Check.Refactor.PipeChainStart
  def run_command(step_state, name, cmd, options \\ %{})
  def run_command(step_state = %StepState{status: :ok}, name, cmd, options) do
    step_state = if Map.get(options, :echo_cmd, true) do
      Endpoint.broadcast("builds", "output", %{build_id: step_state.build.id, job_id: step_state.job.id, step: name, value: "Running: " <> cmd})
      %{step_state | output: "Running: " <> cmd}
    end
    Task.async(fn ->
      cmd = if Map.get(options, :in_docker, true) do
        "docker exec #{container_name(step_state)} sh -c \"#{cmd}\""
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
        |> Enum.each(fn(row) -> Endpoint.broadcast("builds", "output", %{build_id: step_state.build.id, job_id: step_state.job.id, step: name, value: row}) end)
        loop(proc, name, step_state, output <> data)
      {^pid, :result, %Porcelain.Result{status: 0}} ->
        %StepState{step_state | status: :ok, output: step_state.output <> output}
      {^pid, :result, %Porcelain.Result{status: _}} ->
        %StepState{step_state | status: :error, output: step_state.output <> output}
    end
  end

  defp await(task) do
    if @executor == Porcelain do
      Task.await(task, 3_600_000)
    else
      task
    end
  end
end
