defmodule FlintUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :flint_ui,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20"},

      # Dev dependencies
      {:esbuild, "~> 0.8", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "compile"],
      "assets.build": ["esbuild default"]
    ]
  end
end
