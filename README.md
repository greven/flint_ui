# FlintUI

Accessible, unstyled UI components for Phoenix LiveView, plus a styled layer
you generate into your own application.

FlintUI ships two layers:

- **Base** — headless `FlintUI.*` components with accessible markup, ARIA
  state, and keyboard behavior. They ship no CSS.
- **Styled** — thin wrappers generated with `mix flint.add`. They map a small
  set of presentational props onto `data-*` hooks and delegate behavior to the
  base. You own and can edit the generated code.

Theming is plain CSS built from `--fl-*` tokens, so Tailwind is optional.

## Installation

Add FlintUI to your dependencies:

```elixir
def deps do
  [
    {:flint_ui, "~> 0.1.0"}
  ]
end
```

Then set up the components module and theme:

```sh
mix flint.setup
```

Generate the styled wrappers you need:

```sh
mix flint.add button
mix flint.add --all
```

Use the generated components through your HTML helpers:

```heex
<.button variant="solid">Save</.button>
```

The headless base stays available explicitly:

```heex
<FlintUI.button class="my-button">Save</FlintUI.button>
```

## Documentation

The docs site is a separate Phoenix app under `docs/`. It covers the styled
component, the headless base, and the CSS contract for every component.

```sh
cd docs && mise exec -- mix phx.server
```

## Development

The library and the docs site are two separate Mix projects. `mix` is available
through `mise`:

```sh
mise exec -- mix test                    # library
cd docs && mise exec -- mix precommit    # docs
```

The docs server should be run from `docs/` so it can be stopped normally. Do
not wrap it in a root Mix alias; `mix cmd` runs it in a separate OS session.
