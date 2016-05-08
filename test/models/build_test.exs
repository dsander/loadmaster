defmodule Loadmaster.BuildTest do
  use Loadmaster.ModelCase

  alias Loadmaster.Build

  @valid_attrs %{pull_request_id: 42, git_remote: "git://github.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset =
      insert_repository
      |> build_assoc(:builds)
      |> Build.changeset(@valid_attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Build.changeset(%Build{}, @invalid_attrs)
    refute changeset.valid?
  end
end
