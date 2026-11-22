defmodule FlintUI.Theme.CSSTest do
  use ExUnit.Case, async: true

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "defines prefixed tokens with automatic light/dark", %{css: css} do
    assert css =~ "color-scheme: light dark;"
    assert css =~ "--fl-color-primary: var(--fl-color-neutral);"
    assert css =~ "--fl-color-primary-on: var(--fl-color-neutral-on);"
    assert css =~ "--fl-color-gray-600:"
    assert css =~ "--fl-color-neutral: light-dark("
    assert css =~ "--fl-radius:"
    assert css =~ "--fl-radius-md:"
    assert css =~ "--fl-font-sans:"
    refute css =~ "--fl-palette-"
  end

  test "defines eighteen palette hues and role aliases instead of role scales", %{css: css} do
    for hue <- FlintUI.Palette.hue_names() do
      assert css =~ "--fl-color-#{hue}-50:"
      assert css =~ "--fl-color-#{hue}-950:"
      assert css =~ "--fl-color-#{hue}:"
      assert css =~ ~s|:where([data-color="#{hue}"])|
    end

    for role <- ~w(primary secondary neutral success info warning danger dark light) do
      assert css =~ "--fl-color-#{role}:"
      assert css =~ "--fl-color-#{role}-on:"
      assert css =~ "--fl-color-#{role}-on-soft:"
      assert css =~ "--fl-color-#{role}-soft:"
      assert css =~ "--fl-color-#{role}-soft-border:"
    end

    assert css =~ "--fl-color-secondary: var(--fl-color-gray);"
    assert css =~ "--fl-color-success: var(--fl-color-green);"
    assert css =~ "--fl-color-warning: var(--fl-color-yellow);"
    assert css =~ "--fl-color-danger: var(--fl-color-red);"
    assert css =~ "--fl-color-info: var(--fl-color-blue);"
    refute css =~ "--fl-color-primary-50:"
    refute css =~ "--fl-color-danger-950:"
  end

  test "defines absolute tones and maps them through the shared hook", %{css: css} do
    assert css =~ "--fl-color-dark: var(--fl-color-gray-900);"
    assert css =~ "--fl-color-light: var(--fl-color-gray-50);"
    assert css =~ "--fl-color-dark-on: var(--fl-color-gray-50);"
    assert css =~ "--fl-color-light-on: var(--fl-color-gray-900);"
    assert css =~ "--fl-color-dark-on-soft: light-dark("
    assert css =~ "--fl-color-light-on-soft: light-dark("

    for tone <- ~w(dark light) do
      assert css =~ ~s|:where([data-color="#{tone}"])|
    end
  end

  test "defines the text, surface, and border ladders", %{css: css} do
    for token <- ~w(
          text-highlighted
          text
          text-toned
          text-muted
          text-dimmed
          text-inverted
          background
          surface
          surface-subtle
          surface-strong
          surface-raised
          inverted
          border
          border-subtle
          border-strong
          ring
        ) do
      assert css =~ "--fl-color-#{token}:"
    end

    refute css =~ "--fl-color-disabled"
    refute css =~ "--fl-color-accent"
    refute css =~ "--fl-color-input"
    refute css =~ "--fl-color-elevated"
    refute css =~ "--fl-color-surface-soft"
    refute css =~ "--fl-color-surface-foreground"
    refute css =~ "--fl-color-muted:"
    refute css =~ "--fl-color-surface-muted"
    refute css =~ "--fl-color-surface-accented"
    refute css =~ "--fl-color-border-muted"
    refute css =~ "--fl-color-border-accented"
    assert css =~ "--fl-disabled-opacity: 0.5;"

    assert css =~ "--fl-surface-ink: light-dark("
    assert css =~ "--fl-color-surface-raised: light-dark("

    assert css =~
             ~r/--fl-color-border-subtle: color-mix\(in oklab, var\(--fl-surface-ink\) 7%, var\(--fl-color-surface\)\)/

    assert css =~
             ~r/--fl-color-border: color-mix\(in oklab, var\(--fl-surface-ink\) 10%, var\(--fl-color-surface\)\)/

    assert css =~
             ~r/--fl-color-border-strong: color-mix\(in oklab, var\(--fl-surface-ink\) 18%, var\(--fl-color-surface\)\)/
  end

  test "solid controls darken their fill for the border", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-variant="solid"\]:not\(\[data-state="on"\]\) \{[^}]*border-color: color-mix\(/

    assert css =~ ~s([data-control]:is()
    assert css =~ "var(--fl-border-strength-solid)"
  end

  test "the surface base anchors the page and the fill ladder stays below the edges", %{css: css} do
    assert css =~ "--fl-surface-base: var(--fl-color-gray-950);"
    assert css =~ "--fl-surface-page-tint: 0%;"
    assert css =~ "--fl-surface-page-lift: 0%;"

    assert css =~
             ~r/--fl-surface-ink: light-dark\(\s*var\(--fl-surface-base\),\s*color-mix\(in oklab, oklch\(1 0 0\) 98\.25%, var\(--fl-surface-base\)\)\s*\)/

    assert css =~
             ~r/--fl-color-surface: light-dark\(\s*color-mix\(in oklab, oklch\(1 0 0\) calc\(99\.5% - var\(--fl-surface-page-tint\)\), var\(--fl-surface-base\)\),\s*color-mix\(in oklab, oklch\(1 0 0\) calc\(7% \+ var\(--fl-surface-page-lift\)\), var\(--fl-surface-base\)\)\s*\)/

    assert css =~
             ~r/--fl-surface-page-light: color-mix\(\s*in oklab,\s*var\(--fl-surface-base\) calc\(1\.75% \+ var\(--fl-surface-page-tint\)\),\s*oklch\(1 0 0\)\s*\)/

    assert css =~
             ~r/--fl-surface-page-dark: color-mix\(\s*in oklab,\s*oklch\(1 0 0\) var\(--fl-surface-page-lift\),\s*var\(--fl-surface-base\)\s*\)/

    assert css =~
             ~r/--fl-color-background: light-dark\(\s*var\(--fl-surface-page-light\),\s*var\(--fl-surface-page-dark\)\s*\)/

    for {name, percent} <- [
          {"surface-subtle", "3%"},
          {"surface-strong", "6%"},
          {"border-subtle", "7%"},
          {"border", "10%"},
          {"border-strong", "18%"}
        ] do
      assert css =~
               ~r/--fl-color-#{name}: color-mix\(in oklab, var\(--fl-surface-ink\) #{percent}, var\(--fl-color-surface\)\)/
    end

    assert css =~
             ~r/--fl-color-surface-raised: light-dark\(\s*color-mix\(in oklab, oklch\(1 0 0\) calc\(100% - var\(--fl-surface-page-tint\)\), var\(--fl-surface-base\)\),\s*color-mix\(in oklab, oklch\(1 0 0\) calc\(12% \+ var\(--fl-surface-page-lift\)\), var\(--fl-surface-base\)\)\s*\)/

    refute css =~ "--fl-surface-step"
    refute css =~ "--fl-color-control:"
  end

  test "text tiers derive from one anchor and clear AA where used", %{css: css} do
    assert css =~
             "--fl-text-base: light-dark(var(--fl-color-gray-700), var(--fl-color-gray-200));"

    assert css =~ "--fl-color-text: var(--fl-text-base);"

    assert css =~
             ~r/--fl-color-text-inverted: light-dark\(\s*oklch\(1 0 0\),\s*var\(--fl-color-gray-800\)\s*\)/

    neutral = fn shade ->
      [_, value] = Regex.run(~r/--fl-color-gray-#{shade}: ([^;]+);/, css)
      value
    end

    light_base = neutral.(700)
    dark_base = neutral.(200)

    {light_highlighted, dark_highlighted} =
      resolve_text(css, "text-highlighted", light_base, dark_base)

    {light_toned, dark_toned} = resolve_text(css, "text-toned", light_base, dark_base)
    {light_muted, _dark_muted} = resolve_text(css, "text-muted", light_base, dark_base)
    {light_dimmed, dark_dimmed} = resolve_text(css, "text-dimmed", light_base, dark_base)

    white = "oklch(100% 0 none)"
    light_page = neutral.(50)
    light_surface = neutral.(100)
    light_strong = neutral.(200)
    dark_page = neutral.(950)
    dark_surface = neutral.(900)
    dark_strong = neutral.(800)

    for {fg, surfaces} <- [
          {light_base, [light_page, light_surface, light_strong]},
          {dark_base, [dark_page, dark_surface, dark_strong]},
          {light_toned, [light_page, light_surface, light_strong]},
          {dark_toned, [dark_page, dark_surface, dark_strong]}
        ],
        surface <- surfaces do
      assert ratio(fg, surface) >= 4.5
    end

    # Highlighted is the strongest tier in both schemes.
    assert ratio(light_highlighted, white) >= 4.5
    assert ratio(dark_highlighted, dark_page) >= 4.5

    # `text-muted` clears AA on the pure surface, the page tint, and the
    # `surface-subtle` step, but not on the stronger `surface-strong` step.
    assert ratio(light_muted, white) >= 4.5
    assert ratio(light_muted, light_page) >= 4.5
    assert ratio(light_muted, light_surface) >= 4.5
    assert ratio(light_muted, light_strong) < 4.5

    # `dimmed` is intentionally below AA: placeholders and decoration only.
    assert ratio(light_dimmed, white) < 4.5
    assert ratio(dark_dimmed, dark_surface) < 4.5

    # Solid neutral keeps a high-contrast label in both schemes.
    assert ratio(white, neutral.(900)) >= 4.5
    assert ratio(neutral.(800), white) >= 4.5
  end

  test "role on and on-soft map to the shared tone contract", %{css: css} do
    for role <- ~w(primary secondary success info warning danger) do
      assert css =~ ~s|:where([data-color="#{role}"])|
      assert css =~ "--fl-tone: var(--fl-color-#{role});"
      assert css =~ "--fl-tone-on: var(--fl-color-#{role}-on);"
      assert css =~ "--fl-tone-on-soft: var(--fl-color-#{role}-on-soft);"
    end

    refute css =~ "-soft-foreground"

    # Controls read the shared tone with their own fallbacks, so a raw color
    # can write the same public inputs inline.
    assert css =~ "--fl-control-color: var(--fl-tone, var(--fl-color-inverted));"

    assert css =~
             "--fl-control-color-content: var(--fl-tone-on, var(--fl-color-text-inverted));"

    assert css =~ "--fl-control-text: var(--fl-tone-on-soft, var(--fl-control-color));"

    assert css =~
             ~r/\[data-element="toggle"\]\[data-toggle\]\[data-color="neutral"\] \{[^}]*--fl-control-text: var\(--fl-color-text-toned\);/

    assert css =~
             ~r/\[data-element="toggle"\]\[data-toggle\]\[data-color="neutral"\]:not\(\[data-active-color\]\) \{[^}]*--fl-control-active-text: var\(--fl-color-text-highlighted\);/

    # A toggled neutral label takes the strongest ink so the state still reads
    # on the faint soft fill.
    assert css =~
             ~r/\[data-control\]\[data-active-color="neutral"\] \{[^}]*--fl-control-active-text: var\(--fl-color-text-highlighted\);/
  end

  test "palette fills and text shades clear AA where used" do
    alias FlintUI.Palette
    alias FlintUI.Palette.CSS
    alias FlintUI.Palette.Contrast

    white = "oklch(100% 0 0)"

    for hue <- Palette.hues() do
      shades = FlintUI.Palette.default().module.shades(hue)
      core = Map.fetch!(shades, Palette.core_shade(hue))
      content = Map.fetch!(shades, 50)

      assert Contrast.ratio(core, content) >= 4.5 or
               Contrast.ratio(core, white) >= 4.5 or
               Contrast.ratio(core, "oklch(0% 0 0)") >= 4.5,
             "#{hue} needs a readable label on its core fill"

      [_, light_step, dark_step] =
        Regex.run(
          ~r/--fl-color-#{hue}-on-soft: light-dark\(\s*var\(--fl-color-#{hue}-(\d+)\),\s*var\(--fl-color-#{hue}-(\d+)\)\s*\);/s,
          CSS.hue_tokens(hue, shades)
        )

      light_text = Map.fetch!(shades, String.to_integer(light_step))
      dark_text = Map.fetch!(shades, String.to_integer(dark_step))

      assert Contrast.ratio(light_text, Contrast.light_surface_strong()) >= 4.5,
             "#{hue}-#{light_step} should read on the light surface-strong tint"

      assert Contrast.ratio(light_text, Contrast.mix(core, white, 0.12)) >= 4.5,
             "#{hue}-#{light_step} should read on its soft fill"

      assert Contrast.ratio(dark_text, Contrast.dark_background()) >= 4.5,
             "#{hue}-#{dark_step} should read on the dark surface-strong tint"

      assert Contrast.ratio(dark_text, Contrast.mix(core, Contrast.dark_surface(), 0.18)) >= 4.5,
             "#{hue}-#{dark_step} should read on its soft fill"
    end
  end

  test "shared control effects replace per-component effect and radius tokens", %{css: css} do
    assert css =~ "--fl-control-depth: 1;"
    assert css =~ "--fl-control-shadow: var(--fl-shadow-base);"
    assert css =~ "--fl-control-press: translateY(1px);"

    refute css =~ "--fl-button-depth:"
    refute css =~ "--fl-button-shadow:"
    refute css =~ "--fl-button-press:"
    refute css =~ "--fl-button-radius:"
    refute css =~ "--fl-toggle-radius:"
    refute css =~ "--fl-card-radius:"
    refute css =~ "--fl-input-radius:"
  end

  test "controls share one radius token that follows the scale", %{css: css} do
    assert css =~ "--fl-control-radius: var(--fl-radius-md);"
    assert css =~ "border-radius: var(--fl-control-radius);"
    assert css =~ "border-radius: calc(var(--fl-control-radius) - 1px);"

    refute css =~ "--fl-button-radius:"
    refute css =~ "--fl-toggle-radius:"
  end

  test "the none radius step removes the control radius", %{css: css} do
    for selector <- [
          ~s([data-control][data-radius="none"]),
          ~s([data-field][data-radius="none"]),
          ~s([data-element="badge"][data-radius="none"])
        ] do
      assert css =~ selector
      assert css =~ ~s(#{selector} {\n        --fl-control-radius: 0;)
    end
  end

  test "defines type, spacing, elevation, and motion scales", %{css: css} do
    assert css =~ "--fl-font-mono:"
    assert css =~ "--fl-font-size-md: 1rem;"

    for {weight, value} <- [
          thin: 100,
          extralight: 200,
          light: 300,
          normal: 400,
          medium: 500,
          semibold: 600,
          bold: 700,
          extrabold: 800,
          black: 900
        ] do
      assert css =~ "--fl-font-weight-#{weight}: #{value};"
    end

    for size <- ~w(2xl 3xl 4xl 5xl 6xl) do
      assert css =~ "--fl-font-size-#{size}:"
      assert css =~ "--fl-line-height-#{size}:"
    end

    for tracking <- ~w(tighter tight normal wide wider widest) do
      assert css =~ "--fl-font-tracking-#{tracking}:"
    end

    assert css =~ "--fl-spacing: 0.25rem;"
    assert css =~ "--fl-spacing-lg: calc(var(--fl-spacing) * 4);"
    assert css =~ "--fl-shadow-md:"
    assert css =~ "--fl-breakpoint-lg: 64rem;"
    assert css =~ "--fl-container-7xl: 80rem;"
    assert css =~ "--fl-duration-fast: 150ms;"
    assert css =~ "--fl-ease-out:"
  end

  test "the typography primitive owns the shared text hooks", %{css: css} do
    assert css =~ "[data-typography]"
    assert css =~ ~s([data-typography][data-size="6xl"])
    assert css =~ ~s|:where([data-color="primary"])|

    for weight <- ~w(thin extralight light normal medium semibold bold extrabold black) do
      assert css =~ ~s([data-typography][data-weight="#{weight}"])
    end

    assert css =~ ~s([data-typography][data-align="center"])
  end

  test "link underlines use the link ink and solidify on hover and focus", %{css: css} do
    assert css =~ "text-decoration-color: color-mix(in oklab, currentColor, transparent 75%);"
    assert css =~ "transition: text-decoration-color var(--fl-duration-fast) var(--fl-ease-out);"

    assert css =~
             ~s|[data-element="text"]:is(a):is(:hover, :focus-visible)|

    assert css =~
             ~s|[data-element="text"] :is(a):not([data-element]):is(:hover, :focus-visible)|
  end

  test "defines shared control metrics", %{css: css} do
    for size <- ~w(xs sm md lg xl) do
      assert css =~ "--fl-control-height-#{size}:"
      assert css =~ "--fl-control-font-size-#{size}:"
      assert css =~ "--fl-control-line-height-#{size}:"
      assert css =~ "--fl-control-gap-#{size}:"
      assert css =~ "--fl-control-icon-#{size}:"
    end
  end

  test "controls the scheme and ships named presets", %{css: css} do
    assert css =~ ~s([data-color-scheme="light"])
    assert css =~ ~s([data-color-scheme="dark"])
    assert css =~ ~s([data-theme="pastel"])
    assert css =~ ~s([data-theme="modern"])
  end

  test "styles every component behind its wrapper hook", %{css: css} do
    assert css =~ "@layer components {"
    assert css =~ ~s([data-control])
    assert css =~ ~s|[data-control][data-variant="solid"]:not([data-state="on"])|
    assert css =~ ~s([data-control][data-color="neutral"])
    assert css =~ ~s{:is([data-element="icon"], [data-element="loading"])}
    assert css =~ ~s([data-element="card"][data-card])
    assert css =~ ~s([data-element="card"][data-variant="soft"])
    assert css =~ ~s([data-element="card"][data-variant="strong"])
    assert css =~ ~s([data-element="card"][data-variant="ghost"])
    assert css =~ "--fl-card-surface: transparent;"
    assert css =~ ~s([data-element="card"][data-inverted][data-variant="ghost"])
    assert css =~ ~s([data-element="group"][data-attached])
    assert css =~ ~s([data-element="group"][data-surface] {)
    assert css =~ "--fl-group-surface: var(--fl-color-surface);"
    assert css =~ "background: var(--fl-group-surface);"
    assert css =~ ~s([data-element="group"][data-surface="solid"])
    assert css =~ ~s([data-element="group"][data-surface="soft"])
    assert css =~ ~s([data-element="group"][data-surface="strong"])
    assert css =~ ~s([data-element="group"][data-surface="ghost"])
    assert css =~ "--fl-color-primary:"
    assert css =~ ~s|[data-control][data-variant="solid"]:not([data-state="on"])|

    assert css =~ ~s|[data-control] :is([data-element="icon"], [data-element="loading"])|

    assert css =~
             ~s|[data-element="toggle"][data-toggle] > :is([data-part="on-state"], [data-part="off-state"]) {\n        display: contents;|

    assert css =~ ~s([data-element="toggle"][data-toggle][data-color="neutral"])
    assert css =~ ~s([data-control][data-state="on"][data-active-variant="soft"])
    assert css =~ ~s|:where([data-active-color="primary"])|
    assert css =~ ~s([data-element="loading"][data-size])
    assert css =~ ~s([data-element="loading_text"][data-variant="dots"])
    assert css =~ ~s([data-element="loading_text"][data-variant="blink"])
    assert css =~ ~s([data-element="loading_text"][data-variant="shimmer"])
    assert css =~ ~s([data-element="loading_text"][data-variant="wave"])
    assert css =~ ~s([data-element="icon"][data-icon])
    assert css =~ "--fl-icon-size:"
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
    assert css =~ ~s([data-element="tabs"][data-variant="segmented"])
    assert css =~ ~s([data-element="tabs"][data-variant="minimal"])
    assert css =~ ~s|:where([data-color="primary"])|
    assert css =~ ~s([data-element="tabs"][data-size="lg"])
    assert css =~ ~s([data-element="tabs"][data-grow])
    assert css =~ ~s([data-element="tabs"][data-justify="center"])
    assert css =~ ~s([data-element="tabs"][data-justify="end"])
    assert css =~ ~s([data-element="tabs"][data-justify="between"])
    assert css =~ "[data-tabs-tab]"
  end

  test "tabs expose the tab and content gaps as public inputs", %{css: css} do
    assert css =~
             ~r/\[data-element="tabs"\]\[data-tabs\]\s*>\s*\[data-part="tablist"\]\s*\{\s*display: flex;\s*gap: var\(--fl-tabs-gap, var\(--fl-spacing-xs\)\);/

    assert css =~
             ~r/\[data-element="tabs"\]\[data-tabs\]\s*\{[^}]*gap: var\(--fl-tabs-content-gap, var\(--fl-spacing-md\)\);/

    # The segmented variant keeps its 2px track by writing the input, so a
    # consumer can still override it.
    assert css =~
             ~r/\[data-element="tabs"\]\[data-variant="segmented"\]\s*>\s*\[data-part="tablist"\]\s*\{\s*--fl-tabs-gap: 2px;/

    refute css =~ ~s([data-element="tabs"][data-gap])
  end

  test "tabs scope default trigger visuals and expose five inputs", %{css: css} do
    assert css =~ "[data-element=\"tabs\"][data-tabs]"

    assert css =~
             ~r/\[data-element="tabs"\]\[data-tabs\]\s*>\s*\[data-part="tablist"\]\s*>\s*\[data-part="tab"\]\[data-tabs-tab\]/

    assert css =~ "--fl-tabs-color: var(--fl-tone, var(--fl-color-inverted));"
    assert css =~ "--fl-tabs-text: var(--fl-tone-on-soft, var(--fl-color-text));"
    assert css =~ "--fl-tabs-surface: var(--fl-color-surface);"
    assert css =~ "--fl-tabs-gap"
    assert css =~ "--fl-tabs-content-gap"
    refute css =~ "--fl-tabs-radius"

    assert css =~ ~s([data-element="tabs"][data-tabs][data-fadable])
    assert css =~ "[data-fade-end]"

    assert css =~
             ~r/\[data-element="tabs"\]\[data-variant="outlined"\]\s*>\s*\[data-part="tablist"\]\s*>\s*\[data-part="tab"\]\[data-tabs-tab\]\[data-state="active"\] \{\s*color: var\(--fl-color-text\);/
  end

  test "the outlined indicator hands over between tabs", %{css: css} do
    # The outgoing bar shrinks and leaves over the fast duration; the incoming
    # bar grows to the full tab width over the base duration, so the two bars
    # do not cross-fade at the same weight.
    assert css =~
             ~r/\[data-part="tab"\]\[data-tabs-tab\]::after \{[^}]*transform: scaleX\(0\.6\);[^}]*transition:\s*background-color var\(--fl-duration-fast\)/

    assert css =~
             ~r/\[data-part="tab"\]\[data-tabs-tab\]\[data-state="active"\]::after \{\s*background: var\(--fl-tabs-color\);\s*transform: scaleX\(1\);\s*transition:\s*background-color var\(--fl-duration-base\)/

    assert css =~ "transform: scaleY(0.6);"
    assert css =~ "transform: scaleY(1);"
  end

  test "tabs scope parts to their own root so nested instances stay independent" do
    # The docs put component examples inside a page-level tab panel, so a tabs
    # instance can nest. A descendant part selector would let the outer
    # instance style the inner one.
    css = File.read!(FlintUI.Generator.part_path("styled/tabs.css"))

    refute css =~ ~r/\]\s+\[data-part=/
    refute css =~ ~r/^\s*\[data-part=/m
    assert css =~ ~r/>\s*\[data-part="tablist"\]\s*>\s*\[data-part="tab"\]/
  end

  test "an attached group overlaps children into a single seam", %{css: css} do
    # The later child's opaque border covers the previous child's border at the
    # seam, so only one line shows whatever the child's fill.
    assert css =~ "margin-inline-start: -1px"
    assert css =~ "margin-block-start: -1px"
    assert css =~ "--fl-color-surface:"

    assert css =~
             ~r/--fl-color-border: color-mix\(in oklab, var\(--fl-surface-ink\) 10%, var\(--fl-color-surface\)\)/

    # Chromatic borders are opaque and share the soft strength across subtle and
    # surface.
    assert css =~ ~r/var\(--fl-border-strength-soft\),\s+var\(--fl-color-surface\)/
    refute css =~ ~r/var\(--fl-border-strength\),\s+var\(--fl-color-surface\)/
  end

  test "bordered controls paint an opaque fill and a clipped hover overlay", %{css: css} do
    assert css =~ "background: var(--fl-color-surface);"
    assert css =~ "background: currentColor;"
    assert css =~ "inset: -1px;"
    assert css =~ "overflow: clip;"
    assert css =~ "--fl-control-hover-opacity: 0.04;"
    assert css =~ "--fl-control-active-opacity: 0.07;"
  end

  test "soft and subtle fills composite at the shared tint opacity", %{css: css} do
    assert css =~ "--fl-tint-opacity: 0.9;"

    for part <- ~w(styled/badge.css primitives/control.css) do
      source = File.read!(FlintUI.Generator.part_path(part))
      assert source =~ "calc(var(--fl-tint-opacity, 0.9) * 100%)"
    end
  end

  test "alert body text is slightly muted below a title", %{css: css} do
    assert css =~
             ~r/\[data-element="alert"\]:is\(\[data-variant="outline"\], \[data-variant="soft"\]\) \[data-part="title"\] \+ \[data-part="body"\],\s*\[data-element="alert"\]:not\(\[data-background\]\) \[data-part="title"\] \+ \[data-part="body"\] \{[^}]*color: light-dark\(\s*color-mix\(\s*in oklab,\s*currentColor 88%,\s*black\s*\),\s*color-mix\(\s*in oklab,\s*currentColor 78%,\s*white\s*\)\s*\)/

    assert css =~ ~r/\[data-element="alert"\] \[data-part="body"\] \{[^}]*color: currentColor/
  end

  test "background={false} removes the surface and keeps the role label", %{css: css} do
    assert css =~
             ~r/\[data-element="alert"\]:not\(\[data-background\]\) \{[^}]*background: transparent;[^}]*color: var\(--fl-alert-text/
  end

  test "border selects the edge style without changing the surface", %{css: css} do
    assert css =~ ~r/\[data-element="alert"\]\[data-border="dashed"\] \{\s*border-style: dashed;/
    assert css =~ ~r/\[data-element="alert"\]\[data-border="none"\] \{\s*border-style: none;/
  end

  test "every colored control variant uses the role text token", %{css: css} do
    for variant <- ~w(soft subtle surface outline ghost link) do
      assert css =~
               ~r/\[data-control\]\[data-variant="#{variant}"\][^{,]*[^{]*\{[^}]*color: var\(--fl-control-text/
    end

    assert css =~ "var(--fl-control-text) 75%"
    refute css =~ "--fl-button-soft-text"
  end

  test "badge surface and outline use different border strengths", %{css: css} do
    assert css =~
             ~r/\[data-element="badge"\]\[data-variant="outline"\] \{[^}]*border-color: var\(--fl-badge-color, var\(--fl-color-inverted\)\)/

    assert css =~
             ~r/\[data-element="badge"\]\[data-variant="surface"\] \{[^}]*border-color: var\(\s*--fl-badge-soft-border,/

    # Subtle keeps the faint matching border too.
    assert css =~
             ~r/\[data-element="badge"\]\[data-variant="subtle"\] \{[^}]*border-color: var\(\s*--fl-badge-soft-border,/

    # The border width is a public input with a 1px default.
    assert css =~ "border: var(--fl-badge-border-width, 1px) solid transparent;"
    assert css =~ "2 * var(--fl-badge-border-width, 1px)"
  end

  test "surface uses the soft role border while outline uses the full role color", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-variant="outline"\]:not\(\[data-state="on"\]\) \{[^}]*border-color: var\(--fl-control-color\)/

    assert css =~
             ~r/\[data-control\]\[data-variant="surface"\]:not\(\[data-state="on"\]\) \{[^}]*border-color: var\(--fl-control-soft-border\)/

    assert css =~
             ~r/\[data-control\]\[data-state="on"\]\[data-active-variant="surface"\] \{[^}]*border-color: var\(--fl-control-active-soft-border, var\(--fl-control-soft-border\)\)/

    assert css =~
             ~r/--fl-control-soft-border: var\(\s*--fl-tone-soft-border,/

    assert css =~ "--fl-control-active-soft-border: color-mix("
    assert css =~ "var(--fl-control-active-color, var(--fl-control-color)) 32%"
  end

  test "dashed is an orthogonal border modifier, not a variant", %{css: css} do
    assert css =~ ~r/\[data-control\]\[data-dashed\] \{\s*border-style: dashed;/
    assert css =~ ~r/\[data-element="badge"\]\[data-dashed\] \{\s*border-style: dashed;/
  end

  test "a dashed outline fades its border to half transparency in both states", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-variant="outline"\]:not\(\[data-state="on"\]\)\[data-dashed\] \{\s*border-color: color-mix\(in oklab, var\(--fl-control-color\) 50%, transparent\);/

    assert css =~
             ~r/\[data-control\]\[data-state="on"\]\[data-active-variant="outline"\]\[data-dashed\] \{\s*border-color: color-mix\(in oklab, var\(--fl-control-active-color, var\(--fl-control-color\)\) 50%, transparent\);/
  end

  test "pills use the full radius and indicator markers keep compact padding", %{css: css} do
    # Badges add inline padding for the label; the nested indicator badge resets
    # it so a one-character count stays a circle. Controls only change the radius.
    assert css =~ ~s([data-element="badge"][data-pill] {)
    assert css =~ "--_badge-pill-padding: calc(var(--_badge-padding) + 0.1875rem);"

    assert css =~
             ~r/\[data-element="indicator"\] \[data-element="badge"\]\[data-pill\] \{\s*--_badge-pill-padding: var\(--_badge-padding\);/

    assert css =~
             ~r/\[data-control\]\[data-pill\] \{\s*--fl-control-radius: var\(--fl-radius-full\);/
  end

  test "the control primitive applies the same treatments in both states", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-variant="solid"\]:not\(\[data-state="on"\]\) \{[^}]*background: var\(--fl-control-color\);/

    assert css =~
             ~r/\[data-control\]\[data-state="on"\]\[data-active-variant="solid"\] \{[^}]*background: var\(--fl-control-active-color, var\(--fl-control-color\)\);/

    assert css =~
             ~r/\[data-control\]\[data-variant="soft"\]:not\(\[data-state="on"\]\),[^}]*background: color-mix\(/

    assert css =~
             ~r/\[data-control\]\[data-state="on"\]\[data-active-variant="soft"\],[^}]*background: color-mix\(/

    assert css =~
             ~r/\[data-control\]:is\([^)]*\[data-variant="solid"\]:not\(\[data-state="on"\]\)[^)]*\)::before/

    assert css =~ ~s|[data-control]:not([data-depth])|
  end

  test "controls expose only public color inputs", %{css: css} do
    refute css =~ "--_fl-button-"
    refute css =~ "--_fl-toggle-"
    refute css =~ "--fl-button-surface"
    refute css =~ "--fl-toggle-surface"

    assert css =~ "--fl-control-color: var(--fl-tone, var(--fl-color-inverted));"
    assert css =~ "--fl-focus-ring-color: var(--fl-color-primary);"
    refute css =~ "--fl-focus-ring-color: var(--fl-control-color"

    assert css =~ "var(--fl-control-shadow, 0 0 #0000)"
    assert css =~ "var(--fl-control-press, none)"
    assert css =~ ~s|[data-control]:not([data-depth])|

    refute css =~ ~r/\[data-control\]\[data-depth\] \{\s*--fl-control-depth: 1;/
  end

  test "focus pairs a full-color border with the shared ring", %{css: css} do
    assert css =~ "--fl-focus-border-color: var(--fl-focus-ring-color);"
    assert css =~ "--fl-focus-color-danger: var(--fl-color-danger);"
    assert css =~ "--fl-focus-border-color: initial;"
    assert css =~ "border-color: var(--fl-focus-border-color, revert-layer);"

    assert css =~ ~s|[data-control]:focus-visible:not([data-disabled])|

    assert css =~ ~s([data-element="badge"][data-part][data-variant]:focus-visible)

    assert css =~
             ~s([data-element="card"][data-card][data-link][data-outline]:focus-visible)
  end

  test "square and wide buttons are boxed and full-width", %{css: css} do
    assert css =~ ~s([data-control][data-square])
    assert css =~ "aspect-ratio: 1;"
    assert css =~ "padding-inline: 0;"
    assert css =~ ~s([data-control][data-wide])
    assert css =~ "width: 100%;"
  end

  test "justify buttons distribute their content within the available width", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-justify="start"\] \{\s*justify-content: flex-start;/

    assert css =~
             ~r/\[data-control\]\[data-justify="end"\] \{\s*justify-content: flex-end;/

    assert css =~
             ~r/\[data-control\]\[data-justify="between"\] \{\s*justify-content: space-between;/
  end

  test "square buttons keep their icon at full strength", %{css: css} do
    assert css =~
             ~r/\[data-control\]:not\(\[data-square\]\)\s*:is\(\[data-element="icon"\], \[data-element="loading"\]\) \{\s*color: color-mix\(in oklab, currentColor 70%, transparent\);/
  end

  test "inset buttons negate only the requested sides", %{css: css} do
    for size <- ~w(xs sm md lg xl) do
      assert css =~
               ~r/\[data-control\]\[data-size="#{size}"\] \{[^}]*--_inset-inline: calc\(\s*-1 \* \(var\(--fl-control-padding-x-#{size}\) \+ 1px\)/

      assert css =~
               ~r/\[data-control\]\[data-size="#{size}"\] \{[^}]*--_inset-block: calc\(\s*-1 \* \(\(var\(--fl-control-height-#{size}\) - var\(--fl-control-line-height-#{size}\)\) \/ 2\)/

      assert css =~ ~s([data-control][data-inset][data-square])

      assert css =~
               "--_inset-inline: calc(-1 * ((var(--fl-control-height-#{size}) - var(--fl-control-icon-#{size})) / 2))"
    end

    for side <- ~w(top bottom left right) do
      assert css =~ ~s([data-control][data-inset~="#{side}"])
    end

    assert css =~ ~s([data-control][data-inset=""])
    assert css =~ ~s([data-control][data-inset~="all"])

    assert css =~ ~s([data-control][data-variant="link"])
    assert css =~ "--_inset-block: 0;"
  end

  test "loading buttons keep a progress cursor", %{css: css} do
    assert css =~
             ~r/\[data-control\]\[data-loading\]:not\(\[data-disabled\]\) \{\s*cursor: progress;/

    assert css =~ ~r/:not\(\s*\[data-loading\]\s*\):hover::after/
    assert css =~ ~r/:not\(\s*\[data-loading\]\s*\):active/
  end

  test "loading indicators are hidden until the button is loading", %{css: css} do
    assert css =~
             ~r/\[data-control\]:not\(\[data-loading\]\) > \[data-loading-indicator\] \{\s*display: none;/
  end

  test "card exposes five inputs and styles bodies directly", %{css: css} do
    refute css =~ "--_fl-card-"
    refute css =~ "--fl-card-band-surface"
    refute css =~ "--fl-card-body-"
    refute css =~ "--fl-card-panel-"
    refute css =~ "--fl-card-divider"
    refute File.read!(FlintUI.Generator.part_path("styled/card.css")) =~ "--fl-color-primary"

    for body <- ~w(seamless inset flush divided separated separated-header separated-footer) do
      assert css =~ ~s([data-body="#{body}"])
    end

    for spacing <- ~w(xs sm md lg xl) do
      assert css =~ ~s([data-element="card"][data-spacing="#{spacing}"])
    end

    assert css =~ ~s|[data-element="card"]:not([data-outline])[data-card]|
    assert css =~ ~s|[data-element="card"]:not([data-shadow])[data-card]|
    assert css =~ ~s|[data-element="card"][data-inverted]|
    assert css =~ ~s|[data-element="card"][data-card][data-link]|
    assert css =~ "background: var(--fl-card-surface, var(--fl-color-surface));"
    assert css =~ "border: 1px solid var(--fl-card-border, var(--fl-color-border));"
    assert css =~ "box-shadow: var(--fl-card-shadow, var(--fl-elevation-surface));"
  end

  test "raised surfaces share one layered elevation recipe", %{css: css} do
    assert css =~ "--fl-elevation-level: 2;"
    assert css =~ "--fl-elevation-step: 0.4;"
    assert css =~ ":where([data-elevation], .fl-surface) {"
    assert css =~ "--fl-elevation-surface:"
    assert css =~ "inset 0 1px 0 0 var(--fl-elevation-highlight)"
    assert css =~ "inset 0 0 0 1px var(--fl-elevation-hairline)"
    assert css =~ "0 0 0 1px var(--fl-elevation-ring)"
    assert css =~ "box-shadow: var(--fl-elevation-surface);"
    assert css =~ "--fl-elevation-ring: light-dark(var(--fl-color-border), rgb(0 0 0 / 40%));"
    assert css =~ "--fl-elevation-ring: light-dark(transparent, rgb(0 0 0 / 40%));"
    assert css =~ "--fl-elevation-hairline: transparent;"
    assert css =~ "--fl-elevation-highlight: transparent;"
    assert css =~ "--fl-elevation-level: 3;"
  end

  test "a vertical separator stretches in flex and keeps a fallback length", %{css: css} do
    vertical = ~r/\[data-element="separator"\]\[data-orientation="vertical"\]\[data-separator\]/

    # `block-size: 100%` resolves to zero in an indefinite-height flex row and
    # prevents the item from stretching; `align-self` plus a minimum length
    # fills the row and still renders outside one.
    assert css =~ ~r/#{vertical.source} \{[^}]*align-self: stretch;/s
    assert css =~ ~r/#{vertical.source} \{[^}]*min-block-size: var\(--fl-spacing-xl\);/s
    refute css =~ ~r/#{vertical.source} \{[^}]*block-size: 100%;/s
  end

  test "boolean styling hooks are presence/absence, never string values", %{css: css} do
    for hook <- ~w(square wide depth outline shadow inverted padded) do
      refute css =~ ~r/\[data-#{hook}="(true|false)"\]/
    end
  end

  test "collapsible exposes timing inputs and runtime-only size hooks", %{css: css} do
    assert css =~ "--fl-collapsible-duration, var(--fl-duration-base)"
    assert css =~ "--fl-collapsible-easing, var(--fl-ease-in-out)"
    assert css =~ "var(--_fl-collapsible-height, auto)"
    refute css =~ "var(--fl-collapsible-height"
  end

  test "shared motion keyframes are public and components reuse them", %{css: css} do
    for keyframe <-
          ~w(fl-fade-in fl-fade-out fl-pop-in fl-pop-out fl-slide-in fl-slide-out fl-rotate-in fl-rotate-out fl-shake fl-flash fl-spin fl-ping fl-pulse fl-bounce fl-heartbeat) do
      assert css =~ "@keyframes #{keyframe}"
    end

    assert css =~ "--fl-motion-pop-scale"
    assert css =~ "--fl-motion-pop-translate"
    assert css =~ "--fl-motion-slide-from"
    assert css =~ "--fl-motion-rotate-from"
    assert css =~ "--fl-motion-rotate-scale"
    assert css =~ "--fl-motion-shake-distance"
    assert css =~ "--fl-motion-flash-opacity"
    assert css =~ "--fl-heartbeat-scale"

    assert css =~ "animation: fl-pop-in"
    assert css =~ "animation: fl-pop-out"
    assert css =~ "animation: fl-fade-in"
    assert css =~ "animation: fl-fade-out"

    # The four enter/exit components reference the shared keyframes instead of
    # shipping local copies.
    refute css =~ "@keyframes fl-dropdown-"
    refute css =~ "@keyframes fl-popover-"
    refute css =~ "@keyframes fl-tooltip-"
    refute css =~ "@keyframes fl-modal-"
  end

  defp resolve_text(css, token, light_base, dark_base) do
    branch =
      "color-mix\\(in oklab, var\\(--fl-text-base\\) [\\d.]+%, oklch\\([^)]*\\)\\)|oklch\\([^)]*\\)"

    [_, light, dark] =
      Regex.run(
        Regex.compile!(
          "--fl-color-#{token}: light-dark\\(\\s*(#{branch}),\\s*(#{branch})\\s*\\);",
          "s"
        ),
        css
      )

    {resolve_branch(light, light_base), resolve_branch(dark, dark_base)}
  end

  defp resolve_branch("oklch(" <> _ = value, _base), do: value

  defp resolve_branch(expression, base) do
    [_, percent, other] =
      Regex.run(~r/var\(--fl-text-base\) ([\d.]+)%, (oklch\([^)]*\))/, expression)

    {weight, _} = Float.parse(percent)
    FlintUI.Palette.Contrast.mix(base, other, weight / 100)
  end

  defp ratio(fg, bg), do: FlintUI.Palette.Contrast.ratio(fg, bg)
end
