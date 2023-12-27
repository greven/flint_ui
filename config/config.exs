import Config

config :phoenix,
  json_library: Jason

if Mix.env() == :dev do
  esbuild = fn args ->
    [
      args: ~w(./js/flint --bundle) ++ args,
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
  end

  config :esbuild,
    version: "0.19.10",
    default: esbuild.(~w(--format=esm --target=es2017 --outfile=../priv/static/flint.js))
end
