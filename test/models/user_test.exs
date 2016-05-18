defmodule Loadmaster.UserTest do
  use Loadmaster.ModelCase

  alias Loadmaster.User

  @valid_attrs %{email: "email", password: "password", username: "username", invitation_token: "try-loadmaster"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.registration_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid invitation_token" do
    changeset = User.registration_changeset(%User{}, %{ @valid_attrs | invitation_token: "invalid" })
    refute changeset.valid?
  end
end
