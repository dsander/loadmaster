defmodule Loadmaster.Repo.Migrations.AddCommitShaToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :commit_sha, :string
    end
  end
end
