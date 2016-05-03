defmodule Loadmaster.Repo.Migrations.AddGitRemoteToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :git_remote, :string
    end
  end
end
