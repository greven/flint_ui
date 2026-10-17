defmodule FlintUI.MixProject do
  use Mix.Project

  def project do
    [
      app: :flint_ui,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers() ++ [:flint_theme],
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
      {:igniter, "~> 0.6", optional: true},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:ex_doc, "~> 0.40", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["cmd npm install --prefix assets"],
      "assets.build": ["cmd npm run build --prefix assets"],
      "assets.watch": ["cmd npm start --prefix assets"],
      "docs.setup": [
        "deps.get",
        "assets.setup",
        "assets.build",
        "cmd --cd docs mix deps.get",
        "cmd --cd docs mix assets.setup",
        "cmd --cd docs mix assets.build"
      ]
    ]

    # The docs site is its own Phoenix app; run it from its own directory:
    #   cd docs && mix phx.server
    # (wrapping it in `mix cmd` here would spawn the server in a separate OS
    # session, so Ctrl+C could not stop it and it would be left on the port.)
  end
end
