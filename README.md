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
your app stylesheet. Button-like controls share the `--fl-control-*` inputs and
text fields share `--fl-field-*`; component-prefixed variables remain available
for the few per-instance escapes.

```css
/* assets/css/app.css */
@import "./flint.css";

:root {
  --fl-color-primary: oklch(0.55 0.24 275);
  --fl-color-primary-on: oklch(1 0 0);
  /* Tinted, surface, outline, ghost, and link use the role's AA on-soft shade. */
  --fl-color-primary-on-soft: light-dark(
    oklch(0.491 0.27 292.581),
    oklch(0.702 0.183 293.541)
  );
}
```

Each role has three core jobs: the bare role is the fill, `-on` is the label
on that fill, and `-on-soft` is the role as text on a neutral or soft surface.
It also owns `-soft` and `-soft-border` for tinted and bordered variants. Those
blend the role with the surface rather than repeating the solid fill, so a light
role and a dark one stay equally visible. Components composite the tint at
`--fl-tint-opacity` (90%); the soft control paints it at half strength. Either
way the surface below shows through while the `-soft` token keeps enough
strength to stay visible. Primary and secondary
ship the neutral ramp by default, so a fresh theme assumes no brand hue;
override the role or its scale to opt in. Chromatic fills start at the `600`
step; when a solid control cannot carry a light label there, the fill steps to
`700` so the label stays near-white. Warning is the exception: amber stays at `600` with a dark
label so it does not turn brown. Both labels are contrast-picked against the
resolved fill. Text follows the same tiered idea: `text-highlighted`
for headings, `text` for body, `text-toned` for secondary copy, `text-muted` for
meta, and `text-dimmed` for placeholders. `text-dimmed` is below AA by design;
do not use it for readable content.

Neutral chrome is built from one anchor, `--fl-surface-base` (the darkest
ink, default `gray-950`). The page (`background`), `surface`, and
`surface-raised` are white mixes of that ink, so each step up is brighter in
both schemes. Tonal fills then tint toward `--fl-surface-ink` over the surface:
`surface-subtle` at 3% and `surface-strong` at 6%, followed by
`border-subtle` 7%, `border` 10%, and `border-strong` 18%. The order is
intentional: a fill never reaches the quietest edge, so an edge never sinks into
the panel it bounds. Remapping the gray ramp retints the whole chrome through
`--fl-surface-base`; override the base alone to make the dark page darker or
lighter while the surfaces stay a step brighter. For a smaller move,
`--fl-surface-page-tint` mixes ink into the light page and
`--fl-surface-page-lift` adds white to the dark page, carrying the whole ladder
with them. Set `--fl-surface-page-light` / `--fl-surface-page-dark` for an
absolute page such as white or black; at white the solid ladder bottoms out, so
separate cards with borders, shadows, or the tonal fills. Chrome fills and
edges name the
amount of tint (`subtle` / default / `strong`), while ink names loudness
(`text-muted` and friends).

To retint a hue, remap its ramp in `app.css`. Every role that aliases the hue
follows, and the derived `-on` and `-on-soft` tokens update with the ramp. With
Tailwind, point the ramp at the `--color-*` variables:

```css
:root {
  --fl-color-rose-50: var(--color-brand-50);
  /* … 100 through 900 … */
  --fl-color-rose-950: var(--color-brand-950);
}
```

Without Tailwind, paste literal values into the same variables. The `gray` ramp
drives the whole chrome. Custom themes are `[data-theme="…"]` blocks in the same
app stylesheet.

`mix flint.setup --tailwind` writes a bridge that maps each utility family to its
own token (`text-default`, `bg-surface`, `border-default`, `text-primary` vs
`bg-primary`). That mapping needs Tailwind 4.1 or newer.

## CSS utilities

FlintUI also ships a small first-party utility layer, installed by default with
`mix flint.setup` as `assets/css/flint-utilities.css`. It is plain CSS, reads
the same `--fl-*` tokens, and uses an `fl-` prefix so it can sit next to
Tailwind or another utility layer.

Start with the layout primitives:

```heex
<div class="fl-stack fl-gap-sm">
  <div class="fl-cluster">
    <span class="fl-bg-success-soft fl-text-success">Shipped</span>
    <.button variant="surface">Refresh</.button>
  </div>
  <div class="fl-grid" style="--fl-grid-min: 12rem;">
    <div>One</div>
    <div>Two</div>
    <div>Three</div>
  </div>
</div>
```

`fl-stack`, `fl-cluster`, `fl-split`, `fl-flank`, `fl-frame`, and `fl-grid`
adapt to the available width without breakpoint classes. The atomic utilities
(`fl-p-md`, `fl-gap-sm`, `fl-text-lg`, `fl-bg-primary`, `fl-rounded-lg`, …) are
the escape hatch. Named motion utilities (`fl-animate-pulse`, `fl-animate-spin`,
`fl-animate-pop-in`, …) wrap the shared keyframes and turn off under reduced
motion. There is no JIT and no arbitrary-value syntax.

The layer is included by default; pass `--no-utilities` to `flint.setup` or
`flint.theme` to leave it out. Run `mix flint.utilities` to refresh the
generated file, and see the CSS Utilities guide for the full reference.

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
mix flint.icons phosphor --tailwind
```

The task adds an asset-only git dependency and runs `mix deps.get`. Heroicons
(`hero-*`), Lucide (`lucide-*`), Phosphor (`ph-*`, including the `-fill` and
`-duotone` weights), Simple Icons (`si-*`), and Flag Icons (`flag-*`) are
supported. Plain CSS mode writes `assets/css/flint-<set>.css`;
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
