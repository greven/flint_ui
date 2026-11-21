defmodule FlintUIDocsWeb.Theme.CustomizingLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.Snippets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Customizing")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_customizing}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Customizing"
          subtitle="Change the token that owns the decision. Start with a shared token, then remap a hue or override a single instance only when the broader change is wrong."
        />

        <DocsComponents.section title="Override a token" id="tokens">
          <DocsComponents.content_paragraph class="mt-3">
            Override a shared token in your app stylesheet, after the FlintUI
            import. Every component that reads the token follows, in both color
            schemes. Prefer the semantic token over a component input.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:token_override)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Override one instance" id="color-instance">
          <DocsComponents.content_paragraph class="mt-3">
            The <code class="docs-code font-mono">color</code>
            attribute selects a semantic role. To change a single instance
            without touching the theme, override the component's public color
            input — the rest of the variant derives from it.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:override_css)} lang={:css} />
          <DocsComponents.code_block code={Snippets.snippet(:override_heex)} lang={:heex} />
          <DocsComponents.content_paragraph class="mt-3">
            For scoping a change in general — theme, class, inline style, parts,
            and states — see <.link
              navigate={~p"/getting-started/styling"}
              class="docs-link"
            >Styling</.link>.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Retune the chrome" id="chrome">
          <DocsComponents.content_paragraph class="mt-3">
            <code class="docs-code font-mono">--fl-surface-base</code>
            is the single chrome anchor. The page defaults to a white mix of
            it, and surface and raised are white mixes of it, so changing this
            one token moves the whole ramp while keeping each step brighter.
            It defaults to <code class="docs-code font-mono">gray-950</code>, so remapping the
            gray hue still retints everything.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:chrome_base)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            A darker base — even black — makes a near-black dark page and a
            faintly tinted light page. A lighter base lifts the dark page.
            Surfaces stay a step brighter than the default page.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            For a smaller move, set <code class="docs-code font-mono">--fl-surface-page-tint</code>
            and <code class="docs-code font-mono">--fl-surface-page-lift</code>.
            Tint mixes ink into the light page; lift adds white to the dark
            page. Both carry the rungs above them, so every step keeps its
            spacing. They default to <code class="docs-code font-mono">0%</code>,
            and <code class="docs-code font-mono">1%</code>
            tint / <code class="docs-code font-mono">2%</code>
            lift is a subtle step.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            For an absolute page, set <code class="docs-code font-mono">--fl-surface-page-light</code>
            and <code class="docs-code font-mono">--fl-surface-page-dark</code>.
            A pure white light page is the top of the ladder, so solid cards
            resolve near white; separate them with borders or shadows, or use
            the tonal <code class="docs-code font-mono">surface-subtle</code>
            and <code class="docs-code font-mono">surface-strong</code>
            fills. A
            pure black dark page keeps the anchored surfaces, so cards stay a
            step brighter.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:page_extremes)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            Text has its own anchor. Set <code class="docs-code font-mono">--fl-text-base</code>
            to retune the body ink; the highlighted, toned, muted, and dimmed
            tiers follow.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Remap a hue" id="remapping-a-hue">
          <DocsComponents.content_paragraph class="mt-3">
            Each palette hue is eleven shade variables plus five derived tokens.
            The derived tokens reference the ramp, so remapping the eleven shades
            updates the fill, label, on-soft text, and tinted treatments together. This is
            the quickest way to make a shipped hue match your brand — for example,
            remap <code class="docs-code font-mono">rose</code>
            to a <code class="docs-code font-mono">brand</code>
            scale.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:palette_css)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            The palette's <code class="docs-code font-mono">gray</code>
            hue drives the whole chrome through <code class="docs-code font-mono">--fl-surface-base</code>:
            page, cards, tints, text tiers, borders, and the secondary role.
            Remap it to warm or cool every surface at once.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:neutral_palette)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Remap a role" id="role-remap">
          <DocsComponents.content_paragraph class="mt-3">
            To change what a semantic role points at, override the role's five
            tokens. That keeps the semantic name and lets a palette switch retint
            the brand.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:brand_css)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Custom hues" id="custom-hues">
          <DocsComponents.content_paragraph class="mt-3">
            Add an app-specific hue name in config, then generate its ramp:
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Names that would shadow a semantic role or chrome token — <code class="docs-code font-mono">primary</code>, <code class="docs-code font-mono">text</code>, <code class="docs-code font-mono">surface</code>, <code class="docs-code font-mono">border</code>, and so on — are reserved.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:custom_hues_config)} />
          <DocsComponents.code_block code={Snippets.snippet(:custom_hues)} lang={:sh} />
          <DocsComponents.content_paragraph class="mt-3">
            The generated file contains the eleven shades, the five derived
            tokens, and the base and active hooks. Import it after <code class="docs-code font-mono">flint.css</code>, then
            <code class="docs-code font-mono">color="brand"</code>
            works like any shipped hue. Use
            <code class="docs-code font-mono">--from tailwind:rose</code>
            to copy an existing ramp instead of seeding one.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:custom_hues_use)} lang={:heex} />
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end
end
