defmodule Loadmaster.Image do
  use Loadmaster.Web, :model

  schema "images" do
    field :name, :string
    field :cache_image, :string
    field :dockerfile, :string
    field :context, :string
    belongs_to :repository, Loadmaster.Repository
    has_many :jobs, Loadmaster.Job

    timestamps()
  end

  @fields [:name, :cache_image, :dockerfile, :context, :repository_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:repository)
  end
end
