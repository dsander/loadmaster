defmodule Loadmaster.ImageTest do
  use Loadmaster.ModelCase

  alias Loadmaster.Image

  @valid_attrs %{cache_image: "some content", context: "some content", dockerfile: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Image.changeset(%Image{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Image.changeset(%Image{}, @invalid_attrs)
    refute changeset.valid?
  end
end
