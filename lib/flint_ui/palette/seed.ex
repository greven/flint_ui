defmodule FlintUI.Palette.Seed do
  @moduledoc """
  Generates a palette ramp from one seed color.

  The seed becomes the `600` shade exactly. Lighter and darker shades keep the
  seed's hue, interpolate toward near-white and near-black in OKLCH, and scale
  chroma down at the extremes. The result feeds
  `FlintUI.Palette.CSS.render_custom_hue/3`.
  """

  alias FlintUI.Palette.Color

  @lower [
    {50, 1.0, 0.15},
    {100, 0.85, 0.25},
    {200, 0.65, 0.45},
    {300, 0.45, 0.65},
    {400, 0.25, 0.85},
    {500, 0.10, 0.95}
  ]

  @upper [
    {700, 0.15, 0.95},
    {800, 0.35, 0.85},
    {900, 0.55, 0.70},
    {950, 0.75, 0.55}
  ]

  @doc """
  Builds the eleven shades from `value`, an accepted raw color string.

  Raises `ArgumentError` when the color cannot be parsed.
  """
  def from_color(value) do
    case Color.parse(value) do
      {:ok, color} ->
        core_l = clamp(color.l, 0.30, 0.92)

        lower =
          Map.new(@lower, fn {shade, lightness, chroma} ->
            l = core_l + (0.985 - core_l) * lightness
            {shade, Color.format(l, clamp(color.c * chroma, 0.0, 0.4), color.h)}
          end)

        upper =
          Map.new(@upper, fn {shade, lightness, chroma} ->
            l = core_l - (core_l - 0.27) * lightness
            {shade, Color.format(l, clamp(color.c * chroma, 0.0, 0.4), color.h)}
          end)

        lower
        |> Map.merge(upper)
        |> Map.put(600, color.css)

      :error ->
        raise ArgumentError,
              "invalid seed color #{inspect(value)}. Use #rgb, #rrggbb, rgb(...), or oklch(...)."
    end
  end

  defp clamp(value, min, max), do: value |> max(min) |> min(max)
end
