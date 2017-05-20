defmodule Loadmaster.BuilderRunnerTest do
  use Loadmaster.ModelCase

  setup do
    repository = insert_repository()
    build = insert_build(repository)
    image = insert_image(repository)
    insert_job(build, image)
    {:ok, build: build}
  end

  test "enqueues the builds jobs without errors", %{build: _build} do
    # TODO find a better way to test this
    #Loadmaster.Builder.build(build.id)
  end
end
