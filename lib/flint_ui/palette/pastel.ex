defmodule FlintUI.Palette.Pastel do
  @moduledoc """
  A soft, low-chroma palette with lifted midtones.

  Pastel keeps the Tailwind hue vocabulary but lifts the light half of every
  chromatic ramp and scales chroma down. Accent hues use a lighter core (`400`)
  so `color="<hue>"` resolves to a pastel fill with a dark label.

  The `gray` ramp keeps Tailwind's lightness so the chrome ladder, dark
  surfaces, and neutral roles stay readable; only its tint changes.
  """

  @behaviour FlintUI.Palette

  alias FlintUI.Palette
  alias FlintUI.Palette.{Tailwind, Transform}

  # Lighter than Tailwind through the middle, while retaining a dark text end.
  @lightness %{
    50 => 0.98,
    100 => 0.96,
    200 => 0.92,
    300 => 0.87,
    400 => 0.81,
    500 => 0.74,
    600 => 0.66,
    700 => 0.57,
    800 => 0.47,
    900 => 0.37,
    950 => 0.27
  }

  @opts [
    chroma: 0.8,
    lightness: @lightness,
    gray_chroma: 0.005,
    gray_hue: 300.0
  ]

  @impl true
  def name, do: :pastel

  @impl true
  def colors, do: Palette.hues()

  @impl true
  def shades(color), do: Transform.shades(Tailwind, color, @opts)

  @impl true
  def core(:gray), do: Palette.core_shade(:gray)
  def core(_hue), do: 400
end
