defmodule Loadmaster do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Loadmaster.Endpoint, []),
      # Start the Ecto repository
      supervisor(Loadmaster.Repo, []),
      supervisor(Loadmaster.Builder, [%{}]),
      supervisor(Loadmaster.JobSupervisor, []),
      worker(Loadmaster.JobQueue, [])
      # Here you could define other workers and supervisors as children
      # worker(Loadmaster.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Loadmaster.Supervisor]
    start_link = Supervisor.start_link(children, opts)

    if Application.get_env(:loadmaster, :migrate_on_boot) && System.get_env("DO_NOT_MIGRATE") == nil do
      migrate
    end

    start_link
  end

  defp migrate do
    migrations = Path.join([:code.priv_dir(:loadmaster), "repo", "migrations"])
    IO.puts "######### running migrations..."
    Ecto.Migrator.run(Loadmaster.Repo, migrations, :up, all: true)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Loadmaster.Endpoint.config_change(changed, removed)
    :ok
  end
end
