defmodule Loadmaster.GithubStatus do
  use GenServer
  alias Loadmaster.Repo

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def update(job_id, state) do
    GenServer.cast(__MODULE__, {:update, job_id, state})
  end

  def handle_cast({:update, job_id, status}, state) do
    job = Loadmaster.Job
      |> Repo.get!(job_id)
      |> Repo.preload([[build: :repository], :image])

    update_status(%{build: job.build, repository: job.build.repository, image: job.image}, status)

    {:noreply, state}
  end

  defp update_status(%{build: build, repository: repository} = models, status) do
    {user, repo} = Loadmaster.Build.split_git_remote(build)

    client = Tentacat.Client.new(%{access_token: repository.github_token})
    Tentacat.Repositories.Statuses.create user, repo, build.commit_sha, body(models, status), client
  end

  defp body(%{build: build, repository: repository, image: image}, %{state: pr_state, message: message}) do
    %{
      "state": pr_state,
      "target_url": "http://#{Application.get_env(:loadmaster, :domain)}/repositories/#{repository.id}/builds/#{build.id}",
      "description": message,
      "context": "#{image.name}:pr-#{build.pull_request_id}"
    }
  end
end
