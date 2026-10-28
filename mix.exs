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
      aliases: aliases(),
      package: package(),
      description: "Accessible, unstyled Phoenix LiveView components with a CSS theme layer"
    ]
  end

  # The JS bundles and declarations under priv/static are build artifacts (the
  # directory is gitignored). Listing the two bundles explicitly makes
  # `mix hex.build`/`mix hex.publish` fail with "Missing files" unless
  # `mix assets.build` ran first; `priv` still packages the rest of the output.
  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/greven/flint_ui"},
      files: ~w(
        lib
        priv
        priv/static/flint.js
        priv/static/flint-sound.js
        mix.exs
        package.json
        .formatter.exs
        README.md
        LICENSE.md
        NOTICE.md
      )
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
      {:phoenix, "~> 1.8.16"},
      {:phoenix_live_view, "~> 1.2.13"},
      {:igniter, "~> 0.8", optional: true},
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
