Code.require_file "test/test_command_runner.ex"
Code.require_file "test/test_builder.ex"
Code.require_file "test/test_executor.ex"

ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Loadmaster.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Loadmaster.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Loadmaster.Repo)
