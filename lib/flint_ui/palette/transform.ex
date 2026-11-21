defmodule FlintUI.Palette.Transform do
  @moduledoc false

  # Builds a palette by retuning another palette's OKLCH ramps. The recipe keeps
  # the source hue vocabulary and shade count while changing chroma, hue, and
  # optionally lightness, so contrast behavior stays predictable.

  alias FlintUI.Palette.Color

  @doc """
  Returns a shade map for `hue`, transformed from `source`.

  Options:

    * `:chroma` — multiplier for chromatic hues.
    * `:lightness` — a map of shade → OKLCH lightness for chromatic hues.
    * `:gray_chroma` — absolute chroma for the `gray` hue.
    * `:gray_hue` — hue angle for the `gray` hue.
    * `:gray_lightness` — an optional map of shade → OKLCH lightness for `gray`.
    * `:hue_shift` — degrees added to every chromatic hue.
  """
  def shades(source, hue, opts) do
    source.shades(hue)
    |> Enum.map(fn {shade, value} -> {shade, transform(value, hue, shade, opts)} end)
    |> Map.new()
  end

  defp transform(value, hue, shade, opts) do
    {:ok, %{l: l, c: c, h: h}} = Color.parse(value)

    {l, c, h} =
      if hue == :gray do
        {
          lightness(opts, :gray_lightness, shade, l),
          Keyword.get(opts, :gray_chroma, c),
          Keyword.get(opts, :gray_hue, h)
        }
      else
        {
          lightness(opts, :lightness, shade, l),
          min(c * Keyword.get(opts, :chroma, 1.0), 0.4),
          h + Keyword.get(opts, :hue_shift, 0)
        }
      end

    Color.format(l, c, h)
  end

  defp lightness(opts, key, shade, default) do
    case Keyword.get(opts, key) do
      nil -> default
      map -> Map.get(map, shade, default)
    end
  end
end
