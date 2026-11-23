defmodule FlintUI.Theme.ContrastTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette
  alias FlintUI.Palette.{Contrast, Tailwind}

  test "every palette hue has an AA label on its core fill" do
    for palette <- Palette.palettes(), hue <- Palette.hues() do
      shades = palette.module.shades(hue)
      core = Map.fetch!(shades, Palette.core(palette.module, hue))

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

  test "every palette hue has an AA on-soft shade on the page and soft fill" do
    white = "oklch(100% 0 0)"

    for palette <- Palette.palettes(), hue <- Palette.hues() do
      shades = palette.module.shades(hue)
      gray = palette.module.shades(:gray)
      core = Map.fetch!(shades, Palette.core(palette.module, hue))
      light_ink = Map.fetch!(gray, 950)
      dark_base = Map.fetch!(gray, 900)
      dark_ink = Map.fetch!(gray, 50)

      light_backgrounds = [
        white,
        Contrast.mix(light_ink, white, 0.03),
        Contrast.mix(light_ink, white, 0.06),
        Contrast.mix(core, white, 0.12)
      ]

      dark_backgrounds = [
        Map.fetch!(gray, 950),
        dark_base,
        Contrast.mix(dark_ink, dark_base, 0.03),
        Contrast.mix(dark_ink, dark_base, 0.06),
        Contrast.mix(core, dark_base, 0.18)
      ]

      css = FlintUI.Palette.CSS.hue_tokens(hue, shades, core: Palette.core(palette.module, hue))

      [_, light_step, dark_step] =
        Regex.run(
          ~r/--fl-color-#{hue}-on-soft: light-dark\(\s*var\(--fl-color-#{hue}-(\d+)\),\s*var\(--fl-color-#{hue}-(\d+)\)\s*\);/s,
          css
        )

      light_value = Map.fetch!(shades, String.to_integer(light_step))
      dark_value = Map.fetch!(shades, String.to_integer(dark_step))

      for background <- light_backgrounds do
        assert Contrast.ratio(light_value, background) >= Contrast.aa(),
               "#{palette.name}/#{hue}-#{light_step} should read on #{background}"
      end

      for background <- dark_backgrounds do
        assert Contrast.ratio(dark_value, background) >= Contrast.aa(),
               "#{palette.name}/#{hue}-#{dark_step} should read on #{background}"
      end
    end
  end

  test "ghost and link keep an AA label when they carry more of the core tone" do
    # `primitives/control.css` mixes the dark `-on-soft` toward the core by 10%
    # for ghost and link. Every palette must still clear AA on the chrome ladder.
    for palette <- Palette.palettes(), hue <- Palette.hues() do
      shades = palette.module.shades(hue)
      gray = palette.module.shades(:gray)
      core = Map.fetch!(shades, Palette.core(palette.module, hue))

      css = FlintUI.Palette.CSS.hue_tokens(hue, shades, core: Palette.core(palette.module, hue))

      [_, dark_step] =
        Regex.run(
          ~r/--fl-color-#{hue}-on-soft: light-dark\(\s*var\(--fl-color-#{hue}-\d+\),\s*var\(--fl-color-#{hue}-(\d+)\)\s*\);/s,
          css
        )

      on_soft = Map.fetch!(shades, String.to_integer(dark_step))
      mixed = Contrast.mix(core, on_soft, 0.10)

      dark_backgrounds = [
        Map.fetch!(gray, 950),
        Map.fetch!(gray, 900),
        Contrast.mix(Map.fetch!(gray, 50), Map.fetch!(gray, 900), 0.06)
      ]

      for background <- dark_backgrounds do
        assert Contrast.ratio(mixed, background) >= Contrast.aa(),
               "#{palette.name}/#{hue} ghost text should read on #{background}"
      end
    end
  end

  test "role aliases point at palette hues" do
    css = File.read!(FlintUI.Generator.part_path("tokens.css"))

    assert css =~ "--fl-color-secondary: var(--fl-color-gray);"
    assert css =~ "--fl-color-info: var(--fl-color-blue);"
    assert css =~ "--fl-color-success: var(--fl-color-green);"
    assert css =~ "--fl-color-warning: var(--fl-color-yellow);"
    assert css =~ "--fl-color-danger: var(--fl-color-red);"
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

  test "chrome surfaces brighten from the page to the raised layer" do
    white = "oklch(100% 0 0)"
    base = Tailwind.shades(:gray)[950]

    # Mirrors the white mixes in `tokens.css`. One base, one ramp per scheme.
    light = [
      Contrast.mix(base, white, 0.0175),
      Contrast.mix(base, white, 0.005),
      white
    ]

    dark = [
      base,
      Contrast.mix(base, white, 0.93),
      Contrast.mix(base, white, 0.88)
    ]

    for [page, surface, raised] <- [light, dark] do
      assert Contrast.luminance(page) < Contrast.luminance(surface)
      assert Contrast.luminance(surface) < Contrast.luminance(raised)
    end
  end

  test "solid neutral keeps a high-contrast label in both schemes" do
    gray = Tailwind.shades(:gray)
    white = "oklch(100% 0 none)"

    assert Contrast.ratio(white, gray[900]) >= Contrast.aa()
    assert Contrast.ratio(gray[800], white) >= Contrast.aa()
  end
end
