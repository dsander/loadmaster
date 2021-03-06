defmodule Loadmaster.UserController do
  use Loadmaster.Web, :controller

  alias Loadmaster.User
  alias Loadmaster.Auth
  alias Loadmaster.Router.Helpers

  plug :scrub_params, "user" when action in [:create, :update]
  plug :authenticate_user when action in [:index, :show]
  plug :user_owned when action in [:edit, :update, :delete]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.update_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end

  def user_owned(conn = %{params: %{"id" => id}}, _opts) do
    if conn.assigns.current_user.id != String.to_integer(id) do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt
    else
      conn
    end
  end
end
