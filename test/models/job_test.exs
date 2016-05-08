defmodule Loadmaster.JobTest do
  use Loadmaster.ModelCase

  alias Loadmaster.Job

  @valid_attrs %{data: %{}, state: "pending"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    repository = insert_repository
    build = insert_build(repository)
    image = insert_image(repository)
    changeset = Job.changeset(%Job{}, Dict.merge(@valid_attrs, build_id: build.id, image_id: image.id))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Job.changeset(%Job{}, @invalid_attrs)
    refute changeset.valid?
  end
end
