defmodule FlintUIDocsWeb.Theme.ThemesLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.Snippets

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Themes",
       themes: FlintUI.Theme.presets()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_themes}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Themes"
          subtitle="Presets override tokens only, so they compose with the selected palette and the light or dark scheme."
        />

        <DocsComponents.section title="Theme presets" id="presets">
          <DocsComponents.content_paragraph class="mt-3">
            FlintUI ships named presets. Select one by setting
            <code class="docs-code font-mono">data-theme</code>
            on the <code class="docs-code font-mono">&lt;html&gt;</code>
            element; a preset only overrides tokens, so it composes with the
            light/dark scheme and the selected palette. <strong>default</strong>
            has no stylesheet — it is the base <code class="docs-code font-mono">:root</code>
            theme — so selecting it clears <code class="docs-code font-mono">data-theme</code>.
            Pick one to preview it on this page:
          </DocsComponents.content_paragraph>
          <Layouts.theme_preset_picker themes={@themes} class="mt-3" />
          <DocsComponents.code_block code={Snippets.snippet(:presets)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Light and dark" id="light-dark">
          <DocsComponents.content_paragraph class="mt-3">
            Light and dark are automatic. To force a scheme, set
            <code class="docs-code font-mono">data-color-scheme</code>
            on the <code class="docs-code font-mono">&lt;html&gt;</code>
            element — the header's toggle does this. The scheme is independent
            of the selected preset.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:light_dark)} />
        </DocsComponents.section>

        <DocsComponents.section title="Custom themes" id="custom-themes">
          <DocsComponents.content_paragraph class="mt-3">
            Add a <code class="docs-code font-mono">[data-theme="…"]</code>
            block to your app CSS, after the theme import, then select it via <code class="docs-code font-mono">data-theme</code>.
            This site's own <code class="docs-code font-mono">brand</code>
            preset lives in <code class="docs-code font-mono">docs/assets/css/app.css</code>
            and is selectable in the preset picker above.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:custom)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Browse themes" id="browse">
          <DocsComponents.content_paragraph class="mt-3">
            A visual theme gallery and editor are on the way. For now, the
            <.link navigate={~p"/themes"} class="docs-link">Themes page</.link>
            is the preview surface, and this guide is the reference for the tokens
            behind it.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button navigate={~p"/themes"} variant="surface">
              Open themes
            </Components.button>
            <Components.button
              navigate={~p"/guides/theming/customizing"}
              variant="ghost"
              icon="lucide-wand-sparkles"
            >
              Customize a theme
            </Components.button>
          </div>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end
end
