defmodule FlintUI.PaletteTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette
  alias FlintUI.Palette.Tailwind

  test "tailwind is the default palette" do
    assert Palette.default().name == :tailwind
    assert Palette.default().module == Tailwind
  end

  test "every palette defines the eighteen portable hues" do
    for palette <- Palette.palettes() do
      assert palette.module.colors() == Palette.hues(),
             "#{palette.name} must define the shared hue vocabulary"
    end
  end

  test "every palette hue has the full shade range" do
    for palette <- Palette.palettes(), hue <- Palette.hues() do
      assert palette.module.shades(hue) |> Map.keys() |> Enum.sort() ==
               Palette.shade_keys() |> Enum.sort()
    end
  end

  test "tailwind shade values are oklch strings" do
    assert Tailwind.shades(:red)[600] == "oklch(57.7% 0.245 27.325)"
    assert Tailwind.shades(:pink)[500] == "oklch(65.6% 0.241 354.308)"
  end

  test "tailwind gray uses the neutral ramp so chrome starts achromatic" do
    assert Tailwind.shades(:gray)[600] == "oklch(43.9% 0 none)"
  end

  test "tailwind exposes every neutral ramp, default first" do
    assert Tailwind.neutral_ramps() |> hd() == :neutral
    assert :gray in Tailwind.neutral_ramps()
    assert Tailwind.neutral_shades(:neutral) == Tailwind.shades(:gray)
    assert Tailwind.neutral_shades(:gray)[600] == "oklch(44.6% 0.03 256.802)"
  end

  test "every core shade is part of the palette ramp" do
    for hue <- Palette.hues() do
      assert Palette.core_shade(hue) in Palette.shade_keys()
    end
  end

  test "presets put the implicit default first and omit its source name" do
    assert Palette.presets() == [:default, :natural, :bright]
    refute :tailwind in Palette.presets()
  end

  test "build/1 maps shade keys in order" do
    assert Palette.build(["a", "b"]) == %{50 => "a", 100 => "b"}
  end
end
