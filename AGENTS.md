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
- The root `.formatter.exs` covers the root and `dev/` only. `docs/` has its own `.formatter.exs` with the `Phoenix.LiveView.HTMLFormatter` plugin.

## Conventions

### Dogfood FlintUI components in the docs

Use FlintUI's own components in the docs site whenever one covers the markup. When a new
FlintUI component supersedes a bespoke pattern in the docs, replace the bespoke markup in
the same change that adds the component. This exercises components in real use while they
are being built.

Exception: the modules under `docs/lib/flint_ui_docs_web/examples/` may keep raw HTML when
they are deliberately demonstrating the unstyled component API.

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

### Use the built-in `JSON` module

Elixir 1.18+ ships a `JSON` module that implements the interface `Phoenix.json_library/0`
expects (`encode!/1`, `decode!/1`, `encode_to_iodata!/1`). Configure it with
`config :phoenix, :json_library, JSON` (root `config/config.exs` and `docs/config/config.exs`)
and **never add Jason** as a dependency.

## References

Prefer these authoritative sources when implementing a component:

- **Accessibility** — [React Aria](https://react-spectrum.adobe.com/react-aria/) is the
  primary reference for ARIA roles, states, properties, and keyboard interaction.
  Cross-check against the [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
  and the [MDN ARIA reference](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA).
  Consult them before choosing roles, states, and keyboard behavior, and record the result in
  the component's `## Accessibility` and `## Keyboard` docs (see `FlintUI.Button`).

- **Phoenix LiveView components** — reference existing libraries when shaping APIs and
  composition: [Doggo](https://github.com/woylie/doggo) and
  [Corex](https://github.com/corex-ui/corex). [FluxonUI](https://fluxonui.com/) is closed
  source but useful as a reference for design and component coverage.

- **Component libraries** — draw layout, styling, and API inspiration from
  [shadcn/ui](https://ui.shadcn.com), [Nuxt UI](https://ui.nuxt.dev), and
  [Mantine](https://mantine.dev/).

## `core_components` parity status

| CoreComponents function | FlintUI equivalent | Status |
| --- | --- | --- |
| `icon/1` | `FlintUI.Icon` | Shipped. Class-based (`name` is a CSS class); the docs wire Lucide via a Tailwind `matchComponents` plugin. Core `icon` deleted and usages migrated to `lucide-*`. |
| `flash/1` + bespoke `Layouts.flash_group/1` | none | Future. Cover with a FlintUI flash/toast, then delete core `flash`, replace `flash_group/1`, and drop `show/2`/`hide/2` if unused. |
| `input/1` | none | Future. Cover with a FlintUI field/input, then delete core `input`. |
| `header/1`, `table/1`, `list/1` | none | Future, only if FlintUI ships equivalents. |
| `translate_error/1`, `translate_errors/2` | n/a | Stay in the app; not a parity target. |
