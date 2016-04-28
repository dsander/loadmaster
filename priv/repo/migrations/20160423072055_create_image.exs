defmodule Loadmaster.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :string
      add :cache_image, :string
      add :dockerfile, :string
      add :context, :string
      add :repository_id, references(:repositories, on_delete: :delete_all)

      timestamps
    end
    create index(:images, [:repository_id])

  end
end
