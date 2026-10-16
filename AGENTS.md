# AGENTS.md

Repository-wide guidance for agents working on FlintUI.

## What this repo is

- `lib/` — the `flint_ui` library: accessible, unstyled Phoenix LiveView components.
- `assets/` — the TypeScript runtime (hooks), bundled into `priv/static/flint.js`.
- `docs/` — the docs website (its own Mix project; see `docs/AGENTS.md`).
- `dev/` — the workbench app (its own Mix project).

`mix` is not on `PATH`; run Elixir commands through `mise exec -- mix ...`.

## Verification

- Library: `mise exec -- mix format && mise exec -- mix compile --warnings-as-errors && mise exec -- mix test` (run from the repo root).
- Docs: `mise exec -- mix precommit` (run from `docs/`; it runs `compile --warnings-as-errors`, `deps.unlock --unused`, `format`, `test`).

## Conventions

### Dogfood FlintUI components in the docs

Use FlintUI's own components in the docs site whenever one covers the markup. When a new
FlintUI component supersedes a bespoke pattern in the docs, replace the bespoke markup in
the same change that adds the component. This exercises components in real use while they
are being built.

Exception: the modules under `docs/lib/flint_ui_docs_web/component_docs/` may keep raw HTML when
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
styling snippets from `FlintUIDocsWeb.ComponentDocs.styling/1`), `ThemeLive`
(which lists tokens by reading `FlintUI.Generator.theme_source/0`), and
`ComponentsLive` (the component index).

### Component docs pages

Every component page (`/components/:name`, rendered by `FlintUIDocsWeb.ComponentLive`)
has three URL-driven tabs — **Docs** (default), **Base** (`?tab=base`), and
**Styles** (`?tab=styles`). The generated styled component is centre stage on
Docs; Base documents the headless imported component; Styles gathers what you
consume when styling this component. Legacy `?tab=styled` / `?tab=api` links
resolve to Docs.

- **Docs** — the generated component: `Usage` (the interactive styled playground
  plus one subsection per attribute, each with its own preview), `Examples` (the
  recipe cards), `API reference` (the full surface as it is usable on the
  generated component — base attributes and styled props merged into one table,
  base + styled slots, and events, with a link to the Base tab's `Data attributes`),
  and `Changelog` (placeholder).
- **Base** — the headless component: `Anatomy` (a structured tree of the rendered
  markup: wrapper, inner parts, `data-*` hooks, and states), `Usage` (the
  playground with no controls, plus the base-only usage subsections),
  `Accessibility` (prose plus the `Keyboard` table), and `API reference` (base
  `Attributes`, `Slots`, `Events`, and `Data attributes`).
- **Styles** — the styling contract: `Theme` (the token namespaces the component
  reads, with links to Theming and Styling) and `CSS variables` (any runtime
  custom properties the component sets, e.g. `--fl-collapsible-height`).

Page content is authored per component in
`docs/lib/flint_ui_docs_web/component_docs/<name>.ex` (behaviour
`FlintUIDocsWeb.ComponentDocs.Page`), not in the template. Each module declares
`controls/0` (the Docs playground), `usage/0`, `examples/0`, `anatomy/0`,
`styling/0`, `structure/0`, `render_playground/1`, `render_code/1`,
`render_usage/1`, and `render_block/1`. `accessibility/0` defaults to the
`## Accessibility` section of the component's moduledoc (`FlintUI.Docs.section/2`);
keyboard comes from the component's `keyboard/0`.

`usage/0` is the single source of truth for the per-attribute subsections: each
entry is tagged `layer: :base` or `layer: :styled`, and both tabs render the
entries that apply to them from the same list (`ComponentDocs.usage/1` vs
`ComponentDocs.base_usage/1`). `render_usage/1` matches on the entry `id` and
receives the tab's `layer`, so the Docs tab previews the generated component and
the Base tab previews the headless one from the same clause; entries that cannot
be demonstrated live (e.g. a pushed server event) set `preview: false` to render
the Code tab only. `render_block/1` renders the Examples recipes. `anatomy/0` returns a
`%{body, nodes}` tree rendered by `FlintUIDocsWeb.DocBlocks.anatomy/1`, with
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
playground state, controls, and highlighted Code tab. `kind` is `:playground`
(interactive; `layer` selects base vs styled), `:usage`, or `:block`; call it as
`<PreviewComponent.preview ...>`. Code snippets are highlighted server-side by
`FlintUIDocsWeb.Highlight` (Makeup).

The docs site is itself a styled-layer consumer: `docs/lib/flint_ui_docs_web/components.ex`
is generated by `mix flint.add --all`, and the app stylesheet imports the assembled
`priv/static/flint.css`. The headless base and the generated components share
the `<.button>` name, so the generated module is referenced explicitly (aliased)
rather than imported into the docs' HTML helpers.

### Preview/code parity

A preview and its Code tab are two views of the same example, so they must agree.
A test asserts no snippet contains a `...` placeholder; the rest is convention:

- The Code tab is complete, copy-pasteable HEEx that renders the same markup as the
  preview. No `...` or elided content.
- Previews must not depend on docs-private helpers; if a helper is used, its source
  is part of the snippet.
- Prefer composing FlintUI components over bespoke markup. When a component's theme
  does not own a look, compose a generated component that does (`<.button variant=…>`,
  `<.icon>`) and show that composition in the snippet.
- Raw Tailwind is reserved for layout the design system does not own (containers,
  spacing, the `max-w-*` canvas); when it is used, the exact classes appear in the
  snippet. Share them through a helper so the preview and the snippet cannot drift.
- `usage/0` entries document one attribute with minimal, literal markup; `examples/0`
  show full composition. Both must match their `render_*` output, so update the
  `code` string and the render together.
- Live playgrounds derive their snippet from `render_code/1`; keep it in step with
  `render_playground/1`.
- Examples whose styling relies on Tailwind carry two code flavors — `Tailwind`
  (utilities; this is what the preview renders) and `CSS` (the same example with
  semantic classes plus a companion stylesheet in `styles`). Declare them with
  `codes: [%{label, lang, code, styles?}]` on a `usage/0`/`examples/0` entry, or
  return a flavor list from `render_code/1`; a single `code`/string still works.
  The flavor switcher lives inside the Code tab.

When adding a multi-part component, set `data-element` on the root only; parts carry
`data-part`. This keeps the root-only presence hook meaningful and lets a part be
another FlintUI component without clobbering that child's `data-element`-keyed theme.

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
  `class` and the base attributes folded into `rest`); slot declarations are the
  base's own slots (from `FlintUI.Docs.slots/1`) merged with the entry's extra
  slots. Never bake Tailwind classes into a wrapper.
- **Themes are CSS**, assembled from parts under `priv/templates/`
  (`tokens.css`, the shared `base.css` rules, then `styled/<name>.css`, colocated
  with the wrapper template). `FlintUI.Generator.theme_source/0` concatenates
  them (tokens first, then `base.css`, then components in registry order), and
  the `:flint_theme` Mix compiler
  (`Mix.Tasks.Compile.FlintTheme`) writes the aggregate to `priv/static/flint.css`
  for the docs to import. `mix flint.setup`/`flint.theme` write that same aggregate
  to the host's `assets/css/flint.css`. Tokens are prefixed `--fl-*`, with automatic
  light/dark via `color-scheme` + `light-dark()` and named themes via
  `[data-theme="…"]`. Component rules live in `@layer components` and are keyed on
  the wrapper hooks, so the headless base stays unstyled.
- **Tailwind is optional.** `mix flint.setup --tailwind` / `mix flint.theme --tailwind`
  patch the host stylesheet with an `@theme inline` bridge from `--fl-*` to utilities.
  Never add Tailwind as a dependency of the library.
- **Tasks** (`lib/mix/tasks/flint.*.ex`) are Igniter tasks guarded by
  `Code.ensure_loaded?(Igniter)`, so they compile only when Igniter is present.
  `flint.setup` wires the module and theme, `flint.add` generates wrappers into
  `MyAppWeb.Components`, and `flint.theme` refreshes the stylesheet.

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
4. `docs/lib/flint_ui_docs_web/component_docs/foo.ex` - a
   `FlintUIDocsWeb.ComponentDocs.Page` with `controls/0`, `usage/0` (base/styled
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
