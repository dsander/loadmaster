defmodule Loadmaster.WebhookControllerTest do
  use Loadmaster.ConnCase

  setup do
    user = insert_user(username: "admin")
    conn = assign(conn(), :current_user, user)
    repository = insert_repository

    {:ok, conn: conn, user: user, repository: repository}
  end

  test "handle responds with 405 when the action is not handled", %{conn: conn, repository: repository} do
    conn = post conn, webhook_path(conn, :handle, repository.token), %{"action" => "closed"}

    assert json_response(conn, 405) == "ok"
  end

  test "handle responds with 501 when an action is not implemented", %{conn: conn, repository: repository} do
    conn = post conn, webhook_path(conn, :handle, repository.token), %{"action" => "unknown"}

    assert json_response(conn, 501) == "ok"
  end

  test "handle starts a build when needed", %{conn: conn, repository: repository} do
    image = insert_image(repository)
    conn = post conn, webhook_path(conn, :handle, repository.token), %{"action" => "opened", "pull_request" => %{"number" => 1234}, "repository" => %{"clone_url" => "git://my_clone_url"}}

    assert json_response(conn, 200) == "ok"
  end
end
