import Config

if Mix.env() == :dev do
  esbuild = fn args ->
    [
      args: ~w(./js --bundle) ++ args,
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
  end

  config :esbuild,
    version: "0.19.10",
    default: esbuild.(~w(--format=esm --target=es2017 --outfile=../priv/static/flint.js))

  config :tailwind,
    version: "3.4.0",
    default: [
      args: ~w(
        --config=tailwind.config.js
        --input=css/flint.css
        --output=../priv/static/flint.css
      ),
      cd: Path.expand("../assets", __DIR__)
    ]
end
