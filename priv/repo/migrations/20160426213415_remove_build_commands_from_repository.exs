defmodule Huginnbuilder.Repo.Migrations.RemoveBuildCommandsFromRepository do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      remove :build_commands
    end
  end
end
