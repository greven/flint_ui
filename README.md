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

## Theming

The generated theme is plain CSS. Import it and override semantic tokens in
your app stylesheet:

```css
/* assets/css/app.css */
@import "./flint.css";

:root {
  --fl-color-primary: oklch(0.55 0.24 275);
  --fl-color-primary-foreground: oklch(1 0 0);
  /* Ghost and link use the role's AA text shade. */
  --fl-color-primary-text: light-dark(
    oklch(0.491 0.27 292.581),
    oklch(0.702 0.183 293.541)
  );
}
```

Tinted and outlined control labels derive from the role fill, so changing the
fill updates them too. For a full Tailwind-derived `50..950` scale, run the
optional generator:

```sh
mix flint.palette --primary indigo --neutral zinc
```

It writes `assets/css/flint-palette.css` (imported after the theme). Override it
in `app.css` afterwards, or skip the generator and theme entirely in CSS. Custom
themes are `[data-theme="…"]` blocks in the same app stylesheet.

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
