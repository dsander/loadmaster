defmodule Huginnbuilder.Repository do
  use Huginnbuilder.Web, :model

  schema "repositories" do
    field :token, :string
    field :docker_user, :string
    field :docker_email, :string
    field :docker_password, :string
    field :build_commands, :string

    timestamps
  end

  @required_fields ~w(docker_user docker_email docker_password build_commands)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model) do
    model
    |> cast(:empty, @required_fields, @optional_fields)
    |> IO.inspect
  end

  def changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> stuff
  end

  def stuff(changeset) do
    IO.inspect changeset
    put_change(changeset, :token, random_string(32))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
