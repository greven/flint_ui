# AGENTS.md

Repository guidance for FlintUI. **NEVER append session logs, progress notes, or new sections to this file.** Only add a rule if a test or compiler cannot enforce it; put component details in `@moduledoc` or `docs/` instead.

## Commands (`mix` requires `mise exec --`)

- Single test (default during dev): `mise exec -- mix test test/path/to_test.exs --max-failures 1`
- Full check (only before finishing): `mise exec -- mix format && mise exec -- mix compile --warnings-as-errors && mise exec -- mix test`
- Assets (`priv/static/` is gitignored; required before Hex build): `mise exec -- mix assets.build`
- Docs (run when `docs/` or wrappers change): `cd docs && mise exec -- mix flint.update --force && mise exec -- mix precommit`
- Custom hue: `mise exec -- mix flint.palette brand --from "#8b5cf6"`

## Core Rules

- **Pre-release:** No deprecation shims or compatibility layers. Change APIs directly and update all internal consumers, wrappers, and docs in the same commit.
- **No accidental deps:** Use Elixir's built-in `JSON` (never `Jason`), standard library, and optional Tailwind. Floating UI is bundled in `priv/static/flint.js` and imported **only** in `assets/src/lib/position.ts`.
- **Tool preference:** Prefer Tidewave MCP (`get_source_location`, `project_eval`, `get_docs`) over `grep` and shell exploration when the docs server is running.

## Architecture & Sources of Truth

- **Base (`lib/flint_ui/base/<name>.ex`):** Implements `FlintUI.Component` (`meta/0`, `build_attrs/1`, `render/1`, plus `parts_attrs/0`, `keyboard/0`, `events/0`, `css_vars/0`, `states/0` as needed). Registered in `lib/flint_ui.ex`. Components with `:global` attrs must declare `attr :flint_parts, :map, default: nil, doc: false` right before `render/1`.
- **DOM & Focus:** `data-element` on root only; `data-part` on parts (nested FlintUI components keep `data-element`). `parts_attrs/0` is strictly in DOM order. Add bordered interactive controls' focused root to `priv/templates/focus.css` using `var(--fl-focus-border-color, revert-layer)`.
- **Styled (`lib/flint_ui/styled/<name>.ex`, `priv/templates/styled/<name>.{ex.eex,css}`):** Thin wrappers emitting `# flint_ui:` markers; call only base components and frozen seam (`FlintUI.Styled.Color`, `.Size`, `.ContainerSize`). Bump `FlintUI.Generator.wrapper_api/0` when changing templates, props, or forwarded attrs/slots.
- **Primitives & Tokens (`priv/templates/`):** Controls opt into `data-control` (`primitives/control.css`); fields opt into `data-field` + `data-field-control` (`primitives/field.css`). Component CSS lives in `@layer components`, keeps anatomy only, has selectors for every non-default prop, and **never** defines `--fl-<component>-radius` or exceeds 5 `--fl-<name>-*` vars (`--_fl-*` is JS-internal). Utilities live in `FlintUI.Utilities` (`fl-` prefix, `@layer utilities`), never in `Generator.part_paths/0`.
- **Color & Surface Tokens:** `color` accepts semantic roles (`primary`, `secondary`, `info`, `success`, `warning`, `danger`), `neutral` (inverted black/white), `inherit`, or the 18 palette hues (`palettes/*.css`). Text tiers (`text`, `text-highlighted`, `text-toned`, `text-muted`, `text-dimmed`—never use `dimmed` for readable text) derive from `--fl-text-base`. Chrome ladder (`background`, `surface`, `surface-raised`, `surface-subtle` 3%, `surface-strong` 6%, `border-subtle` 7%, `border` 10%, `border-strong` 18%) derives from `--fl-surface-base`.
- **Design notes (`design/`):** Check before touching covered areas (e.g., `design/pending.md`); delete note once shipped and documented.

## Testing Contract (Keep Lean & Non-Flaky)

- **No brittle HTML/CSS assertions:** Never assert exact class strings, whitespace, inline style order, or generated hash strings. Assert semantic DOM (`data-element`, `data-part`, `data-*` state hooks, ARIA attributes) via `LazyHTML` / `Floki` or `Phoenix.LiveViewTest.render_component/2`.
- **Core behavior only:** Write 1 focused test file per component (`test/base/<name>_test.exs`, `test/styled/<name>_test.exs`). Test default render, key prop -> `data-*` mappings, slot rendering, and ARIA/keyboard attributes. Do not test CSS cascade or duplicate checks already enforced by `test/theme/contract_test.exs` and `test/generator/seam_test.exs`.
- **Targeted runs:** Always run the single changed test file during iteration; run full `mix test` only once at the end.

## Docs (`docs/AGENTS.md` + `docs/lib/flint_ui_docs_web/docs/<name>.ex`)

- Implement `FlintUIDocsWeb.Docs.Page` (`base_docs/0`, `sections/0`, `render_section/1`, `parts_demo/1` using `@parts_id`). Start pages with `<DocsComponents.page_header ...>`; use `<Markdown.prose>` or `class="docs-link"` (never bare `underline`).
- **CoreComponents parity:** When shipping a `CoreComponents` replacement (`flash`, `table`, `list`), delete it from `docs/lib/flint_ui_docs_web/components/core_components.ex` and migrate all usages in the same change.
