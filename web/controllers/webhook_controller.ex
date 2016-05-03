defmodule Loadmaster.WebhookController do
  use Loadmaster.Web, :controller

  alias Loadmaster.Repository
  alias Loadmaster.Build
  alias Loadmaster.Job

  def handle(conn, %{"token" => token, "action" => action, "pull_request" => pull_request} = params) when action in ["opened", "synchronize", "reopened"] do
    repository =
      Repo.get_by!(Repository, token: token)
      |> Repo.preload(:images)

    build =
      repository
      |> build_assoc(:builds)
      |> Build.changeset(%{pull_request_id: pull_request["number"], git_remote: params["repository"]["clone_url"]})

    {:ok, build} = Repo.transaction fn ->
      build = Repo.insert!(build)
      for image <- repository.images do
        IO.inspect(image)
        initial_data = %{
          setup: %{state: "pending", output: []},
          login: %{state: "pending", output: []},
          clone: %{state: "pending", output: []},
          update_cache: %{state: "pending", output: []},
          build: %{state: "pending", output: []},
          push: %{state: "pending", output: []},
          teardown: %{state: "pending", output: []},
        }
        build
        |> build_assoc(:jobs)
        |> Job.changeset(%{image_id: image.id, state: "pending", data: initial_data})
        |> Repo.insert!
      end
      build
    end

    Loadmaster.Builder.build(build.id)

    conn
    |> put_status(200)
    |> json(:ok)
  end

  def handle(conn, %{"action" => action} = params) when action in ["closed"] do
    conn
    |> put_status(405)
    |> json(:ok)
  end

  def handle(conn, %{"action" => action} = params) do
    data = Poison.encode!(params)
    {epoch, sec, msec} = :erlang.timestamp()
    filename = Integer.to_string(epoch) <> Integer.to_string(sec) <> Integer.to_string(msec) <> ".json"
    File.write!(Loadmaster.Endpoint.config(:root) <> "/test/fixtures/" <> filename, data)
    conn
    |> put_status(501)
    |> json(:ok)
  end
end