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
  /* Tinted, surface, outline, ghost, and link use the role's AA text shade. */
  --fl-color-primary-text: light-dark(
    oklch(0.491 0.27 292.581),
    oklch(0.702 0.183 293.541)
  );
}
```

Each role has three core jobs: the bare role is the fill, `-content` is the
label on that fill, and `-text` is the role as text on a neutral surface. It
also owns `-soft` and `-soft-border` for tinted and bordered variants. Those
blend the role with the surface rather than repeating the solid fill, so a light
role and a dark one stay equally visible. Components composite the tint at
`--fl-tint-opacity` (90%), so the surface below shows through while the
`-soft` token keeps enough strength to stay visible. Primary and secondary
ship the neutral ramp by default, so a fresh theme assumes no brand hue;
override the role or its scale to opt in. Chromatic fills start at the `600`
step; when a solid control cannot carry a light label there, the fill steps to
`700` so the label stays near-white. Warning is the exception: amber stays at `600` with a dark
label so it does not turn brown. Both labels are contrast-picked against the
resolved fill. Text follows the same tiered idea: `text-highlighted`
for headings, `text` for body, `text-toned` for secondary copy, `text-muted` for
meta, and `text-dimmed` for placeholders. `text-dimmed` is below AA by design;
do not use it for readable content.

Neutral chrome is anchored on the pure `surface`: white in light and
`neutral-950` in dark. The page (`background`) is a one-step tint toward the
opposite neutral extreme, `surface-subtle` is two steps, and `surface-strong`
is four. `--fl-surface-step` sets one step; the default 1.5% keeps the ladder at
1.5/3/6%, and raising it strengthens every surface together. The tint order is
the same in both schemes, so the page is never pure and a card is never the page
color. Chrome fills and edges name the amount of tint (`subtle` / default /
`strong`), while ink names loudness (`text-muted` and friends): a surface only
ever moves away from the pure anchor, so `bg-subtle` / `bg-strong` and
`border-subtle` / `border-strong` read as amounts, not ranks against the page.

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
only color contract; source palette names never become CSS variables. Re-check
`-content` and `-text` after remapping a scale: their shade refs follow the new
scale, but the shipped picks assume the default scales. Custom themes are
`[data-theme="…"]` blocks in the same app stylesheet.

`mix flint.setup --tailwind` writes a bridge that maps each utility family to its
own token (`text-default`, `bg-surface`, `border-default`, `text-primary` vs
`bg-primary`). That mapping needs Tailwind 4.1 or newer.

## Icons and flags

`<.icon>` applies `name` verbatim as a class; FlintUI does not ship icon assets.
Icons install with Tailwind or plain CSS. Flags for `<.flag>` install as copied
SVGs, so the code can be dynamic and works the same with either styling mode:

```sh
mix flint.icons flags --assets
mix flint.icons flags --assets --only pt,us,br

mix flint.icons lucide --tailwind
mix flint.icons lucide --css
mix flint.icons lucide --css --scan
```

The task adds an asset-only git dependency and runs `mix deps.get`. Heroicons
(`hero-*`), Lucide (`lucide-*`), Simple Icons (`si-*`), and Flag Icons
(`flag-*`) are supported. Plain CSS mode writes `assets/css/flint-<set>.css`;
add `--scan` to emit only the classes found in your source and install the
`:flint_icons` compiler. `--assets` copies the flag SVGs to
`priv/static/images/flags`, which is what `<.flag>` loads at runtime. See the docs
guide for the class prefixes and usage.

```heex
<.icon name="lucide-house" />
<.flag code="pt" label="Portugal" />
<.flag code={@country_code} shape="round" label={@country_name} />
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
