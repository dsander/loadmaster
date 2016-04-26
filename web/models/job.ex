defmodule Huginnbuilder.Job do
  use Huginnbuilder.Web, :model

  schema "jobs" do
    field :state, :string
    field :data, :map
    belongs_to :build, Huginnbuilder.Build
    belongs_to :image, Huginnbuilder.Image

    timestamps
  end

  @required_fields ~w(state data image_id build_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:build)
    |> assoc_constraint(:image)
  end
end
