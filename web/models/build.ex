defmodule Loadmaster.Build do
  use Loadmaster.Web, :model
  alias Loadmaster.Repo
  alias Loadmaster.Build
  alias Loadmaster.Job

  schema "builds" do
    field :pull_request_id, :integer
    field :git_remote, :string
    field :commit_sha, :string
    belongs_to :repository, Loadmaster.Repository
    has_many :jobs, Loadmaster.Job

    timestamps()
  end

  @required_fields [:pull_request_id, :repository_id, :git_remote, :commit_sha]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:repository)
  end

  def for_repository(query, repository_id) do
    from p in query, where: p.repository_id == ^repository_id
  end

  def sorted(query) do
    from p in query, order_by: [desc: :id]
  end

  def run(build, repository) do
    {:ok, build} = Repo.transaction fn ->
      build = Repo.insert!(build)
      for image <- repository.images do
        build
        |> build_assoc(:jobs)
        |> Job.create_changeset(%{image_id: image.id, state: "pending"})
        |> Repo.insert!
      end
      build
    end
    build
  end

  def rerun(id) do
    build =
      Build
      |> Repo.get!(id)
      |> Repo.preload(:jobs)

    {:ok, _} = Repo.transaction fn ->
      for job <- build.jobs do
        job
        |> Job.create_changeset(%{state: "pending"})
        |> Repo.update!
      end
    end
    build
  end

  def split_git_remote(%Build{git_remote: git_remote}) do
    %{"user" => user, "repository" => repository} = Regex.named_captures(~r/\/(?<user>[^\/]+)\/(?<repository>[^\/]+)\.git\z/, git_remote)
    {user, repository}
  end
end
