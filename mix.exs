defmodule LevantarVuelo.MixProject do
  use Mix.Project

  def project do
    [
      app: :levantar_vuelo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {LevantarVuelo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.3"},
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8.3"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
