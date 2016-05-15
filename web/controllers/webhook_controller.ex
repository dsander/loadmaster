defmodule Loadmaster.WebhookController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Repository
  alias Loadmaster.Build

  @builder Application.get_env(:loadmaster, :builder) || Loadmaster.Builder
  def handle(conn, %{"token" => token, "action" => action, "pull_request" => pull_request} = params) when action in ["opened", "synchronize", "reopened"] do
    repository =
      Repository
      |> Repo.get_by!(token: token)
      |> Repo.preload(:images)

    build =
      repository
      |> build_assoc(:builds)
      |> Build.changeset(%{pull_request_id: pull_request["number"], git_remote: params["repository"]["clone_url"]})
      |> Build.run(repository)

    @builder.build(build.id)

    conn
    |> put_status(200)
    |> json(:ok)
  end

  def handle(conn, %{"action" => action}) when action in ["closed"] do
    conn
    |> put_status(405)
    |> json(:ok)
  end

  def handle(conn, %{"action" => _} = params) do
    if System.get_env("MIX_ENV") == "prod" do
      conn
      |> put_status(405)
      |> json(:ok)
    else
      data = Poison.encode!(params)
      {epoch, sec, msec} = :erlang.timestamp()
      filename = Integer.to_string(epoch) <> Integer.to_string(sec) <> Integer.to_string(msec) <> ".json"
      File.write!(Loadmaster.Endpoint.config(:root) <> "/test/fixtures/" <> filename, data)
      conn
      |> put_status(501)
      |> json(%{debug_filename: filename})
    end
  end
end
