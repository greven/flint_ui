defmodule FlintUI.FlintCSSTest do
  use ExUnit.Case, async: true

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "defines prefixed tokens with automatic light/dark", %{css: css} do
    assert css =~ "color-scheme: light dark;"
    assert css =~ "--fl-color-primary: light-dark("
    assert css =~ "--fl-radius:"
    assert css =~ "--fl-radius-md:"
    assert css =~ "--fl-font-sans:"
  end

  test "defines a 50..950 scale and three jobs per semantic role", %{css: css} do
    for role <- ~w(primary secondary neutral success info warning error) do
      assert css =~ "--fl-color-#{role}-50:"
      assert css =~ "--fl-color-#{role}-950:"
      assert css =~ "--fl-color-#{role}: light-dark("
      assert css =~ "--fl-color-#{role}-content: light-dark("
      assert css =~ "--fl-color-#{role}-text: light-dark("
      refute css =~ "--fl-color-#{role}-foreground"
      refute css =~ "--fl-color-#{role}-soft-foreground"
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
          surface-soft
          control
          muted
          inverted
          border
          border-muted
          border-accented
          ring
        ) do
      assert css =~ "--fl-color-#{token}:"
    end

    refute css =~ "--fl-color-disabled"
    refute css =~ "--fl-color-accent"
    refute css =~ "--fl-color-input"
    refute css =~ "--fl-color-elevated"
    refute css =~ "--fl-color-surface-muted"
    refute css =~ "--fl-color-surface-foreground"
    assert css =~ "--fl-disabled-opacity: 0.5;"
  end

  test "border weight is a theme knob instead of a token per role", %{css: css} do
    assert css =~ "--fl-border-strength: 50%;"
    assert css =~ "--fl-border-strength-soft: 25%;"
    assert css =~ "--fl-border-strength-solid: 12%;"

    for role <- ~w(primary secondary neutral success info warning error) do
      refute css =~ "--fl-color-#{role}-border:"
      refute css =~ "--fl-color-#{role}-border-soft:"
    end
  end

  test "solid buttons darken their fill for the border", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant="solid"\] \{[^}]*border-color: color-mix\(\s*in oklab,\s*var\(--fl-button-color, var\(--fl-color-inverted\)\),\s*oklch\(0% 0 0\) var\(--fl-border-strength-solid\)/

    assert css =~
             ~r/\[data-element="button"\]\[data-variant\]:is\(\s*\[data-variant="solid"\],/
  end

  test "surface steps are opaque and move toward the muted step", %{css: css} do
    assert css =~
             ~r/--fl-color-surface-soft: color-mix\(\s*in oklab,\s*var\(--fl-color-muted\) 50%,\s*var\(--fl-color-surface\)\s*\)/

    assert css =~
             "--fl-color-surface: light-dark(oklch(1 0 0), var(--fl-color-neutral-900));"

    assert css =~
             ~r/--fl-color-control: light-dark\(\s*var\(--fl-color-surface\),\s*color-mix\(\s*in oklab,\s*var\(--fl-color-background\) 50%,\s*var\(--fl-color-surface\) 50%\s*\)\s*\)/

    assert css =~
             ~r/--fl-color-muted: light-dark\(\s*var\(--fl-color-neutral-100\),\s*var\(--fl-color-neutral-800\)\s*\)/
  end

  test "text tiers are softened neutrals that clear AA where used", %{css: css} do
    assert css =~
             ~r/--fl-color-text-highlighted: light-dark\(\s*var\(--fl-color-neutral-900\),\s*oklch\(1 0 0\)\s*\)/

    assert css =~
             ~r/--fl-color-text: light-dark\(\s*var\(--fl-color-neutral-700\),\s*var\(--fl-color-neutral-200\)\s*\)/

    assert css =~
             ~r/--fl-color-text-toned: light-dark\(\s*var\(--fl-color-neutral-600\),\s*var\(--fl-color-neutral-300\)\s*\)/

    assert css =~
             ~r/--fl-color-text-inverted: light-dark\(\s*oklch\(1 0 0\),\s*var\(--fl-color-neutral-800\)\s*\)/

    neutral = fn shade ->
      [_, value] = Regex.run(~r/--fl-color-neutral-#{shade}: ([^;]+);/, css)
      value
    end

    white = "oklch(100% 0 none)"
    light_control = white
    light_muted = neutral.(100)
    dark_control = FlintUI.Palette.Contrast.mix(neutral.(950), neutral.(900), 0.50)
    dark_surface = neutral.(900)
    dark_muted = neutral.(800)

    for {fg, surfaces} <- [
          {neutral.(700), [light_control, light_muted]},
          {neutral.(200), [dark_control, dark_surface, dark_muted]},
          {neutral.(600), [light_control, light_muted]},
          {neutral.(300), [dark_control, dark_surface, dark_muted]}
        ],
        surface <- surfaces do
      assert FlintUI.Palette.Contrast.ratio(fg, surface) >= 4.5
    end

    # Highlighted is the strongest tier in both schemes.
    assert FlintUI.Palette.Contrast.ratio(neutral.(900), white) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(white, neutral.(950)) >= 4.5

    # `muted` clears AA on the page and surface-soft, but not on a muted fill.
    assert FlintUI.Palette.Contrast.ratio(neutral.(500), white) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(neutral.(500), neutral.(50)) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(neutral.(500), neutral.(100)) < 4.5

    # `dimmed` is intentionally below AA: placeholders and decoration only.
    assert FlintUI.Palette.Contrast.ratio(neutral.(400), white) < 4.5
    assert FlintUI.Palette.Contrast.ratio(neutral.(500), neutral.(950)) < 4.5

    # Solid neutral keeps a high-contrast label in both schemes.
    assert FlintUI.Palette.Contrast.ratio(white, neutral.(900)) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(neutral.(800), white) >= 4.5
  end

  test "role content and text map to the three jobs", %{css: css} do
    for role <- ~w(primary secondary success info warning error) do
      assert css =~ "--fl-button-color-content: var(--fl-color-#{role}-content);"
      assert css =~ "--fl-button-text: var(--fl-color-#{role}-text);"
      assert css =~ "--fl-toggle-color-content: var(--fl-color-#{role}-content);"
      assert css =~ "--fl-toggle-text: var(--fl-color-#{role}-text);"
    end

    refute css =~ "-soft-foreground"

    # Neutral colored text keeps the page ink and the inverted label.
    assert css =~ "--fl-button-text: var(--fl-color-text);"
    assert css =~ "--fl-button-color-content: var(--fl-color-text-inverted);"
    assert css =~ "--fl-toggle-text: var(--fl-color-text);"
  end

  test "role text clears AA on control and tinted surfaces", %{css: css} do
    alias FlintUI.Palette.{Contrast, Tailwind}

    neutral = fn shade ->
      [_, value] = Regex.run(~r/--fl-color-neutral-#{shade}: ([^;]+);/, css)
      value
    end

    white = "oklch(100% 0 none)"
    dark_control = Contrast.mix(neutral.(950), neutral.(900), 0.50)

    # The docs palette: fill shade, AA text shade in light, AA text shade in dark.
    roles = [
      {"primary", :red, 600, 700, 500},
      {"secondary", :gray, 600, 600, 400},
      {"success", :emerald, 700, 800, 600},
      {"info", :blue, 600, 700, 500},
      {"warning", :amber, 400, 700, 400},
      {"error", :red, 600, 700, 500}
    ]

    for {role, color, fill_shade, light_text_shade, dark_text_shade} <- roles do
      shades = Tailwind.shades(color)
      fill = Map.fetch!(shades, fill_shade)
      light_text = Map.fetch!(shades, light_text_shade)
      dark_text = Map.fetch!(shades, dark_text_shade)

      for {surface, background} <- [
            {"light control", white},
            {"light tint", Contrast.mix(fill, white, 0.10)}
          ] do
        ratio = Contrast.ratio(light_text, background)

        assert ratio >= 4.5,
               "#{role} light text on #{surface}: #{Float.round(ratio, 2)}"
      end

      for {surface, background} <- [
            {"dark control", dark_control},
            {"dark tint", Contrast.mix(fill, dark_control, 0.10)}
          ] do
        ratio = Contrast.ratio(dark_text, background)

        assert ratio >= 4.5,
               "#{role} dark text on #{surface}: #{Float.round(ratio, 2)}"
      end
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

  test "defines type, spacing, elevation, and motion scales", %{css: css} do
    assert css =~ "--fl-font-mono:"
    assert css =~ "--fl-font-size-md: 1rem;"
    assert css =~ "--fl-font-weight-medium: 500;"
    assert css =~ "--fl-spacing: 0.25rem;"
    assert css =~ "--fl-spacing-lg: calc(var(--fl-spacing) * 4);"
    assert css =~ "--fl-shadow-md:"
    assert css =~ "--fl-breakpoint-lg: 64rem;"
    assert css =~ "--fl-container: 80rem;"
    assert css =~ "--fl-duration-fast: 150ms;"
    assert css =~ "--fl-ease-out:"
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
    assert css =~ ~s([data-element="button"][data-variant])
    assert css =~ ~s([data-element="button"][data-color="neutral"])
    assert css =~ ~s{:is([data-element="icon"], [data-element="loading"])}
    assert css =~ ~s([data-element="card"][data-card])
    assert css =~ ~s([data-element="card"][data-variant="soft"])
    assert css =~ ~s([data-element="card"][data-variant="ghost"])
    assert css =~ "--fl-card-surface: transparent;"
    assert css =~ ~s([data-element="card"][data-inverted][data-variant="ghost"])
    assert css =~ ~s([data-element="group"][data-variant="attached"])
    assert css =~ ~s([data-element="group"][data-variant="framed"])
    assert css =~ "--fl-color-primary:"
    assert css =~ ~s([data-element="toggle"][data-variant])
    assert css =~ ~s([data-element="toggle"][data-variant] > [data-element="icon"])
    assert css =~ ~s([data-element="toggle"][data-color="neutral"])
    assert css =~ ~s([data-element="loading"][data-size])
    assert css =~ ~s([data-element="loading_text"][data-variant="dots"])
    assert css =~ ~s([data-element="loading_text"][data-variant="blink"])
    assert css =~ ~s([data-element="loading_text"][data-variant="shimmer"])
    assert css =~ ~s([data-element="loading_text"][data-variant="wave"])
    assert css =~ ~s([data-element="icon"][data-size])
    assert css =~ "--fl-icon-size:"
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
    assert css =~ ~s([data-element="tabs"][data-variant="segmented"])
    assert css =~ ~s([data-element="tabs"][data-variant="minimal"])
    assert css =~ ~s([data-element="tabs"][data-color="primary"])
    assert css =~ ~s([data-element="tabs"][data-size="lg"])
    assert css =~ ~s([data-element="tabs"][data-grow])
    assert css =~ ~s([data-element="tabs"][data-align="center"])
    assert css =~ ~s([data-element="tabs"][data-align="end"])
    assert css =~ ~s([data-element="tabs"][data-align="spaced"])
    assert css =~ ~s([data-element="tabs"][data-gap="sm"])
    assert css =~ ~s([data-element="tabs"][data-gap="md"])
    assert css =~ ~s([data-element="tabs"][data-gap="lg"])
    assert css =~ ~s([data-element="tabs"][data-gap="xl"])
    assert css =~ "[data-tabs-tab]"
  end

  test "tabs gap overrides the variant spacing", %{css: css} do
    for value <- ~w(sm md lg xl) do
      assert css =~
               ~r/\[data-element="tabs"\]\[data-gap="#{value}"\]\s*>\s*\[data-part="tablist"\]\s*\{\s*gap: var\(--fl-spacing-#{value}\);/
    end

    # The variant baselines and the gap overrides tie on specificity, so the
    # overrides must come later in the stylesheet to win.
    gap = :binary.match(css, ~s([data-element="tabs"][data-gap="md"])) |> elem(0)
    segmented = :binary.match(css, ~s([data-element="tabs"][data-variant="segmented"])) |> elem(0)
    minimal = :binary.match(css, ~s([data-element="tabs"][data-variant="minimal"])) |> elem(0)

    assert gap > segmented
    assert gap > minimal
  end

  test "tabs scope default trigger visuals and expose three inputs", %{css: css} do
    assert css =~ "[data-element=\"tabs\"][data-tabs]"

    assert css =~
             ~r/\[data-element="tabs"\]\[data-tabs\]\s*>\s*\[data-part="tablist"\]\s*>\s*\[data-part="tab"\]\[data-tabs-tab\]/

    assert css =~ "--fl-tabs-color: var(--fl-color-inverted);"
    assert css =~ "--fl-tabs-text: var(--fl-color-text);"
    assert css =~ "--fl-tabs-surface: var(--fl-color-control);"
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

  test "an attached group overlaps children onto an opaque control fill", %{css: css} do
    # The later child's opaque fill covers the previous border at the seam, so
    # only one line shows. Neutral borders can stay alpha because the fill under
    # them does not change on hover.
    assert css =~ "margin-inline-start: -1px"
    assert css =~ "margin-block-start: -1px"
    assert css =~ "--fl-color-control:"
    assert css =~ "oklch(1 0 0 / 8%)"

    # Chromatic borders are opaque against the control fill.
    assert css =~ ~r/var\(--fl-border-strength\),\s+var\(--fl-color-control\)/
    assert css =~ ~r/var\(--fl-border-strength-soft\),\s+var\(--fl-color-control\)/
  end

  test "bordered controls paint an opaque fill and a clipped hover overlay", %{css: css} do
    assert css =~ "background: var(--fl-color-control);"
    assert css =~ "background: currentColor;"
    assert css =~ "inset: -1px;"
    assert css =~ "overflow: clip;"
    assert css =~ "--fl-control-hover-opacity: 0.04;"
    assert css =~ "--fl-control-active-opacity: 0.07;"
  end

  test "every colored button variant uses the role text token", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant="soft"\],\s*\[data-element="button"\]\[data-variant="subtle"\] \{[^}]*color: var\(--fl-button-text/

    for variant <- ~w(outline dashed ghost link) do
      assert css =~
               ~r/\[data-element="button"\]\[data-variant="#{variant}"\] \{[^}]*color: var\(--fl-button-text/
    end

    assert css =~
             ~r/\[data-element="button"\]\[data-variant="link"\][^{]*:hover \{\s*color: color-mix\(\s*in oklab,\s*var\(--fl-button-text, var\(--fl-color-inverted\)\) 75%,\s*transparent\s*\);/

    refute css =~ "--fl-button-soft-text"
  end

  test "button and toggle expose only public color inputs", %{css: css} do
    refute css =~ "--_fl-button-"
    refute css =~ "--_fl-toggle-"
    refute css =~ "--fl-button-surface"
    refute css =~ "--fl-toggle-surface"

    assert css =~ "--fl-button-color: var(--fl-color-primary);"
    assert css =~ "--fl-toggle-color: var(--fl-color-primary);"
    assert css =~ "--fl-focus-ring-color: var(--fl-button-color, var(--fl-color-inverted));"

    assert css =~
             "--fl-focus-ring-color: var(--fl-toggle-color, var(--fl-color-inverted));"

    assert css =~ "var(--fl-control-shadow, 0 0 #0000)"
    assert css =~ "var(--fl-control-press, none)"

    assert css =~
             ~r/\[data-element="button"\]:not\(\[data-depth\]\)\[data-variant\] \{\s*--fl-control-depth: 0;/

    refute css =~
             ~r/\[data-element="button"\]\[data-depth\] \{\s*--fl-control-depth: 1;/
  end

  test "square and wide buttons are boxed and full-width", %{css: css} do
    assert css =~ ~s([data-element="button"][data-square])
    assert css =~ "aspect-ratio: 1;"
    assert css =~ "padding-inline: 0;"
    assert css =~ ~s([data-element="button"][data-wide])
    assert css =~ "width: 100%;"
  end

  test "square buttons keep their icon at full strength", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant\]:not\(\[data-square\]\)\s*>\s*:is\(\[data-element="icon"\], \[data-element="loading"\]\) \{\s*color: color-mix\(in oklab, currentColor 70%, transparent\);/
  end

  test "inset buttons negate their padding", %{css: css} do
    for size <- ~w(xs sm md lg xl) do
      assert css =~
               ~r/\[data-element="button"\]\[data-inset\]\[data-size="#{size}"\] \{\s*margin-inline: calc\(\s*-1 \* \(var\(--fl-control-padding-x-#{size}\) \+ 1px\)/

      assert css =~
               ~r/\[data-inset\]\[data-square\]:not\(\s*\[data-variant="link"\]\s*\)\[data-size="#{size}"\] \{\s*margin: calc\(/
    end
  end

  test "loading buttons keep a progress cursor", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-loading\]:not\(\[data-disabled\]\) \{\s*cursor: progress;/

    assert css =~ ~r/:not\(\s*\[data-loading\]\s*\):hover::after/
    assert css =~ ~r/:not\(\s*\[data-loading\]\s*\):active/
  end

  test "loading indicators are hidden until the button is loading", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]:not\(\[data-loading\]\) > \[data-loading-indicator\] \{\s*display: none;/
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
    assert css =~ "background: var(--fl-card-surface, var(--fl-color-surface));"
    assert css =~ "border: 1px solid var(--fl-card-border, var(--fl-color-border));"
    assert css =~ "box-shadow: var(--fl-card-shadow, var(--fl-shadow-base));"
  end

  test "boolean styling hooks are presence/absence, never string values", %{css: css} do
    for hook <- ~w(square wide depth inset outline shadow inverted padded) do
      refute css =~ ~r/\[data-#{hook}="(true|false)"\]/
    end
  end

  test "collapsible exposes timing inputs and runtime-only size hooks", %{css: css} do
    assert css =~ "--fl-collapsible-duration, var(--fl-duration-base)"
    assert css =~ "--fl-collapsible-easing, var(--fl-ease-in-out)"
    assert css =~ "var(--_fl-collapsible-height, auto)"
    refute css =~ "var(--fl-collapsible-height"
  end
end
