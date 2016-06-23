defmodule Loadmaster.RepositoryControllerTest do
  use Loadmaster.ConnCase
  import Loadmaster.TestHelpers

  alias Loadmaster.Repository
  @valid_attrs %{docker_email: "some content", docker_password: "some content", docker_user: "some content", name: "test"}
  @invalid_attrs %{}

  setup do
    user = insert_user(username: "admin")
    conn = assign(conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, repository_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing repositories"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, repository_path(conn, :new)
    assert html_response(conn, 200) =~ "New repository"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, repository_path(conn, :create), repository: @valid_attrs
    assert redirected_to(conn) == repository_path(conn, :index)
    assert Repo.get_by(Repository, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, repository_path(conn, :create), repository: @invalid_attrs
    assert html_response(conn, 200) =~ "New repository"
  end

  test "shows chosen resource", %{conn: conn} do
    repository = insert_repository(@valid_attrs)
    conn = get conn, repository_path(conn, :show, repository)
    assert html_response(conn, 200) =~ "Show repository"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, repository_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = get conn, repository_path(conn, :edit, repository)
    assert html_response(conn, 200) =~ "Edit repository"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    repository = insert_repository(@valid_attrs)
    conn = put conn, repository_path(conn, :update, repository), repository: @valid_attrs
    assert redirected_to(conn) == repository_path(conn, :show, repository)
    assert Repo.get_by(Repository, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = put conn, repository_path(conn, :update, repository), repository: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit repository"
  end

  test "deletes chosen resource", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = delete conn, repository_path(conn, :delete, repository)
    assert redirected_to(conn) == repository_path(conn, :index)
    refute Repo.get(Repository, repository.id)
  end
end
