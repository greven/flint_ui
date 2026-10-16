defmodule FlintUI.Palette.CSSTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.CSS
  alias FlintUI.Palette.Tailwind

  test "renders raw palette, role scale, alias, and foreground under :root" do
    css = CSS.render(primary: {Tailwind, :indigo})

    assert css =~ ":root {"
    assert css =~ "--fl-palette-indigo-600: oklch(51.1% 0.262 276.966);"
    assert css =~ "--fl-color-primary-600: var(--fl-palette-indigo-600);"
    assert css =~ "--fl-color-primary: light-dark("
    assert css =~ "--fl-color-primary-foreground: light-dark("
  end

  test "uses a data-theme selector when a theme name is given" do
    css = CSS.render([primary: {Tailwind, :indigo}], theme: "brand")
    assert css =~ ~s([data-theme="brand"] {)
  end

  test "refs mode points at the host's --color-* variables" do
    css = CSS.render([primary: {Tailwind, :indigo}], refs: true)
    assert css =~ "--fl-palette-indigo-600: var(--color-indigo-600);"
  end

  test "deduplicates a color shared by several roles" do
    css = CSS.render(primary: {Tailwind, :zinc}, neutral: {Tailwind, :zinc})
    assert css |> String.split("--fl-palette-zinc-600:") |> length() == 2
  end

  test "picks a dark foreground for a light alias shade" do
    css = CSS.render([primary: {Tailwind, :yellow}], light_shade: 300, dark_shade: 300)

    assert css =~ "var(--fl-color-primary-950),\n    var(--fl-color-primary-950)"
  end

  test "picks a light foreground for a dark alias shade" do
    css = CSS.render([primary: {Tailwind, :blue}], light_shade: 900, dark_shade: 900)

    assert css =~ "var(--fl-color-primary-50),\n    var(--fl-color-primary-50)"
  end

  test "picks the higher-contrast foreground for a mid-tone fill" do
    # green-600 reads better against green-950 than green-50.
    css = CSS.render([success: {Tailwind, :green}], light_shade: 600, dark_shade: 600)

    assert css =~ "--fl-color-success-foreground: light-dark(\n    var(--fl-color-success-950)"
  end

  test "falls back to pure white/black when the ramp extremes miss AA" do
    # red-600/red-50 is 4.36 (below AA); pure white reads better at 4.76 and
    # keeps the vivid red-600 fill instead of darkening it.
    css = CSS.render([error: {Tailwind, :red}], light_shade: 600, dark_shade: 600)

    assert css =~ "--fl-color-error-foreground: light-dark(\n    oklch(100% 0 0),"
  end

  test "a pinned shade gives a light label" do
    css = CSS.render([success: {Tailwind, :green}], shades: %{success: {700, 400}})

    assert css =~ "--fl-color-success: light-dark(\n    var(--fl-color-success-700),"
    assert css =~ "--fl-color-success-foreground: light-dark(\n    var(--fl-color-success-50),"
  end

  test "the :contrast option raises the target to AAA" do
    aa = CSS.render([primary: {Tailwind, :red}], light_shade: 600, dark_shade: 400)

    aaa =
      CSS.render([primary: {Tailwind, :red}],
        light_shade: 600,
        dark_shade: 400,
        contrast: :aaa
      )

    assert aa =~ "--fl-color-primary-text: light-dark(\n    var(--fl-color-primary-700),"
    assert aaa =~ "--fl-color-primary-text: light-dark(\n    var(--fl-color-primary-900),"
  end

  test "emits a contrast-safe text alias per role" do
    css = CSS.render([warning: {Tailwind, :amber}], shades: %{warning: 400})

    # amber-400 as text on white would be ~1.7:1; amber-700 clears AA (5.05:1).
    assert css =~
             "--fl-color-warning-text: light-dark(\n    var(--fl-color-warning-700),\n    var(--fl-color-warning-400)"
  end

  test ":shades pins one role's alias and contrast-picks its foreground" do
    css =
      CSS.render(
        [primary: {Tailwind, :indigo}, warning: {Tailwind, :amber}],
        shades: %{warning: 400}
      )

    # warning resolves amber-400 in both schemes; light amber picks a dark label.
    assert css =~
             "--fl-color-warning: light-dark(\n    var(--fl-color-warning-400),\n    var(--fl-color-warning-400)"

    assert css =~
             "--fl-color-warning-foreground: light-dark(\n    var(--fl-color-warning-950),\n    var(--fl-color-warning-950)"

    # primary is untouched and keeps the global 600 anchor in both schemes.
    assert css =~
             "--fl-color-primary: light-dark(\n    var(--fl-color-primary-600),\n    var(--fl-color-primary-600)"
  end

  test "keeps a solid fill equally saturated in dark mode" do
    # The alias resolves to the same shade in both schemes, so the dark fill is
    # as vivid as the light one and keeps a light label (never a washed-out
    # pale fill with dark text).
    css = CSS.render(error: {Tailwind, :red})

    assert css =~
             "--fl-color-error: light-dark(\n    var(--fl-color-error-600),\n    var(--fl-color-error-600)"

    assert css =~
             "--fl-color-error-foreground: light-dark(\n    oklch(100% 0 0),\n    oklch(100% 0 0)"
  end
end
