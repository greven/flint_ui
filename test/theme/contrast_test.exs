defmodule FlintUI.Theme.ContrastTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette
  alias FlintUI.Palette.{Contrast, Tailwind}

  test "every palette hue has an AA label on its core fill" do
    for palette <- Palette.palettes(), hue <- Palette.hues() do
      shades = palette.module.shades(hue)
      core = Map.fetch!(shades, Palette.core_shade(hue))

      candidates = [
        Map.fetch!(shades, 50),
        Map.fetch!(shades, 950),
        "oklch(100% 0 0)",
        "oklch(0% 0 0)"
      ]

      best =
        candidates
        |> Enum.map(fn value -> {value, Contrast.ratio(core, value) || 0.0} end)
        |> Enum.max_by(&elem(&1, 1))

      assert elem(best, 1) >= Contrast.aa(),
             "#{palette.name}/#{hue} needs a readable label on its core fill"
    end
  end

  test "every palette hue has an AA text shade on the page" do
    for palette <- Palette.palettes(), hue <- Palette.hues() do
      shades = palette.module.shades(hue)
      light_page = Map.fetch!(shades, 50)
      dark_surface = Map.fetch!(shades, 900)

      assert Contrast.ratio(Map.fetch!(shades, 800), light_page) >= Contrast.aa(),
             "#{palette.name}/#{hue}-800 should read on the light page"

      assert Contrast.ratio(Map.fetch!(shades, 300), dark_surface) >= Contrast.aa(),
             "#{palette.name}/#{hue}-300 should read on the dark surface"
    end
  end

  test "role aliases point at palette hues" do
    css = File.read!(FlintUI.Generator.part_path("tokens.css"))

    assert css =~ "--fl-color-secondary: var(--fl-palette-gray);"
    assert css =~ "--fl-color-info: var(--fl-palette-blue);"
    assert css =~ "--fl-color-success: var(--fl-palette-green);"
    assert css =~ "--fl-color-warning: var(--fl-palette-amber);"
    assert css =~ "--fl-color-error: var(--fl-palette-red);"
    assert css =~ "--fl-color-primary: var(--fl-color-neutral);"
  end

  test "text tiers are softened neutrals that clear AA where used" do
    gray = Tailwind.shades(:gray)

    # The default ink and toned ink on the light surfaces.
    assert Contrast.ratio(gray[700], gray[50]) >= Contrast.aa()
    assert Contrast.ratio(gray[600], gray[100]) >= Contrast.aa()

    # The dark ink tiers on the dark surfaces.
    assert Contrast.ratio(gray[200], gray[900]) >= Contrast.aa()
    assert Contrast.ratio(gray[300], gray[800]) >= Contrast.aa()

    # `text-muted` clears AA on the pure surface, the page tint, and the
    # `surface-subtle` step, but not on the stronger `surface-strong` step.
    muted = Contrast.mix(gray[500], gray[600], 0.9)
    assert Contrast.ratio(muted, gray[50]) >= Contrast.aa()
    assert Contrast.ratio(muted, gray[100]) >= Contrast.aa()
    assert Contrast.ratio(muted, gray[200]) < Contrast.aa()

    # `dimmed` is intentionally below AA: placeholders and decoration only.
    assert Contrast.ratio(gray[400], gray[50]) < Contrast.aa()
    assert Contrast.ratio(gray[500], gray[950]) < Contrast.aa()
  end

  test "solid neutral keeps a high-contrast label in both schemes" do
    gray = Tailwind.shades(:gray)
    white = "oklch(100% 0 none)"

    assert Contrast.ratio(white, gray[900]) >= Contrast.aa()
    assert Contrast.ratio(gray[800], white) >= Contrast.aa()
  end
end
