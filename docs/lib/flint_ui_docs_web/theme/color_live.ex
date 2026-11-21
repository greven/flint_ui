defmodule FlintUIDocsWeb.Theme.ColorLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUI.Palette.Contrast
  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.Snippets

  @white "oklch(100% 0 0)"
  @black "oklch(0% 0 0)"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Color",
       palettes: FlintUI.Palette.presets(),
       swatches: hue_swatches(),
       neutrals: neutral_swatches()
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

          <DocsComponents.code_block code={Snippets.snippet(:palettes)} lang={:css} />

          <Layouts.palette_picker palettes={@palettes} class="mt-8" />
          <div class="mt-4 grid grid-cols-2 gap-2 sm:grid-cols-3">
            <.color_swatch :for={swatch <- @swatches} swatch={swatch} />
          </div>
          <DocsComponents.content_paragraph class="mt-3 text-xs">
            Each swatch shows a hue's default fill — the shade its
            <code class="docs-code font-mono">color</code>
            prop resolves to; the default varies by hue so the label clears AA.
            Hover or focus a shade in the scale below to preview it in the swatch
            and read its number. Click a swatch to copy its CSS variable, for
            example <code class="docs-code font-mono">var(--fl-color-rose)</code>
            or <code class="docs-code font-mono">var(--fl-color-rose-300)</code>.
          </DocsComponents.content_paragraph>

          <DocsComponents.subsection title="Neutral ramps" id="neutral-ramps">
            <DocsComponents.content_paragraph class="mt-3">
              The chrome is built from the palette's <code class="docs-code font-mono">gray</code>
              hue, which defaults to Tailwind's <code class="docs-code font-mono">neutral</code>
              ramp. These are Tailwind's neutral ramps — fixed source values, not
              part of the palette switch. Remap
              <code class="docs-code font-mono">--fl-color-gray-*</code>
              to any of them to retint surfaces, borders, text, and the secondary
              role without touching the semantic roles.
            </DocsComponents.content_paragraph>
            <div class="mt-4 grid grid-cols-2 gap-2 sm:grid-cols-3">
              <.color_swatch :for={swatch <- @neutrals} swatch={swatch} />
            </div>
            <DocsComponents.content_paragraph class="mt-3 text-xs">
              Click a neutral swatch to copy a ready-to-paste remap block, or a
              shade to copy its single declaration. <code class="docs-code font-mono">neutral</code>
              is the default.
            </DocsComponents.content_paragraph>
          </DocsComponents.subsection>
        </DocsComponents.section>

        <DocsComponents.section title="Palette Hues" id="palette-colors">
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

        <DocsComponents.section title="Semantic Colors" id="semantic-colors">
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
            yellow; and <strong>danger</strong>
            red. A
            palette switch changes what those hues look like; a role override
            changes which hue a role points at.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button
              :for={role <- ~w(neutral info success warning danger secondary)}
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

        <DocsComponents.section title="Absolute Tones" id="absolute">
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

  attr :swatch, :map, required: true

  defp color_swatch(assigns) do
    ~H"""
    <div
      data-color-swatch={@swatch.id}
      style={swatch_style(@swatch)}
      class={[
        "rounded-xl border border-default bg-surface p-1.5 transition-colors",
        "hover:border-strong focus-within:border-strong"
      ]}
    >
      <button
        type="button"
        data-swatch-main
        data-copy
        data-copy-value={@swatch.copy_value}
        data-copy-success-label={@swatch.copy_success}
        aria-label={@swatch.copy_label}
        class={[
          "group flex h-20 w-full cursor-pointer flex-col justify-between rounded-lg p-2 text-left",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-strong"
        ]}
      >
        <span class="flex items-start justify-between gap-2">
          <span class="font-mono text-xs font-semibold tracking-wide">{@swatch.name}</span>
          <span class="font-mono text-[11px] tabular-nums opacity-70">
            <span data-swatch-core>{@swatch.core}</span>
            <span data-swatch-preview aria-hidden="true"></span>
          </span>
        </span>
        <span class="flex items-end justify-between gap-2">
          <span class="font-mono text-[9px] uppercase tracking-wider opacity-60">
            {@swatch.badge}
          </span>
          <span class={[
            "flex size-3.5 items-center justify-center opacity-0 transition-opacity",
            "group-hover:opacity-100 group-focus-visible:opacity-100 group-data-[state=success]:opacity-100"
          ]}>
            <FlintUI.icon name="lucide-copy" class="size-3 group-data-[state=success]:hidden" />
            <FlintUI.icon name="lucide-check" class="hidden size-3 group-data-[state=success]:block" />
          </span>
        </span>
      </button>

      <div class="mt-1.5 grid grid-cols-11 gap-px">
        <button
          :for={shade <- @swatch.shades}
          type="button"
          data-copy
          data-copy-value={shade.copy_value}
          data-copy-success-label={shade.copy_success}
          data-copy-duration="1200"
          aria-label={shade.copy_label}
          title={shade.copy_label}
          data-shade={shade.key}
          style={"background-color: var(--_fl-swatch-#{shade.key}-fill)"}
          class={[
            "relative h-5 cursor-pointer transition-transform duration-150",
            "first:rounded-l-sm last:rounded-r-sm",
            "hover:z-10 hover:scale-y-125 focus-visible:z-10",
            "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-strong"
          ]}
        ></button>
      </div>
    </div>
    """
  end

  defp hue_swatches do
    default_palette = FlintUI.Palette.default()

    Enum.map(FlintUI.Palette.hues(), fn hue ->
      shades = default_palette.module.shades(hue)
      name = Atom.to_string(hue)

      %{
        id: name,
        name: name,
        badge: nil,
        core: FlintUI.Palette.core_shade(hue),
        fill: "var(--fl-color-#{name})",
        on: "var(--fl-color-#{name}-on)",
        copy_value: "var(--fl-color-#{name})",
        copy_label: "Copy var(--fl-color-#{name})",
        copy_success: "Copied var(--fl-color-#{name})",
        shades:
          Enum.map(FlintUI.Palette.shade_keys(), fn shade ->
            token = "var(--fl-color-#{name}-#{shade})"

            %{
              key: shade,
              fill: token,
              on: hue_label(name, shades, shade),
              copy_value: token,
              copy_label: "Copy #{token}",
              copy_success: "Copied #{token}"
            }
          end)
      }
    end)
  end

  defp neutral_swatches do
    Enum.map(FlintUI.Palette.Tailwind.neutral_ramps(), fn ramp ->
      shades = FlintUI.Palette.Tailwind.neutral_shades(ramp)
      name = Atom.to_string(ramp)
      core = 600

      %{
        id: "neutral-#{name}",
        name: name,
        badge: if(ramp == :neutral, do: "default"),
        core: core,
        fill: Map.fetch!(shades, core),
        on: raw_label(shades, core),
        copy_value: gray_remap(name, shades),
        copy_label: "Copy the #{name} ramp as the gray remap",
        copy_success: "Copied the #{name} gray remap",
        shades:
          Enum.map(FlintUI.Palette.shade_keys(), fn shade ->
            %{
              key: shade,
              fill: Map.fetch!(shades, shade),
              on: raw_label(shades, shade),
              copy_value: "--fl-color-gray-#{shade}: #{Map.fetch!(shades, shade)};",
              copy_label: "Copy --fl-color-gray-#{shade}",
              copy_success: "Copied --fl-color-gray-#{shade}"
            }
          end)
      }
    end)
  end

  # The label that stays readable on a fill. This mirrors the on-fill rule in
  # `FlintUI.Palette.CSS`: prefer a near-white or near-black ramp extreme when
  # it clears AA, otherwise fall back to pure white or black. Every shipped
  # palette keeps the Tailwind lightness ramp, so scoring the default palette
  # still holds after a `data-palette` switch.
  defp hue_label(hue, shades, shade) do
    case label(shades, shade) do
      {:ramp, key} -> "var(--fl-color-#{hue}-#{key})"
      {:extreme, value} -> value
    end
  end

  defp raw_label(shades, shade) do
    case label(shades, shade) do
      {:ramp, key} -> Map.fetch!(shades, key)
      {:extreme, value} -> value
    end
  end

  defp label(shades, shade) do
    base = Map.fetch!(shades, shade)

    {ramp, ramp_ratio} =
      [50, 950]
      |> Enum.map(fn key -> {key, Contrast.ratio(base, Map.fetch!(shades, key)) || 0.0} end)
      |> Enum.max_by(&elem(&1, 1))

    extreme =
      [@white, @black]
      |> Enum.max_by(&(Contrast.ratio(base, &1) || 0.0))

    if ramp_ratio >= Contrast.aa(), do: {:ramp, ramp}, else: {:extreme, extreme}
  end

  defp swatch_style(%{fill: fill, on: on, core: core, shades: shades}) do
    previews =
      Enum.map_join(shades, "\n", fn %{key: key, fill: fill, on: on} ->
        "--_fl-swatch-#{key}-fill: #{fill};\n--_fl-swatch-#{key}-on: #{on};"
      end)

    """
    --_fl-swatch-fill: #{fill};
    --_fl-swatch-on: #{on};
    --_fl-swatch-label: '#{core}';
    #{previews}
    """
  end

  defp gray_remap(name, shades) do
    declarations =
      Enum.map_join(FlintUI.Palette.shade_keys(), "\n", fn shade ->
        "  --fl-color-gray-#{shade}: #{Map.fetch!(shades, shade)};"
      end)

    """
    /* Tailwind #{name} as the FlintUI gray ramp. */
    :root {
    #{declarations}
    }
    """
  end
end
