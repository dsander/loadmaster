defmodule Loadmaster.RepositoryController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Repository

  plug :scrub_params, "repository" when action in [:create, :update]
  plug :authenticate_user when action in [:show, :new, :create, :edit, :update, :delete]

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
end
