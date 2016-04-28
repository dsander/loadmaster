defmodule Loadmaster.BuildController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Build
  alias Loadmaster.Repository

  plug :authenticate_user
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

  defp load_repository(%{params: %{"repository_id" => repository_id}} = conn, _opts) do
    repository =
      Repo.get!(Repository, repository_id)
      |> Repo.preload(:builds)
    assign(conn, :repository, repository)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.repository])
  end
end
