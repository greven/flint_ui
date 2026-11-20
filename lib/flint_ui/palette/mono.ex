defmodule FlintUI.Palette.Mono do
  @moduledoc """
  An achromatic palette.

  Every hue keeps its lightness ramp but drops to zero chroma, which is useful
  for wireframes, print-like interfaces, and demonstrating that a component's
  color contract is hue-independent.
  """

  @behaviour FlintUI.Palette

  alias FlintUI.Palette
  alias FlintUI.Palette.{Tailwind, Transform}

  @opts [chroma: 0.0, gray_chroma: 0.0, gray_hue: 0.0]

  @impl true
  def name, do: :mono

  @impl true
  def colors, do: Palette.hues()

  @impl true
  def shades(color), do: Transform.shades(Tailwind, color, @opts)
end
