defmodule FlintUI.Palette.CSS do
  @moduledoc """
  Renders a palette source into a theme stylesheet part.

  Each hue emits its `50..950` ramp plus five derived tokens:

    * `--fl-color-{hue}` — the core fill (see `FlintUI.Palette.core/2`);
    * `--fl-color-{hue}-on` — the label on that fill;
    * `--fl-color-{hue}-on-soft` — the most saturated AA shade for text on the
      page or a soft fill;
    * `--fl-color-{hue}-soft` — the tinted fill;
    * `--fl-color-{hue}-soft-border` — the matching tinted edge.

  Derived tokens reference the ramp rather than literal colors wherever
  possible, so remapping a hue's eleven shade variables in an app stylesheet
  updates its label, on-soft text, and tinted treatments at the same time.

  The default palette renders under `:root, [data-palette="<name>"]`; other
  palettes render under `[data-palette="<name>"]`. `render_hooks/1` emits the
  `data-color` tone hooks, and `render_custom_hue/3` combines a generated ramp
  with its hooks for `mix flint.palette`.
  """

  alias FlintUI.Palette
  alias FlintUI.Palette.Contrast

  @roles ~w(primary secondary neutral info success warning danger dark light)

  @white "oklch(100% 0 0)"
  @black "oklch(0% 0 0)"

  @doc """
  Renders the `data-color` and `data-active-color` tone hooks.

  The hooks cover semantic roles plus the canonical palette hues by default.
  Pass `:hues` and `:roles` to render a different set, as `mix flint.palette`
  does for one custom hue.
  """
  def render_hooks(opts \\ []) do
    roles = Keyword.get(opts, :roles, @roles)
    hues = Keyword.get(opts, :hues, Palette.hue_names())

    base =
      Enum.map_join(roles, "\n", &role_hook("data-color", &1)) <>
        Enum.map_join(hues, "\n", &hue_hook("data-color", &1))

    active =
      Enum.map_join(roles ++ hues, "\n", &hue_hook("data-active-color", &1))

    """
    /* Color hooks. One selected color, one five-token tone set.
     *
     * `data-color` is the base tone; `data-active-color` is the toggled tone.
     * Components read `--fl-tone*` / `--fl-active-tone*`, so a role and a palette
     * hue are interchangeable. Raw colors write the same inputs inline, and an
     * omitted hook (for example `color="inherit"`) lets the parent tone through.
     */

    @layer components {
    #{indent(String.trim_trailing(base))}

    #{indent(String.trim_trailing(active))}
    }
    """
  end

  defp role_hook(attribute, role) do
    """
    :where([#{attribute}="#{role}"]) {
        --fl-tone: var(--fl-color-#{role});
        --fl-tone-on: var(--fl-color-#{role}-on);
        --fl-tone-on-soft: var(--fl-color-#{role}-on-soft);
        --fl-tone-soft: var(--fl-color-#{role}-soft);
        --fl-tone-soft-border: var(--fl-color-#{role}-soft-border);
    }
    """
  end

  defp hue_hook(attribute, hue) do
    prefix = if attribute == "data-active-color", do: "--fl-active-tone", else: "--fl-tone"

    """
    :where([#{attribute}="#{hue}"]) {
        #{prefix}: var(--fl-color-#{hue});
        #{prefix}-on: var(--fl-color-#{hue}-on);
        #{prefix}-on-soft: var(--fl-color-#{hue}-on-soft);
        #{prefix}-soft: var(--fl-color-#{hue}-soft);
        #{prefix}-soft-border: var(--fl-color-#{hue}-soft-border);
    }
    """
  end

  @doc """
  Renders a standalone stylesheet part for one app-defined hue.

  The block contains the eleven shades, the five derived tokens, and the base
  and active hooks. Import it after `flint.css` and add the hue to
  `config :flint_ui, extra_hues: [...]`.
  """
  def render_custom_hue(name, shades, opts \\ []) do
    hue = to_string(name)
    core = Keyword.get(opts, :core, 600)
    tokens = hue_tokens(hue, shades, core: core, contrast: Keyword.get(opts, :contrast))
    hooks = render_hooks(roles: [], hues: [hue])

    """
    /* Custom palette hue `#{hue}`. Import after flint.css. */
    :root {
    #{indent(tokens)}
    }

    #{hooks}\
    """
  end

  @doc """
  Renders the CSS block for `source`.

  Options:

    * `:default` — render under `:root` as well as the palette selector.
    * `:contrast` — the target ratio for labels and text shades: `:aa`
      (default), `:aaa`, or an explicit number.
  """
  def render_palette(source, opts \\ []) do
    target = Contrast.target(Keyword.get(opts, :contrast))

    hues =
      source
      |> source_hues()
      |> Enum.map_join("\n\n", fn hue ->
        hue_tokens(hue, source.shades(hue),
          core: Palette.core(source, hue),
          contrast: target
        )
      end)

    "#{selector(source, opts)} {\n#{indent(hues)}\n}\n"
  end

  defp source_hues(source), do: source.colors()

  defp selector(source, opts) do
    if Keyword.get(opts, :default, false) do
      ~s(:root,\n[data-palette="#{source.name()}"])
    else
      ~s([data-palette="#{source.name()}"])
    end
  end

  @doc """
  Renders the eleven shades and five derived tokens for one hue.

  `core` defaults to `FlintUI.Palette.core_shade/1`; pass `:core` to pin a
  different shade. This is the block the palette parts and `mix flint.palette`
  share.
  """
  def hue_tokens(hue, shades, opts \\ []) do
    target = Contrast.target(Keyword.get(opts, :contrast))
    core = Keyword.get(opts, :core, Palette.core_shade(hue))
    core_value = shade_value(shades, core)

    # `on-soft` is used both on the soft fill and as role text on the page, so
    # score it against the lightest backdrop in each scheme: `surface-strong`
    # and the tinted soft fill. The soft fill mixes with the surface anchor
    # (`--fl-color-surface`), so mirror that base here.
    light_soft = Contrast.mix(core_value, @white, 0.12)
    dark_soft = Contrast.mix(core_value, Contrast.dark_surface(), 0.18)

    light_backgrounds = [Contrast.light_surface_strong(), light_soft]
    dark_backgrounds = [Contrast.dark_background(), dark_soft]

    light_step = text_step(shades, light_backgrounds, target, [700, 800, 900, 600])
    dark_step = text_step(shades, dark_backgrounds, target, [400, 300, 200, 500])

    scale =
      Enum.map_join(Palette.shade_keys(), "\n", fn shade ->
        "--fl-color-#{hue}-#{shade}: #{shade_value(shades, shade)};"
      end)

    footer = """
    --fl-color-#{hue}: var(--fl-color-#{hue}-#{core});
    --fl-color-#{hue}-on: #{on_value(hue, shades, core, target)};
    --fl-color-#{hue}-on-soft: light-dark(
        var(--fl-color-#{hue}-#{light_step}),
        var(--fl-color-#{hue}-#{dark_step})
    );
    --fl-color-#{hue}-soft: light-dark(
        color-mix(in oklab, var(--fl-color-#{hue}) 12%, var(--fl-color-surface)),
        color-mix(in oklab, var(--fl-color-#{hue}) 18%, var(--fl-color-surface))
    );
    --fl-color-#{hue}-soft-border: color-mix(
        in oklab,
        var(--fl-color-#{hue}) var(--fl-border-strength-soft),
        var(--fl-color-surface)
    );\
    """

    scale <> "\n\n" <> footer
  end

  # The label on the core fill. Prefer the ramp's near-white/near-black extremes
  # so a remapped ramp carries its label with it; fall back to pure white/black
  # when both extremes miss the target (a mid-tone fill such as red-600).
  @content_shades [50, 950]

  defp on_value(hue, shades, core, target) do
    base = shade_value(shades, core)

    {key, ratio} =
      @content_shades
      |> Enum.map(fn shade ->
        {shade, Contrast.ratio(base, shade_value(shades, shade)) || 0.0}
      end)
      |> Enum.max_by(&elem(&1, 1))

    {extreme, extreme_ratio} =
      [
        {@white, Contrast.ratio(base, @white) || 0.0},
        {@black, Contrast.ratio(base, @black) || 0.0}
      ]
      |> prefer_white(target)

    cond do
      ratio >= target -> "var(--fl-color-#{hue}-#{key})"
      extreme_ratio >= target -> extreme
      ratio >= extreme_ratio -> "var(--fl-color-#{hue}-#{key})"
      true -> extreme
    end
  end

  # A light label is the default for a saturated fill; only switch to black
  # when white misses the target.
  defp prefer_white([{white, white_ratio}, {black, black_ratio}], target) do
    cond do
      white_ratio >= target -> {white, white_ratio}
      black_ratio >= target -> {black, black_ratio}
      white_ratio >= black_ratio -> {white, white_ratio}
      true -> {black, black_ratio}
    end
  end

  # The shade used as colored text on the page and soft fill. A candidate must
  # clear the target on every backdrop; fall back to the shade with the best
  # worst-case ratio when the whole ramp is too flat (or a custom palette is
  # unusually constrained).
  defp text_step(shades, backgrounds, target, preferred) do
    worst_ratio = fn shade ->
      value = shade_value(shades, shade)

      backgrounds
      |> Enum.map(&(Contrast.ratio(value, &1) || 0.0))
      |> Enum.min()
    end

    case Enum.find(preferred, &(worst_ratio.(&1) >= target)) do
      nil -> Enum.max_by(Palette.shade_keys(), worst_ratio)
      step -> step
    end
  end

  defp shade_value(shades, shade), do: Map.get(shades, shade, Map.get(shades, to_string(shade)))

  defp indent(text) do
    text
    |> String.split("\n")
    |> Enum.map_join("\n", fn
      "" -> ""
      line -> "    " <> line
    end)
  end
end
