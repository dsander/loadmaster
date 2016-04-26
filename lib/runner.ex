defmodule Huginnbuilder.Runner.StepState do
  defstruct repository: nil, job: nil, build: nil, status: :ok, output: ""
end

defmodule Huginnbuilder.Runner do
  alias Huginnbuilder.Repo
  alias Huginnbuilder.Runner.StepState
  alias Huginnbuilder.Job
  alias Huginnbuilder.Endpoint

  def run(build) do
    build = Repo.preload(build, [:repository, :jobs])
    repository = Repo.preload(build.repository, :images)
    for job <- build.jobs do
      File.rm_rf "./builds/huginn"
      job = Repo.preload(job, :image)
      job = Repo.update!(Job.changeset(job, %{state: "running"}))

      image = job.image
      %StepState{repository: repository, job: job, build: build}
      |> step(:login)
      |> step(:clone)
      |> step(:update_cache)
      |> step(:build)
      |> step(:push)

      job = Repo.update!(Job.changeset(job, %{state: "success"}))
    end
  end

  def step(step_state = %StepState{status: :ok}, name = :login) do
    step_state
    |> start_step_processing(name)
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :clone) do
    step_state
    |> start_step_processing(name)
    |> run_command(name, "sleep 1; git clone --depth=1 https://github.com/cantino/huginn.git huginn")
    |> run_command(name, "cd huginn; git fetch origin pull/#{step_state.build.pull_request_id}/head:pr; git checkout pr")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :error}, name) do
    step_state
  end

  def write_step_state(step_state = %StepState{status: :ok}, name) do
    step_state
    |> update_step_state(Atom.to_string(name), "success")
  end

  def write_step_state(step_state = %StepState{status: :error}, name) do
    step_state
    |> update_step_state(Atom.to_string(name), "error")
  end

  def start_step_processing(step_state, name) do
    update_step_state(step_state, Atom.to_string(name), "running")
  end

  def step(step_state = %StepState{status: :ok}, name = :update_cache) do
    step_state
    |> start_step_processing(name)
    |> run_command(name, "docker pull #{step_state.job.image.cache_image}")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :build) do
    step_state
    |> start_step_processing(name)
    |> run_command(name, "cd huginn; docker build -t #{step_state.job.image.name}:pr-#{step_state.build.pull_request_id} -f #{step_state.job.image.dockerfile} #{step_state.job.image.context}")
    |> write_step_state(name)
  end

  def step(step_state = %StepState{status: :ok}, name = :push) do
    step_state
    |> start_step_processing(name)
    |> write_step_state(name)
  end

  def update_step_state(step_state = %StepState{}, name, value) do
    data = put_in(step_state.job.data, [name], %{state: value, output: String.split(step_state.output, "\n")})
    job = Repo.update!(Job.changeset(step_state.job, %{data: data}))
    Endpoint.broadcast("build:#{step_state.build.id}", "update_state", %{job_id: step_state.job.id, step: name, value: value})
    %StepState{ step_state | job: job, output: "" }
  end

  def run_command(step_state = %StepState{status: :ok}, name, cmd) do
    Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: "Running: " <> cmd})
    Task.async(fn ->
      Porcelain.spawn_shell("cd builds;" <> cmd <> " 2>&1",
                              in: :receive, out: {:send, self()}, err: {:send, self()})
      |> loop(name, step_state)
    end)
    |> Task.await(1200_000)
  end

  def run_command(step_state = %StepState{status: :error}, name, cmd) do
    IO.puts "run_command skipping: " <> cmd
    step_state
  end

  def loop(%Porcelain.Process{pid: pid} = proc, name, step_state, output \\ "") do
    receive do
      {^pid, :data, _, data} ->
        data
        |> String.split("\n")
        |> Enum.each(fn(row) -> Endpoint.broadcast("build:#{step_state.build.id}", "output", %{job_id: step_state.job.id, step: name, row: row}) end)
        loop(proc, name, step_state, output <> data)
      {^pid, :result, %Porcelain.Result{status: 0}} ->
        %StepState{ step_state | status: :ok, output: step_state.output <> output }
      {^pid, :result, %Porcelain.Result{status: status}} ->
        %StepState{ step_state | status: :error, output: step_state.output <> output }
    end
  end
end