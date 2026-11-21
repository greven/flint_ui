defmodule FlintUIDocsWeb.Theme.CssUtilitiesLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.Snippets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "CSS Utilities")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_css_utilities}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="CSS Utilities"
          subtitle="FlintUI ships no utility layer. Components read tokens, and utilities are an opt-in mapping you own."
        >
          <:meta>
            <div class="mt-4">
              <Components.badge variant="subtle" color="warning" size="sm" icon="lucide-hammer">
                Planned
              </Components.badge>
            </div>
          </:meta>
        </DocsComponents.page_header>

        <DocsComponents.section title="Opt-in utilities" id="utilities">
          <DocsComponents.content_paragraph class="mt-3">
            To use tokens as Tailwind utilities, map them in your own <code class="docs-code font-mono">@theme</code>.
            <code class="docs-code font-mono">mix flint.setup --tailwind</code>
            writes this for you. Colors map per utility family, so <code class="docs-code font-mono">text-default</code>, <code class="docs-code font-mono">bg-surface</code>,
            and <code class="docs-code font-mono">border-default</code>
            read the text, surface, and
            border tokens. Roles split the same way:
            <code class="docs-code font-mono">text-primary</code>
            is the AA text shade while <code class="docs-code font-mono">bg-primary</code>
            is the fill.
            This needs Tailwind 4.1 or newer.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:tailwind)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            The mapping is optional. FlintUI works without Tailwind, and the
            components themselves never depend on a utility class.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="What comes next" id="planned">
          <DocsComponents.content_paragraph class="mt-3">
            A first-party utility layer is planned as an opt-in package, not a
            default. Until then, map the tokens you need in
            <code class="docs-code font-mono">@theme</code>
            or write plain CSS against the <code class="docs-code font-mono">--fl-*</code>
            variables.
          </DocsComponents.content_paragraph>
          <div class="mt-4 rounded-lg border border-default bg-subtle p-4 text-sm">
            <p class="font-medium text-default">No API to learn yet</p>
            <p class="mt-1 text-toned">
              The current mapping is the supported path. Any first-party
              utilities will build on the same tokens, so a theme you write today
              keeps working.
            </p>
          </div>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end
end
