defmodule Loadmaster.Repository do
  use Loadmaster.Web, :model

  schema "repositories" do
    field :token, :string
    field :docker_user, :string
    field :docker_email, :string
    field :docker_password, :string
    has_many :images, Loadmaster.Image
    has_many :builds, Loadmaster.Build

    timestamps
  end

  @required_fields ~w(docker_user docker_email docker_password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model) do
    model
    |> cast(:empty, @required_fields, @optional_fields)
  end

  def changeset(model = %{token: nil}, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> create_token
  end

  def changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def create_token(model) do
    put_change(model, :token, random_string(32))
  end

  defp random_string(string_length) do
    string_length |> :crypto.strong_rand_bytes |> Base.url_encode64 |> binary_part(0, string_length)
  end
end
