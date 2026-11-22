defmodule FlintUIDocsWeb.Theme.CssUtilitiesLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Markdown

  @impl true
  def mount(_params, _session, socket) do
    families = FlintUI.Utilities.families()

    classes =
      for family <- families,
          utility <- family.utilities do
        Map.put(utility, :family, family.id)
      end

    {:ok,
     assign(socket,
       page_title: "CSS Utilities",
       query: "",
       families: families,
       classes: classes
     )}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, assign(socket, :query, query)}
  end

  def handle_event("search", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns, :groups, grouped_classes(assigns.classes, assigns.families, assigns.query))

    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_css_utilities}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="CSS Utilities"
          subtitle="A small, fixed utility layer for layout, spacing, motion, and theme-aware styling. It is included by default and reads the same --fl-* tokens as the components."
        />

        <DocsComponents.section title="Included by default" id="included">
          <DocsComponents.content_paragraph class="mt-3">
            <code class="docs-code font-mono">mix flint.setup</code>
            writes <code class="docs-code font-mono">assets/css/flint-utilities.css</code>
            and imports it after <code class="docs-code font-mono">flint.css</code>.
            <code class="docs-code font-mono">mix flint.theme</code>
            refreshes both stylesheets. Run
            <code class="docs-code font-mono">mix flint.utilities</code>
            to refresh the utility file on its own.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            The layer is included by default because it is small and the
            <code class="docs-code font-mono">fl-</code>
            prefix keeps it out of the way. Pass
            <code class="docs-code font-mono">--no-utilities</code>
            to <code class="docs-code font-mono">flint.setup</code>
            or <code class="docs-code font-mono">flint.theme</code>
            to leave it out, or remove the import from your app stylesheet.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:install)} lang={:shell} />
        </DocsComponents.section>

        <DocsComponents.section title="Layers and reset" id="layers">
          <DocsComponents.content_paragraph>
            The theme declares one cascade order. Utilities win over the
            component theme, while the internal focus layer stays last so an
            author utility cannot remove a focus treatment.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:layers)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            The generated file starts with a small base reset:
            <code class="docs-code font-mono">box-sizing: border-box</code>
            on every element, zero initial border widths, and <code
              class="docs-code font-mono"
              phx-no-curly-interpolation
            >body { margin: 0 }</code>. The
            zero border width is what makes <code class="docs-code font-mono">fl-border</code>
            and the border-style utilities predictable. Pass
            <code class="docs-code font-mono">--no-reset</code>
            to <code class="docs-code font-mono">mix flint.utilities</code>
            to omit it; width utilities still set their own width and style.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Layout primitives" id="layout">
          <DocsComponents.content_paragraph>
            Start here. These classes cover the layouts that would otherwise
            need a flex or grid recipe with media queries. Each one adapts to the
            available width on its own.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Each primitive exposes public inputs for one-offs: <code class="docs-code font-mono">--fl-stack-gap</code>, <code class="docs-code font-mono">--fl-cluster-gap</code>, <code class="docs-code font-mono">--fl-split-gap</code>, <code class="docs-code font-mono">--fl-flank-gap</code>, <code class="docs-code font-mono">--fl-flank-size</code>, <code class="docs-code font-mono">--fl-flank-content</code>, <code class="docs-code font-mono">--fl-frame-ratio</code>, <code class="docs-code font-mono">--fl-grid-min</code>, and <code class="docs-code font-mono">--fl-grid-gap</code>. Set them on the
            element with <code class="docs-code font-mono">style</code> or in a
            custom class.
          </DocsComponents.content_paragraph>

          <DocsComponents.subsection title="Stack" id="stack">
            <DocsComponents.content_paragraph>
              A vertical flex column with a consistent gap. Use it for forms,
              card bodies, and prose groups. Pair it with
              <code class="docs-code font-mono">fl-gap-*</code>
              to change the spacing.
            </DocsComponents.content_paragraph>
            <div class="fl-stack mt-4">
              <DocsComponents.content_placeholder class="h-12" />
              <DocsComponents.content_placeholder class="h-12" />
              <DocsComponents.content_placeholder class="h-12" />
            </div>
            <DocsComponents.code_block code={snippet(:stack)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Cluster" id="cluster">
            <DocsComponents.content_paragraph>
              A wrapping horizontal group for tags, button rows, and inline
              metadata. Items are vertically centered by default.
            </DocsComponents.content_paragraph>
            <div class="fl-cluster mt-4">
              <span class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
                Design
              </span>
              <span class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
                Shipped
              </span>
              <span class="fl-bg-warning-soft fl-text-warning fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
                Review
              </span>
              <span class="fl-bg-info-soft fl-text-info fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
                Backlog
              </span>
            </div>
            <DocsComponents.code_block code={snippet(:cluster)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Split" id="split">
            <DocsComponents.content_paragraph>
              Push the first and last children to opposite ends. It wraps when
              the container is too narrow. Use
              <code class="docs-code font-mono">fl-split-column</code>
              for a vertical split.
            </DocsComponents.content_paragraph>
            <div class="fl-split mt-4">
              <div>
                <p class="fl-text-sm fl-font-semibold fl-text-highlighted">Deployments</p>
                <p class="fl-text-sm fl-text-toned">Last deploy 2 minutes ago.</p>
              </div>
              <Components.button variant="surface" size="sm">Refresh</Components.button>
            </div>
            <DocsComponents.code_block code={snippet(:split)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Flank" id="flank">
            <DocsComponents.content_paragraph>
              One item stays at its natural size while the other fills the
              remaining space. Use <code class="docs-code font-mono">fl-flank-end</code>
              to flank the last child instead of the first.
            </DocsComponents.content_paragraph>
            <div class="fl-flank mt-4">
              <div class="fl-size-3xl fl-rounded-full fl-bg-strong"></div>
              <div class="fl-stack fl-gap-xs">
                <p class="fl-text-sm fl-font-semibold fl-text-highlighted">Aragorn</p>
                <p class="fl-text-sm fl-text-toned">
                  All we have to decide is what to do with the time that is given to us.
                </p>
              </div>
            </div>
            <DocsComponents.code_block code={snippet(:flank)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Frame" id="frame">
            <DocsComponents.content_paragraph>
              A box with a fixed aspect ratio and clipped media. Frames default
              to a square; use <code class="docs-code font-mono">fl-frame-landscape</code>
              or <code class="docs-code font-mono">fl-frame-portrait</code>
              for the other common ratios. Pair it with a radius utility.
            </DocsComponents.content_paragraph>
            <div class="fl-grid mt-4" style="--fl-grid-min: 10rem;">
              <div class="fl-frame fl-frame-square fl-rounded-lg fl-bg-strong">
                <div class="fl-flex fl-h-full fl-items-center fl-justify-center fl-text-muted">
                  1 / 1
                </div>
              </div>
              <div class="fl-frame fl-frame-landscape fl-rounded-lg fl-bg-strong">
                <div class="fl-flex fl-h-full fl-items-center fl-justify-center fl-text-muted">
                  16 / 9
                </div>
              </div>
              <div class="fl-frame fl-frame-portrait fl-rounded-lg fl-bg-strong">
                <div class="fl-flex fl-h-full fl-items-center fl-justify-center fl-text-muted">
                  9 / 16
                </div>
              </div>
            </div>
            <DocsComponents.code_block code={snippet(:frame)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Grid" id="grid">
            <DocsComponents.content_paragraph>
              <code class="docs-code font-mono">fl-grid</code>
              is an auto-fit grid: it chooses the column count from the
              available width. Set <code class="docs-code font-mono">--fl-grid-min</code>
              for a one-off minimum column size, or use
              <code class="docs-code font-mono">fl-grid-cols-*</code>
              and <code class="docs-code font-mono">fl-col-span-*</code>
              when you need an explicit template.
            </DocsComponents.content_paragraph>
            <div class="fl-grid mt-4" style="--fl-grid-min: 9rem;">
              <DocsComponents.content_placeholder class="h-24" />
              <DocsComponents.content_placeholder class="h-24" />
              <DocsComponents.content_placeholder class="h-24" />
              <DocsComponents.content_placeholder class="h-24" />
              <DocsComponents.content_placeholder class="h-24" />
              <DocsComponents.content_placeholder class="h-24" />
            </div>
            <DocsComponents.code_block code={snippet(:grid)} />
          </DocsComponents.subsection>

          <DocsComponents.subsection title="Container" id="container">
            <DocsComponents.content_paragraph>
              A centered, padded page wrapper. Use
              <code class="docs-code font-mono">fl-container</code>
              for the responsive wrapper, or one named variant on its own
              (<code class="docs-code font-mono">fl-container-md</code>, …)
              for a fixed cap. <code class="docs-code font-mono">fl-container-fluid</code>
              stays full width.
            </DocsComponents.content_paragraph>
            <div class="fl-container mt-4 fl-rounded-lg fl-bg-subtle">
              <div class="fl-p-md fl-text-sm fl-text-toned">
                This content is inside <code class="docs-code font-mono">fl-container</code>.
              </div>
            </div>
            <DocsComponents.code_block code={snippet(:container)} />
          </DocsComponents.subsection>
        </DocsComponents.section>

        <DocsComponents.section title="Responsive display" id="responsive">
          <DocsComponents.content_paragraph>
            The layout primitives are responsive by design, so most pages do not
            need breakpoint classes. For the remaining "hide on small screens"
            cases, the display utilities accept a breakpoint prefix.
          </DocsComponents.content_paragraph>
          <div class="mt-4 overflow-x-auto">
            <table class="w-full text-left text-sm">
              <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
                <tr>
                  <th class="py-2 pr-6 font-medium">Prefix</th>
                  <th class="py-2 pr-6 font-medium">Min width</th>
                  <th class="py-2 font-medium">Example</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  :for={{name, width} <- FlintUI.Utilities.breakpoints()}
                  class="border-b border-subtle"
                >
                  <td class="py-2 pr-6 font-mono text-xs">{name}</td>
                  <td class="py-2 pr-6">{width}</td>
                  <td class="py-2 font-mono text-xs">fl-{name}-hidden</td>
                </tr>
              </tbody>
            </table>
          </div>
          <DocsComponents.content_paragraph class="mt-4">
            Classes are mobile-first: <code class="docs-code font-mono">fl-hidden fl-md-flex</code>
            hides an element below <code class="docs-code font-mono">48rem</code>
            and makes it a flex container from there up.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:responsive)} />
        </DocsComponents.section>

        <DocsComponents.section title="Color" id="colors">
          <DocsComponents.content_paragraph>
            Color utilities read the semantic roles and chrome ladders. The
            direct forms paint a property; the <code class="docs-code font-mono">fl-tone-*</code>
            forms remap the five <code class="docs-code font-mono">--fl-tone*</code>
            inputs so a custom class can respond to a role the same way the
            components respond to <code class="docs-code font-mono">data-color</code>.
          </DocsComponents.content_paragraph>
          <div class="fl-cluster mt-4">
            <span class="fl-bg-primary fl-text-primary-on fl-rounded-md fl-px-sm fl-py-xs fl-text-sm">
              Primary
            </span>
            <span class="fl-bg-primary-soft fl-text-primary fl-rounded-md fl-px-sm fl-py-xs fl-text-sm">
              Primary soft
            </span>
            <span class="fl-bg-surface fl-border fl-border-default fl-text-default fl-rounded-md fl-px-sm fl-py-xs fl-text-sm">
              Surface
            </span>
            <span class="fl-bg-inverted fl-text-inverted fl-rounded-md fl-px-sm fl-py-xs fl-text-sm">
              Inverted
            </span>
          </div>
          <DocsComponents.code_block code={snippet(:colors)} />
          <DocsComponents.content_paragraph class="mt-4">
            Border width and style utilities do not set a color. Pair
            <code class="docs-code font-mono">fl-border</code>
            with <code class="docs-code font-mono">fl-border-default</code>
            (or a role) for the theme edge; without a color utility, the border
            follows the text color.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-4">
            Use <code class="docs-code font-mono">fl-tone-success</code>
            on an element and read <code class="docs-code font-mono">--fl-tone*</code>
            from your own class. Change the tone class and every declaration
            follows:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:tone)} lang={:css} />
          <div
            class="fl-tone-success mt-4 fl-text-sm"
            style="background: var(--fl-tone-soft); border: 1px solid var(--fl-tone-soft-border); color: var(--fl-tone-on-soft); padding: var(--fl-spacing-sm); border-radius: var(--fl-radius-md);"
          >
            A success callout that follows the role tokens.
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Surface" id="surface">
          <DocsComponents.content_paragraph>
            <code class="docs-code font-mono">fl-surface</code>
            applies the elevation primitive's composed shadow: an inner border,
            a top highlight, an outer ring, and three drop shadows. The recipe
            lives on the primitive, so it is defined once and stays in sync
            with <code class="docs-code font-mono">data-elevation</code>
            surfaces; the utility only applies it. The border follows the
            chrome ladder, so point <code class="docs-code font-mono">--fl-elevation-border</code>
            at <code class="docs-code font-mono">--fl-color-border-strong</code>
            for a heavier edge. Level 2 is the default; raise it with <code class="docs-code font-mono">--fl-elevation-level</code>.
          </DocsComponents.content_paragraph>
          <div class="mt-4 grid gap-4 sm:grid-cols-3">
            <div
              :for={level <- 1..3}
              class="fl-surface fl-rounded-lg fl-p-md"
              style={"--fl-elevation-level: #{level}"}
            >
              <span class="fl-text-xs fl-text-muted">level {level}</span>
            </div>
          </div>
          <DocsComponents.code_block code={snippet(:surface)} />
        </DocsComponents.section>

        <DocsComponents.section title="Motion" id="motion">
          <DocsComponents.content_paragraph>
            The shared keyframes in <code class="docs-code font-mono">flint.css</code>
            have matching animation utilities. Entrance classes
            (<code class="docs-code font-mono">fl-animate-fade-in</code>, <code class="docs-code font-mono">fl-animate-pop-in</code>, <code class="docs-code font-mono">fl-animate-slide-in</code>, <code class="docs-code font-mono">fl-animate-rotate-in</code>)
            run once and hold their final state. Attention classes
            (<code class="docs-code font-mono">fl-animate-shake</code>, <code class="docs-code font-mono">fl-animate-flash</code>)
            run once; let the state change carry the message afterwards.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            The looping classes mirror Tailwind's <code class="docs-code font-mono">animate-*</code>
            timings, so either can be swapped without a visual change. Every
            motion utility turns off under <code class="docs-code font-mono">prefers-reduced-motion: reduce</code>:
            the state change still lands, only the movement is removed. Exit
            animations stay with the component or JS that keeps the element
            mounted until the animation ends; the shared exit keyframes are
            still available in app CSS.
          </DocsComponents.content_paragraph>

          <div class="fl-grid mt-4" style="--fl-grid-min: 8.5rem;">
            <div class="fl-stack fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-p-sm">
              <div class="fl-flex fl-h-12 fl-items-center fl-justify-center fl-overflow-hidden">
                <span class="fl-size-3xl fl-rounded-md fl-bg-primary fl-animate-pulse"></span>
              </div>
              <code class="docs-code font-mono text-xs">fl-animate-pulse</code>
            </div>
            <div class="fl-stack fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-p-sm">
              <div class="fl-flex fl-h-12 fl-items-center fl-justify-center fl-overflow-hidden">
                <span class="fl-size-3xl fl-rounded-md fl-bg-primary fl-animate-bounce"></span>
              </div>
              <code class="docs-code font-mono text-xs">fl-animate-bounce</code>
            </div>
            <div class="fl-stack fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-p-sm">
              <div class="fl-flex fl-h-12 fl-items-center fl-justify-center fl-overflow-hidden">
                <span class="fl-size-3xl fl-rounded-md fl-bg-primary fl-animate-heartbeat"></span>
              </div>
              <code class="docs-code font-mono text-xs">fl-animate-heartbeat</code>
            </div>
            <div class="fl-stack fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-p-sm">
              <div class="fl-flex fl-h-12 fl-items-center fl-justify-center fl-overflow-hidden">
                <span class="fl-size-3xl fl-rounded-md fl-bg-primary fl-animate-ping"></span>
              </div>
              <code class="docs-code font-mono text-xs">fl-animate-ping</code>
            </div>
            <div class="fl-stack fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-p-sm">
              <div class="fl-flex fl-h-12 fl-items-center fl-justify-center fl-overflow-hidden">
                <Components.icon
                  name="lucide-loader-circle"
                  class="fl-animate-spin fl-text-primary"
                />
              </div>
              <code class="docs-code font-mono text-xs">fl-animate-spin</code>
            </div>
          </div>

          <DocsComponents.content_paragraph class="mt-4">
            Tune a one-shot with <code class="docs-code font-mono">fl-duration-fast</code>, <code class="docs-code font-mono">fl-duration-base</code>, <code class="docs-code font-mono">fl-duration-slow</code>, or <code class="docs-code font-mono">fl-ease-*</code>. The duration and
            easing classes are emitted after the animation classes, so they win
            regardless of class order. The looping classes set their own timing
            to stay aligned with Tailwind; an explicit duration class overrides
            that default. Use <code class="docs-code font-mono">fl-animate-none</code>
            to remove an animation.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            The keyframes are part of the theme, so motion utilities need <code class="docs-code font-mono">flint.css</code>. Geometry inputs
            such as <code class="docs-code font-mono">--fl-motion-slide-from</code>
            and <code class="docs-code font-mono">--fl-heartbeat-scale</code>
            still work on the class.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:motion)} />
        </DocsComponents.section>

        <DocsComponents.section title="Class reference" id="reference">
          <DocsComponents.content_paragraph>
            Every class is fixed and emitted into the generated file. Search by
            class name or by the CSS it sets. There are <strong>{length(@classes)}</strong>
            classes in this build.
          </DocsComponents.content_paragraph>

          <form id="utility-search-form" phx-change="search" phx-submit="search" class="mt-4">
            <label for="utility-search" class="fl-sr-only">Search utilities</label>
            <input
              type="search"
              id="utility-search"
              name="query"
              value={@query}
              placeholder="Search classes or declarations"
              phx-debounce="150"
              class="w-full rounded-md border border-default bg-surface px-3 py-2 text-sm text-default placeholder:text-dimmed focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </form>

          <p
            :if={@groups == []}
            class="mt-6 rounded-lg border border-default bg-subtle p-4 text-sm text-toned"
          >
            No utilities match “{@query}”.
          </p>

          <div :if={@groups != []} class="mt-6 max-h-[42rem] space-y-8 overflow-y-auto pr-2">
            <section :for={group <- @groups} id={"reference-" <> to_string(group.id)}>
              <h3 class="text-lg font-semibold text-highlighted">{group.title}</h3>
              <Markdown.prose content={group.description} class="mt-1 text-sm" />
              <div class="mt-3 overflow-x-auto">
                <table class="w-full text-left text-sm">
                  <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
                    <tr>
                      <th class="py-2 pr-6 font-medium">Class</th>
                      <th class="py-2 font-medium">CSS</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr :for={utility <- group.utilities} class="border-b border-subtle last:border-0">
                      <td class="py-2 pr-6 align-top">
                        <code class="font-mono text-xs text-highlighted">{utility.class}</code>
                      </td>
                      <td class="py-2 align-top">
                        <code class="font-mono text-xs text-toned">{utility.declaration}</code>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </section>
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Customizing" id="customizing">
          <DocsComponents.content_paragraph>
            Utilities read tokens, so the first lever is the theme. Override a
            token in your app stylesheet after the imports and every utility
            that reads it follows. For a one-off, use the public custom
            properties on the layout primitives, or add a class after the
            imports.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:customizing)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-4">
            Need a value the scale does not have? Use <code class="docs-code font-mono">style</code>
            for a single element or write a custom class. There is no arbitrary
            value syntax and no JIT, so the generated file stays predictable.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="What is not included" id="limits">
          <DocsComponents.content_paragraph>
            The layer deliberately stops where a fixed scale stops:
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph as="ul" class="mt-4">
            <li>No arbitrary values such as <code class="docs-code font-mono">fl-p-[13px]</code>.</li>
            <li>
              No pseudo-state variants such as <code class="docs-code font-mono">hover:</code>
              or <code class="docs-code font-mono">focus:</code>.
            </li>
            <li>
              No full palette shade matrix; use the semantic roles or the
              <code class="docs-code font-mono">--fl-color-*</code>
              variables.
            </li>
            <li>
              No arbitrary transform, transition, filter, or gradient
              utilities. Named animations cover the common motion; write a
              custom class for anything else.
            </li>
            <li>
              No Bootstrap-style row/column grid; use <code class="docs-code font-mono">fl-grid</code>
              or an explicit <code class="docs-code font-mono">fl-grid-cols-*</code>
              template.
            </li>
            <li>
              No native-element theme or long-form prose helper. Those are
              separate, larger layers.
            </li>
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Tailwind and other utilities" id="tailwind">
          <DocsComponents.content_paragraph>
            The <code class="docs-code font-mono">fl-</code>
            prefix means this layer can sit next to Tailwind, UnoCSS, or your
            own atomic classes. Utilities are emitted in <code class="docs-code font-mono">@layer utilities</code>, after the
            component theme, so they override component defaults without <code class="docs-code font-mono">!important</code>.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            If you use the <.link navigate={~p"/guides/theming"} class="docs-link">Tailwind bridge</.link>,
            <code class="docs-code font-mono">bg-primary</code>
            and <code class="docs-code font-mono">fl-bg-primary</code>
            resolve the same token. You can use either; you do not need both.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end

  defp grouped_classes(classes, families, query) do
    query = query |> String.trim() |> String.downcase()

    filtered =
      Enum.filter(classes, fn utility ->
        query == "" or
          String.contains?(String.downcase(utility.class), query) or
          String.contains?(String.downcase(utility.declaration), query)
      end)

    for family <- families,
        utilities = Enum.filter(filtered, &(&1.family == family.id)),
        utilities != [] do
      %{
        id: family.id,
        title: family.title,
        description: family.description,
        utilities: utilities
      }
    end
  end

  defp snippet(:install) do
    """
    mix flint.setup

    # The utility layer is written to assets/css/flint-utilities.css and
    # imported after flint.css. Refresh it on its own with:
    mix flint.utilities

    # Leave it out:
    mix flint.setup --no-utilities
    """
  end

  defp snippet(:layers) do
    """
    @layer base, components, utilities, focus;
    """
  end

  defp snippet(:stack) do
    """
    <div class="fl-stack">
      <div>One</div>
      <div>Two</div>
      <div>Three</div>
    </div>
    """
  end

  defp snippet(:cluster) do
    """
    <div class="fl-cluster">
      <span class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs">
        Design
      </span>
      <span class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs">
        Shipped
      </span>
    </div>
    """
  end

  defp snippet(:split) do
    """
    <div class="fl-split">
      <div>
        <p class="fl-font-semibold">Deployments</p>
        <p class="fl-text-sm fl-text-toned">Last deploy 2 minutes ago.</p>
      </div>
      <.button variant="surface" size="sm">Refresh</.button>
    </div>
    """
  end

  defp snippet(:flank) do
    """
    <div class="fl-flank">
      <div class="fl-size-3xl fl-rounded-full fl-bg-strong"></div>
      <div class="fl-stack fl-gap-xs">
        <strong>Aragorn</strong>
        <span class="fl-text-toned">King of Gondor</span>
      </div>
    </div>
    """
  end

  defp snippet(:frame) do
    """
    <div class="fl-frame fl-frame-landscape fl-rounded-lg">
      <img src="/images/cover.jpg" alt="" />
    </div>
    """
  end

  defp snippet(:grid) do
    """
    <div class="fl-grid" style="--fl-grid-min: 9rem;">
      <div>One</div>
      <div>Two</div>
      <div>Three</div>
    </div>
    """
  end

  defp snippet(:container) do
    """
    <div class="fl-container">
      <p>Centered, padded page content.</p>
    </div>
    """
  end

  defp snippet(:responsive) do
    """
    <div class="fl-hidden fl-md-flex">
      Visible from the md breakpoint up.
    </div>
    """
  end

  defp snippet(:colors) do
    """
    <span class="fl-bg-primary fl-text-primary-on">Primary</span>
    <span class="fl-bg-primary-soft fl-text-primary">Primary soft</span>
    <span class="fl-bg-surface fl-border fl-border-default fl-text-default">Surface</span>
    """
  end

  defp snippet(:tone) do
    """
    .callout {
      background: var(--fl-tone-soft);
      border: 1px solid var(--fl-tone-soft-border);
      color: var(--fl-tone-on-soft);
    }
    """
  end

  defp snippet(:surface) do
    """
    <div class="fl-surface fl-rounded-lg fl-p-lg" style="--fl-elevation-level: 3;">
      <p class="fl-font-semibold">Raised surface</p>
      <p class="fl-text-sm fl-text-toned">
        Border, top highlight, outer ring, and drop shadows.
      </p>
    </div>
    """
  end

  defp snippet(:motion) do
    """
    <!-- Looping. Timing matches Tailwind's animate-* classes. -->
    <span class="fl-size-sm fl-rounded-full fl-bg-primary fl-animate-pulse"></span>
    <.icon name="lucide-loader-circle" class="fl-animate-spin" />

    <!-- Entrance: runs once and holds the final state. -->
    <div class="fl-animate-pop-in">Saved.</div>

    <!-- One-shot attention. Let the state carry the message after. -->
    <p class="fl-animate-shake fl-text-danger">That name is taken.</p>

    <!-- Tune a one-shot, or remove the animation. -->
    <div class="fl-animate-fade-in fl-duration-slow fl-ease-linear">Filters applied.</div>
    <div class="fl-animate-pulse fl-animate-none">Static status dot</div>
    """
  end

  defp snippet(:customizing) do
    """
    /* assets/css/app.css, after the flint.css and flint-utilities.css imports */
    :root {
      --fl-spacing: 0.3rem;
    }

    .my-card {
      background: var(--fl-color-surface);
      border: 1px solid var(--fl-color-border);
      padding: var(--fl-spacing-lg);
      border-radius: var(--fl-radius-lg);
    }
    """
  end
end
