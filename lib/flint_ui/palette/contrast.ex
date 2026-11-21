defmodule FlintUI.Palette.Contrast do
  @moduledoc """
  WCAG contrast utilities for `oklch()` color values.

  `FlintUI.Palette.CSS` uses these to derive accessible foreground/text shades
  from a palette scale instead of hardcoding them: the solid "on-fill" label is
  the shade with the highest contrast against the fill, and the "as text" alias
  is the most saturated shade that still meets the AA ratio against every
  backdrop it can sit on (the surface ladder and the tinted soft fill).

  Colors are converted oklch → oklab → linear sRGB and scored with the WCAG 2.1
  relative-luminance formula.
  """

  # WCAG 2.1 contrast tiers for normal-size text.
  @aa 4.5
  @aaa 7.0

  # Reference surfaces for role text. Light text starts on white; dark text
  # starts on the 5.5% `surface-strong` tint, the lightest dark backdrop a role
  # text token sits on. Scoring against the lightest backdrop in each scheme is
  # the strict case.
  @light_background "oklch(100% 0 none)"
  @dark_background "oklch(24.8% 0 none)"

  # A tinted soft fill mixes over the surface anchor, not the strong tint:
  # white in light, `gray-900` in dark. Keep these in step with `tokens.css`.
  @light_surface_strong "oklch(95.3% 0 none)"
  @dark_surface "oklch(20.5% 0 none)"

  @pattern ~r/^\s*oklch\(\s*([0-9.]+)(%?)\s+([0-9.]+|none)(?:\s+([0-9.]+|none))?\s*\)\s*$/

  @doc "The AA contrast ratio threshold (normal text)."
  def aa, do: @aa

  @doc "The AAA contrast ratio threshold (normal text)."
  def aaa, do: @aaa

  @doc """
  Resolves a contrast target: `:aa` (default), `:aaa`, or an explicit ratio.
  """
  def target(nil), do: @aa
  def target(:aa), do: @aa
  def target(:aaa), do: @aaa
  def target(ratio) when is_number(ratio), do: ratio * 1.0

  @doc """
  The light-mode surface anchor (white).

  Raw colors model their tinted surface over this anchor.
  """
  def light_background, do: @light_background

  @doc """
  The dark-mode `surface-strong` tint: the lightest dark backdrop a label sits
  on.

  Raw-color tints and palette `-on-soft` shades are scored against it.
  """
  def dark_background, do: @dark_background

  @doc "The light-mode `surface-strong` tint a colored label can sit on."
  def light_surface_strong, do: @light_surface_strong

  @doc """
  The dark-mode surface anchor (`gray-900`).

  A tinted soft fill mixes its hue over this anchor, so the `-on-soft` shade is
  scored against the same base the CSS paints.
  """
  def dark_surface, do: @dark_surface

  @doc """
  The WCAG contrast ratio between two `oklch()` strings.

  Returns a float in `1.0..21.0`, or `nil` when either value cannot be parsed.
  """
  def ratio(a, b) do
    case {luminance(a), luminance(b)} do
      {ya, yb} when is_float(ya) and is_float(yb) ->
        {hi, lo} = {max(ya, yb), min(ya, yb)}
        (hi + 0.05) / (lo + 0.05)

      _ ->
        nil
    end
  end

  @doc "The WCAG relative luminance (0..1) of an `oklch()` string, or `nil`."
  def luminance(value) when is_binary(value) do
    case oklab(value) do
      {l, a, b} -> linear_luminance(oklab_to_linear(l, a, b))
      nil -> nil
    end
  end

  def luminance(_), do: nil

  @doc """
  Mixes two `oklch()` colors in oklab (`weight` of the first), returning an
  `oklch()` string. Used to model `color-mix(... N%, transparent)` over a page.
  """
  def mix(a, b, weight) when is_float(weight) do
    with {la, aa, ba} <- oklab(a),
         {lb, ab, bb} <- oklab(b) do
      l = weight * la + (1 - weight) * lb
      x = weight * aa + (1 - weight) * ab
      y = weight * ba + (1 - weight) * bb

      chroma = :math.sqrt(x * x + y * y)
      hue = :math.atan2(y, x) * 180 / :math.pi()
      hue = if hue < 0, do: hue + 360, else: hue

      "oklch(#{number(l * 100)}% #{number(chroma)} #{number(hue)})"
    end
  end

  # `to_string/1` switches to scientific notation for small chromas
  # (`7.65e-4`), which the oklch parser above cannot read. Keep the mixed
  # result in plain decimal form so it can be scored and used as CSS.
  defp number(value), do: :erlang.float_to_binary(value, [:compact, decimals: 6])

  defp oklab(value) when is_binary(value) do
    case Regex.run(@pattern, value) do
      [_, l, percent, chroma, hue] ->
        lightness = to_float(l) |> then(&if(percent == "%", do: &1 / 100, else: &1))
        radius = to_float(chroma)
        angle = to_float(hue) * :math.pi() / 180
        {lightness, radius * :math.cos(angle), radius * :math.sin(angle)}

      _ ->
        nil
    end
  end

  defp oklab(_), do: nil

  defp linear_luminance(linear) do
    {r, g, b} = linear
    0.2126 * clamp(r) + 0.7152 * clamp(g) + 0.0722 * clamp(b)
  end

  defp oklab_to_linear(l, a, b) do
    # oklab → lms → linear sRGB (D65).
    l_ = l + 0.3963377774 * a + 0.2158037573 * b
    m_ = l - 0.1055613458 * a - 0.0638541728 * b
    s_ = l - 0.0894841775 * a - 1.2914855480 * b

    {ll, mm, ss} = {cube(l_), cube(m_), cube(s_)}

    {
      4.0767416621 * ll - 3.3077115913 * mm + 0.2309699292 * ss,
      -1.2684380046 * ll + 2.6097574011 * mm - 0.3413193965 * ss,
      -0.0041960863 * ll - 0.7034186147 * mm + 1.7076147010 * ss
    }
  end

  defp cube(x), do: x * x * x

  defp clamp(x), do: x |> max(0.0) |> min(1.0)

  defp to_float("none"), do: 0.0

  defp to_float(value) do
    # `Float.parse/1` rejects a leading dot (".194"), which minified source emits.
    value = if String.starts_with?(value, "."), do: "0" <> value, else: value

    case Float.parse(value) do
      {float, _} -> float
      :error -> 0.0
    end
  end
end
