defmodule Huginnbuilder.BuildTest do
  use Huginnbuilder.ModelCase

  alias Huginnbuilder.Build

  @valid_attrs %{pull_request_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Build.changeset(%Build{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Build.changeset(%Build{}, @invalid_attrs)
    refute changeset.valid?
  end
end
