defmodule Loadmaster.CommandRunnerTest do
  use Loadmaster.ModelCase

  setup do
    repository = insert_repository()
    build = insert_build(repository)
    image = insert_image(repository)
    job = insert_job(build, image)
    {:ok, job: job, build: build}
  end

  test "it runs a command", %{job: job, build: build} do
    task = Loadmaster.CommandRunner.run_command(%Loadmaster.BuildRunner.StepState{status: :ok, job: job, build: build}, :test, "true")
    send task.pid, {task.pid, :result, %Porcelain.Result{status: 0}}
    step_state = Task.await(task)
    assert step_state.status == :ok
  end

  test "returns the correct state ", %{job: job, build: build} do
    task = Loadmaster.CommandRunner.run_command(%Loadmaster.BuildRunner.StepState{status: :ok, job: job, build: build}, :test, "true")
    send task.pid, {task.pid, :result, %Porcelain.Result{status: 1}}
    step_state = Task.await(task)
    assert step_state.status == :error
  end

  test "it captures the command output", %{job: job, build: build} do
    task = Loadmaster.CommandRunner.run_command(%Loadmaster.BuildRunner.StepState{status: :ok, job: job, build: build}, :test, "true")
    send task.pid, {task.pid, :data, nil, "line one\nline two"}
    send task.pid, {task.pid, :result, %Porcelain.Result{status: 0}}
    step_state = Task.await(task)
    assert step_state.status == :ok
    assert step_state.output == "Running: trueline one\nline two"
  end

  test "it does not do anything when a previous command failed" do
    step_state = %Loadmaster.BuildRunner.StepState{status: :error}
    step_state2 = Loadmaster.CommandRunner.run_command(step_state, nil, nil, nil)
    assert step_state == step_state2
  end
end
