defmodule Loadmaster.Repo.Migrations.CreateRepository do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :token, :string
      add :docker_user, :string
      add :docker_email, :string
      add :docker_password, :string
      add :build_commands, :text

      timestamps
    end

  end
end
