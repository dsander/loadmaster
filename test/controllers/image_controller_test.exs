defmodule Loadmaster.ImageControllerTest do
  use Loadmaster.ConnCase
  import Loadmaster.TestHelpers

  alias Loadmaster.Image
  @valid_attrs %{cache_image: "some content", context: "some content", dockerfile: "some content", name: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user(username: "admin")
    conn = assign(conn(), :current_user, user)
    repository = insert_repository
    {:ok, conn: conn, user: user, repository: repository}
  end

  test "lists all entries on index", %{conn: conn, repository: repository} do
    conn = get conn, repository_image_path(conn, :index, repository)
    assert html_response(conn, 200) =~ "Listing images"
  end

  test "renders form for new resources", %{conn: conn, repository: repository} do
    conn = get conn, repository_image_path(conn, :new, repository)
    assert html_response(conn, 200) =~ "New image"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, repository: repository} do
    conn = post conn, repository_image_path(conn, :create, repository), image: @valid_attrs
    assert redirected_to(conn) == repository_image_path(conn, :index, repository)
    assert Repo.get_by(Image, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, repository: repository} do
    conn = post conn, repository_image_path(conn, :create, repository), image: @invalid_attrs
    assert html_response(conn, 200) =~ "New image"
  end

  test "renders form for editing chosen resource", %{conn: conn, repository: repository} do
    image = insert_image(repository)
    conn = get conn, repository_image_path(conn, :edit, repository, image)
    assert html_response(conn, 200) =~ "Edit image"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, repository: repository} do
    image = insert_image(repository)
    conn = put conn, repository_image_path(conn, :update, repository, image), image: @valid_attrs
    assert redirected_to(conn) == repository_image_path(conn, :index, repository)
    assert Repo.get_by(Image, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, repository: repository} do
    image = insert_image(repository)
    conn = put conn, repository_image_path(conn, :update, repository, image), image: %{name: ""}
    assert html_response(conn, 200) =~ "Edit image"
  end

  test "deletes chosen resource", %{conn: conn, repository: repository} do
    image = insert_image(repository)
    conn = delete conn, repository_image_path(conn, :delete, repository, image)
    assert redirected_to(conn) == repository_image_path(conn, :index, repository)
    refute Repo.get(Image, image.id)
  end
end
