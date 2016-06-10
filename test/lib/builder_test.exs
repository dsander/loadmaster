defmodule Loadmaster.BuilderRunnerTest do
  use Loadmaster.ModelCase

  setup do
    repository = insert_repository
    build = insert_build(repository)
    image = insert_image(repository)
    insert_job(build, image)
    {:ok, build: build}
  end

  test "enqueues the builds jobs without errors", %{build: build} do
    Loadmaster.Builder.build(build.id)
  end
end