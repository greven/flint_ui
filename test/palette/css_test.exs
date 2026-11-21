defmodule FlintUI.Palette.CSSTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette
  alias FlintUI.Palette.{CSS, Color, Contrast, Natural, Pastel, Seed, Tailwind}

  test "renders the eighteen hues and derived tokens under :root" do
    css = CSS.render_palette(Tailwind, default: true)

    assert css =~ ~s(:root,\n[data-palette="tailwind"])
    assert css =~ "--fl-color-red-50:"
    assert css =~ "--fl-color-red-950:"
    assert css =~ "--fl-color-red: var(--fl-color-red-600);"
    assert css =~ "--fl-color-red-on: oklch(100% 0 0);"
    assert css =~ "--fl-color-yellow-on: var(--fl-color-yellow-950);"
    assert css =~ "--fl-color-red-on-soft: light-dark("
    assert css =~ "var(--fl-color-red-700)"
    assert css =~ "var(--fl-color-red-400)"
    assert css =~ "--fl-color-red-soft: light-dark("
    assert css =~ "color-mix(in oklab, var(--fl-color-red) 12%"
    assert css =~ "--fl-color-red-soft-border: color-mix("

    for hue <- Palette.hue_names() do
      assert css =~ "--fl-color-#{hue}:"
    end
  end

  test "on-soft stays as vivid as AA allows in each scheme" do
    css = CSS.render_palette(Tailwind, default: true)

    assert css =~
             ~r/--fl-color-red-on-soft: light-dark\(\s*var\(--fl-color-red-700\),\s*var\(--fl-color-red-400\)\s*\);/

    # Warm hues cannot clear AA at 700 on the light surface-strong tint, so
    # only the light step backs off; the dark step stays at 400.
    assert css =~
             ~r/--fl-color-green-on-soft: light-dark\(\s*var\(--fl-color-green-800\),\s*var\(--fl-color-green-400\)\s*\);/
  end

  test "derived tokens stay relative so a ramp remap follows" do
    css = CSS.render_palette(Tailwind, default: true)

    assert css =~ "--fl-color-pink: var(--fl-color-pink-600);"
    assert css =~ "--fl-color-pink-on: oklch(100% 0 0);"
    assert css =~ "var(--fl-color-pink-700)"
    assert css =~ "var(--fl-color-pink-400)"
    assert css =~ "color-mix(in oklab, var(--fl-color-pink)"
  end

  test "named palettes scope under data-palette only" do
    css = CSS.render_palette(Natural)

    assert css =~ ~s([data-palette="natural"] {)
    refute css =~ ":root"
  end

  test "every shipped palette renders every hue" do
    for palette <- Palette.palettes() do
      css = CSS.render_palette(palette.module, default: Map.get(palette, :default, false))

      for hue <- Palette.hue_names() do
        assert css =~ "--fl-color-#{hue}-50:"
        assert css =~ "--fl-color-#{hue}:"
      end
    end
  end

  test "a transformed palette keeps the same contract but different colors" do
    css = CSS.render_palette(Natural)

    refute Natural.shades(:red)[600] == Tailwind.shades(:red)[600]
    assert css =~ "--fl-color-red: var(--fl-color-red-600);"
    assert css =~ "--fl-color-red-soft: light-dark("
  end

  test "a palette can choose its own core shade" do
    css = CSS.render_palette(Pastel)

    assert css =~ "--fl-color-blue: var(--fl-color-blue-400);"
    assert css =~ "--fl-color-amber: var(--fl-color-amber-400);"
    assert css =~ "--fl-color-gray: var(--fl-color-gray-600);"
    assert css =~ "--fl-color-blue-on: var(--fl-color-blue-950);"
  end

  test "a stricter contrast target raises the text steps" do
    aa = CSS.render_palette(Tailwind, default: true)
    aaa = CSS.render_palette(Tailwind, default: true, contrast: :aaa)

    refute aa == aaa
    assert aaa =~ "--fl-color-red-on-soft: light-dark("
  end

  test "the color hooks match the hue registry" do
    path = FlintUI.Generator.part_path("colors.css")

    assert File.read!(path) == CSS.render_hooks(),
           "colors.css is stale; regenerate it from FlintUI.Palette.CSS.render_hooks/0"
  end

  test "a custom hue can render only its own hooks" do
    hooks = CSS.render_hooks(roles: [], hues: ["brand"])

    assert hooks =~ ~s|:where([data-color="brand"])|
    assert hooks =~ ~s|:where([data-active-color="brand"])|
    assert hooks =~ "--fl-tone: var(--fl-color-brand);"
    assert hooks =~ "--fl-active-tone: var(--fl-color-brand);"
    refute hooks =~ ~s|data-color="primary"|
  end

  test "a seed ramp anchors 600 at the seed and keeps eleven shades" do
    shades = Seed.from_color("#8b5cf6")
    {:ok, seed} = Color.parse("#8b5cf6")

    assert shades |> Map.keys() |> Enum.sort() == Palette.shade_keys() |> Enum.sort()
    assert shades[600] == seed.css

    for {_shade, css} <- shades do
      assert {:ok, _color} = Color.parse(css)
    end
  end

  test "a seeded hue renders the ramp, derived tokens, and hooks" do
    shades = Seed.from_color("#8b5cf6")
    css = CSS.render_custom_hue("brand", shades)

    assert css =~ ":root {"
    assert css =~ "--fl-color-brand-50:"
    assert css =~ "--fl-color-brand: var(--fl-color-brand-600);"
    assert css =~ "--fl-color-brand-on:"
    assert css =~ "--fl-color-brand-on-soft: light-dark("
    assert css =~ "--fl-color-brand-soft: light-dark("
    assert css =~ ~s|:where([data-color="brand"])|
    assert css =~ ~s|:where([data-active-color="brand"])|
  end

  test "a seeded core has an AA label" do
    shades = Seed.from_color("#8b5cf6")
    core = shades[600]

    candidates = [shades[50], shades[950], "oklch(100% 0 0)", "oklch(0% 0 0)"]

    best =
      candidates
      |> Enum.map(fn value -> {value, Contrast.ratio(core, value) || 0.0} end)
      |> Enum.max_by(&elem(&1, 1))

    assert elem(best, 1) >= Contrast.aa()
  end

  test "every shipped palette part matches its renderer output" do
    for palette <- Palette.palettes() do
      expected =
        CSS.render_palette(palette.module, default: Map.get(palette, :default, false))

      path = FlintUI.Generator.part_path(palette.css)

      assert File.read!(path) == expected,
             "#{palette.css} is stale; regenerate it from FlintUI.Palette.CSS"
    end
  end
end
