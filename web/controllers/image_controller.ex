defmodule Huginnbuilder.ImageController do
  use Huginnbuilder.Web, :controller

  alias Huginnbuilder.Image
  alias Huginnbuilder.Repository

  plug :scrub_params, "image" when action in [:create, :update]
  plug :authenticate_user
  plug :load_repository

  def index(conn, _params, repository) do
    images = Repo.all(Image)
    render(conn, "index.html", images: images)
  end

  def new(conn, _params, repository) do
    changeset =
      repository
      |> build_assoc(:images)
      |> Image.changeset

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"image" => image_params}, repository) do
    changeset =
      repository
      |> build_assoc(:images)
      |> Image.changeset(image_params)

    case Repo.insert(changeset) do
      {:ok, _image} ->
        conn
        |> put_flash(:info, "Image created successfully.")
        |> redirect(to: repository_image_path(conn, :index, repository))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, repository) do
    image = Repo.get!(Image, id)
    render(conn, "show.html", image: image)
  end

  def edit(conn, %{"id" => id}, repository) do
    image = Repo.get!(Image, id)
    changeset = Image.changeset(image)
    render(conn, "edit.html", image: image, changeset: changeset, repository: repository)
  end

  def update(conn, %{"id" => id, "image" => image_params}, repository) do
    image =Repo.get!(Image, id)
    changeset = Image.changeset(image, image_params)

    case Repo.update(changeset) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image updated successfully.")
        |> redirect(to: repository_image_path(conn, :index, repository))
      {:error, changeset} ->
        render(conn, "edit.html", image: image, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, repository) do
    image = Repo.get!(Image, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(image)

    conn
    |> put_flash(:info, "Image deleted successfully.")
    |> redirect(to: repository_image_path(conn, :index, repository))
  end


  defp load_repository(%{params: %{"repository_id" => repository_id}} = conn, _opts) do
    assign(conn, :repository, Repo.get!(Repository, repository_id))
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.repository])
  end
end
