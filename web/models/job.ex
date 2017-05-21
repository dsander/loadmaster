defmodule Loadmaster.Job do
  use Loadmaster.Web, :model

  schema "jobs" do
    field :state, :string
    field :data, :map
    belongs_to :build, Loadmaster.Build
    belongs_to :image, Loadmaster.Image

    timestamps()
  end

  @required_fields [:state, :data, :image_id, :build_id]
  @initial_data %{
                  setup: %{state: "pending", output: []},
                  login: %{state: "pending", output: []},
                  clone: %{state: "pending", output: []},
                  update_cache: %{state: "pending", output: []},
                  build: %{state: "pending", output: []},
                  push: %{state: "pending", output: []},
                  teardown: %{state: "pending", output: []},
                }
  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:build)
    |> assoc_constraint(:image)
  end

  def create_changeset(model, params) do
    model
    |> cast(params, [:state, :image_id, :build_id])
    |> put_change(:data, @initial_data)
    |> validate_required(@required_fields)
    |> assoc_constraint(:build)
    |> assoc_constraint(:image)
  end
end
