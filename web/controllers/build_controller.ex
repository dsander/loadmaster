defmodule Loadmaster.BuildController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Build
  alias Loadmaster.Repository
  alias Loadmaster.Job

  plug :authenticate_user, except: :run
  plug :load_repository

  def index(conn, _params, repository) do
    render(conn, "index.html", builds: repository.builds)
  end

  def show(conn, %{"id" => id}, repository) do
    build =
      Repo.get!(Build, id)
      |> Repo.preload(jobs: :image)
    render(conn, "show.html", build: build)
  end

  def run(conn, %{"id" => id}, repository) do
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

    Loadmaster.Builder.build(build.id)

    conn
    |> put_flash(:info, "Started!!!")
    |> redirect(to: repository_build_path(conn, :show, build.repository_id, build))
  end

  defp action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.repository])
  end

  defp load_repository(%{params: %{"repository_id" => repository_id}} = conn, _opts) do
    repository =
      Repo.get!(Repository, repository_id)
      |> Repo.preload(:builds)
    assign(conn, :repository, repository)
  end
end
