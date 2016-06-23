defmodule Loadmaster.RepositoryTest do
  use Loadmaster.ModelCase

  alias Loadmaster.Repository

  @valid_attrs %{build_commands: "some content", docker_email: "some content", docker_password: "some content", docker_user: "some content", token: "some content", name: "test"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Repository.changeset(%Repository{}, @invalid_attrs)
    refute changeset.valid?
  end
end
