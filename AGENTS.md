# AGENTS.md

Repository-wide guidance for agents working on FlintUI.

Only add a rule here when the code, tests, or docs cannot answer it. Prefer a
moduledoc, a CSS comment, or a docs page, and link to it instead of restating it.

## What this repo is

FlintUI ships an accessible, headless component layer plus a styled layer that
consumers generate into their own app. The docs site is a consumer of both.

- `lib/flint_ui/base/` — `FlintUI.Base.*`: the headless components.
- `lib/flint_ui/` — the `Component` behaviour, `API` (function generation),
  `Styled` registry, `Generator`, `Theme`, palette tooling, and Mix tasks.
- `priv/templates/` — styled wrapper templates (`styled/<name>.ex.eex`) and
  theme CSS parts (`tokens.css`, `base.css`, `themes/`, `styled/<name>.css`).
- `assets/` — the TypeScript hooks and the optional sound runtime, bundled to
  `priv/static/flint.js` and `flint-sound.js`. `priv/static/` is gitignored
  build output, and both bundles are listed in `package/0`, so a Hex build fails
  until `mix assets.build` has run.
- `test/` — base component, API, generator, palette, and theme-contract tests.
- `docs/` — the docs website, its own Mix project (see `docs/AGENTS.md`).

`mix` is not on `PATH`; run Elixir commands through `mise exec -- mix ...`.

## Commands

```sh
mise exec -- mix setup                  # deps + npm install + assets build
mise exec -- mix assets.build           # rebuild the priv/static bundles
mise exec -- mix assets.watch           # rebuild on change

mise exec -- mix format
mise exec -- mix compile --warnings-as-errors
mise exec -- mix test

cd docs && mise exec -- mix precommit   # docs: compile, format, test
cd docs && mise exec -- mix phx.server  # run the docs site
```

## Development status

FlintUI is pre-release and has no published release. Do not add compatibility
layers, deprecation shims, or migration paths for old component APIs: change the
API directly and update every internal consumer and doc in the same change.
Breaking changes are expected until the first release.

## Architecture

- **Base layer.** `FlintUI.Base.*` modules implement the `FlintUI.Component`
  behaviour. `FlintUI.API.component/2` generates the public function from the
  module's declared attrs, slots, moduledoc, and `build_attrs/1`; `use FlintUI`
  generates and imports them. `lib/flint_ui.ex` holds the component registry.
- **Styled layer.** Each `FlintUI.Styled.Entry` names the base, target, CSS
  part, props (`FlintUI.Styled.Prop`), slots (`FlintUI.Styled.Slot`), public CSS
  variables (`FlintUI.Styled.Var`), and token namespaces.
  `FlintUI.Generator.component_source/1` renders the wrapper from
  `priv/templates/styled/<name>.ex.eex`. Wrappers stay thin: declare props and
  slots, map props onto `data-*`, forward `class`/`rest` (whitelisted like the
  base contract), and delegate behavior to the base.
- **Theme.** `FlintUI.Generator.theme_source/0` concatenates `tokens.css`,
  `base.css`, the presets in `FlintUI.Theme`, then component CSS in registry
  order. The `:flint_theme` compiler writes `priv/static/flint.css` for the
  docs; `mix flint.setup`/`flint.theme` write the same aggregate to a host's
  `assets/css/flint.css`.
- **Naming.** Generated components are the primary `<.button>`/`<.toggle>`
  (import the host's components module). The headless base stays explicit
  (`FlintUI.button`, or a `prefix:`). The docs dogfood both, so the base is
  imported there with a prefix.

### Sources of truth

| Concern                                   | Source of truth                             |
| ----------------------------------------- | ------------------------------------------- |
| Base props, ARIA, keyboard, moduledoc     | `lib/flint_ui/base/<name>.ex`               |
| Styled props, slots, public CSS variables | `lib/flint_ui/styled/<name>.ex`             |
| Theme tokens and scales                   | `priv/templates/tokens.css`                 |
| Component CSS and its rationale           | `priv/templates/styled/<name>.css`          |
| Page content and examples                 | `docs/lib/flint_ui_docs_web/docs/<name>.ex` |
| Docs navigation and routes                | `docs/lib/flint_ui_docs_web/nav.ex`         |

### Design notes

`design/` holds contributor-only records of behavior decisions that are settled
but not fully shipped. Check it before changing an area it covers; when an entry
ships, move its contract into the moduledoc and docs page and delete the entry.

| Area                                              | Design note         |
| ------------------------------------------------- | ------------------- |
| Pending/loading actions, activation guards, forms | `design/pending.md` |

## Component rules

- **Accessibility first.** Prefer the native element that already carries the
  semantics. Document roles, states, and keyboard behavior in the moduledoc
  under `## Accessibility` and `## Keyboard`, and implement them in markup, not
  only in prose. Use React Aria and the WAI-ARIA Authoring Practices as the
  reference.
- **Metadata is part of the API.** Implement `meta/0`; add `parts_attrs/0`,
  `keyboard/0`, `events/0`, and `css_vars/0` when the component has them. They
  drive the docs tables.
- **Declare `flint_parts`.** A component with a `:global` attribute (usually
  `:rest`) must declare `attr :flint_parts, :map, default: nil, doc: false`
  immediately before `render/1`; compilation fails otherwise.
- **DOM contract.** Set `data-element` on the root only; parts carry
  `data-part`. A part that is another FlintUI component keeps its own
  `data-element`.
- **Group is child-agnostic.** `group.css` targets direct children, so any
  control can be joined. The only child names are in the `size` cascade; a new
  control opts in there. Group is not a complete toolbar (no roving focus or
  arrow keys), so do not document it as one.
- **No dependencies by accident.** Tailwind is never a library dependency.
  Elixir's built-in `JSON` is the JSON library; never add Jason. Prefer the
  standard library before adding a package.

## Styling contract

- **Tokens are the styling API.** Components read `--fl-*` custom properties;
  Tailwind is optional. Light/dark is automatic via `color-scheme` and
  `light-dark()`. Force a scheme with `data-color-scheme`; select a preset with
  `data-theme` (presets override tokens only, never `color-scheme`).
- **Semantic color roles** own a `50..950` scale plus three jobs: the bare role
  is the fill, `-content` is the label on that fill, and `-text` is the role as
  text on a neutral surface. Palette tooling picks the labels for AA; retinting a
  role by overriding its fill means setting the derived tokens too. `color`
  accepts semantic roles first; a raw color is a per-instance escape hatch for
  data-driven accents. A
  raw color is used exactly as the fill and its labels derive from it, but it
  does not participate in presets or the role contract. Prefer a role or a
  theme override for app-wide color.
- **Text tiers have jobs.** `text` is the default ink, `text-highlighted` is for
  headings and strong labels, `text-toned` is for secondary copy and
  descriptions, `text-muted` is meta and labels, and `text-dimmed` is
  placeholders and decoration. `text-dimmed` is below AA on purpose; never use
  it for readable content or interactive labels. On the full toned fill, prefer
  `text-toned` over `text-muted`.
- **Chrome ladders share three levels.** `muted` is the faint step, the bare
  token is the default, and `accented` is the strong step:
  `surface-muted` / `surface` / `surface-accented`, and `border-muted` /
  `border` / `border-accented`. Never use `muted` for a strong fill.
- **Neutral is inverted; surfaces are neutral.** `color="neutral"` is the plain
  black/white inverted surface, not the neutral hue ramp. Components that take
  no color (Card) use neutral surface tokens, never a hue.
- **Component inputs are a narrow escape hatch.** At most five public
  `--fl-<name>-*` inputs, and only for what a prop or theme token cannot
  express. `--_fl-*` is reserved for JS-published runtime values and is never
  documented as an input.
- **CSS lives in `@layer components`**, keyed on the wrapper's `data-*` hooks,
  so the base stays unstyled. Focus and control effects are shared theme
  tokens; respect `prefers-reduced-motion`.
- **Shared scales, no per-component shapes.** Buttons, toggles, and future form
  controls read `--fl-control-*` and `--fl-control-radius`; components with
  their own anatomy read the radius scale directly. There are no
  `--fl-<component>-radius` tokens.

## Recipes

### Add or change a base component

1. `lib/flint_ui/base/<name>.ex`: `use FlintUI.Component`, implement `meta/0`,
   `build_attrs/1`, and `render/1`, plus `parts_attrs/0` and `keyboard/0` when
   applicable. Declare attrs/slots and a moduledoc with `## Accessibility` and
   `## Keyboard`.
2. Register the component in `@components` in `lib/flint_ui.ex`, including any
   helper functions to delegate.
3. Add `test/base/<name>_test.exs` covering markup, states, and ARIA.
4. Update the styled entry/CSS and the docs page in the same change.

### Add a styled component

All four parts, in one change:

1. `lib/flint_ui/styled/<name>.ex` — the `FlintUI.Styled.Entry`: base, target,
   install command, CSS part, token namespaces, props, slots, public variables.
2. `priv/templates/styled/<name>.ex.eex` — the thin wrapper.
3. `priv/templates/styled/<name>.css` — a selector for every non-default prop
   value, keyed on `[data-element="<name>"][data-*="…"]`.
4. `docs/lib/flint_ui_docs_web/docs/<name>.ex` — the docs page.

`test/theme_contract_test.exs` fails if the CSS part is missing, a prop value
has no selector, a token namespace is undefined, or a component declares a
per-component radius token.

### Update docs

Read `docs/AGENTS.md` first. Page content is authored per component in
`docs/lib/flint_ui_docs_web/docs/<name>.ex`, not in the LiveView template. A
docs test fails unless every public base attribute and styled prop is covered by
`usage/0`, so new API is not done until its docs page covers it. Dogfood
FlintUI components in the docs; only deliberate unstyled demonstrations may
keep raw HTML.

### Definition of done

- `mise exec -- mix format`
- `mise exec -- mix compile --warnings-as-errors`
- `mise exec -- mix test`
- `cd docs && mise exec -- mix precommit` if anything under `docs/` changed.
- `mise exec -- mix assets.build` if anything under `assets/` changed; required
  before a Hex build.

## CoreComponents parity

FlintUI aims to cover the components `phx.new` ships in
`MyAppWeb.CoreComponents`. When a FlintUI component supersedes a core function:

1. Delete that function from
   `docs/lib/flint_ui_docs_web/components/core_components.ex`.
2. Migrate every usage to the FlintUI component.
3. Remove dead helpers (e.g. `show/2`, `hide/2`) and update imports.

This is mandatory, not cosmetic: `docs/lib/flint_ui_docs_web.ex` imports both
core and Flint components, so a duplicate name is a compile-time conflict.

| CoreComponents function                     | FlintUI equivalent  | Status                                                                                                                                                             |
| ------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `icon/1`                                    | `FlintUI.Base.Icon` | Shipped. Class-based (`name` is a CSS class); the docs wire Lucide via a Tailwind `matchComponents` plugin. Core `icon` deleted and usages migrated to `lucide-*`. |
| `flash/1` + bespoke `Layouts.flash_group/1` | none                | Future. Cover with a FlintUI flash/toast, then delete core `flash`, replace `flash_group/1`, and drop `show/2`/`hide/2` if unused.                                 |
| `input/1`                                   | none                | Future. Cover with a FlintUI field/input, then delete core `input`.                                                                                                |
| `header/1`, `table/1`, `list/1`             | none                | Future, only if FlintUI ships equivalents.                                                                                                                         |
| `translate_error/1`, `translate_errors/2`   | n/a                 | Stay in the app; not a parity target.                                                                                                                              |

## References

- **Accessibility** — [React Aria](https://react-spectrum.adobe.com/react-aria/)
  is the primary reference for roles, states, and keyboard interaction.
  Cross-check the [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
  and the [MDN ARIA reference](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA).
- **Phoenix LiveView components** — [Doggo](https://github.com/woylie/doggo) and
  [Corex](https://github.com/corex-ui/corex) for API and composition;
  [FluxonUI](https://fluxonui.com/) for coverage and design.
- **Component libraries** — [shadcn/ui](https://ui.shadcn.com),
  [Nuxt UI](https://ui.nuxt.dev), and [Mantine](https://mantine.dev) for layout,
  styling, and API inspiration.
