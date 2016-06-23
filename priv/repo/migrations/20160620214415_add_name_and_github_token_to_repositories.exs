defmodule Loadmaster.Repo.Migrations.AddNameAndGithubTokenToRepositories do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :name, :string
      add :github_token, :string
    end
  end
end
