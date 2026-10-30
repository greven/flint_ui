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
  --fl-color-primary-content: oklch(1 0 0);
  /* Tinted, outlined, ghost, and link use the role's AA text shade. */
  --fl-color-primary-text: light-dark(
    oklch(0.491 0.27 292.581),
    oklch(0.702 0.183 293.541)
  );
}
```

Each role has three jobs: the bare role is the fill, `-content` is the label on
that fill, and `-text` is the role as text on a neutral surface. Text follows the
same tiered idea: `text-highlighted` for headings, `text` for body, `text-toned`
for secondary copy, `text-muted` for meta, and `text-dimmed` for placeholders.
`text-dimmed` is below AA by design; do not use it for readable content.

Neutral chrome uses the same three-level idea: `surface` is the panel,
`surface-muted` is the half step, and `surface-accented` is the full toned fill.
`muted` always means the faint step and `accented` always means the strong one,
so `bg-muted` / `bg-accented` and `border-muted` / `border-accented` read the
same way.

For a full `50..950` scale, map the role shades to the palette you already
have. With Tailwind, point them at the `--color-*` variables in `app.css`:

```css
:root {
  --fl-color-primary-50: var(--color-rose-50);
  /* … 100 through 500 … */
  --fl-color-primary-600: var(--color-rose-600);
  /* … 700 through 900 … */
  --fl-color-primary-950: var(--color-rose-950);
  --fl-color-primary: light-dark(
    var(--fl-color-primary-600),
    var(--fl-color-primary-600)
  );
}
```

Without Tailwind, paste the literal scale into `app.css`. The role scale is the
only color contract; source palette names never become CSS variables. Custom
themes are `[data-theme="…"]` blocks in the same app stylesheet.

`mix flint.setup --tailwind` writes a bridge that maps each utility family to its
own token (`text-default`, `bg-surface`, `border-default`, `text-primary` vs
`bg-primary`). That mapping needs Tailwind 4.1 or newer.

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
