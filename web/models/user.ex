defmodule Huginnbuilder.User do
  use Huginnbuilder.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :invitation_token, :string, virtual: true

    timestamps
  end

  @required_fields ~w(username email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
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

  def validate_invitation_token(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{invitation_token: "hello"}} ->
        changeset
      _ ->
        add_error(changeset, :invitation_token, "is invalid")
    end
  end

  def hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
