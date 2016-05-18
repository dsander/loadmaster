defmodule Loadmaster.TestHelpers do
  alias Loadmaster.Repo
  import Ecto

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      username: "User #{Base.encode16((:crypto.rand_bytes(8)))}",
      email: "#{Base.encode16((:crypto.rand_bytes(8)))}@example.com",
      password: "secret",
      invitation_token: "try-loadmaster"
    }, attrs)

    %Loadmaster.User{}
    |> Loadmaster.User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_repository(attrs \\ %{docker_email: "some content", docker_password: "some content", docker_user: "some content"}) do
    %Loadmaster.Repository{}
    |> Loadmaster.Repository.changeset(attrs)
    |> Repo.insert!
  end

  def insert_build(repository \\ insert_repository, attrs \\ %{pull_request_id: 42, git_remote: "git://github.com"}) do
    repository
    |> build_assoc(:builds)
    |> Loadmaster.Build.changeset(attrs)
    |> Repo.insert!
  end

  def insert_image(repository \\ insert_repository, attrs \\ %{cache_image: "some content", context: "some content", dockerfile: "some content", name: "some content"}) do
    %Loadmaster.Image{}
    |> Loadmaster.Image.changeset(Dict.merge(attrs, repository_id: repository.id))
    |> Repo.insert!
  end

  def insert_job(build \\ insert_build, image \\ insert_image, attrs \\ %{state: "pending", data: %{}}) do
    %Loadmaster.Job{}
    |> Loadmaster.Job.changeset(Dict.merge(attrs, build_id: build.id, image_id: image.id))
    |> Repo.insert!
  end
end
