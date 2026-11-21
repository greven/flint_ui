defmodule FlintUIDocsWeb.Theme.ColorLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.Snippets

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Color",
       palettes: FlintUI.Palette.presets(),
       hues: FlintUI.Palette.hue_names()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_color}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Color"
          subtitle="Color has three layers: a palette of raw hues, semantic roles that point at those hues, and a color prop that selects either one."
        />

        <DocsComponents.section title="Palettes" id="palettes">
          <DocsComponents.content_paragraph class="mt-3">
            A palette is the color spectrum: eighteen hues, each with a
            <code class="docs-code font-mono">50..950</code>
            scale. It answers <em>what is pink?</em>
            without deciding what pink means.
            The default palette mirrors Tailwind; every other palette retunes the
            same eighteen hue names, so <code class="docs-code font-mono">color="pink"</code>
            follows whichever palette is active.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Select one with <code class="docs-code font-mono">data-palette</code>
            on the <code class="docs-code font-mono">&lt;html&gt;</code>
            element. Palettes compose with themes and schemes: any theme, any
            palette, either scheme. Clearing the attribute selects the default.
          </DocsComponents.content_paragraph>
          <Layouts.palette_picker palettes={@palettes} class="mt-3" />
          <div class="mt-4 grid grid-cols-3 gap-2 sm:grid-cols-6">
            <button
              :for={hue <- @hues}
              type="button"
              data-copy
              data-copy-value={"var(--fl-color-#{hue})"}
              data-copy-success-label={"Copied var(--fl-color-#{hue})"}
              aria-label={"Copy var(--fl-color-#{hue})"}
              class={[
                "group cursor-pointer overflow-hidden rounded-lg border border-default text-left transition",
                "hover:border-strong focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-strong"
              ]}
            >
              <span class="block h-8" style={"background: var(--fl-color-#{hue});"} />
              <span class="block h-3" style={"background: var(--fl-color-#{hue}-soft);"} />
              <span class="flex items-center justify-between gap-1 px-2 py-1.5">
                <span class="font-mono text-xs text-toned">{hue}</span>
                <span class="relative flex size-3.5 shrink-0 items-center justify-center">
                  <FlintUI.icon
                    name="lucide-copy"
                    class="size-3 text-dimmed transition group-hover:text-default group-data-[state=success]:hidden"
                  />
                  <FlintUI.icon
                    name="lucide-check"
                    class="hidden size-3 text-success group-data-[state=success]:block"
                  />
                </span>
              </span>
            </button>
          </div>
          <DocsComponents.content_paragraph class="mt-3 text-xs">
            Click a swatch to copy its CSS variable, for example <code class="docs-code font-mono">var(--fl-color-rose)</code>.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:palettes)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Palette hues" id="palette-colors">
          <DocsComponents.content_paragraph class="mt-3">
            The <code class="docs-code font-mono">color</code>
            attribute also accepts any of the eighteen palette hues.
            <code class="docs-code font-mono">color="pink"</code>
            uses the active palette's core pink; the prop names a hue, not a
            shade. A specific shade is a CSS escape hatch — set the tone set
            (<code class="docs-code font-mono">--fl-tone</code>
            and its companions)
            or remap the hue in your app stylesheet.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            A hue is not a role: it does not follow role remaps, but it does follow
            the palette and the light/dark scheme. Use it for decoration,
            data-driven accents, and one-off examples. For anything app-wide, map
            a role instead — see <.link
              navigate={~p"/guides/theming/customizing#role-remap"}
              class="docs-link"
            >Remap a role</.link>.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button color="rose">Rose</Components.button>
            <Components.button color="emerald">Emerald</Components.button>
            <Components.button variant="solid" color="sky">Sky</Components.button>
          </div>
          <DocsComponents.code_block code={Snippets.snippet(:palette_colors)} />
        </DocsComponents.section>

        <DocsComponents.section title="Color roles" id="color-roles">
          <DocsComponents.content_paragraph class="mt-3">
            Semantic roles alias palette hues. A role owns no scale; it points at
            one hue's five-token tone set: the fill
            (<code class="docs-code font-mono">-primary</code>), the label on that
            fill (<code class="docs-code font-mono">-primary-on</code>), the
            role as text on a neutral or soft surface
            (<code class="docs-code font-mono">-primary-on-soft</code>), and the tint
            pair (<code class="docs-code font-mono">-primary-soft</code>, <code class="docs-code font-mono">-primary-soft-border</code>).
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            <strong>primary</strong>
            is the brand slot. Unbranded, it follows the neutral ink, so a fresh
            app is monochrome until a theme maps primary to a hue. <strong>neutral</strong>
            is the page's opposite — dark in light and light in dark — and the
            unbranded primary aliases it. <strong>secondary</strong>
            follows the palette's gray; <strong>info</strong>
            blue; <strong>success</strong>
            green; <strong>warning</strong>
            amber; and <strong>error</strong>
            red. A
            palette switch changes what those hues look like; a role override
            changes which hue a role points at.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button
              :for={role <- ~w(neutral info success warning error secondary)}
              variant="surface"
              color={role}
            >
              {role}
            </Components.button>
            <Components.button variant="surface" color="cyan">cyan</Components.button>
            <Components.button variant="surface" color="pink">pink</Components.button>
          </div>
          <DocsComponents.code_block code={Snippets.snippet(:colors)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            For the variable-level reference, see
            <.link
              navigate={~p"/guides/theming/tokens/colors"}
              class="docs-link"
            >Colors</.link>
            under Design Tokens.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Absolute tones" id="absolute">
          <DocsComponents.content_paragraph class="mt-3">
            <code class="docs-code font-mono">neutral</code>
            is the page's opposite: it is dark in light and light in dark. For a fill
            that must not follow the scheme — a control composed against a fixed
            surface or another component — use the absolute tones
            <code class="docs-code font-mono">dark</code>
            and <code class="docs-code font-mono">light</code>
            on any <code class="docs-code font-mono">color</code>
            attribute. They are not semantic
            roles: they have no scale and are not offered in the component examples or
            pickers. They alias the palette gray extremes, so retinting the neutral ramp
            retints them too, and a theme can override the fill and label pair directly.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button variant="solid" color="dark">Dark</Components.button>
            <Components.button variant="solid" color="light">Light</Components.button>
            <Components.button variant="surface" color="dark">Dark surface</Components.button>
            <Components.button variant="surface" color="light">Light surface</Components.button>
          </div>
          <DocsComponents.code_block code={Snippets.snippet(:absolute)} lang={:css} />
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end
end
