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

  @impl true
  def mount(_params, _session, socket) do
    page = Tokens.get!(socket.assigns.live_action)

    {:ok,
     assign(socket,
       page_title: page.title,
       token_page: page,
       type_scale: @type_scale,
       weights: @weights,
       tracking: @tracking,
       spacing_scale: @spacing_scale,
       breakpoints: @breakpoints,
       containers: @containers,
       radius_scale: @radius_scale,
       shadows: @shadows,
       durations: @durations,
       easings: @easings
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
    <DocsComponents.section title="Semantic roles" id="roles">
      <DocsComponents.content_paragraph class="mt-3">
        A role points at one palette hue's five-token tone set. The fill is the
        role itself; <code class="docs-code font-mono">-on</code>
        labels
        that fill, <code class="docs-code font-mono">-on-soft</code>
        is the role as
        text on a neutral or soft surface, and <code class="docs-code font-mono">-soft</code>
        and <code class="docs-code font-mono">-soft-border</code>
        are the tinted
        pair. <code class="docs-code font-mono">-on-soft</code>
        picks the most saturated shade that still clears AA on both the surface
        ladder and the tinted soft fill, so it stays vivid instead of fading to
        a pastel.
      </DocsComponents.content_paragraph>
      <div class="mt-4 overflow-x-auto">
        <table class="w-full min-w-lg text-left text-sm">
          <thead class="border-b border-default text-xs tracking-wider text-muted uppercase">
            <tr>
              <th class="py-3 pr-6 font-medium">Role</th>
              <th class="py-3 pr-6 font-medium">Default hue</th>
              <th class="py-3 pr-6 font-medium">Fill</th>
              <th class="py-3 font-medium">On soft</th>
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
                  {"warning", "amber"},
                  {"error", "red"}
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
            </tr>
          </tbody>
        </table>
      </div>
      <DocsComponents.code_block code={Snippets.snippet(:colors)} lang={:css} />
    </DocsComponents.section>

    <DocsComponents.section title="Text tiers" id="text">
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

    <DocsComponents.section title="Tone hooks" id="tone-hooks">
      <DocsComponents.content_paragraph class="mt-3">
        A <code class="docs-code font-mono">color</code>
        prop resolves to one five-token tone set. A semantic role and a palette
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
        scale so buttons, inputs, and toggles line up. Text fields add
        <code class="docs-code font-mono">--fl-field-padding-x-*</code>
        so their inline padding is roomier at the same height. Those inputs are
        documented on the shared primitive and the components that adopt it,
        not here.
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
        together. Background, surface, and raised are white mixes of that ink,
        so each step up the ramp is brighter in both schemes.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        Tonal fills are a tint of <code class="docs-code font-mono">--fl-surface-ink</code>
        over the surface: <code class="docs-code font-mono">surface-subtle</code>
        at 3% and <code class="docs-code font-mono">surface-strong</code>
        at 6%. <code class="docs-code font-mono">surface-raised</code>
        lifts overlays above a card. It is white in light, where white is already
        the top, and a 12% white mix of the base in dark.
      </DocsComponents.content_paragraph>
      <DocsComponents.content_paragraph class="mt-3">
        Set <code class="docs-code font-mono">--fl-surface-base</code>
        to move the whole ramp: a darker value darkens the dark page and tints
        the light page, while the surfaces stay a step brighter.
      </DocsComponents.content_paragraph>
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
        instead of switching to a dedicated fill. Soft tints composite at <code class="docs-code font-mono">--fl-tint-opacity</code>, which keeps
        a tinted fill from swallowing the text on top of it.
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
        Hover and active are a <code class="docs-code font-mono">currentColor</code>
        overlay inside the border; retune them with
        <code class="docs-code font-mono">--fl-control-hover-opacity</code>
        and <code class="docs-code font-mono">--fl-control-active-opacity</code>.
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
        <code class="docs-code font-mono">--fl-focus-color-error</code>
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
end
