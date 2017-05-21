defmodule Loadmaster.BuildRunner do
  alias Loadmaster.Repo
  alias Loadmaster.Build
  import Ecto.Query, only: [from: 2]

  def run(build_id) do
    build =
      Build
      |> Repo.get!(build_id)
      |> Repo.preload(jobs: from(j in Loadmaster.Job, order_by: j.image_id))

    for job <- build.jobs do
      Loadmaster.JobQueue.enqueue(job.id)
    end
    build.jobs
  end
end
