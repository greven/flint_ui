# FlintUi

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `flint_ui` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flint_ui, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/flint_ui>.

## Development

The library and the docs site are two separate Mix projects. Run each from its
own directory (`mix` is on `PATH` via `mise exec --`):

```sh
mise exec -- mix test                 # library
cd docs && mise exec -- mix phx.server # docs site (http://localhost:4000)
```

Don't wrap the docs server in a root Mix alias: `mix cmd` runs it in a separate
OS session, so Ctrl+C can't stop it and it is left listening on the port.

