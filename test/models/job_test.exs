defmodule Huginnbuilder.JobTest do
  use Huginnbuilder.ModelCase

  alias Huginnbuilder.Job

  @valid_attrs %{data: %{}, state: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Job.changeset(%Job{}, @invalid_attrs)
    refute changeset.valid?
  end
end
