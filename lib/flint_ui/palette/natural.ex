defmodule FlintUI.Palette.Natural do
  @moduledoc """
  A low-chroma palette with warm, stone-like neutrals.

  It keeps the Tailwind lightness ramps but softens every hue, so components
  read quieter without changing their contrast behavior.
  """

  @behaviour FlintUI.Palette

  alias FlintUI.Palette
  alias FlintUI.Palette.{Tailwind, Transform}

  @opts [chroma: 0.55, gray_chroma: 0.008, gray_hue: 60.0]

  @impl true
  def name, do: :natural

  @impl true
  def colors, do: Palette.hues()

  @impl true
  def shades(color), do: Transform.shades(Tailwind, color, @opts)
end
