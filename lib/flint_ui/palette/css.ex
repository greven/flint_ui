defmodule FlintUI.Palette.CSS do
  @moduledoc """
  Renders a palette mapping into theme CSS.

  Given a mapping of semantic role to a `{palette_module, color_name}`, it emits:

    * `--fl-color-{role}-{shade}` — the role's scale, written directly from the
      source palette;
    * `--fl-color-{role}` and `--fl-color-{role}-foreground` — the role alias and
      a contrast-picked label for a solid fill;
    * `--fl-color-{role}-text` — a shade safe to use as text on the page
      background (see `FlintUI.Palette.Contrast`).

  Source palette names never become CSS variables: the role scale is the only
  color contract. Every role in the mapping overrides the default theme, because
  the block lands after `flint.css` in the host stylesheet.
  """

  alias FlintUI.Palette
  alias FlintUI.Palette.Contrast

  @roles ~w(primary secondary neutral success info warning error)a

  @doc """
  Renders the CSS block for `mapping`.

  `mapping` is an enumerable of `{role, {palette_module, color_name}}`. Options:

    * `:theme` — a preset name; renders under `[data-theme="<name>"]` instead of
      `:root`.
    * `:light_shade` / `:dark_shade` — the shade a role alias resolves to per
      scheme (defaults `600` / `600`, so a solid fill stays equally saturated in
      both schemes — lightening it in dark washes the fill out and pairs it with
      a dark label).
    * `:shades` — per-role override of the alias shade(s), e.g.
      `%{warning: 400}` (both schemes) or `%{warning: {300, 500}}`. Roles not
      listed keep `:light_shade`/`:dark_shade`.
    * `:contrast` — the target ratio for computed label/text shades: `:aa`
      (default, 4.5), `:aaa` (7.0), or an explicit number.
  """
  def render(mapping, opts \\ []) do
    mapping =
      mapping
      |> Enum.map(fn {role, {source, color}} -> {role, source, color} end)
      |> Enum.sort_by(fn {role, _source, _color} -> Enum.find_index(@roles, &(&1 == role)) end)

    light = Keyword.get(opts, :light_shade, 600)
    dark = Keyword.get(opts, :dark_shade, 600)
    shades = Keyword.get(opts, :shades, %{})
    target = Contrast.target(Keyword.get(opts, :contrast))

    [
      selector(opts),
      " {\n",
      Enum.map_join(mapping, "\n", fn {role, source, color} ->
        {role_light, role_dark} = role_shades(shades, role, light, dark)
        role_block({role, source, color}, role_light, role_dark, target)
      end),
      "\n}\n"
    ]
    |> IO.iodata_to_binary()
  end

  # A role's alias shades: `nil` falls back to the global pair, an integer pins
  # both schemes, and a `{light, dark}` tuple pins each.
  defp role_shades(shades, role, light, dark) do
    case Map.get(shades, role) do
      nil -> {light, dark}
      {role_light, role_dark} -> {role_light, role_dark}
      shade -> {shade, shade}
    end
  end

  defp selector(opts) do
    case Keyword.get(opts, :theme) do
      nil -> ":root"
      theme -> ~s([data-theme="#{theme}"])
    end
  end

  defp role_block({role, source, color}, light, dark, target) do
    shades = source.shades(color)

    scale =
      Enum.map_join(Palette.shade_keys(), "\n", fn shade ->
        "  --fl-color-#{role}-#{shade}: #{shade_value(shades, shade)};"
      end)

    text_light =
      text_shade(
        shades,
        light,
        text_background(shades, light, Contrast.light_background()),
        target
      )

    text_dark =
      text_shade(
        shades,
        dark,
        text_background(shades, dark, Contrast.dark_background()),
        target
      )

    footer = """
      --fl-color-#{role}: light-dark(
        var(--fl-color-#{role}-#{light}),
        var(--fl-color-#{role}-#{dark})
      );
      --fl-color-#{role}-foreground: light-dark(
        #{foreground_value(role, shades, light, target)},
        #{foreground_value(role, shades, dark, target)}
      );
      --fl-color-#{role}-text: light-dark(
        var(--fl-color-#{role}-#{text_light}),
        var(--fl-color-#{role}-#{text_dark})
      );
    """

    scale <> "\n\n" <> String.trim_trailing(footer)
  end

  # The label on a solid fill. Prefer the ramp's tinted extreme (near-white `50`
  # or near-black `950`) when it clears the target; a mid-tone fill whose extremes
  # both fall short (e.g. red-600) falls back to pure white/black — which reads
  # better than the off-white `50` and keeps the fill vivid instead of darkening
  # it. If even pure white/black misses the target (e.g. AAA on a mid-tone), the
  # best-contrast option is used.
  @foreground_shades [50, 950]
  @extreme_values ["oklch(100% 0 0)", "oklch(0% 0 0)"]

  defp foreground_value(role, shades, shade, target) do
    base = shade_value(shades, shade)

    {key, ratio} =
      @foreground_shades
      |> Enum.map(fn candidate ->
        {candidate, Contrast.ratio(base, shade_value(shades, candidate)) || 0.0}
      end)
      |> Enum.max_by(&elem(&1, 1))

    {extreme, extreme_ratio} =
      @extreme_values
      |> Enum.map(fn value -> {value, Contrast.ratio(base, value) || 0.0} end)
      |> Enum.max_by(&elem(&1, 1))

    cond do
      ratio >= target -> "var(--fl-color-#{role}-#{key})"
      extreme_ratio >= target -> extreme
      ratio >= extreme_ratio -> "var(--fl-color-#{role}-#{key})"
      true -> extreme
    end
  end

  # The text-carrying variants paint the color over the page (the `subtle`
  # surface, 10%, deepening to 15% on hover), so the alias is scored against the
  # darkest of those tints — pure white would overstate the contrast.
  @text_tint 0.15

  defp text_background(shades, shade, page) do
    Contrast.mix(shade_value(shades, shade), page, @text_tint)
  end

  # The color used as text on the page: the shade nearest the brand alias that
  # still clears the target ratio against the tinted surface. When no shade
  # qualifies (a mid-tone brand color, or an unreachable target) the most legible
  # shade is used instead.
  defp text_shade(shades, shade, background, target) do
    keys = Palette.shade_keys()

    ratios =
      Enum.map(keys, fn key ->
        {key, Contrast.ratio(shade_value(shades, key), background) || 0.0}
      end)

    case Enum.filter(ratios, fn {_key, ratio} -> ratio >= target end) do
      [] ->
        {best, _} = Enum.max_by(ratios, &elem(&1, 1))
        best

      passing ->
        index = Enum.find_index(keys, &(&1 == shade)) || 0

        {best, _} =
          Enum.min_by(passing, fn {key, _} -> abs(Enum.find_index(keys, &(&1 == key)) - index) end)

        best
    end
  end

  defp shade_value(shades, shade), do: Map.get(shades, shade, Map.get(shades, to_string(shade)))
end
