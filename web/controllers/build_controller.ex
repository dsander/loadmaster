defmodule Loadmaster.BuildController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Build
  alias Loadmaster.Repository
  alias Loadmaster.Job

  plug :authenticate_user

  def index(conn, %{"repository_id" => repository_id}) do
    builds =
      Build
      |> Build.for_repository(repository_id)
      |> Build.sorted
      |> Repo.all

    render(conn, "index.html", builds: builds)
  end

  def show(conn, %{"id" => id}) do
    build =
      Repo.get!(Build, id)
      |> Repo.preload(jobs: :image)
    render(conn, "show.html", build: build)
  end

  @builder Application.get_env(:loadmaster, :builder) || Loadmaster.Builder
  def run(conn, %{"id" => id}) do
    build =
      Repo.get!(Build, id)
      |> Repo.preload(jobs: :image)

    {:ok, _} = Repo.transaction fn ->
      for job <- build.jobs do
        initial_data = %{
          setup: %{state: "pending", output: []},
          login: %{state: "pending", output: []},
          clone: %{state: "pending", output: []},
          update_cache: %{state: "pending", output: []},
          build: %{state: "pending", output: []},
          push: %{state: "pending", output: []},
          teardown: %{state: "pending", output: []},
        }
        Job.changeset(job, %{image_id: job.image.id, state: "pending", data: initial_data})
        |> Repo.update!
      end
    end

    @builder.build(build.id)

    conn
    |> put_flash(:info, "Build was restarted.")
    |> redirect(to: repository_build_path(conn, :show, build.repository_id, build))
  end
end
