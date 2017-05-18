defmodule Loadmaster.User do
  use Loadmaster.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :invitation_token, :string, virtual: true

    timestamps
  end

  @required_fields ~w(username email password)
  @optional_fields ~w(invitation_token)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def registration_changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> validate_invitation_token
    |> hash_password
  end

  def update_changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> hash_password
  end

  def validate_invitation_token(model) do
    token = Application.get_env(:loadmaster, :invitation_token)
    case model do
      %Ecto.Changeset{changes: %{invitation_token: ^token}} ->
        model
      _ ->
        add_error(model, :invitation_token, "is invalid")
    end
  end

  def hash_password(model) do
    case model do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(model, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        model
    end
  end
end
