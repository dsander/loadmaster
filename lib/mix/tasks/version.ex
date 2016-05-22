defmodule Mix.Tasks.Loadmaster.Version do
  use Mix.Task

  def run(_) do
    IO.puts Mix.Project.config[:version]
  end
end
