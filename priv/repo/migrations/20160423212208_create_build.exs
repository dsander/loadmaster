defmodule Loadmaster.Repo.Migrations.CreateBuild do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :pull_request_id, :integer
      add :repository_id, references(:repositories, on_delete: :delete_all)

      timestamps
    end
    create index(:builds, [:repository_id])

  end
end
