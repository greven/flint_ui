defmodule FlintUI.Palette.Bright do
  @moduledoc """
  A higher-chroma palette with cool, blue-leaning neutrals.
  """

  @behaviour FlintUI.Palette

  alias FlintUI.Palette
  alias FlintUI.Palette.{Tailwind, Transform}

  @opts [chroma: 1.15, gray_chroma: 0.012, gray_hue: 250.0]

  @impl true
  def name, do: :bright

  @impl true
  def colors, do: Palette.hues()

  @impl true
  def shades(color), do: Transform.shades(Tailwind, color, @opts)
end
