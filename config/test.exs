use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :loadmaster, Loadmaster.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :loadmaster, Loadmaster.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "loadmaster_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :loadmaster,
  command_executor: Loadmaster.TestExecutor,
  builder: LoadMaster.TestBuilder,
  command_runner: Loadmaster.TestCommandRunner

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
