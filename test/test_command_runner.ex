defmodule Loadmaster.TestCommandRunner do

  def run_command(step_state, _name, _cmd, _options \\ %{}) do
    step_state
  end

  def container_name(step_state) do
    step_state.job.id
  end
end
