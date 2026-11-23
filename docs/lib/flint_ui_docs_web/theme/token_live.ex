defmodule FlintUIDocsWeb.Theme.TokenLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.{Snippets, Tokens}

  @type_scale [
    {"xs", "0.75rem", "1rem"},
    {"sm", "0.875rem", "1.25rem"},
    {"md", "1rem", "1.5rem"},
    {"lg", "1.125rem", "1.75rem"},
    {"xl", "1.25rem", "2rem"},
    {"2xl", "1.5rem", "2rem"},
    {"3xl", "1.875rem", "2.25rem"},
    {"4xl", "2.25rem", "2.5rem"},
    {"5xl", "3rem", "1"},
    {"6xl", "3.75rem", "1"}
  ]

  @weights [
    {"thin", "100"},
    {"light", "300"},
    {"normal", "400"},
    {"medium", "500"},
    {"semibold", "600"},
    {"bold", "700"},
    {"black", "900"}
  ]

  @tracking [
    {"tighter", "-0.05em"},
    {"tight", "-0.025em"},
    {"normal", "0em"},
    {"wide", "0.025em"},
    {"wider", "0.05em"},
    {"widest", "0.1em"}
  ]

  @spacing_scale [
    {"xs", 1},
    {"sm", 2},
    {"md", 3},
    {"lg", 4},
    {"xl", 6},
    {"2xl", 8},
    {"3xl", 12}
  ]

  @breakpoints [
    {"sm", "40rem"},
    {"md", "48rem"},
    {"lg", "64rem"},
    {"xl", "80rem"},
    {"2xl", "96rem"}
  ]

  @containers [
    {"xs", "20rem"},
    {"sm", "24rem"},
    {"md", "28rem"},
    {"lg", "32rem"},
    {"xl", "36rem"},
    {"2xl", "42rem"},
    {"3xl", "48rem"},
    {"4xl", "56rem"},
    {"5xl", "64rem"},
    {"6xl", "72rem"},
    {"7xl", "80rem"}
  ]

  @radius_scale [
    {"xs", "var(--fl-radius-xs)"},
    {"sm", "var(--fl-radius-sm)"},
    {"md", "var(--fl-radius-md)"},
    {"lg", "var(--fl-radius-lg)"},
    {"xl", "var(--fl-radius-xl)"},
    {"2xl", "var(--fl-radius-2xl)"},
    {"full", "var(--fl-radius-full)"}
  ]

  @shadows [
    {"2xs", "var(--fl-shadow-2xs)"},
    {"xs", "var(--fl-shadow-xs)"},
    {"sm", "var(--fl-shadow-sm)"},
    {"md", "var(--fl-shadow-md)"},
    {"lg", "var(--fl-shadow-lg)"},
    {"xl", "var(--fl-shadow-xl)"}
  ]

  @durations [
    {"fast", "150ms"},
    {"base", "200ms"},
    {"slow", "300ms"}
  ]

  @easings [
    {"out", "cubic-bezier(0, 0, 0.2, 1)", "Entering, expanding, and settling"},
    {"in-out", "cubic-bezier(0.4, 0, 0.2, 1)", "Moving between two states"}
  ]

  @shared_animations [
    {"fl-fade-in", "Opacity 0 → 1", "—"},
    {"fl-fade-out", "Opacity 1 → 0", "—"},
    {"fl-pop-in", "Fade and scale in from a small offset",
     "--fl-motion-pop-scale, --fl-motion-pop-translate"},
    {"fl-pop-out", "Fade and scale out to a small offset",
     "--fl-motion-pop-scale, --fl-motion-pop-translate"},
    {"fl-slide-in", "Fade and slide in from an offset", "--fl-motion-slide-from"},
    {"fl-slide-out", "Fade and slide out to an offset", "--fl-motion-slide-from"},
    {"fl-rotate-in", "Fade, rotate, and scale in",
     "--fl-motion-rotate-from, --fl-motion-rotate-scale"},
    {"fl-rotate-out", "Fade, rotate, and scale out",
     "--fl-motion-rotate-from, --fl-motion-rotate-scale"},
    {"fl-shake", "Quick horizontal shake", "--fl-motion-shake-distance"},
    {"fl-flash", "Two quick opacity flashes", "--fl-motion-flash-opacity"},
    {"fl-spin", "Rotate one full turn", "—"},
    {"fl-ping", "Scale up and fade out", "—"},
    {"fl-pulse", "Fade to half opacity and back", "—"},
    {"fl-bounce", "Drop and settle", "—"},
    {"fl-heartbeat", "Double scale beat", "--fl-heartbeat-scale"}
  ]

  @animation_demos [
    {"Fade in", "fl-fade-in", :enter},
    {"Fade out", "fl-fade-out", :exit},
    {"Pop in", "fl-pop-in", :enter},
    {"Pop out", "fl-pop-out", :exit},
    {"Slide in", "fl-slide-in", :enter},
    {"Slide out", "fl-slide-out", :exit},
    {"Rotate in", "fl-rotate-in", :enter},
    {"Rotate out", "fl-rotate-out", :exit},
    {"Shake", "fl-shake", :attention},
    {"Flash", "fl-flash", :attention},
    {"Spin", "fl-spin", :loop},
    {"Ping", "fl-ping", :loop},
    {"Pulse", "fl-pulse", :loop},
    {"Bounce", "fl-bounce", :loop},
    {"Heartbeat", "fl-heartbeat", :loop}
  ]

  @component_animations [
    {"Indicator", "/components/indicator",
     ~w(fl-indicator-pulse fl-indicator-ping fl-indicator-heartbeat fl-indicator-bounce)},
    {"Loading", "/components/loading",
     ~w(fl-loading-spin fl-loading-dash fl-loading-fade fl-loading-bounce fl-loading-bar-scale fl-loading-infinity)},
    {"Loading Text", "/components/loading_text",
     ~w(fl-loading-text-dot fl-loading-text-blink fl-loading-text-shimmer fl-loading-text-wave)},
    {"Progress", "/components/progress",
     ~w(fl-progress-carousel fl-progress-swing fl-progress-elastic fl-progress-stripes)},
    {"Progress Ring", "/components/progress_ring",
     ~w(fl-progress-ring-spin fl-progress-ring-sweep)},
    {"Collapsible", "/components/collapsible", ~w(fl-collapsible-expand fl-collapsible-collapse)},
    {"Accordion Item", "/components/accordion_item",
     ~w(fl-accordion-expand fl-accordion-collapse)}
  ]

  @impl true
  def mount(_params, _session, socket) do
    page = Tokens.get!(socket.assigns.live_action)

    {:ok,
     assign(socket,
       page_title: page.title,
       token_page: page,
       hues: FlintUI.Palette.hue_names(),
       type_scale: @type_scale,
       weights: @weights,
       tracking: @tracking,
       spacing_scale: @spacing_scale,
       breakpoints: @breakpoints,
       containers: @containers,
       radius_scale: @radius_scale,
       shadows: @shadows,
       durations: @durations,
       easings: @easings,
       shared_animations: @shared_animations,
       animation_demos: @animation_demos,
       component_animations: @component_animations
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={@token_page.id}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title={@token_page.title}
          subtitle={@token_page.subtitle}
        />
        {render_token(@live_action, assigns)}
      </div>
    </Layouts.app>
    """
  end

  defp render_token(:colors, assigns) do
    ~H"""
    <DocsComponents.section title="Raw Hues" id="hues">
      <DocsComponents.content_paragraph class="mt-3">
        The
        <.link
          navigate={~p"/guides/theming/color"}
          class="docs-link"
        >palette</.link>
        exposes eighteen raw hues. Each hue is a <code class="docs-code font-mono">50..950</code>
        ramp plus a six-token tone set: the core fill <code class="docs-code font-mono">--fl-color-&lt;hue&gt;</code>, its label <code class="docs-code font-mono">--fl-color-&lt;hue&gt;-on</code>, the hue
        as text on its own tint <code class="docs-code font-mono">--fl-color-&lt;hue&gt;-on-soft</code>,
        the hue as text on chrome <code class="docs-code font-mono">--fl-color-&lt;hue&gt;-on-surface</code>,
        and the tinted pair <code class="docs-code font-mono">--fl-color-&lt;hue&gt;-soft</code>
        and <code class="docs-code font-mono">--fl-color-&lt;hue&gt;-soft-border</code>.
        These tokens follow the active palette and the light/dark scheme, but
        they do not follow role remaps. Use a raw hue for decoration and
        data-driven accents; map a role for anything app-wide.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Color</th>
              <th class="py-3 pr-6 font-medium">Fill</th>
              <th class="py-3 pr-6 font-medium">On fill</th>
              <th class="py-3 font-medium">Preview</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr :for={hue <- @hues}>
              <td class="py-3 pr-6 font-medium">{hue}</td>
              <td class="py-3 pr-6">
                <code class="docs-code font-mono">--fl-color-{hue}</code>
              </td>
              <td class="py-3 pr-6">
                <code class="docs-code font-mono">--fl-color-{hue}-on</code>
              </td>
              <td class="py-3">
                <div
                  aria-hidden="true"
                  class="grid size-10 place-items-center rounded-md text-sm font-semibold"
                  style={"background: var(--fl-color-#{hue}); color: var(--fl-color-#{hue}-on);"}
                >
                  Aa
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </DocsComponents.section>

    <DocsComponents.section title="Semantic Roles" id="roles">
      <DocsComponents.content_paragraph class="mt-3">
        A role points at one palette hue's six-token tone set. The fill is the
        role itself; <code class="docs-code font-mono">-on</code>
        labels
        that fill, <code class="docs-code font-mono">-on-soft</code>
        is the role as
        text on its own tint, <code class="docs-code font-mono">-on-surface</code>
        is the role as text on the chrome, and <code class="docs-code font-mono">-soft</code>
        and <code class="docs-code font-mono">-soft-border</code>
        are the tinted
        pair. <code class="docs-code font-mono">-on-soft</code>
        picks the most saturated shade that still clears AA on the tinted fill,
        while <code class="docs-code font-mono">-on-surface</code>
        starts from the most chromatic shade and lifts it only as far as the
        chrome ladder requires, so colored text stays vivid instead of fading to
        a pastel.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Role</th>
              <th class="py-3 pr-6 font-medium">Default hue</th>
              <th class="py-3 pr-6 font-medium">Fill</th>
              <th class="py-3 pr-6 font-medium">On soft</th>
              <th class="py-3 font-medium">On surface</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr :for={
              {role, hue} <-
                [
                  {"primary", "neutral ink"},
                  {"secondary", "gray"},
                  {"neutral", "gray (inverted)"},
                  {"info", "blue"},
                  {"success", "green"},
                  {"warning", "yellow"},
                  {"danger", "red"}
                ]
            }>
              <td class="py-3 pr-6 font-medium">{role}</td>
              <td class="py-3 pr-6 text-toned">{hue}</td>
              <td class="py-3 pr-6">
                <code class="docs-code font-mono">--fl-color-{role}</code>
              </td>
              <td class="py-3">
                <code class="docs-code font-mono">--fl-color-{role}-on-soft</code>
              </td>
              <td class="py-3">
                <code class="docs-code font-mono">--fl-color-{role}-on-surface</code>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:colors)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Text Tiers" id="text">
      <DocsComponents.content_paragraph class="mt-3">
        <code class="docs-code font-mono">--fl-text-base</code>
        is the single text anchor: a softened neutral —
        <code class="docs-code font-mono">gray-700</code>
        in light, <code class="docs-code font-mono">gray-200</code>
        in dark — rather than near-black or white. The other tiers are tonal
        mixes of it toward black or white, so overriding the anchor retunes the
        whole ramp. <code class="docs-code font-mono">text-highlighted</code>
        is the strongest tier for headings and strong labels;
        <code class="docs-code font-mono">text-toned</code>
        is one step softer for secondary copy, and <code class="docs-code font-mono">text-muted</code>
        is for meta and labels. Solid controls don't use these: their labels
        come from the role <code class="docs-code font-mono">-on</code>
        tokens, which are chosen to clear AA against the fill (usually white or
        the darkest shade).
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <div
          :for={
            {name, token} <-
              [
                {"text-highlighted", "var(--fl-color-text-highlighted)"},
                {"text", "var(--fl-color-text)"},
                {"text-toned", "var(--fl-color-text-toned)"},
                {"text-muted", "var(--fl-color-text-muted)"},
                {"text-dimmed", "var(--fl-color-text-dimmed)"}
              ]
          }
          class="rounded-xl border border-default p-4"
          style={"color: #{token};"}
        >
          <p class="font-semibold leading-5">{name}</p>
          <p class="mt-1 text-sm">The quick brown fox</p>
        </div>
      </div>
      <div class="mt-4 rounded-lg border border-default bg-subtle p-4 text-sm text-default">
        <p class="font-medium">Dimmed is below AA by design</p>
        <p class="mt-1">
          <code class="docs-code font-mono">text-dimmed</code>
          is 2.6:1 on white and 4.6:1 on the dark page. Use it for placeholders,
          disabled labels, and decoration — never for body copy or interactive
          labels. <code class="docs-code font-mono">text-muted</code>
          clears AA on <code class="docs-code font-mono">surface</code>, the page, and <code class="docs-code font-mono">surface-subtle</code>; on
          <code class="docs-code font-mono">surface-strong</code>
          in light it is 4.17:1, so use <code class="docs-code font-mono">text-toned</code>
          there.
        </p>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:text)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Tone Hooks" id="tone-hooks">
      <DocsComponents.content_paragraph class="mt-3">
        A <code class="docs-code font-mono">color</code>
        prop resolves to one six-token tone set. A semantic role and a palette
        hue use the same hook, so components only read
        <code class="docs-code font-mono">--fl-tone*</code>
        and never need to know which one you chose. Raw colors write the same
        inputs inline, and <code class="docs-code font-mono">color="inherit"</code>
        omits the hook so the parent tone shows through.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:tone_hooks)} lang={:css} />
      <DocsComponents.content_paragraph class="mt-3">
        To browse the palette itself, see <.link
          navigate={~p"/guides/theming/color"}
          class="docs-link"
        >Color</.link>.
      </DocsComponents.content_paragraph>
    </DocsComponents.section>

    <DocsComponents.section title="Overrides" id="overrides">
      <DocsComponents.content_paragraph class="mt-3">
        Point a role at another hue in your app stylesheet, or remap a palette
        hue's eleven-shade ramp. A role override keeps the semantic name; a hue
        remap updates every role that points at that hue.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:brand_css)} lang={:css} />
      <DocsComponents.content_paragraph class="mt-3">
        See
        <.link
          navigate={~p"/guides/theming/customizing"}
          class="docs-link"
        >Customizing</.link>
        for the full recipes.
      </DocsComponents.content_paragraph>
    </DocsComponents.section>
    """
  end

  defp render_token(:typography, assigns) do
    ~H"""
    <DocsComponents.section title="Families" id="families">
      <DocsComponents.content_paragraph class="mt-3">
        Body copy uses <code class="docs-code font-mono">--fl-font-sans</code>;
        code, token names, and keyboard hints use <code class="docs-code font-mono">--fl-font-mono</code>. Components
        inherit both rather than declaring their own families.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-3 sm:grid-cols-2">
        <div class="rounded-lg border border-default bg-subtle p-4">
          <p class="font-mono text-xs text-muted">--fl-font-sans</p>
          <p class="mt-2 text-xl" style="font-family: var(--fl-font-sans);">
            The quick brown fox
          </p>
        </div>
        <div class="rounded-lg border border-default bg-subtle p-4">
          <p class="font-mono text-xs text-muted">--fl-font-mono</p>
          <p class="mt-2 text-xl" style="font-family: var(--fl-font-mono);">
            mix flint.add button
          </p>
        </div>
      </div>
    </DocsComponents.section>

    <DocsComponents.section title="Scale" id="scale">
      <DocsComponents.content_paragraph class="mt-3">
        Size and line height are paired tokens. Use the pair, not one half, so
        headings and body copy keep their intended rhythm.
      </DocsComponents.content_paragraph>
      <div class="mt-4 divide-y divide-default border-y border-default">
        <div
          :for={{name, size, leading} <- @type_scale}
          class="flex items-baseline gap-4 py-2"
        >
          <code class="w-28 shrink-0 text-xs text-muted">--fl-font-size-{name}</code>
          <span style={"font-size: #{size}; line-height: #{leading};"}>
            The quick brown fox
          </span>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:typography)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Weights and tracking" id="weights">
      <DocsComponents.content_paragraph class="mt-3">
        Weight and tracking are a shared vocabulary. Components use
        <code class="docs-code font-mono">medium</code>
        and <code class="docs-code font-mono">semibold</code>
        for labels and
        headings; tracking is available for display type and small caps.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-6 sm:grid-cols-2">
        <div class="space-y-1">
          <p
            :for={{name, weight} <- @weights}
            style={"font-weight: #{weight};"}
          >
            {name} <span class="font-mono text-xs text-muted">{weight}</span>
          </p>
        </div>
        <div class="space-y-1">
          <p
            :for={{name, value} <- @tracking}
            class="text-sm"
            style={"letter-spacing: #{value};"}
          >
            {name} <span class="font-mono text-xs text-muted">{value}</span>
          </p>
        </div>
      </div>
    </DocsComponents.section>
    """
  end

  defp render_token(:spacing, assigns) do
    ~H"""
    <DocsComponents.section title="Scale" id="scale">
      <DocsComponents.content_paragraph class="mt-3">
        <code class="docs-code font-mono">--fl-spacing</code>
        is the base unit; every step is a multiple of it. Change the base to
        retune density across the whole theme, or override one step when a
        single gap needs to breathe.
      </DocsComponents.content_paragraph>
      <div class="mt-4 space-y-2">
        <div :for={{name, step} <- @spacing_scale} class="flex items-center gap-4">
          <code class="w-28 shrink-0 text-xs text-muted">--fl-spacing-{name}</code>
          <div
            class="h-3 rounded-full bg-inverted"
            style={"width: calc(var(--fl-spacing) * #{step} * 3);"}
          />
          <span class="font-mono text-xs text-muted">{step}× base</span>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:spacing)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Breakpoints and containers" id="breakpoints">
      <DocsComponents.content_paragraph class="mt-3">
        Breakpoints and container widths are tokens too. They keep docs,
        examples, and app layouts on the same steps without copying magic
        numbers between stylesheets.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-6 sm:grid-cols-2">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Breakpoint</th>
                <th class="py-2 font-medium">Width</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-default">
              <tr :for={{name, width} <- @breakpoints}>
                <td class="py-2 pr-4 font-mono text-xs">--fl-breakpoint-{name}</td>
                <td class="py-2 text-toned">{width}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Container</th>
                <th class="py-2 font-medium">Width</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-default">
              <tr :for={{name, width} <- @containers}>
                <td class="py-2 pr-4 font-mono text-xs">--fl-container-{name}</td>
                <td class="py-2 text-toned">{width}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </DocsComponents.section>

    <DocsComponents.section title="Control sizing" id="controls">
      <DocsComponents.content_paragraph class="mt-3">
        Form controls share a <code class="docs-code font-mono">--fl-control-*</code>
        scale so buttons, inputs, and toggles line up. Text fields derive their
        inline padding from the same scale, adding a small inset on top of <code class="docs-code font-mono">--fl-control-padding-x-*</code>, so
        their padding is roomier at the same height. Tune the control padding
        and the field follows; the inset itself is owned by the field
        primitive. Those inputs are documented on the shared primitive and the
        components that adopt it, not here.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:scaling)} lang={:css} />
    </DocsComponents.section>
    """
  end

  defp render_token(:radius, assigns) do
    ~H"""
    <DocsComponents.section title="Scale" id="scale">
      <DocsComponents.content_paragraph class="mt-3">
        Roundness starts from <code class="docs-code font-mono">--fl-radius</code>
        and its scale steps. Change the base unit to retune every step at once.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid grid-cols-3 gap-3 sm:grid-cols-4 lg:grid-cols-7">
        <div :for={{name, value} <- @radius_scale} class="text-center">
          <div
            class="mx-auto size-12 border border-strong bg-strong"
            style={"border-radius: #{value};"}
          />
          <p class="mt-2 font-mono text-xs text-muted">{name}</p>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:radius)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Control radius" id="control-radius">
      <DocsComponents.content_paragraph class="mt-3">
        Buttons, toggles, and inputs share
        <code class="docs-code font-mono">--fl-control-radius</code>
        (default <code class="docs-code font-mono">var(--fl-radius-md)</code>).
        Components with their own shape, such as cards, badges, avatars, and
        switches, read the scale step that fits their anatomy. A theme that
        wants a component-specific exception targets its hook. For a single
        square control, set <code class="docs-code font-mono">radius="none"</code>
        instead of overriding the token.
      </DocsComponents.content_paragraph>
      <div class="mt-4 flex flex-wrap items-center gap-3">
        <Components.button variant="surface">Default radius</Components.button>
        <Components.button variant="surface" radius="none">Square</Components.button>
        <Components.button variant="surface" pill>Pill</Components.button>
      </div>
    </DocsComponents.section>
    """
  end

  defp render_token(:borders, assigns) do
    ~H"""
    <DocsComponents.section title="Edge scale" id="edges">
      <DocsComponents.content_paragraph class="mt-3">
        All three edges are a tint of the same
        <code class="docs-code font-mono">--fl-surface-ink</code>
        over <code class="docs-code font-mono">surface</code>:
        <code class="docs-code font-mono">border-subtle</code>
        at 7%, <code class="docs-code font-mono">border</code>
        at 10%, and <code class="docs-code font-mono">border-strong</code>
        at 18%. Because fills stop at 6%, an edge never sinks into the
        panel it bounds, in either scheme.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        <code class="docs-code font-mono">border-subtle</code>
        is the quiet edge for dividers and soft fills, <code class="docs-code font-mono">border</code>
        is the default edge, and <code class="docs-code font-mono">border-strong</code>
        is the heavier edge for inputs, hover targets, and emphasis.
        The boxes below keep a transparent fill so only the edge shows, and
        use a 2px width so the steps are easy to compare.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-3 sm:grid-cols-3">
        <div
          :for={
            {name, token, role} <-
              [
                {"border-subtle", "var(--fl-color-border-subtle)", "Dividers, soft fills"},
                {"border", "var(--fl-color-border)", "Cards, panels"},
                {"border-strong", "var(--fl-color-border-strong)", "Inputs, hover targets"}
              ]
          }
          class="rounded-xl border-2 bg-transparent p-4"
          style={"border-color: #{token};"}
        >
          <p class="font-mono text-sm font-semibold">{name}</p>
          <p class="mt-1 text-xs text-muted">{role}</p>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:borders)} lang={:css} />
    </DocsComponents.section>
    """
  end

  defp render_token(:surfaces, assigns) do
    ~H"""
    <DocsComponents.section title="Chrome ladder" id="ladder">
      <DocsComponents.content_paragraph class="mt-3">
        <code class="docs-code font-mono">--fl-surface-base</code>
        is the single chrome anchor: the darkest ink every surface is built
        from. It defaults to <code class="docs-code font-mono">gray-950</code>, so
        remapping the gray ramp retints the page, surfaces, tints, and edges
        together. The page is an explicit color per scheme that defaults to a
        white mix of that ink; surface and raised are white mixes of the ink,
        so each step up the ramp is brighter in both schemes.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        Tonal fills are a tint of <code class="docs-code font-mono">--fl-surface-ink</code>
        over the surface: <code class="docs-code font-mono">surface-subtle</code>
        at 3% and <code class="docs-code font-mono">surface-strong</code>
        at 6%. <code class="docs-code font-mono">surface-raised</code>
        lifts overlays above a card. It is a 100% white mix in light, where
        white is already the top, and a 12% white mix of the base in dark.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        Set <code class="docs-code font-mono">--fl-surface-base</code>
        to move the whole ramp: a darker value darkens the dark page and tints
        the light page, while the surfaces stay a step brighter.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        For a smaller adjustment, set <code class="docs-code font-mono">--fl-surface-page-tint</code>
        and <code class="docs-code font-mono">--fl-surface-page-lift</code>.
        They move the page off the anchor extremes and carry the ladder with
        them: tint mixes ink into the light page, lift adds white to the dark
        page, and every step keeps its spacing. They are separate because the
        light page has less contrast headroom. A 1% tint puts the light page
        near <code class="docs-code font-mono">gray-100</code>, and a 2% lift
        moves the dark page off <code class="docs-code font-mono">gray-950</code>
        without reaching <code class="docs-code font-mono">gray-900</code>.
        Keep the tint near 1% if <code class="docs-code font-mono">text-muted</code>
        sits on the page: a darker light page spends text AA headroom. The dark
        side stays comfortable through about 5%.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        The page is also a pair of explicit colors:
        <code class="docs-code font-mono">--fl-surface-page-light</code>
        and <code class="docs-code font-mono">--fl-surface-page-dark</code>.
        Set them directly for absolute values, such as a pure white light page
        or a pure black dark page. A white page is the top of the light ladder,
        so solid cards resolve near white and rely on borders or shadows; the
        tonal <code class="docs-code font-mono">surface-subtle</code>
        and <code class="docs-code font-mono">surface-strong</code>
        fills still provide tinted panels.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:page_extremes)} lang={:css} />
      <DocsComponents.content_paragraph class="mt-3">
        The chrome ladder is ordered: subtle (3%) &lt; strong (6%) &lt;
        border-subtle (7%) &lt; border (10%) &lt; border-strong (18%).
        That keeps a divider above the fill it bounds in both schemes.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <Components.card :for={variant <- ~w(solid soft strong)} variant={variant}>
          <:title>{variant}</:title>
          <p class="text-sm text-toned">Body</p>
        </Components.card>
        <div
          class="rounded-xl border border-default p-4"
          style="background: var(--fl-color-surface-raised);"
        >
          <p class="font-semibold">raised</p>
          <p class="mt-1 text-sm text-toned">Overlays</p>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:surfaces)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Opacity" id="opacity">
      <DocsComponents.content_paragraph class="mt-3">
        Disabled controls dim with <code class="docs-code font-mono">--fl-disabled-opacity</code>
        instead of switching to a dedicated fill. Tinted fills composite at <code class="docs-code font-mono">--fl-tint-opacity</code>, which keeps
        a tinted fill from swallowing the text on top of it; the soft button
        uses half that strength, matching its ghost hover.
      </DocsComponents.content_paragraph>
      <div class="mt-4 flex flex-wrap items-center gap-3">
        <Components.button variant="subtle" disabled>Disabled subtle</Components.button>
        <Components.button variant="solid" color="primary" disabled>
          Disabled solid
        </Components.button>
      </div>
    </DocsComponents.section>
    """
  end

  defp render_token(:shadows, assigns) do
    ~H"""
    <DocsComponents.section title="Shadow scale" id="scale">
      <DocsComponents.content_paragraph class="mt-3">
        The shadow scale is neutral and shared. Use it for elevation on cards,
        menus, and overlays; pair it with <code class="docs-code font-mono">surface-raised</code>
        when an overlay needs both a lift and a fill.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-3">
        <div :for={{name, value} <- @shadows} class="text-center">
          <div
            class="mx-auto grid size-16 place-items-center rounded-lg border border-subtle bg-surface"
            style={"box-shadow: #{value};"}
          >
            <span class="font-mono text-xs text-muted">{name}</span>
          </div>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:shadows)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Raised surfaces" id="surface">
      <DocsComponents.content_paragraph class="mt-3">
        Add <code class="docs-code font-mono">class="fl-surface"</code>
        to any element for a trimmed, layered surface: an inner border, a top
        highlight, an outer ring, and three drop shadows. Level 2 is
        the default; raise it with <code class="docs-code font-mono">--fl-elevation-level</code>, and retune the strip with <code class="docs-code font-mono">--fl-elevation-border</code>, <code class="docs-code font-mono">--fl-elevation-ring</code>, <code class="docs-code font-mono">--fl-elevation-highlight</code>, and <code class="docs-code font-mono">--fl-elevation-shadow-color</code>.
        The border follows the chrome ladder, so point it at
        <code class="docs-code font-mono">--fl-color-border-strong</code>
        for a heavier edge or <code class="docs-code font-mono">--fl-color-border-subtle</code>
        for a quieter one.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-4 sm:grid-cols-3">
        <div
          :for={level <- 1..3}
          class="fl-surface flex h-24 flex-col justify-end rounded-lg p-4"
          style={"--fl-elevation-level: #{level}"}
        >
          <span class="font-mono text-xs text-muted">level {level}</span>
        </div>
      </div>
      <DocsComponents.content_paragraph class="mt-4">
        The card feeds its own border into
        <code class="docs-code font-mono">--fl-elevation-border</code>
        and recomposes <code class="docs-code font-mono">--fl-elevation-surface</code>
        with <code class="docs-code font-mono">--fl-card-shadow</code>
        as the depth, so <code class="docs-code font-mono">--fl-elevation-level</code>
        and <code class="docs-code font-mono">--fl-card-border</code>
        raise or lower it too. The primitive applies the composed shadow once,
        so the card never declares its own <code class="docs-code font-mono">box-shadow</code>.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:surface)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Control depth" id="depth">
      <DocsComponents.content_paragraph class="mt-3">
        Solid and surface buttons are raised: <code class="docs-code font-mono">solid</code>
        wears a top highlight, <code class="docs-code font-mono">surface</code>
        a bottom inner line, and both scale with the shared <code class="docs-code font-mono">--fl-control-depth</code>. Shadows are
        independent and always on for <code class="docs-code font-mono">solid</code>, <code class="docs-code font-mono">subtle</code>, and <code class="docs-code font-mono">surface</code>;
        set <code class="docs-code font-mono">--fl-control-shadow</code>
        to <code class="docs-code font-mono">0 0 #0000</code>
        to remove them. Pressing
        sinks the button with <code class="docs-code font-mono">--fl-control-press</code>.
        Hover and active are an overlay inside the border. Solid is strongest and
        the bordered variants sit in the middle. <code class="docs-code font-mono">ghost</code>, <code class="docs-code font-mono">soft</code>, and
        <code class="docs-code font-mono">subtle</code>
        paint a tone tint instead of a text-color wash: ghost uses the plain soft
        fill at half opacity, while soft and subtle mix that tint toward the role
        color so the hover still reads against their own fill. Retune a tier with
        <code class="docs-code font-mono">--fl-control-hover-opacity</code>
        and <code class="docs-code font-mono">--fl-control-active-opacity</code>;
        each variant sets them on the control, so override them on a control
        selector rather than the root.
      </DocsComponents.content_paragraph>
      <div class="mt-4 flex flex-wrap items-center gap-3">
        <Components.button variant="solid" color="primary">solid</Components.button>
        <Components.button variant="surface">surface</Components.button>
        <Components.button variant="solid" color="primary" depth={false}>flat</Components.button>
        <Components.button variant="ghost">ghost (flat)</Components.button>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:depth)} lang={:css} />
    </DocsComponents.section>
    """
  end

  defp render_token(:focus, assigns) do
    ~H"""
    <DocsComponents.section title="Geometries" id="geometries">
      <DocsComponents.content_paragraph class="mt-3">
        Focus is one shared outline. Switch the geometry with
        <code class="docs-code font-mono">data-focus</code>
        on <code class="docs-code font-mono">&lt;html&gt;</code>
        or any container, then tune the color and opacity once for every
        component. The default <code class="docs-code font-mono">ring</code>
        sits at the component edge; <code class="docs-code font-mono">outline</code>
        keeps a gap, and <code class="docs-code font-mono">inset</code>
        draws inside the edge for dense or clipped layouts.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        The <code class="docs-code font-mono">ring</code>
        preset also colors the border of bordered interactive controls with <code class="docs-code font-mono">--fl-focus-border-color</code>,
        pairing the translucent ring with a full-color edge.
        <code class="docs-code font-mono">outline</code>
        and <code class="docs-code font-mono">inset</code>
        leave the border unchanged. Structural borders such as card bands
        and tab-list rules stay neutral. Invalid inputs will use
        <code class="docs-code font-mono">--fl-focus-color-danger</code>
        for both the border and the ring.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Preset</th>
              <th class="py-3 pr-6 font-medium">Width</th>
              <th class="py-3 pr-6 font-medium">Offset</th>
              <th class="py-3 font-medium">Look</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr>
              <td class="py-3 pr-6"><code class="docs-code font-mono">ring</code></td>
              <td class="py-3 pr-6 text-toned">3px</td>
              <td class="py-3 pr-6 text-toned">0</td>
              <td class="py-3 text-toned">Default; sits against the edge</td>
            </tr>
            <tr>
              <td class="py-3 pr-6"><code class="docs-code font-mono">outline</code></td>
              <td class="py-3 pr-6 text-toned">2px</td>
              <td class="py-3 pr-6 text-toned">2px</td>
              <td class="py-3 text-toned">Gap between control and ring</td>
            </tr>
            <tr>
              <td class="py-3 pr-6"><code class="docs-code font-mono">inset</code></td>
              <td class="py-3 pr-6 text-toned">2px</td>
              <td class="py-3 pr-6 text-toned">-2px</td>
              <td class="py-3 text-toned">Inside the edge; dense layouts</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-4 flex flex-wrap items-center gap-3">
        <div data-focus="ring"><Components.button variant="surface">Ring</Components.button></div>
        <div data-focus="outline">
          <Components.button variant="surface">Outline</Components.button>
        </div>
        <div data-focus="inset">
          <Components.button variant="surface">Inset</Components.button>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:focus)} lang={:css} />
    </DocsComponents.section>
    """
  end

  defp render_token(:transitions, assigns) do
    ~H"""
    <DocsComponents.section title="Durations" id="durations">
      <DocsComponents.content_paragraph class="mt-3">
        Motion uses a three-step duration scale. Use <code class="docs-code font-mono">fast</code>
        for color and border changes, <code class="docs-code font-mono">base</code>
        for expanding and collapsing, and <code class="docs-code font-mono">slow</code>
        sparingly for larger surfaces.
      </DocsComponents.content_paragraph>
      <div class="mt-4 grid gap-3 sm:grid-cols-3">
        <div :for={{name, duration} <- @durations} class="group rounded-lg border border-default p-4">
          <p class="font-mono text-xs text-muted">--fl-duration-{name}</p>
          <p class="mt-1 text-sm text-toned">{duration}</p>
          <div class="mt-3 h-2 rounded-full bg-strong">
            <div
              class="h-2 rounded-full bg-inverted transition-all group-hover:w-full"
              style={"width: 20%; transition-duration: #{duration};"}
            />
          </div>
        </div>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:transitions)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Easings" id="easings">
      <DocsComponents.content_paragraph class="mt-3">
        Two easings cover most interactions. Use <code class="docs-code font-mono">out</code>
        when something enters or settles, and <code class="docs-code font-mono">in-out</code>
        when it moves between two visible states.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Token</th>
              <th class="py-3 pr-6 font-medium">Value</th>
              <th class="py-3 font-medium">Use for</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr :for={{name, value, use} <- @easings}>
              <td class="py-3 pr-6 font-mono text-xs">--fl-ease-{name}</td>
              <td class="py-3 pr-6 text-toned">{value}</td>
              <td class="py-3 text-toned">{use}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </DocsComponents.section>

    <DocsComponents.section title="Reduced motion" id="reduced-motion">
      <DocsComponents.content_paragraph class="mt-3">
        Components guard their transitions and animations with <code class="docs-code font-mono">@media (prefers-reduced-motion: reduce)</code>.
        The tokens never force motion. If you add motion in app CSS, keep the
        same guard and let the reduced-motion rule remove the movement, not the
        state change.
      </DocsComponents.content_paragraph>
    </DocsComponents.section>
    """
  end

  defp render_token(:animations, assigns) do
    ~H"""
    <DocsComponents.section title="Shared animations" id="shared">
      <DocsComponents.content_paragraph class="mt-3">
        These keyframes ship with the theme and are safe to reuse in app CSS.
        They describe the motion only; pair them with a duration and easing from
        the
        <.link
          navigate={~p"/guides/theming/tokens/transitions"}
          class="docs-link"
        >transitions</.link>
        scale. The
        <.link navigate={~p"/guides/theming/css-utilities"} class="docs-link">CSS utilities</.link>
        layer wraps the common recipes as <code class="docs-code font-mono">fl-animate-*</code>
        classes, including a reduced-motion guard.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Keyframe</th>
              <th class="py-3 pr-6 font-medium">Effect</th>
              <th class="py-3 font-medium">Inputs</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr :for={{name, effect, inputs} <- @shared_animations}>
              <td class="py-3 pr-6">
                <code class="docs-code font-mono">@keyframes {name}</code>
              </td>
              <td class="py-3 pr-6 text-toned">{effect}</td>
              <td class="py-3 font-mono text-xs text-muted">{inputs}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-4 grid gap-3 sm:grid-cols-3">
        <div
          :for={{label, keyframe, kind} <- @animation_demos}
          id={"motion-demo-" <> keyframe}
          phx-hook=".MotionDemo"
          class="motion-demo rounded-lg border border-default bg-surface p-4"
        >
          <div class="flex items-center justify-between gap-2">
            <span class="text-xs font-medium text-toned">{label}</span>
            <code class="docs-code font-mono text-[0.65rem]">{keyframe}</code>
          </div>
          <div class="mt-4 grid h-14 place-items-center overflow-hidden">
            <div
              class="size-5 rounded-md bg-inverted"
              data-motion-target
              data-motion-anim={keyframe}
              data-motion-initial={if kind == :enter, do: "hidden"}
              data-motion-loop={if kind == :loop, do: keyframe}
            />
          </div>
          <div class="mt-2 flex min-h-7 items-center justify-between gap-2">
            <p class="text-xs text-muted">{motion_caption(kind)}</p>
            <button
              :if={kind != :loop}
              type="button"
              data-motion-play
              class="rounded-md border border-default px-2 py-1 text-xs font-medium text-toned transition-colors hover:bg-subtle hover:text-highlighted"
            >
              Play
            </button>
          </div>
        </div>
      </div>
      <DocsComponents.content_paragraph class="mt-3">
        Press <strong>Play</strong> on a one-shot animation to see it. Entrance
        demos start hidden and reset after playing, so every press is a fresh
        entrance; exit demos start visible and reset to visible. The looping
        keyframes run continuously.
      </DocsComponents.content_paragraph>
    </DocsComponents.section>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".MotionDemo">
      export default {
        mounted() {
          const target = this.el.querySelector("[data-motion-target]");
          const play = this.el.querySelector("[data-motion-play]");
          let resetTimer;

          play?.addEventListener("click", () => {
            clearTimeout(resetTimer);
            target.removeAttribute("data-motion-playing");
            void target.offsetWidth;
            target.setAttribute("data-motion-playing", "");
          });

          target?.addEventListener("animationend", () => {
            clearTimeout(resetTimer);
            resetTimer = setTimeout(
              () => target.removeAttribute("data-motion-playing"),
              700,
            );
          });
        },
      };
    </script>

    <DocsComponents.section title="Composing" id="composing">
      <DocsComponents.content_paragraph class="mt-3">
        Enter and exit animations use the short duration scale. Looping
        animations set their own duration, because the transition scale is tuned
        for hovers and short reveals, not for a spinner. The four Tailwind
        mirrors use the same timing as their defaults: <code class="docs-code font-mono">spin</code>
        is <code class="docs-code font-mono">1s linear</code>,
        <code class="docs-code font-mono">ping</code>
        is <code class="docs-code font-mono">1s</code>
        with <code class="docs-code font-mono">cubic-bezier(0, 0, 0.2, 1)</code>,
        <code class="docs-code font-mono">pulse</code>
        is <code class="docs-code font-mono">2s</code>
        with <code class="docs-code font-mono">cubic-bezier(0.4, 0, 0.6, 1)</code>, and
        <code class="docs-code font-mono">bounce</code>
        is <code class="docs-code font-mono">1s</code>.
        <code class="docs-code font-mono">fl-shake</code>
        and <code class="docs-code font-mono">fl-flash</code>
        are one-shot attention cues: run them once for a failed submit or a
        saved confirmation, and never loop them.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:animations)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Component animations" id="component-animations">
      <DocsComponents.content_paragraph class="mt-3">
        Each component owns its remaining keyframes, so they can be tuned
        without changing the shared set. The component page documents what each
        prop selects and when the animation runs.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Component</th>
              <th class="py-3 font-medium">Keyframes</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-default">
            <tr :for={{component, path, keyframes} <- @component_animations}>
              <td class="py-3 pr-6">
                <.link navigate={path} class="docs-link">{component}</.link>
              </td>
              <td class="py-3 font-mono text-xs text-muted">
                {Enum.join(keyframes, ", ")}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </DocsComponents.section>

    <DocsComponents.section title="Reduced motion" id="reduced-motion">
      <DocsComponents.content_paragraph class="mt-3">
        Shared keyframes do not disable themselves. If you apply one in app CSS,
        keep the same reduced-motion guard the components use and remove the
        movement, not the state change.
      </DocsComponents.content_paragraph>
      <DocsComponents.code_block code={Snippets.snippet(:animation_reduced_motion)} lang={:css} />
    </DocsComponents.section>
    """
  end

  defp motion_caption(:enter), do: "Plays once, then resets"
  defp motion_caption(:exit), do: "Plays once, then resets"
  defp motion_caption(:attention), do: "One-shot"
  defp motion_caption(:loop), do: "Loops continuously"
end
