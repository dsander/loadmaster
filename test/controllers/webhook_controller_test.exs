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

    assert json_response(conn, 501)
    %{"debug_filename" => filename} = json_response(conn, 501)
    File.rm!(Loadmaster.Endpoint.config(:root) <> "/test/fixtures/" <> filename)
  end

  test "it does not save received data when MIX_ENV is set to 'prod'", %{conn: conn, repository: repository} do
    prev_env = System.get_env("MIX_ENV")
    System.put_env("MIX_ENV", "prod")
    conn = post conn, webhook_path(conn, :handle, repository.token), %{"action" => "unknown"}

    assert json_response(conn, 405) == "ok"
    if prev_env do
      System.put_env("MIX_ENV", prev_env)
    else
      System.delete_env("MIX_ENV")
    end
  end

  test "handle starts a build when needed", %{conn: conn, repository: repository} do
    insert_image(repository)
    conn = post conn, webhook_path(conn, :handle, repository.token), %{"action" => "opened", "pull_request" => %{"number" => 1234, "head" => %{"sha" => "4e31309c3441f0f7ab2b3baca5f68d43e32657d4"}}, "repository" => %{"clone_url" => "git://my_clone_url"}}
    assert json_response(conn, 200) == "ok"

    build = Repo.one(from b in Loadmaster.Build, order_by: [desc: b.id], limit: 1)
    assert build.git_remote == "git://my_clone_url"
    assert build.commit_sha == "4e31309c3441f0f7ab2b3baca5f68d43e32657d4"
  end
end
