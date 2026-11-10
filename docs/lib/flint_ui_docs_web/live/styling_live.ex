defmodule FlintUIDocsWeb.StylingLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Markdown

  @impl true
  def mount(_params, _session, socket) do
    pages =
      FlintUI.components()
      |> Enum.sort()
      |> Enum.map(fn name -> {name, Docs.styling(name)} end)
      |> Enum.reject(fn {_name, styling} -> is_nil(styling) end)

    {:ok, assign(socket, page_title: "Styling", pages: pages)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:getting_started} page={:styling}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Styling"
          subtitle="FlintUI has two layers: headless base components that ship behavior and data-* hooks, and a generated styled layer that is plain CSS you own. Both accept the same small set of styling tools, so a change works the same way whichever layer you render."
        />

        <DocsComponents.section title="Where a change belongs" id="scope">
          <DocsComponents.content_paragraph>
            Start from the narrowest place that solves the problem. Reaching further than
            you need is how a design system turns into a pile of one-off overrides.
          </DocsComponents.content_paragraph>
          <div class="mt-4 overflow-x-auto">
            <table class="w-full min-w-xl text-left text-sm">
              <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
                <tr>
                  <th class="py-3 pr-6 font-medium">Need</th>
                  <th class="py-3 pr-6 font-medium">Reach for</th>
                  <th class="py-3 font-medium">Scope</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-default">
                <tr class="align-top">
                  <td class="py-3 pr-6">Change the look across the app</td>
                  <td class="py-3 pr-6 text-toned">
                    Theme token or preset
                  </td>
                  <td class="py-3 text-toned">Every component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change one value on one instance</td>
                  <td class="py-3 pr-6 text-toned">
                    <code class="docs-code font-mono">style</code>
                    with a custom property or declaration
                  </td>
                  <td class="py-3 text-toned">That element</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change several properties on one instance</td>
                  <td class="py-3 pr-6 text-toned">
                    <code class="docs-code font-mono">class</code> with utilities or a CSS rule
                  </td>
                  <td class="py-3 text-toned">That element</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Style a part of a component</td>
                  <td class="py-3 pr-6 text-toned">
                    <code class="docs-code font-mono">class</code>
                    on the root plus <code class="docs-code font-mono">[data-part]</code>
                  </td>
                  <td class="py-3 text-toned">That component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Style a built-in state</td>
                  <td class="py-3 pr-6 text-toned">
                    <code class="docs-code font-mono">data-*</code>
                    selector (<code class="docs-code font-mono">data-disabled</code>, <code class="docs-code font-mono">data-state</code>, …)
                  </td>
                  <td class="py-3 text-toned">That state</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Pick a mode the component models</td>
                  <td class="py-3 pr-6 text-toned">
                    Component attribute (<code class="docs-code font-mono">variant</code>, <code class="docs-code font-mono">color</code>, <code class="docs-code font-mono">size</code>, …)
                  </td>
                  <td class="py-3 text-toned">That component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change a component permanently</td>
                  <td class="py-3 pr-6 text-toned">
                    The generated wrapper or your app CSS
                  </td>
                  <td class="py-3 text-toned">Your app</td>
                </tr>
              </tbody>
            </table>
          </div>
          <DocsComponents.content_paragraph class="mt-4">
            Theme-wide changes are plain CSS in your app stylesheet, after the
            <code class="docs-code font-mono">flint.css</code>
            import. See <.link navigate={~p"/guides/theming"} class="docs-link">Theming</.link>
            for the token list, presets, and how to override them.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Attributes such as <code class="docs-code font-mono">variant</code>, <code class="docs-code font-mono">color</code>, and
            <code class="docs-code font-mono">size</code>
            belong to the <strong>generated styled components</strong>. The headless base
            (<code class="docs-code font-mono">FlintUI.button/1</code>, …) is unstyled by design: it
            renders the same markup, behavior, and <code class="docs-code font-mono">data-*</code>
            hooks, and you bring all of the CSS.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Root class" id="class">
          <DocsComponents.content_paragraph>
            Every component forwards <code class="docs-code font-mono">class</code>
            and the rest of your attributes onto its root element and marks itself with <code class="docs-code font-mono">data-element</code>. Style the root, or any part it
            exposes, with a plain selector.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:class)} />
          <DocsComponents.content_paragraph class="mt-3">
            The theme ships in <code class="docs-code font-mono">@layer components</code>, so a
            utility class or an unlayered rule of your own wins over it without <code class="docs-code font-mono">!important</code>. An inline
            <code class="docs-code font-mono">style</code>
            wins over both. That ordering is intentional: the theme is the floor, your
            classes are the day-to-day override, and inline styles are for one-offs.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="One-off values" id="style">
          <DocsComponents.content_paragraph>
            Every component accepts <code class="docs-code font-mono">style</code>: it is a global
            HTML attribute, and the wrappers forward the rest of your attributes to the
            root. Use it for a single value on a single element, normally one of the
            component's public custom properties.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button variant="solid">Default</Components.button>
            <Components.button
              variant="solid"
              style="--fl-button-color: #7c3aed; --fl-button-color-content: #ffffff"
            >
              Custom
            </Components.button>
          </div>
          <DocsComponents.code_block code={snippet(:style)} />
          <DocsComponents.content_paragraph class="mt-3">
            Inline styles cannot express <code class="docs-code font-mono">:hover</code>,
            pseudo-elements, or another part. A class can, and a utility library's
            arbitrary variants can too, as described in <a href="#utilities" class="docs-link">Utility CSS</a>.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-4">
            If you use Tailwind or another utility library, you can often skip
            <code class="docs-code font-mono">style</code>
            entirely. Utilities are emitted in a later cascade layer than the theme, so
            they win without <code class="docs-code font-mono">!important</code>:
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button
              variant="solid"
              class="bg-violet-600 text-white hover:bg-violet-500"
            >
              Utilities
            </Components.button>
          </div>
          <DocsComponents.code_block code={snippet(:tailwind_one_off)} />
          <DocsComponents.content_paragraph class="mt-4">
            Component variables (<code class="docs-code font-mono">--fl-button-*</code>, <code class="docs-code font-mono">--fl-card-*</code>, …) are the supported per-instance
            inputs. Each component's <strong>CSS</strong>
            tab lists its public variables and what derives from them. Set them inline for
            one element, or from a class when several properties change together:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:vars_heex)} />
          <DocsComponents.code_block code={snippet(:vars_css)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-4">
            For a color, the generated wrappers offer a shortcut:
            <code class="docs-code font-mono">color="#7c3aed"</code>
            sets the fill and derives the content and text inputs for you. Keep the
            variables for the cases that are not a single color.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Parts" id="parts">
          <DocsComponents.content_paragraph>
            A component marks its root with <code class="docs-code font-mono">data-element</code>
            and each internal part with <code class="docs-code font-mono">data-part</code>. Put a
            class on the root, then select the part. The hooks are the same in both
            layers.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:parts)} />
          <DocsComponents.content_paragraph class="mt-3">
            Slot content is your own markup, so wrap it when you need a handle inside a
            slot. Slots only accept the attributes a component declares for them, not
            global ones.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="State" id="state">
          <DocsComponents.content_paragraph>
            State such as disabled, loading, open, or pressed is reflected as
            <code class="docs-code font-mono">data-*</code>
            attributes (and the matching ARIA attributes), so you can style it without
            tracking state yourself. Each component's Base tab documents the exact hooks
            it sets.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:state)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Utility CSS" id="utilities">
          <DocsComponents.content_paragraph>
            Tailwind is optional, and FlintUI is not coupled to it. Utilities are just
            classes on the root, and Tailwind emits them in
            <code class="docs-code font-mono">@layer utilities</code>
            — after the theme's <code class="docs-code font-mono">@layer components</code>
            — so
            they win without <code class="docs-code font-mono">!important</code>. UnoCSS, your own
            atomic classes, or any unlayered stylesheet behave the same way.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:utilities)} />
          <DocsComponents.content_paragraph class="mt-4">
            Arbitrary variants reach parts and states, so most one-off styling never
            needs a stylesheet at all:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:variants)} />
          <DocsComponents.content_paragraph class="mt-4">
            Utilities only change the properties they name. Component state follows
            the theme: focus is one shared ring, and the <code class="docs-code font-mono">ring</code>
            preset also colors the border, driven by <code class="docs-code font-mono">--fl-focus-ring-color</code>, <code class="docs-code font-mono">--fl-focus-border-color</code>, and the other
            <code class="docs-code font-mono">--fl-focus-ring-*</code>
            tokens, so retinting it once updates every component. Set the token
            on <code class="docs-code font-mono">:root</code>, or use
            <code class="docs-code font-mono">data-focus</code>
            to switch the whole app between the <code class="docs-code font-mono">ring</code>, <code class="docs-code font-mono">outline</code>, and
            <code class="docs-code font-mono">inset</code>
            presets.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            To use FlintUI tokens as utilities too — <code class="docs-code font-mono">bg-primary</code>, <code class="docs-code font-mono">border-default</code>, … — map them once with <code class="docs-code font-mono">mix flint.setup --tailwind</code>. The
            <.link navigate={~p"/guides/theming"} class="docs-link">Theming</.link>
            guide covers the bridge.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Attributes first" id="attributes">
          <DocsComponents.content_paragraph>
            When a component already models a change, use the attribute. <code class="docs-code font-mono">variant</code>, <code class="docs-code font-mono">color</code>, <code class="docs-code font-mono">size</code>, and
            boolean modes such as <code class="docs-code font-mono">outline</code>
            or <code class="docs-code font-mono">depth</code>
            are covered by the theme, so they keep working across presets and color
            schemes.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:attributes)} />
          <DocsComponents.content_paragraph class="mt-3">
            Attributes describe structure or a mode; they are not a styling language.
            There is no <code class="docs-code font-mono">border</code>
            prop. <code class="docs-code font-mono">color</code>
            accepts a semantic role, or a raw CSS color for a one-off accent or a value
            that comes from data; the component derives its label and text colors from
            it. Raw colors do not follow presets, so use a role (or a theme override)
            when the color is part of the system.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button color="#1D72FE" variant="solid">Raw color</Components.button>
            <Components.toggle color="#1D72FE" pressed>Bold</Components.toggle>
          </div>
          <DocsComponents.code_block code={snippet(:raw_color)} />
        </DocsComponents.section>

        <DocsComponents.section :if={@pages != []} title="By component" id="components">
          <DocsComponents.content_paragraph>
            These are the plain-CSS recipes for the headless components. Each block
            targets the hooks the component exposes; the styled layer uses the same
            markup, so the rules apply to it too.
          </DocsComponents.content_paragraph>
          <DocsComponents.subsection
            :for={{name, styling} <- @pages}
            title={humanize(name)}
            id={to_string(name)}
          >
            <Markdown.prose :if={styling[:body]} content={styling[:body]} />
            <div :for={snippet <- styling.snippets} class="mt-4">
              <p class="text-sm font-medium">{snippet.title}</p>
              <DocsComponents.code_block code={snippet.code} lang={:css} />
            </div>
          </DocsComponents.subsection>
        </DocsComponents.section>

        <p class="mt-8 text-sm text-muted">
          Prefer a starting point? The generated styled layer ships an opinionated theme.
          See <.link navigate={~p"/guides/theming"} class="docs-link">Theming</.link>
          for tokens and custom themes.
        </p>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:class) do
    """
    <FlintUI.button class="my-button" phx-click="save">Save</FlintUI.button>

    [data-element="button"].my-button {
      padding: 0.5rem 1rem;
      border-radius: 0.5rem;
    }
    """
  end

  defp snippet(:style) do
    """
    <.button
      variant="solid"
      style="--fl-button-color: #7c3aed; --fl-button-color-content: #ffffff"
    >
      Save
    </.button>
    """
  end

  defp snippet(:tailwind_one_off) do
    """
    <.button variant="solid" class="bg-violet-600 text-white hover:bg-violet-500">
      Save
    </.button>
    """
  end

  defp snippet(:utilities) do
    """
    <.button variant="ghost" class="text-violet-600 hover:bg-violet-50">
      Save
    </.button>
    """
  end

  defp snippet(:variants) do
    """
    <.card class="**:data-[part=title]:tracking-tight **:data-[part=header]:pb-2">
      <:title>Deployments</:title>
      <p>Last deploy 2 minutes ago.</p>
    </.card>
    """
  end

  defp snippet(:vars_heex) do
    """
    <.card class="compact-card">
      <:title>Deployments</:title>
      <p>Last deploy 2 minutes ago.</p>
    </.card>
    """
  end

  defp snippet(:vars_css) do
    """
    .compact-card {
      --fl-card-spacing: 0.75rem;
      --fl-card-shadow: var(--fl-shadow-sm);
    }
    """
  end

  defp snippet(:parts) do
    """
    <.card class="release-card">
      <:title>Deployments</:title>
      <p>Last deploy 2 minutes ago.</p>
    </.card>

    .release-card [data-part="title"] {
      letter-spacing: -0.01em;
    }

    .release-card [data-part="header"] {
      padding-block-end: 0.5rem;
    }
    """
  end

  defp snippet(:state) do
    """
    [data-element="button"][data-disabled] { opacity: var(--fl-disabled-opacity, 0.5); }

    [data-element="toggle"][data-state="on"] { font-weight: 600; }

    [data-element="collapsible"] [data-part="content"][data-state="open"] {
      animation: expand 250ms ease;
    }
    """
  end

  defp snippet(:attributes) do
    """
    <.button variant="surface" color="error" size="sm">Delete</.button>

    <.card body="divided" spacing="sm" shadow={false}>
      <:title>Deployments</:title>
      <p>Last deploy 2 minutes ago.</p>
    </.card>
    """
  end

  defp snippet(:raw_color) do
    """
    <.button color="#1D72FE" variant="solid">Deploy</.button>
    <.toggle color="#1D72FE" pressed>Bold</.toggle>
    """
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
