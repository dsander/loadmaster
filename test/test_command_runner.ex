defmodule Loadmaster.TestCommandRunner do

  def run_command(step_state, _name, _cmd, _options \\ %{})
  def run_command(step_state, :build, _cmd, _options) do
    %Loadmaster.BuildRunner.StepState{step_state | status: :ok, output: "test output"}
  end

  def run_command(step_state, _name, _cmd, _options) do
    step_state
  end

  def container_name(step_state) do
    step_state.job.id
  end
end
