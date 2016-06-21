defmodule Loadmaster.BuildController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Build

  plug :authenticate_user when action in [:run]

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
      Build
      |> Repo.get!(id)
      |> Repo.preload(jobs: :image)
    render(conn, "show.html", build: build)
  end

  @builder Application.get_env(:loadmaster, :builder) || Loadmaster.Builder
  def run(conn, %{"id" => id}) do
    build = Build.rerun(id)

    @builder.build(build.id)

    conn
    |> put_flash(:info, "Build was restarted.")
    |> turbolinks_redirect(to: repository_build_path(conn, :show, build.repository_id, build))
  end
end
