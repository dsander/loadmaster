defmodule Loadmaster.Mixfile do
  use Mix.Project

  def project do
    [app: :loadmaster,
     version: "0.3.0",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Loadmaster, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :comeonin, :porcelain,
                    :tentacat]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:postgrex, "~> 0.13.0"},
     {:phoenix_ecto, "~> 3.2.0"},
     {:phoenix_html, "~> 2.9.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.13.0"},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 3.0"},
     {:distillery, "~> 1.4"},
     {:porcelain, "~> 2.0"},
     {:excoveralls, "~> 0.5", only: :test},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:edib, "~>  0.10.0", only: :dev},
     {:credo, "~> 0.8.0-rc4", only: [:dev, :test]},
     {:tentacat, "~> 0.5"},
     {:erlware_commons, "0.21.0"}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
    "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
