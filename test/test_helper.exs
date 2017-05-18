Code.require_file "test/test_command_runner.ex"
Code.require_file "test/test_builder.ex"
Code.require_file "test/test_executor.ex"

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Loadmaster.Repo, :manual)
