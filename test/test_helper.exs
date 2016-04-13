ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Huginnbuilder.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Huginnbuilder.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Huginnbuilder.Repo)

