defmodule FlintUI.PaletteTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette
  alias FlintUI.Palette.Tailwind

  test "tailwind exposes the default palette" do
    assert Tailwind.name() == :tailwind
    assert :red in Tailwind.colors()
    assert :indigo in Tailwind.colors()
    assert :zinc in Tailwind.colors()
  end

  test "every tailwind color has the full shade range" do
    for color <- Tailwind.colors() do
      assert Tailwind.shades(color) |> Map.keys() |> Enum.sort() ==
               Palette.shade_keys() |> Enum.sort()
    end
  end

  test "tailwind shade values are oklch strings" do
    assert Tailwind.shades(:red)[600] == "oklch(57.7% 0.245 27.325)"
  end

  test "build/1 maps shade keys in order" do
    assert Palette.build(["a", "b"]) == %{50 => "a", 100 => "b"}
  end
end
