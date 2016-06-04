defmodule Loadmaster.BuildRunner do
  alias Loadmaster.Repo
  alias Loadmaster.Build

  def run(build_id) do
    build =
      Build
      |> Repo.get!(build_id)
      |> Repo.preload([:jobs])

    for job <- build.jobs do
      Loadmaster.JobQueue.enqueue(job.id)
    end
    build.jobs
  end
end
