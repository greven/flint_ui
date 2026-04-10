defmodule FlintUI.MixProject do
  use Mix.Project

  def project do
    [
      app: :flint_ui,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:phoenix, "~> 1.8.5"},
      {:phoenix_live_view, "~> 1.1.28"},
      {:ex_doc, "~> 0.40", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["cmd npm install --prefix assets"],
      "assets.build": ["cmd npm run build --prefix assets"],
      "assets.watch": ["cmd npm start --prefix assets"]
    ]
  end
end
