defmodule FlintUI.Palette.Transform do
  @moduledoc false

  # Builds a palette by retuning another palette's OKLCH ramps. Keeping the
  # lightness ramp and changing chroma/hue is enough to produce a distinct
  # family that still shares the ten portable hue names and the same contrast
  # behavior.

  alias FlintUI.Palette.Color

  @doc """
  Returns a shade map for `hue`, transformed from `source`.

  Options:

    * `:chroma` — multiplier for chromatic hues.
    * `:gray_chroma` — absolute chroma for the `gray` hue.
    * `:gray_hue` — hue angle for the `gray` hue.
    * `:hue_shift` — degrees added to every chromatic hue.
  """
  def shades(source, hue, opts) do
    source.shades(hue)
    |> Enum.map(fn {shade, value} -> {shade, transform(value, hue, opts)} end)
    |> Map.new()
  end

  defp transform(value, hue, opts) do
    {:ok, %{l: l, c: c, h: h}} = Color.parse(value)

    {c, h} =
      if hue == :gray do
        {opts[:gray_chroma], opts[:gray_hue]}
      else
        {min(c * opts[:chroma], 0.4), h + Keyword.get(opts, :hue_shift, 0)}
      end

    Color.format(l, c, h)
  end
end
