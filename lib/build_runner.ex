defmodule Loadmaster.BuildRunner.StepState do
  defstruct repository: nil, job: nil, build: nil, git_remote: nil, status: :ok, output: ""
end

defmodule Loadmaster.BuildRunner do
  alias Loadmaster.Repo
  alias Loadmaster.BuildRunner.StepState
  alias Loadmaster.Endpoint
  alias Loadmaster.Build
  alias Loadmaster.Job

  @command_runner Application.get_env(:loadmaster, :command_runner) || Loadmaster.CommandRunner

  def run(build_id) do
    build =
      Build
      |> Repo.get!(build_id)
      |> Repo.preload([:repository, :jobs])
    repository = Repo.preload(build.repository, :images)

    for job <- build.jobs do
      job = Repo.preload(job, :image)
      job = Repo.update!(Job.changeset(job, %{state: "running", data: Map.put(job.data, :started_at, :os.system_time(:seconds))}))

      step_state = %StepState{repository: repository, job: job, build: build, git_remote: build.git_remote}
      |> step(:setup)
      |> step(:login)
      |> step(:clone)
      # |> step(:update_cache)
      |> step(:build)
      |> step(:push)
      |> step(:teardown)

      Repo.update!(Job.changeset(job, %{state: "success", data: Map.put(step_state.job.data, :finished_at, :os.system_time(:seconds))}))
    end
  end

  def step(step_state = %StepState{status: :ok}, name = :setup) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "docker run -id -v /var/run/docker.sock:/var/run/docker.sock --name #{@command_runner.container_name(step_state)} dsander/loadmaster-builder", %{echo_cmd: false, in_docker: false})
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :login) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "docker login -u #{step_state.repository.docker_user} -p #{step_state.repository.docker_password}", %{echo_cmd: false})
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :clone) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "git clone --depth=1 #{step_state.git_remote} build")
    |> @command_runner.run_command(name, "cd build; git fetch --depth=1 origin pull/#{step_state.build.pull_request_id}/head:pr; git checkout pr")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :update_cache) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "docker pull #{step_state.job.image.cache_image}")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :build) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "cd build; docker build -t #{step_state.job.image.name}:pr-#{step_state.build.pull_request_id} -f #{step_state.job.image.dockerfile} #{step_state.job.image.context}")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :push) do
    step_state
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "docker push #{step_state.job.image.name}:pr-#{step_state.build.pull_request_id}")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: _}, name = :teardown) do
    step_state
    |> Map.put(:status, :ok)
    |> start_step_processing(name)
    |> @command_runner.run_command(name, "docker rm -f #{@command_runner.container_name(step_state)}", %{echo_cmd: false, in_docker: false})
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :error}, _) do
    step_state
  end

  def start_step_processing(step_state, name) do
    update_step_state(step_state, Atom.to_string(name), "running")
  end

  def write_step_state(step_state = %StepState{status: :ok}, name) do
    step_state
    |> update_step_state(Atom.to_string(name), "success")
  end

  def write_step_state(step_state = %StepState{status: :error}, name) do
    step_state
    |> update_step_state(Atom.to_string(name), "error")
  end

  def update_step_state(step_state = %StepState{}, name, value) do
    data = put_in(step_state.job.data, [name], %{state: value, output: String.split(step_state.output, "\n")})
    job = Repo.update!(Job.changeset(step_state.job, %{data: data}))
    Endpoint.broadcast("build:#{step_state.build.id}", "update_state", %{job_id: step_state.job.id, step: name, value: value})
    %StepState{step_state | job: job, output: ""}
  end
end
