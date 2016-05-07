defmodule Loadmaster.Build do
  use Loadmaster.Web, :model

  schema "builds" do
    field :pull_request_id, :integer
    field :git_remote, :string
    belongs_to :repository, Loadmaster.Repository
    has_many :jobs, Loadmaster.Job

    timestamps
  end

  @required_fields ~w(pull_request_id repository_id git_remote)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:repository)
  end

  def for_repository(query, repository_id) do
    from p in query, where: p.repository_id == ^repository_id
  end

  def sorted(query) do
    from p in query, order_by: [desc: :id]
  end
end
