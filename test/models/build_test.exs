defmodule Loadmaster.BuildTest do
  use Loadmaster.ModelCase

  alias Loadmaster.Build

  @valid_attrs %{pull_request_id: 42, git_remote: "git://github.com", commit_sha: "dasda3423423lkj"}
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

  test "parses the git_remote into user and repository name" do
    {user, repository} = Build.split_git_remote(%Build{git_remote: "git://github.com/dsander/huginn.git"})
    assert user == "dsander"
    assert repository == "huginn"
  end
end
