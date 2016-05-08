defmodule Loadmaster.UserTest do
  use Loadmaster.ModelCase

  alias Loadmaster.User

  @valid_attrs %{email: "email", password: "password", username: "username", invitation_token: "hello"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
