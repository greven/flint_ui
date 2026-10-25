# AGENTS.md

Repository-wide guidance for agents working on FlintUI.

## What this repo is

- `lib/` — the `flint_ui` library: accessible, unstyled Phoenix LiveView components.
- `assets/` — the TypeScript runtime (hooks), bundled into `priv/static/flint.js` and
  `priv/static/flint-sound.js`; consumers import them as `"flint_ui"` and `"flint_ui/sound"`
  (the package `exports` map hides `priv/static`), never by a relative path into `deps`.
  Both bundles are listed explicitly in `package/0`, so a Hex build fails if
  `mix assets.build` has not run.
- `docs/` — the docs website (its own Mix project; see `docs/AGENTS.md`).
- `dev/` — the workbench app (its own Mix project).

`mix` is not on `PATH`; run Elixir commands through `mise exec -- mix ...`.

## Development status

FlintUI is pre-release and has no published release. Do not add compatibility
layers, deprecation shims, or migration paths for old component APIs: change the
API directly and update every internal consumer and doc in the same change.
Breaking changes are expected until the first release; reserve careful migration
work for published versions.

## Verification

- Library: `mise exec -- mix format && mise exec -- mix compile --warnings-as-errors && mise exec -- mix test` (run from the repo root).
- Docs: `mise exec -- mix precommit` (run from `docs/`; it runs `compile --warnings-as-errors`, `deps.unlock --unused`, `format`, `test`).

### Tidewave in the docs dev server

Tidewave is wired into the **docs** app only, for `MIX_ENV=dev`. Start the docs
server before an opencode session so its MCP tools are available at
`http://127.0.0.1:4000/tidewave/mcp` (configured in the root `opencode.json`):

    cd docs && mise exec -- mix phx.server

Use `tidewave_project_eval` and `tidewave_get_logs` for runtime behavior,
rendered component output, and LiveView errors. Don't use runtime evaluation
for work the test suite already covers.

## Conventions

### Dogfood FlintUI components in the docs

Use FlintUI's own components in the docs site whenever one covers the markup. When a new
FlintUI component supersedes a bespoke pattern in the docs, replace the bespoke markup in
the same change that adds the component. This exercises components in real use while they
are being built.

Exception: the modules under `docs/lib/flint_ui_docs_web/docs/` may keep raw HTML when
they are deliberately demonstrating the unstyled component API.

### Site structure and navigation

The docs site is organised Nuxt-style into top-level **sections** — Get Started,
Guides, and Components — selected from a bar directly under the header. Each
section holds one or more **categories** (e.g. "Overview", "Theming", or a
`FlintUI.Meta` component type), each of which lists **pages** (the routes). The
sidebar is scoped to the active section and shows its categories and pages, all
expanded.

`docs/lib/flint_ui_docs_web/nav.ex` (`FlintUIDocsWeb.Nav`) is the single source of
truth: `sections/0`, `get!/1`, `first_page_path/1` (used by the section bar), and
`breadcrumbs/2` (the section + category trail shown above each page title by
`Layouts.breadcrumbs/1`). The Components section is generated from
`FlintUI.Docs.grouped_components/0`; the guide sections are declared inline.
Adding a page means adding it to `Nav` and wiring a route whose path matches,
then passing `section` (and, for guides, `page`) to `Layouts.app`. A test asserts
every page path is unique and routable.

Routes are section-prefixed — `/`, `/getting-started/introduction`,
`/getting-started/installation`, `/getting-started/styling`, `/guides/theming`,
`/components` (index), and `/components/:name`. Section roots (`/getting-started`,
`/guides`) redirect to their first page. Standalone lives live in
`docs/lib/flint_ui_docs_web/live/`: `HomeLive` (landing), `IntroductionLive`,
`GettingStartedLive` (Installation), `StylingLive` (which aggregates the base
styling snippets from `FlintUIDocsWeb.Docs.styling/1`), `ThemeLive`
(which lists tokens by reading `FlintUI.Generator.theme_source/0`), and
`ComponentsLive` (the component index).

### Component docs pages

Every component page (`/components/:name`, rendered by `FlintUIDocsWeb.ComponentLive`)
has three URL-driven tabs — **Styled** (default), **Base** (`?tab=base`), and
**CSS** (`?tab=css`). The generated styled component is centre stage on Styled;
Base documents the headless imported component; CSS gathers the styled layer's
CSS contract. Legacy `?tab=styled` / `?tab=api` / `?tab=styles` links resolve to
Styled or CSS as appropriate.

- **Styled** — the generated component: `Usage` (the interactive styled
  playground plus one subsection per styled attribute), a `Base behavior` block
  linking to the Base tab instead of repeating base semantics, `Examples` (the
  recipe cards), `Setup` (the install command and wrapper source),
  and `API reference` (base attributes and styled props merged into one table
  with Attr, Layer, Type, and Description columns; defaults and data hooks are
  folded into each description, data first).
- **Base** — the headless component: `Anatomy` (a structured tree of the rendered
  markup: wrapper, inner parts, `data-*` hooks, and states), `Usage` (prose plus
  code for each base attribute, with no live previews), `Examples` (prose plus
  complete code), `Accessibility` (prose plus the `Keyboard` table), and `API
  reference` (base `Attributes`, `Slots`, `Events`, `Data attributes`, and
  runtime CSS variables).
- **CSS** — the styled layer contract: `Styling contract` prose, `Public CSS
  variables` (`FlintUI.Styled.Var`), `Selectors and state hooks`, `Theme` (token
  namespaces), and `Customization` recipes.

Page content is authored per component in
`docs/lib/flint_ui_docs_web/docs/<name>.ex` (behaviour
`FlintUIDocsWeb.Docs.Page`), not in the template. Each module declares
`controls/0` (the Styled playground), `usage/0`, `examples/0`, `anatomy/0`,
`styling/0`, `css/0`, `structure/0`, `render_playground/1`, `render_code/1`,
`render_usage/1`, and `render_block/1`. `accessibility/0` defaults to the
`## Accessibility` section of the component's moduledoc (`FlintUI.Docs.section/2`);
keyboard comes from the component's `keyboard/0`.

`usage/0` is the single source of truth for the per-attribute subsections: each
public attribute has an entry tagged `layer: :base` or `layer: :styled` and a
`covers` list, and each tab renders only its layer (`Docs.styled_usage/1`
vs `Docs.base_usage/1`). A docs test enforces that every public base
attribute and styled prop is covered. `render_usage/1` matches on the entry `id`.
Styled entries always render their preview and code together; set
`preview_only: true` (and omit `code`) when the demo is the whole point. Base usage
and examples are always prose + code and never render a preview. `examples/0`
entries may be tagged `layer: :base`; the Styled tab shows only styled examples and
Base shows only base examples. `render_block/1` renders the Examples recipes.
`anatomy/0` returns a
`%{body, nodes}` tree rendered by `FlintUIDocsWeb.DocsComponents.anatomy/1`, with
`structure/0` kept as a code-snippet fallback for components that have not been
authored yet. The API tables are derived from the component metadata
(`FlintUI.Docs.*`) plus the `FlintUI.Styled` entry props/slots.

Prose in `usage/0`/`styling/0` and the accessibility section is rendered by
`FlintUIDocsWeb.Markdown`, a small safe Markdown subset (paragraphs, inline code,
fenced/indented code). Do not add a full Markdown dependency. `styling/0` is no
longer shown on the component page: `FlintUIDocsWeb.StylingLive` aggregates the
per-component plain-CSS snippets on the Get Started **Styling** page.

The interactive preview card is `FlintUIDocsWeb.PreviewComponent`, a
`LiveComponent` (in `docs/lib/flint_ui_docs_web/components/`) that owns the
playground state and controls. `kind` is `:playground` (interactive; `layer`
selects base vs styled), `:usage`, or `:block`; call it as
`<PreviewComponent.preview ...>`. The demo is always visible, with optional
controls and code stacked beneath it as one bordered card. The code panel is
`FlintUIDocsWeb.CodeBlock`; in development it offers a Source toggle beside its
copy button. Code snippets are highlighted server-side by
`FlintUIDocsWeb.Highlight` (Makeup), using Paraiso Light and Paraiso Dark via
`light-dark()` so one stylesheet follows the site's color scheme.

The docs site is itself a styled-layer consumer: `docs/lib/flint_ui_docs_web/components.ex`
is generated by `mix flint.add --all`, and the app stylesheet imports the assembled
`priv/static/flint.css`. `FlintUIDocs.Theme` also generates a real color palette
(Tailwind red primary, gray secondary, neutral neutral, emerald/blue/amber/red states)
to `docs/assets/css/flint-palette.css`, imported after the theme so the showcase
shows distinct color roles instead of the neutral default. The headless base and the generated components share
the `<.button>` name, so the generated module is referenced explicitly (aliased)
rather than imported into the docs' HTML helpers.

### Preview, Code, and Source

A preview and its code block document the same API, but they are not two views of
identical markup. The code block is the public teaching snippet; the preview is the
demo. A test asserts no snippet contains a `...` placeholder; the rest is convention:

- The code block is complete, copy-pasteable HEEx. No `...` or elided content. It
  must stand on its own, without docs-private helpers.
- The code block need not reproduce the preview markup exactly. It may show a
  concise representative composition while the preview demonstrates a fuller matrix
  or adds demo-only context. Keep it honest about the API and complete enough to run.
- `usage/0` entries document one attribute with minimal, literal markup; `examples/0`
  show full composition. They are the source of truth for the code block, not for
  the preview's markup.
- Previews are authored in `render_playground/1`, `render_usage/1`, and
  `render_block/1`. They may use docs-private composition, but should still prefer
  FlintUI components over bespoke markup. When a component's theme does not own a
  look, compose a generated component that does (`<.button variant=…>`, `<.icon>`).
- Raw Tailwind is reserved for layout the design system does not own (containers,
  spacing, the `max-w-*` canvas). If the code block uses layout classes, show the
  exact classes there; preview-only layout can stay in the render callback.
- Live playgrounds derive their snippet from `render_code/1`, so it tracks the
  current props. It may show the essential composition rather than every extra the
  playground canvas adds.
- Playground controls are slim addon-style fields below the demo. `controls/0` is
  the full set; `playground_controls/0` optionally returns the keys to show, so a
  page can keep its demo panel short (the button page shows Variant, Color, and
  Size). Hidden controls keep their defaults.
- Examples whose styling relies on Tailwind carry two code flavors — `Tailwind`
  (utilities) and `CSS` (the same example with semantic classes plus a companion
  stylesheet in `styles`). Declare them with
  `codes: [%{label, lang, code, styles?}]` on a `usage/0`/`examples/0` entry, or
  return a flavor list from `render_code/1`; a single `code`/string still works.
  The flavor switcher lives in the code block header.

In development the code block also offers a **Source** toggle beside its copy
button. It is generated automatically by `FlintUIDocsWeb.Docs.Source` from the
matching `render_*` clause, so it always shows the markup that actually produced the
preview and there is no third snippet to maintain. The toggle is enabled by
`config :flint_ui_docs, dev_tools: true` (`docs/config/dev.exs`) and hidden in every
other environment. Because that source is visible while developing, keep the render
callbacks readable and free of dead experiments.

An entry whose rendered demo is the whole point — a full color/variant matrix, for
example — sets `preview_only: true` and omits `code`. The card then renders only the
demo, with no code section. Use this sparingly; most examples should still teach
through their code block.

When adding a multi-part component, set `data-element` on the root only; parts carry
`data-part`. This keeps the root-only presence hook meaningful and lets a part be
another FlintUI component without clobbering that child's `data-element`-keyed theme.

**The Group container is child-agnostic.** `FlintUI.Base.Group` (styled `variant`
`attached`/`framed`) joins any direct children: `group.css` targets `> *` for the
seam/corner geometry, so buttons, toggles and future inputs mash without the group
knowing their type. The only place the group names a child is the `size` cascade
(`> :is([data-element="button"], [data-element="toggle"])`); a new control opts in
by adding its `data-element` there. Attached children overlap by 1px; each
bordered control paints the opaque `--fl-color-control` fill, so the later
child's fill covers the previous border at the seam and only one line shows.
Hover/active are an in-border `currentColor` overlay (clipped to the padding box
for bordered variants, so it follows joined corners and never tints the border),
keeping the alpha border's backdrop stable. The hover overlay is weaker than the
border alpha, so the border still reads while hovering. The hovered/focused child
wins the seam via `z-index`. Prefer composing `<.group>` over a bespoke wrapper
when a set of controls should read as one unit.

Future work: `role="toolbar"` currently only gets the role if the host passes
it. The group does not implement roving focus or arrow-key movement, so the docs
must not present it as a complete toolbar pattern until that lands.

### Keep parity with Phoenix `core_components`

FlintUI aims to cover the components that `phx.new` ships in `MyAppWeb.CoreComponents`.
When a FlintUI component supersedes a core function:

1. Delete that function from `docs/lib/flint_ui_docs_web/components/core_components.ex`.
2. Migrate every usage to the FlintUI component.
3. Remove any now-dead helpers (e.g. `show/2`, `hide/2`) and update imports.

This is mandatory, not cosmetic: `docs/lib/flint_ui_docs_web.ex` imports **both**
`FlintUIDocsWeb.CoreComponents` and `FlintUIDocsWeb.FlintComponents`, so a FlintUI
component that shares a name with a core one is a compile-time import conflict.

### Translation helpers stay in the app

`translate_error/1` and `translate_errors/2` are emitted by `phx.new` into each app's
`MyAppWeb.CoreComponents` and are an i18n/changeset concern, not a UI concern. FlintUI
does **not** own them. When FlintUI ships a form/field component it should accept
already-translated error strings (or call `translate_error/1` only if the host defines
it). Revisit in depth when inputs are implemented.

### Password-manager opt-outs

Password managers inject their fill icon and prompts from their own heuristics;
`autocomplete="off"` alone does not stop them. `FlintUI.Autofill` holds the vendor
opt-outs: `ignore_attributes/0` covers 1Password, LastPass, Bitwarden, Proton Pass,
and Dashlane, and `ignore_class/0` covers Keeper. Use it on any input where autofill
makes no sense, including the docs preview controls. When FlintUI's field/input
component lands, expose the same behaviour as a prop (`autofill="off"` or similar)
that spreads those attributes and adds the class, so consumers do not have to
memorise vendor names.

### Use the built-in `JSON` moduleElixir 1.18+ ships a `JSON` module that implements the interface `Phoenix.json_library/0`

expects (`encode!/1`, `decode!/1`, `encode_to_iodata!/1`). Configure it with
`config :phoenix, :json_library, JSON` (root `config/config.exs` and `docs/config/config.exs`)
and **never add Jason** as a dependency.

## Styled components and theming

FlintUI ships headless components (imported) plus a generated styled layer (copied
into the consumer). The styling contract is framework-agnostic and lives in CSS, so
FlintUI does not require Tailwind.

- **Base components** (`lib/flint_ui/base/*.ex`, modules `FlintUI.Base.*`) are the
  headless, imported layer. The public functions (`FlintUI.button/1`) are generated
  from them by `FlintUI.API`, so `use FlintUI` imports the base.
- **Styled catalog** (`lib/flint_ui/styled.ex` and `styled/*.ex`) is the source of truth
  for the styled layer. Each `FlintUI.Styled.Entry` names the headless `base`, the
  generated `target`, the theme part (`css`), the extra presentational attributes
  (`:props`, `FlintUI.Styled.Prop`) and extra `slots` (`FlintUI.Styled.Slot`), the
  `data-*` hooks the attributes map to (`FlintUI.Styled.Prop.attribute/1`), and the
  theme token namespaces used.
- **Generated wrappers** are rendered from `priv/templates/styled/<name>.ex.eex`
  by `FlintUI.Generator.component_source/1`. They stay thin: declare the attributes
  and slots, map the attributes onto data attributes, forward `class`/`rest`, and
  delegate behavior to the base. The attributes are emitted from the entry (plus
  `class` and the base attributes folded into `rest`); the `rest` whitelist mirrors
  the base's own contract (its declared attributes plus any `include` on the base's
  `rest`), so e.g. the styled button forwards `href`/`navigate`/`patch`. Slot
  declarations are the base's own slots (from `FlintUI.Docs.slots/1`) merged with
  the entry's extra slots. Never bake Tailwind classes into a wrapper.
- **Themes are CSS**, assembled from parts under `priv/templates/`
  (`tokens.css`, the shared `base.css` rules, the theme presets
  `themes/<name>.css` registered in `FlintUI.Theme`, then the component
  stylesheets `styled/<name>.css` colocated with the wrapper template).
  `FlintUI.Generator.theme_source/0` concatenates them (tokens first, then
  `base.css`, then presets, then components in registry order), and the
  `:flint_theme` Mix compiler
  (`Mix.Tasks.Compile.FlintTheme`) writes the aggregate to `priv/static/flint.css`
  for the docs to import. `mix flint.setup`/`flint.theme` write that same aggregate
  to the host's `assets/css/flint.css`. Tokens are prefixed `--fl-*`, with automatic
  light/dark via `color-scheme` + `light-dark()`. **Scheme and preset are
  separate controls:** force a scheme with `data-color-scheme="light|dark"` on
  `<html>`, and select a named preset with `data-theme="<name>"` (a preset only
  overrides tokens, never `color-scheme`). `FlintUI.Theme.presets/0` is the
  UI-selectable list (`:default` plus the CSS-backed `themes/0`); `:default` has
  no stylesheet — it is the `:root` baseline — so selecting it clears
  `data-theme`. The radius scale is `--fl-radius` plus
  the `--fl-radius-*` multipliers. Buttons, toggles, and future form controls
  share `--fl-control-radius` (default `var(--fl-radius-md)`); components with
  their own shape (card, badge, avatar, switch) read the scale step that fits
  their anatomy directly. There are no per-component radius tokens: a theme that
  needs a component-specific shape targets its `data-element` hook in theme CSS.
  Each
  semantic color role owns a `--fl-color-{role}-{50..950}` scale plus three
  aliases: `--fl-color-{role}` (the solid fill), `-foreground` (the label on
  that fill) and `-text` (the role as text on the page). `mix flint.palette`
  computes the label and text shades from the imported scale with
  `FlintUI.Palette.Contrast` (WCAG) so they clear AA — no hardcoded
  foregrounds. The target is configurable (`:contrast` / `--contrast aaa`); the
  label falls back to pure white/black when a mid-tone fill's ramp extremes miss
  it, and the text shade is scored against the subtle surface tint (not the bare
  page) so the tinted variants stay legible. Only the fill's alias shade is a
  design input (a mid-tone fill cannot reach AA against any label, so pick a
  darker/lighter anchor — e.g. `green-700` for a light label). The alias uses the
  **same anchor in both schemes** (default `600`): lightening the fill in dark
  washes it out and pairs it with a dark label, so dark solids stay as saturated
  as light ones (like FluxonUI/Nuxt); only the computed text shade differs per
  scheme.
  **Component inputs are a narrow escape hatch, not the theme API.** A styled
  component may declare at most five public `--fl-{name}-*` inputs, and only for
  something a prop or theme token cannot express (per-instance tinting or
  anatomy-specific geometry). Button and Toggle expose just
  `--fl-{button,toggle}-color`, `-color-foreground`, and `-text`; Card exposes
  spacing, surface, foreground, border, and shadow. Everything else derives
  from theme tokens. `--_fl-*` is reserved for JS-published runtime hooks and
  must never be documented as an input. Component rules live in
  `@layer components` and are keyed on the wrapper hooks, so the headless base
  stays unstyled. The focus ring is tinted with the component color. The
  `color` attribute only accepts semantic roles; arbitrary colors are a
  CSS-level override, not a component prop. A new component-level variable must
  justify why the theme cannot own it.
- **Surfaces are neutral tokens, not colors.** Alongside the semantic roles sit
  scheme-aware neutral surface/text tokens — `--fl-color-surface` (the default
  panel, ≈ Nuxt's `bg-default`), `--fl-color-surface-soft` (an opaque half-step
  toward `elevated`), `--fl-color-surface-muted` (the full muted step, aliasing
  `--fl-color-muted`), `--fl-color-elevated`/`--fl-color-muted`
  (`bg-elevated`/`bg-muted`), `--fl-color-inverted`, `--fl-color-control`,
  `--fl-color-border`, `--fl-color-dimmed`/`--fl-color-muted-foreground`, plus
  `--fl-color-disabled`/`-foreground`/`-border` and `--fl-disabled-opacity`.
  Ink is a neutral scale too, not near-black/white: `--fl-color-foreground`
  (`neutral-700` light / `neutral-200` dark) is the default label, matching
  Fluxon and Tailwind Plus; `--fl-color-foreground-soft` (`neutral-600` /
  `neutral-300`) is secondary copy; `--fl-color-muted-foreground` (`neutral-500` /
  `neutral-400`) is the next step, and `--fl-color-dimmed` is disabled-only.
  `--fl-color-surface-foreground` aliases the default ink. Solid control labels
  do not use the page ink: they use the role `-foreground` aliases, which
  `mix flint.palette` selects for AA against the fill (usually pure white or the
  darkest shade). Keep the foreground steps at or above AA (4.5:1) on the
  surfaces they are used on; `muted-foreground` on a light muted surface is the
  known edge case still to resolve.
  The scale is opaque and moves from the base surface toward `elevated`: light
  steps darker, dark steps lighter. In dark the base surface is `neutral-800`
  and muted/elevated is an 80/20 `neutral-800`/`neutral-700` mix, keeping cards
  lifted off the near-black page. `--fl-color-control` is the opaque fill every
  bordered control paints (light: the surface; dark: a subtle lift off the page),
  so an attached group's later child covers its neighbour's border at the seam.
  Neutral dark borders are foreground-alpha steps (5% muted, 8% default, 12%
  accented/input) so they follow the fill they sit on; because every bordered
  control paints `--fl-color-control` and hover is an in-border overlay, the
  backdrop stays stable. Colored control borders mix the role color with
  `--fl-color-control` using `--fl-border-strength` /
  `--fl-border-strength-soft` instead of shipping a border token per role.
  Never make a surface token translucent over the page; composite over
  `--fl-color-surface` or use the scale directly. Disabled surfaces use the
  muted fill with a dimmed label; colored controls keep their hue and dim
  through `--fl-disabled-opacity`. They derive from the `neutral` role's scale,
  so a palette remap carries through. Components that
  shouldn't take a `color` use these: **Card** exposes only neutral surface
  `variant`s (`solid` default, `soft`, `muted`, `ghost`), never a hue. `ghost`
  has no surface or elevation of its own, so `outline` alone reads as an
  outline-only card and `outline={false}` as a bare container; `inverted` is a
  no-op there (there is no surface to invert). `outline` and
  `shadow` (both true by default) and `inverted` compose with every other
  variant.
  `spacing` runs `xs`/`sm`/`md`/`lg`/`xl` (14/16/20/24/32px, `md` default).
  The Card is a flex container whose `orientation` (`vertical` default,
  `horizontal`) lays out the optional header, body region, and optional footer.
  The body wraps the default slot and the repeatable `:section` regions; there is
  no separate body slot. All body sections share the root `padded` boolean
  (default true); set `padded={false}` for full-bleed content. Header and footer
  actions use the flat `:header_actions`/`:footer_actions` slots because Phoenix
  slot entries must be direct children of the component and cannot nest. The
  styled `body` prop sets how the regions separate: `seamless` (default),
  `separated` (darker header and footer bands), `separated-header`/
  `separated-footer` (one band, with the unbanded region on the body
  surface), `divided` (full-width lines between every
  region and body section), `inset` (a body panel inset from the edges), or
  `flush` (a panel reaching the card's edges). Section and footer slot attributes
  are intentionally absent; dividers and inset are root/body concerns.
  Seamless makes the body `display: contents`, preserving the original
  direct-child gap layout. Separated bodies sit on the card surface so the
  selected variant and inverted treatment carry through; bands are a darker
  shade of that same surface. Divided bodies inherit the card surface because
  the lines are the treatment. In separated modes both outer regions cancel the
  card's block inset, so the banded and unbanded edges reach the rounded edge.
  Inset/flush add a border and radius to the body panel; separated/divided remain
  edge-to-edge. These treatments are direct `[data-body]`/`[data-part]` rules,
  not an internal variable pipeline.
  Band tint is a 1.5% black shade of the card surface in light and 10% in dark,
  so bands stay darker than the body without becoming heavy in light mode.
  Inverted cards swap those strengths. Bands layer over solid, soft and muted
  shells alike; the muted variant does not strengthen them separately because
  its surface is already the stronger step. Inset/flush panels are a subtle well
  on light solid cards and a raised tonal panel in dark and on soft/muted cards;
  inverted cards keep a well with an inset shadow.
  Regions own their inline inset, so divided lines span the card edge to edge. A
  divided padded section or footer also gets block-start padding below the line;
  in horizontal orientation regions own the block inset so the dividers span the
  card height, and that inset matches the sections so every column's content
  lines up. In vertical cards, header/footer block padding is one base step
  tighter than the card spacing (`--fl-card-spacing - --fl-spacing`, 16px at the
  default) while body and section spacing keep `--fl-card-spacing`. Vertical
  flush cards use that same region spacing for the gap around the panel. A
  full-bleed first/last section cancels the card's block inset in the non-panel
  treatments; inside a panel it bleeds to the panel edge.
  The **`color="neutral"`** role (button/toggle, the default) is the inverted
  surface — plain black/white — not the `--fl-color-neutral` hue alias, so it
  stays monochrome even when a palette remaps the neutral ramp. `secondary`
  behaves like any hue (it tints); the docs lean on Nuxt UI's state defaults
  (`success` emerald, `info` blue, `warning` amber, `error` red).
- **Surface effects are layered too.** Depth and shadows are separate:
  `solid` wears a top **rim light** — a 1px `::before` border masked
  top-to-bottom so the line runs a little way down the sides before fading —
  while `outline` wears a bottom inner line. The `depth` prop is a boolean
  (`data-depth="true"|"false"`; boolean props set the string so both states have
  a selector) that flattens only that highlight/line on demand. Shadows are
  always on for `solid`, `subtle`, and `outline` through the shared
  `--fl-control-shadow`; override it with `0 0 #0000` per instance or theme to
  remove them. `dashed`/`ghost`/`link` stay flat, and `soft` has no shadow.
  Shared control effects live in the theme: `--fl-control-depth` scales the rim
  and inner line, `--fl-control-shadow` is the outer elevation,
  `--fl-control-hover-opacity`/`--fl-control-active-opacity` are the in-border
  `currentColor` overlay, and `--fl-control-press` is the `:active` nudge, so a
  preset can flatten or gloss every control at once and a consumer overrides the
  same names per instance via `class`/`style`. Pressing sinks the button:
  `:active` nudges it, fades the rim's opacity to 0, and drops the elevation to a
  transparent shadow (same count/inset-ness, so `box-shadow` transitions), and
  `prefers-reduced-motion` drops only the nudge.
- **Scales are tokens.** `--fl-font-size-*`, `--fl-line-height-*`,
  `--fl-font-weight-*`, `--fl-spacing-*` (base `--fl-spacing` + multipliers),
  `--fl-shadow-*`, `--fl-breakpoint-*`, `--fl-container`, `--fl-duration-*`,
  `--fl-ease-*`, plus `--fl-control-radius` and a shared
  `--fl-control-{height,padding-x,font-size,line-height,gap,icon}-*` scale that
  controls consume (button/toggle read it; the icon size drives any direct
  `[data-element="icon"]` or `[data-element="loading"]` child, which controls
  also `shrink-0` and tint to 70% of the label color, brightening to full on
  hover). The icon publishes its box as `--fl-icon-size` so a host icon set can
  follow it — the docs' Lucide plugin reads `var(--fl-icon-size, 1.5rem)` —
  which lets a control size the icon/loading it wraps even though a Tailwind
  host's icon class lives in the later `utilities` layer. A theme retunes
  density/roundness/type by overriding the base units.
- **Tailwind is optional.** `mix flint.setup --tailwind` / `mix flint.theme --tailwind`
  patch the host stylesheet with an `@theme inline` bridge from `--fl-*` to utilities.
  Never add Tailwind as a dependency of the library.
- **Tasks** (`lib/mix/tasks/flint.*.ex`) are Igniter tasks guarded by
  `Code.ensure_loaded?(Igniter)`, so they compile only when Igniter is present.
  `flint.setup` wires the module and theme, `flint.add` generates wrappers into
  `MyAppWeb.Components`, `flint.theme` refreshes the stylesheet, and
  `flint.palette` maps a `FlintUI.Palette` implementation (Tailwind ships as data
  in `lib/flint_ui/palette/tailwind.ex`) onto the semantic scales, writing
  `assets/css/flint-palette.css` (imported after `flint.css`, so it is never
  clobbered by `flint.theme`). New palettes implement the `FlintUI.Palette`
  behaviour and render through `FlintUI.Palette.CSS`.

Naming: generated components are the primary `<.button>`/`<.toggle>` (import
`MyAppWeb.Components`); the headless base stays explicit (`FlintUI.button`, or a
`prefix:`). The docs dogfood both, so the base is imported there with a prefix.

### Adding a styled component

The styled layer is a four-part contract. To add component `foo`, update all four
in the same change:

1. `lib/flint_ui/styled/foo.ex` - a `FlintUI.Styled.Entry` (base, target,
   install, css part, tokens, `FlintUI.Styled.Prop` attributes, `FlintUI.Styled.Slot`
   slots). This drives generation and the docs Docs/API tables. The generator
   merges the slots with the base's own when it writes the wrapper.
2. `priv/templates/styled/foo.ex.eex` - the thin wrapper (`<%= @attrs %>` attributes,
   `<%= @slots %>` slots, forwards `class`/`rest`, delegates to the base).
3. `priv/templates/styled/foo.css` - rules keyed on
   `[data-element="foo"][data-*="…"]` for every attribute value (reference the part via
   the entry's `css`). `test/theme_contract_test.exs` fails if a registry value
   has no matching selector (add to its exceptions only if the value is handled
   structurally).
4. `docs/lib/flint_ui_docs_web/docs/foo.ex` - a
   `FlintUIDocsWeb.Docs.Page` with `controls/0`, `usage/0` (base/styled
   entries), `examples/0`, `render_playground/1`, `render_usage/1`,
   `render_block/1`, and `styling/0` with plain-CSS snippets for the base.

## References

Prefer these authoritative sources when implementing a component:

- **Accessibility** — [React Aria](https://react-spectrum.adobe.com/react-aria/) is the
  primary reference for ARIA roles, states, properties, and keyboard interaction.
  Cross-check against the [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
  and the [MDN ARIA reference](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA).
  Consult them before choosing roles, states, and keyboard behavior, and record the result in
  the component's `## Accessibility` and `## Keyboard` docs (see `FlintUI.Base.Button`).

- **Phoenix LiveView components** — reference existing libraries when shaping APIs and
  composition: [Doggo](https://github.com/woylie/doggo) and
  [Corex](https://github.com/corex-ui/corex). [FluxonUI](https://fluxonui.com/) is closed
  source but useful as a reference for design and component coverage.

- **Component libraries** — draw layout, styling, and API inspiration from
  [shadcn/ui](https://ui.shadcn.com), [Nuxt UI](https://ui.nuxt.dev), and
  [Mantine](https://mantine.dev/).

## `core_components` parity status

| CoreComponents function                     | FlintUI equivalent  | Status                                                                                                                                                             |
| ------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `icon/1`                                    | `FlintUI.Base.Icon` | Shipped. Class-based (`name` is a CSS class); the docs wire Lucide via a Tailwind `matchComponents` plugin. Core `icon` deleted and usages migrated to `lucide-*`. |
| `flash/1` + bespoke `Layouts.flash_group/1` | none                | Future. Cover with a FlintUI flash/toast, then delete core `flash`, replace `flash_group/1`, and drop `show/2`/`hide/2` if unused.                                 |
| `input/1`                                   | none                | Future. Cover with a FlintUI field/input, then delete core `input`.                                                                                                |
| `header/1`, `table/1`, `list/1`             | none                | Future, only if FlintUI ships equivalents.                                                                                                                         |
| `translate_error/1`, `translate_errors/2`   | n/a                 | Stay in the app; not a parity target.                                                                                                                              |
