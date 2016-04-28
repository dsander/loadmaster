defmodule Loadmaster.Repo.Migrations.CreateJob do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :state, :string
      add :data, :map
      add :build_id, references(:builds, on_delete: :delete_all)
      add :image_id, references(:images, on_delete: :delete_all)

      timestamps
    end
    create index(:jobs, [:build_id])
    create index(:jobs, [:image_id])

  end
end
