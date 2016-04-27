defmodule Huginnbuilder.RepositoryController do
  use Huginnbuilder.Web, :controller

  alias Huginnbuilder.Repository
  alias Huginnbuilder.Build
  alias Huginnbuilder.Job

  plug :scrub_params, "repository" when action in [:create, :update]
  plug :authenticate_user

  def index(conn, _params) do
    repositories = Repo.all(Repository)
    render(conn, "index.html", repositories: repositories)
  end

  def new(conn, _params) do
    changeset = Repository.changeset(%Repository{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"repository" => repository_params}) do
    changeset = Repository.changeset(%Repository{}, repository_params)

    case Repo.insert(changeset) do
      {:ok, _repository} ->
        conn
        |> put_flash(:info, "Repository created successfully.")
        |> redirect(to: repository_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    repository = Repo.get!(Repository, id)
    render(conn, "show.html", repository: repository)
  end

  def edit(conn, %{"id" => id}) do
    repository = Repo.get!(Repository, id)
    changeset = Repository.changeset(repository)
    render(conn, "edit.html", repository: repository, changeset: changeset)
  end

  def update(conn, %{"id" => id, "repository" => repository_params}) do
    repository = Repo.get!(Repository, id)
    changeset = Repository.changeset(repository, repository_params)

    case Repo.update(changeset) do
      {:ok, repository} ->
        conn
        |> put_flash(:info, "Repository updated successfully.")
        |> redirect(to: repository_path(conn, :show, repository))
      {:error, changeset} ->
        render(conn, "edit.html", repository: repository, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    repository = Repo.get!(Repository, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(repository)

    conn
    |> put_flash(:info, "Repository deleted successfully.")
    |> redirect(to: repository_path(conn, :index))
  end

  def run(conn, %{"id" => id}) do
    repository =
      Repo.get!(Repository, id)
      |> Repo.preload(:images)

    build =
      repository
      |> build_assoc(:builds)
      |> Build.changeset(%{pull_request_id: 1446})

    {:ok, build} = Repo.transaction fn ->
      build = Repo.insert!(build)
      for image <- repository.images do
        IO.inspect(image)
        initial_data = %{
          login: %{state: "pending", output: []},
          clone: %{state: "pending", output: []},
          update_cache: %{state: "pending", output: []},
          build: %{state: "pending", output: []},
          push: %{state: "pending", output: []},
        }
        build
        |> build_assoc(:jobs)
        |> Job.changeset(%{image_id: image.id, state: "pending", data: initial_data})
        |> Repo.insert!
      end
      build
    end

    Huginnbuilder.Builder.build(build, "https://github.com/cantino/huginn.git")

    conn
    |> put_flash(:info, "Started!!!")
    |> redirect(to: repository_build_path(conn, :show, repository, build))
    #render(conn, "run.html", repository: repository)
  end
end
