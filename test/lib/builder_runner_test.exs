defmodule Loadmaster.BuilderRunnerTest do
  use Loadmaster.ModelCase

  setup do
    repository = insert_repository
    build = insert_build(repository)
    image = insert_image(repository)
    insert_job(build, image)
    {:ok, build: build}
  end

  test "runs the build without actually doing anything", %{build: build} do
    [job] = Loadmaster.BuildRunner.run(build.id)
    job = Repo.get!(Loadmaster.Job, job.id)
    assert job.state == "success"
    assert job.data == %{"build" => %{"output" => [""], "state" => "success"},
                         "clone" => %{"output" => [""], "state" => "success"},
                          "login" => %{"output" => [""], "state" => "success"},
                          "push" => %{"output" => [""], "state" => "success"},
                          "setup" => %{"output" => [""], "state" => "success"},
                          "teardown" => %{"output" => [""], "state" => "success"}}
  end
end
