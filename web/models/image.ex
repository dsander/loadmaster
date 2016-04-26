defmodule Huginnbuilder.Image do
  use Huginnbuilder.Web, :model

  schema "images" do
    field :name, :string
    field :cache_image, :string
    field :dockerfile, :string
    field :context, :string
    belongs_to :repository, Huginnbuilder.Repository
    has_many :jobs, Huginnbuilder.Job

    timestamps
  end

  @required_fields ~w(name cache_image dockerfile context)
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
end
