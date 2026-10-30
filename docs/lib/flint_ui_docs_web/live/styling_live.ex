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
        <h1 class="text-3xl font-semibold tracking-tight">Styling</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          FlintUI has two layers: headless base components that ship behavior and
          <code class="font-mono">data-*</code>
          hooks, and a generated styled layer that is plain CSS you own. Both accept the
          same small set of styling tools, so a change works the same way whichever layer
          you render.
        </p>

        <DocsComponents.section title="Where a change belongs" id="scope">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Start from the narrowest place that solves the problem. Reaching further than
            you need is how a design system turns into a pile of one-off overrides.
          </p>
          <div class="mt-4 overflow-x-auto">
            <table class="w-full min-w-xl text-left text-sm">
              <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
                <tr>
                  <th class="py-3 pr-6 font-medium">Need</th>
                  <th class="py-3 pr-6 font-medium">Reach for</th>
                  <th class="py-3 font-medium">Scope</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
                <tr class="align-top">
                  <td class="py-3 pr-6">Change the look across the app</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    Theme token or preset
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">Every component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change one value on one instance</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    <code class="font-mono">style</code> with a custom property or declaration
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">That element</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change several properties on one instance</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    <code class="font-mono">class</code> with utilities or a CSS rule
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">That element</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Style a part of a component</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    <code class="font-mono">class</code>
                    on the root plus <code class="font-mono">[data-part]</code>
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">That component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Style a built-in state</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    <code class="font-mono">data-*</code>
                    selector (<code class="font-mono">data-disabled</code>, <code class="font-mono">data-state</code>, …)
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">That state</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Pick a mode the component models</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    Component attribute (<code class="font-mono">variant</code>, <code class="font-mono">color</code>, <code class="font-mono">size</code>, …)
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">That component</td>
                </tr>
                <tr class="align-top">
                  <td class="py-3 pr-6">Change a component permanently</td>
                  <td class="py-3 pr-6 text-zinc-600 dark:text-zinc-400">
                    The generated wrapper or your app CSS
                  </td>
                  <td class="py-3 text-zinc-600 dark:text-zinc-400">Your app</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            Theme-wide changes are plain CSS in your app stylesheet, after the
            <code class="font-mono">flint.css</code>
            import. See <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
            for the token list, presets, and how to override them.
          </p>
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Attributes such as <code class="font-mono">variant</code>, <code class="font-mono">color</code>, and
            <code class="font-mono">size</code>
            belong to the <strong>generated styled components</strong>. The headless base
            (<code class="font-mono">FlintUI.button/1</code>, …) is unstyled by design: it
            renders the same markup, behavior, and <code class="font-mono">data-*</code>
            hooks, and you bring all of the CSS.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Root class" id="class">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Every component forwards <code class="font-mono">class</code>
            and the rest of your attributes onto its root element and marks itself with <code class="font-mono">data-element</code>. Style the root, or any part it
            exposes, with a plain selector.
          </p>
          <DocsComponents.code_block code={snippet(:class)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            The theme ships in <code class="font-mono">@layer components</code>, so a
            utility class or an unlayered rule of your own wins over it without <code class="font-mono">!important</code>. An inline
            <code class="font-mono">style</code>
            wins over both. That ordering is intentional: the theme is the floor, your
            classes are the day-to-day override, and inline styles are for one-offs.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="One-off values" id="style">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Every component accepts <code class="font-mono">style</code>: it is a global
            HTML attribute, and the wrappers forward the rest of your attributes to the
            root. Use it for a single value on a single element, normally one of the
            component's public custom properties.
          </p>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button variant="solid">Default</Components.button>
            <Components.button
              variant="solid"
              style="--fl-button-color: #7c3aed; --fl-button-color-foreground: #ffffff"
            >
              Custom
            </Components.button>
          </div>
          <DocsComponents.code_block code={snippet(:style)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Inline styles cannot express <code class="font-mono">:hover</code>,
            pseudo-elements, or another part. A class can, and a utility library's
            arbitrary variants can too, as described in <a href="#utilities" class="underline">Utility CSS</a>.
          </p>
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            If you use Tailwind or another utility library, you can often skip
            <code class="font-mono">style</code>
            entirely. Utilities are emitted in a later cascade layer than the theme, so
            they win without <code class="font-mono">!important</code>:
          </p>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button
              variant="solid"
              class="bg-violet-600 text-white hover:bg-violet-500"
            >
              Utilities
            </Components.button>
          </div>
          <DocsComponents.code_block code={snippet(:tailwind_one_off)} />
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            Component variables (<code class="font-mono">--fl-button-*</code>, <code class="font-mono">--fl-card-*</code>, …) are the supported per-instance
            inputs. Each component's <strong>CSS</strong>
            tab lists its public variables and what derives from them. Set them inline for
            one element, or from a class when several properties change together:
          </p>
          <DocsComponents.code_block code={snippet(:vars_heex)} />
          <DocsComponents.code_block code={snippet(:vars_css)} lang={:css} />
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            For a color, the generated wrappers offer a shortcut:
            <code class="font-mono">color="#7c3aed"</code>
            sets the fill and derives the foreground and text inputs for you. Keep the
            variables for the cases that are not a single color.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Parts" id="parts">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            A component marks its root with <code class="font-mono">data-element</code>
            and each internal part with <code class="font-mono">data-part</code>. Put a
            class on the root, then select the part. The hooks are the same in both
            layers.
          </p>
          <DocsComponents.code_block code={snippet(:parts)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Slot content is your own markup, so wrap it when you need a handle inside a
            slot. Slots only accept the attributes a component declares for them, not
            global ones.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="State" id="state">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            State such as disabled, loading, open, or pressed is reflected as
            <code class="font-mono">data-*</code>
            attributes (and the matching ARIA attributes), so you can style it without
            tracking state yourself. Each component's Base tab documents the exact hooks
            it sets.
          </p>
          <DocsComponents.code_block code={snippet(:state)} lang={:css} />
        </DocsComponents.section>

        <DocsComponents.section title="Utility CSS" id="utilities">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Tailwind is optional, and FlintUI is not coupled to it. Utilities are just
            classes on the root, and Tailwind emits them in
            <code class="font-mono">@layer utilities</code>
            — after the theme's <code class="font-mono">@layer components</code>
            — so
            they win without <code class="font-mono">!important</code>. UnoCSS, your own
            atomic classes, or any unlayered stylesheet behave the same way.
          </p>
          <DocsComponents.code_block code={snippet(:utilities)} />
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            Arbitrary variants reach parts and states, so most one-off styling never
            needs a stylesheet at all:
          </p>
          <DocsComponents.code_block code={snippet(:variants)} />
          <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
            Utilities only change the properties they name. The component's derived
            states still follow its color input: the focus ring is tinted from <code class="font-mono">--fl-button-color</code>, so a utility-only retint
            leaves the ring at the component color. Set the variable (or a semantic <code class="font-mono">color</code>) when the whole control should re-tint.
          </p>
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            To use FlintUI tokens as utilities too — <code class="font-mono">bg-primary</code>, <code class="font-mono">border-border</code>, … — map them once with <code class="font-mono">mix flint.setup --tailwind</code>. The
            <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
            guide covers the bridge.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Attributes first" id="attributes">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            When a component already models a change, use the attribute. <code class="font-mono">variant</code>, <code class="font-mono">color</code>, <code class="font-mono">size</code>, and
            boolean modes such as <code class="font-mono">outline</code>
            or <code class="font-mono">depth</code>
            are covered by the theme, so they keep working across presets and color
            schemes.
          </p>
          <DocsComponents.code_block code={snippet(:attributes)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Attributes describe structure or a mode; they are not a styling language.
            There is no <code class="font-mono">radius</code>
            or <code class="font-mono">border</code>
            prop. <code class="font-mono">color</code>
            accepts a semantic role, or a raw CSS color for a one-off accent or a value
            that comes from data; the component derives its label and text colors from
            it. Raw colors do not follow presets, so use a role (or a theme override)
            when the color is part of the system.
          </p>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button color="#1D72FE" variant="solid">Raw color</Components.button>
            <Components.toggle color="#1D72FE" pressed>Bold</Components.toggle>
          </div>
          <DocsComponents.code_block code={snippet(:raw_color)} />
        </DocsComponents.section>

        <DocsComponents.section title="By component" id="components">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            These are the plain-CSS recipes for the headless components. Each block
            targets the hooks the component exposes; the styled layer uses the same
            markup, so the rules apply to it too.
          </p>
          <DocsComponents.subsection
            :for={{name, styling} <- @pages}
            title={humanize(name)}
            id={to_string(name)}
          >
            <Markdown.markdown :if={styling[:body]} content={styling[:body]} />
            <div :for={snippet <- styling.snippets} class="mt-4">
              <p class="text-sm font-medium">{snippet.title}</p>
              <DocsComponents.code_block code={snippet.code} lang={:css} />
            </div>
          </DocsComponents.subsection>
        </DocsComponents.section>

        <p class="mt-8 text-sm text-zinc-500">
          Prefer a starting point? The generated styled layer ships an opinionated theme.
          See <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
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
      style="--fl-button-color: #7c3aed; --fl-button-color-foreground: #ffffff"
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
    <.button variant="outline" color="error" size="sm">Delete</.button>

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
