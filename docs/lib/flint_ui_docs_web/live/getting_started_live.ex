defmodule FlintUIDocsWeb.GettingStartedLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @commands [
    {"mix flint.setup",
     "Create the components module, install the theme, and register the JS hooks."},
    {"mix flint.setup --tailwind", "Also map tokens onto Tailwind utilities."},
    {"mix flint.add <name>", "Generate a styled component wrapper."},
    {"mix flint.add --all", "Generate every registered component."},
    {"mix flint.theme", "Refresh the generated theme stylesheet from the library."},
    {"mix flint.icons <set>", "Install icon assets with Tailwind or plain CSS."},
    {"mix flint.icons flags --assets", "Copy flag SVGs for the <.flag> component."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Installation", commands: @commands)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:getting_started} page={:installation}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Installation"
          subtitle="FlintUI ships accessible, unstyled components, plus a styled layer you generate into your own app. Theming is plain CSS, so Tailwind is optional."
        />

        <DocsComponents.section title="1. Add the dependency" id="install">
          <DocsComponents.code_block code={snippet(:dependency)} lang={:elixir} />
          <DocsComponents.content_paragraph class="mt-3">
            Then run <code class="docs-code font-mono">mix deps.get</code>.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="2. Set up the theme" id="setup">
          <DocsComponents.code_block code="mix flint.setup" lang={:shell} />
          <DocsComponents.content_paragraph class="mt-3">
            This creates <code class="docs-code font-mono">MyAppWeb.Components</code>, copies the
            theme stylesheet to <code class="docs-code font-mono">assets/css/flint.css</code>, imports
            it, wires the components module into your HTML helpers, and registers FlintUI's
            LiveView hooks in <code class="docs-code font-mono">assets/js/app.js</code>.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Using Tailwind? Pass <code class="docs-code font-mono">--tailwind</code>
            to also map the
            FlintUI tokens onto utilities (<code class="docs-code font-mono">bg-primary</code>, <code class="docs-code font-mono">border-default</code>, …).
            Pass <code class="docs-code font-mono">--no-js</code>
            if you wire <code class="docs-code font-mono">app.js</code>
            yourself.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code="mix flint.setup --tailwind" lang={:shell} />
        </DocsComponents.section>

        <DocsComponents.section title="3. Brand colors (optional)" id="colors">
          <DocsComponents.content_paragraph>
            Override semantic tokens in your app stylesheet, after the theme
            import. The soft, surface, and outline label derives from the fill,
            so a role needs only its fill and solid label:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:brand)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            For a full <code class="docs-code font-mono">50..950</code>
            scale, map the
            role shades to the palette you already have. With Tailwind, point
            them at the <code class="docs-code font-mono">--color-*</code>
            variables in <code class="docs-code font-mono">app.css</code>; without Tailwind, paste the
            literal scale. The role tokens stay the only color contract.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="4. Generate components" id="generate">
          <DocsComponents.content_paragraph>
            Generate the styled wrappers you need. They are written into your app, so you
            own and can edit them.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:add)} lang={:shell} />
        </DocsComponents.section>

        <DocsComponents.section title="5. Use a component" id="usage">
          <DocsComponents.content_paragraph>
            Generated components are imported from <code class="docs-code font-mono">MyAppWeb.Components</code>, so you use them with the
            familiar tag syntax:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:usage)} />
          <DocsComponents.content_paragraph class="mt-3">
            The headless base stays available explicitly — useful when you want full
            control and no default styling:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:headless)} />
        </DocsComponents.section>

        <DocsComponents.section title="Commands" id="commands">
          <table class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-muted uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Command</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-default">
              <tr :for={{command, description} <- @commands}>
                <td class="py-2 pr-4"><code class="docs-code font-mono">{command}</code></td>
                <td class="py-2 text-toned">{description}</td>
              </tr>
            </tbody>
          </table>
        </DocsComponents.section>

        <p class="mt-8 text-sm text-muted">
          Next: browse the <.link navigate="/components" class="docs-link">components</.link>
          or read about <.link navigate="/guides/theming" class="docs-link">theming</.link>.
        </p>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:dependency), do: ~s({:flint_ui, "~> 0.1"})

  defp snippet(:add) do
    """
    mix flint.add button
    mix flint.add toggle

    # or every component
    mix flint.add --all
    """
  end

  defp snippet(:brand) do
    """
    /* assets/css/app.css */
    @import "./flint.css";

    :root {
      --fl-color-primary: oklch(0.55 0.24 275);
      --fl-color-primary-content: oklch(1 0 0);
      /* Tinted, surface, outline, ghost, and link read -text. */
      --fl-color-primary-text: light-dark(
        oklch(0.491 0.27 292.581),
        oklch(0.702 0.183 293.541)
      );
    }
    """
  end

  defp snippet(:usage) do
    """
    <.button variant="solid" phx-click="save">Save</.button>

    <.toggle toggled>Bold</.toggle>
    """
  end

  defp snippet(:headless) do
    """
    <FlintUI.button class="my-own-class">Save</FlintUI.button>
    """
  end
end
