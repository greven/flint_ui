# docs/AGENTS.md

Guidance for the FlintUI docs app (`docs/`). **NEVER append session logs or generic Elixir/Phoenix tutorials to this file.**

## Commands (run inside `docs/`)

- Single test: `mise exec -- mix test test/path/to_test.exs --max-failures 1`
- Full check (only when done): `mise exec -- mix precommit`
- Sync generated wrappers after library prop/template changes: `mise exec -- mix flint.update --force`

## Docs App Rules

- **Layouts & Components:** Begin LiveView templates with `<Layouts.app flash={@flash} ...>` (passing `current_scope` when in an authenticated `live_session`). Never call `<.flash_group>` outside `layouts.ex`.
- **Icons & Inputs:** Always use FlintUI's `<.icon name="lucide-..." />` (never inline `<svg>`) and `Components.input` for form fields (`CoreComponents.input/1` and `icon/1` were removed).
- **Page Authoring (`docs/lib/flint_ui_docs_web/docs/<name>.ex`):**
  - Implement `FlintUIDocsWeb.Docs.Page`: `base_docs/0`, `sections/0`, `render_section/1`, and `parts_demo/1` (use `@parts_id` for DOM ids).
  - Start every guide/component page with `<DocsComponents.page_header ...>` (never hand-roll `<h1>`).
  - Use `<Markdown.prose content="..." />` or `DocsComponents.content_paragraph/1` for body copy, `class="docs-link"` for HEEx links (never bare `underline`), and `class="docs-code font-mono"` for standalone inline code.
  - Component previews and snippets must use FlintUI `fl-*` utilities (`fl-cluster`, `fl-stack`, `fl-split`, atomics) so copied snippets don't depend on Tailwind. Keep Tailwind only for the docs shell or when demonstrating Tailwind-specific features (transitions, `data-*` variants, arbitrary values).
- **CSS & JS:** Tailwind v4 uses `@import "tailwindcss" source(none);` in `app.css` (never `@apply` or daisyUI). Never write inline `<script>` tags in HEEx; use `Phoenix.LiveView.ColocatedHook` (`name=".HookName"`) or external hooks in `assets/js/`.

## Testing Contract (Keep Lean & Non-Flaky)

- Assert DOM structure via `Phoenix.LiveViewTest` (`has_element?/2`, `element/2`) and `LazyHTML` using explicit element IDs (`#...`).
- **Never** assert exact raw HTML strings, class string order, or prose copy that frequently changes.
- Keep docs tests focused on route rendering, interactive preview events (`render_click`/`render_change`), and docs contract checks (missing attr/prop docs).
