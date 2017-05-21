defmodule Loadmaster.BuildControllerTest do
  use Loadmaster.ConnCase

  setup do
    user = insert_user(username: "admin")
    conn = assign(build_conn(), :current_user, user)
    repository = insert_repository()
    {:ok, conn: conn, user: user, repository: repository}
  end

  test "renders a list of all builds for the repository", %{conn: conn, user: _user, repository: repository} do
    insert_build(repository)
    conn = get conn, repository_build_path(conn, :index, repository)

    assert html_response(conn, 200) =~ "Listing builds"
  end

  test "it shows a specific build", %{conn: conn, user: _user, repository: repository} do
    build = insert_build(repository)
    conn = get conn, repository_build_path(conn, :show, repository, build)

    assert html_response(conn, 200) =~ "Build #{build.id}"
  end

  test "it restarts a build successfully", %{conn: conn, user: _user, repository: repository}  do
    build = insert_build(repository)
    image = insert_image(repository)
    insert_job(build, image)

    conn = post conn, repository_build_path(conn, :run, repository, build)

    assert get_flash(conn, :info) == "Build was restarted."
    assert redirected_to(conn) == repository_build_path(conn, :show, repository, build)
  end
end
