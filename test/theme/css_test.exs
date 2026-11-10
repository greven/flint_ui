defmodule FlintUI.Theme.CSSTest do
  use ExUnit.Case, async: true

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "defines prefixed tokens with automatic light/dark", %{css: css} do
    assert css =~ "color-scheme: light dark;"
    assert css =~ "--fl-color-primary: var(--fl-color-primary-600);"
    assert css =~ "--fl-color-primary-content: light-dark("
    assert css =~ "--fl-color-primary-600: var(--fl-color-neutral-600);"
    assert css =~ "--fl-color-neutral: light-dark("
    assert css =~ "--fl-radius:"
    assert css =~ "--fl-radius-md:"
    assert css =~ "--fl-font-sans:"
  end

  test "defines a 50..950 scale and three jobs per semantic role", %{css: css} do
    for role <- ~w(primary secondary neutral success info warning error) do
      assert css =~ "--fl-color-#{role}-50:"
      assert css =~ "--fl-color-#{role}-950:"
      assert css =~ "--fl-color-#{role}:"
      assert css =~ "--fl-color-#{role}-content: light-dark("
      assert css =~ "--fl-color-#{role}-text: light-dark("
      assert css =~ "--fl-color-#{role}-soft: light-dark("
      assert css =~ "--fl-color-#{role}-soft-border: color-mix("
      refute css =~ "--fl-color-#{role}-foreground"
      refute css =~ "--fl-color-#{role}-soft-foreground"
    end

    # Primary and secondary ship the neutral ramp until a theme brands them.
    for role <- ~w(primary secondary), shade <- ~w(50 100 200 300 400 500 600 700 800 900 950) do
      assert css =~ "--fl-color-#{role}-#{shade}: var(--fl-color-neutral-#{shade});"
    end
  end

  test "defines absolute tones and maps them on every color component", %{css: css} do
    assert css =~ "--fl-color-dark: var(--fl-color-neutral-900);"
    assert css =~ "--fl-color-light: var(--fl-color-neutral-50);"
    assert css =~ "--fl-color-dark-content: var(--fl-color-neutral-50);"
    assert css =~ "--fl-color-light-content: var(--fl-color-neutral-900);"
    assert css =~ "--fl-color-dark-text: light-dark("
    assert css =~ "--fl-color-light-text: light-dark("

    for element <- ~w(button badge toggle tabs loading loading_text),
        tone <- ~w(dark light) do
      assert css =~ ~s([data-element="#{element}"][data-color="#{tone}"])
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

    assert css =~
             ~r/--fl-color-border-subtle: light-dark\(\s*oklch\(0 0 0 \/ 5%\),\s*oklch\(1 0 0 \/ 5%\)\s*\)/
  end

  test "solid buttons darken their fill for the border", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant="solid"\] \{[^}]*border-color: color-mix\(\s*in oklab,\s*var\(--fl-button-color, var\(--fl-color-inverted\)\),\s*oklch\(0% 0 0\) var\(--fl-border-strength-solid\)/

    assert css =~
             ~r/\[data-element="button"\]\[data-variant\]:is\(\s*\[data-variant="solid"\],/
  end

  test "the pure surface anchors the page and the tint steps", %{css: css} do
    assert css =~ "--fl-surface-step: 1.5%;"

    assert css =~
             "--fl-color-surface: light-dark(oklch(1 0 0), var(--fl-color-neutral-950));"

    assert css =~
             ~r/--fl-color-background: color-mix\(\s*in oklab,\s*light-dark\(var\(--fl-color-neutral-950\),\s*var\(--fl-color-neutral-50\)\)\s*var\(--fl-surface-step\),\s*var\(--fl-color-surface\)\s*\)/

    assert css =~
             ~r/--fl-color-surface-subtle: color-mix\(\s*in oklab,\s*light-dark\(var\(--fl-color-neutral-950\),\s*var\(--fl-color-neutral-50\)\)\s*calc\(var\(--fl-surface-step\) \* 2\),\s*var\(--fl-color-surface\)\s*\)/

    assert css =~
             ~r/--fl-color-surface-strong: color-mix\(\s*in oklab,\s*light-dark\(var\(--fl-color-neutral-950\),\s*var\(--fl-color-neutral-50\)\)\s*calc\(var\(--fl-surface-step\) \* 4\),\s*var\(--fl-color-surface\)\s*\)/

    refute css =~ "--fl-color-control:"
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
    # Conservative proxies for the pure surface and the 6% strong step: use
    # surfaces at least as dark as the real light steps and at least as light as
    # the real dark steps so the AA checks do not overstate contrast.
    light_surface = neutral.(100)
    light_strong = neutral.(200)
    dark_surface = neutral.(900)
    dark_strong = neutral.(800)

    for {fg, surfaces} <- [
          {neutral.(700), [light_surface, light_strong]},
          {neutral.(200), [dark_surface, dark_strong]},
          {neutral.(600), [light_surface, light_strong]},
          {neutral.(300), [dark_surface, dark_strong]}
        ],
        surface <- surfaces do
      assert FlintUI.Palette.Contrast.ratio(fg, surface) >= 4.5
    end

    # Highlighted is the strongest tier in both schemes.
    assert FlintUI.Palette.Contrast.ratio(neutral.(900), white) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(white, neutral.(950)) >= 4.5

    # `text-muted` clears AA on the pure surface, the page tint, and the
    # `surface-subtle` step, but not on the stronger `surface-strong` step.
    text_muted = FlintUI.Palette.Contrast.mix(neutral.(500), neutral.(600), 0.9)
    assert FlintUI.Palette.Contrast.ratio(text_muted, white) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(text_muted, neutral.(50)) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(text_muted, neutral.(100)) >= 4.5
    assert FlintUI.Palette.Contrast.ratio(text_muted, neutral.(200)) < 4.5

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
    assert css =~ "--fl-button-text: var(--fl-color-text-toned);"
    assert css =~ "--fl-button-color-content: var(--fl-color-text-inverted);"
    assert css =~ "--fl-toggle-text: var(--fl-color-text-toned);"
  end

  test "role text clears AA on surface and tinted surfaces", %{css: css} do
    alias FlintUI.Palette.{Contrast, Tailwind}

    neutral = fn shade ->
      [_, value] = Regex.run(~r/--fl-color-neutral-#{shade}: ([^;]+);/, css)
      value
    end

    white = "oklch(100% 0 none)"
    dark_surface = neutral.(900)

    # The docs palette: fill shade, AA text shade in light, AA text shade in dark.
    roles = [
      {"primary", :red, 600, 700, 400},
      {"secondary", :gray, 600, 600, 400},
      {"success", :emerald, 700, 800, 500},
      {"info", :blue, 600, 700, 400},
      {"warning", :amber, 400, 800, 400},
      {"error", :red, 600, 700, 400}
    ]

    for {role, color, fill_shade, light_text_shade, dark_text_shade} <- roles do
      shades = Tailwind.shades(color)
      fill = Map.fetch!(shades, fill_shade)
      light_text = Map.fetch!(shades, light_text_shade)
      dark_text = Map.fetch!(shades, dark_text_shade)

      for {surface, background} <- [
            {"light surface", white},
            {"light tint", Contrast.mix(fill, white, 0.25)}
          ] do
        ratio = Contrast.ratio(light_text, background)

        assert ratio >= 4.5,
               "#{role} light text on #{surface}: #{Float.round(ratio, 2)}"
      end

      for {surface, background} <- [
            {"dark surface", dark_surface},
            {"dark tint", Contrast.mix(fill, dark_surface, 0.18)}
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

  test "the none radius step removes the control radius", %{css: css} do
    for name <- ~w(button toggle badge) do
      selector = ~s([data-element="#{name}"][data-radius="none"])
      assert css =~ selector
      assert css =~ ~s(#{selector} {\n        --fl-control-radius: 0;)
    end
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
    assert css =~ ~s([data-element="card"][data-variant="strong"])
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
    assert css =~ ~s([data-element="icon"][data-icon])
    assert css =~ "--fl-icon-size:"
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
    assert css =~ ~s([data-element="tabs"][data-variant="segmented"])
    assert css =~ ~s([data-element="tabs"][data-variant="minimal"])
    assert css =~ ~s([data-element="tabs"][data-color="primary"])
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

    assert css =~ "--fl-tabs-color: var(--fl-color-inverted);"
    assert css =~ "--fl-tabs-text: var(--fl-color-text);"
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

  test "an attached group overlaps children onto an opaque surface fill", %{css: css} do
    # The later child's opaque fill covers the previous border at the seam, so
    # only one line shows. Neutral borders can stay alpha because the fill under
    # them does not change on hover.
    assert css =~ "margin-inline-start: -1px"
    assert css =~ "margin-block-start: -1px"
    assert css =~ "--fl-color-surface:"
    assert css =~ "oklch(1 0 0 / 8%)"

    # Chromatic borders are opaque against the surface fill and share the soft
    # strength across subtle and surface.
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

    for part <- ~w(styled/badge.css styled/button.css styled/toggle.css) do
      source = File.read!(FlintUI.Generator.part_path(part))
      assert source =~ "calc(var(--fl-tint-opacity, 0.9) * 100%)"
    end
  end

  test "every colored button variant uses the role text token", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant="soft"\],\s*\[data-element="button"\]\[data-variant="subtle"\] \{[^}]*color: var\(--fl-button-text/

    for variant <- ~w(surface outline ghost link) do
      assert css =~
               ~r/\[data-element="button"\]\[data-variant="#{variant}"\] \{[^}]*color: var\(--fl-button-text/
    end

    assert css =~
             ~r/\[data-element="button"\]\[data-variant="link"\][^{]*:hover \{\s*color: color-mix\(\s*in oklab,\s*var\(--fl-button-text, var\(--fl-button-color, var\(--fl-color-inverted\)\)\) 75%,\s*transparent\s*\);/

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
    for name <- ~w(button badge toggle) do
      assert css =~
               ~r/\[data-element="#{name}"\]\[data-variant="outline"\][^{]*\{[^}]*border-color: var\(--fl-#{name}-color, var\(--fl-color-inverted\)\)/
    end

    for name <- ~w(button badge) do
      assert css =~
               ~r/\[data-element="#{name}"\]\[data-variant="surface"\] \{[^}]*border-color: var\(\s*--fl-#{name}-soft-border,/
    end

    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant="surface"\]\[data-state="on"\] \{[^}]*border-color: var\(\s*--fl-toggle-soft-border,/

    # Neutral's shared soft border is too quiet for a state change, so the
    # toggle strengthens it to match the colored role edges.
    assert css =~
             "--fl-toggle-soft-border: color-mix(in oklab, var(--fl-toggle-color) 32%, var(--fl-color-surface));"
  end

  test "dashed is an orthogonal border modifier, not a variant", %{css: css} do
    for name <- ~w(button badge toggle) do
      assert css =~
               ~r/\[data-element="#{name}"\]\[data-dashed\] \{\s*border-style: dashed;/
    end
  end

  test "pills use the full radius and indicator markers keep compact padding", %{css: css} do
    # Badges add inline padding for the label; the nested indicator badge resets
    # it so a one-character count stays a circle. Controls only change the radius.
    assert css =~ ~s([data-element="badge"][data-pill] {)
    assert css =~ "--_badge-pill-padding: calc(var(--_badge-padding) + 0.1875rem);"

    assert css =~
             ~r/\[data-element="indicator"\] \[data-element="badge"\]\[data-pill\] \{\s*--_badge-pill-padding: var\(--_badge-padding\);/

    for name <- ~w(button toggle) do
      assert css =~
               ~r/\[data-element="#{name}"\]\[data-pill\] \{\s*--fl-control-radius: var\(--fl-radius-full\);/
    end
  end

  test "toggle variants mirror the button's depth and pressed treatments", %{css: css} do
    # Solid pressed darkens its fill for the border and wears the top rim light.
    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant="solid"\]\[data-state="on"\] \{[^}]*border-color: color-mix\(\s*in oklab,\s*var\(--fl-toggle-color, var\(--fl-color-inverted\)\),\s*oklch\(0% 0 0\) var\(--fl-border-strength-solid\)/

    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant="solid"\]\[data-state="on"\]::before \{\s*border-color: rgb\(255 255 255 \/ calc\(12% \* var\(--fl-control-depth, 1\)\)\);/

    # Surface carries the button's inner line and elevation.
    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant="surface"\] \{\s*box-shadow:\s*inset 0 -1px 0 rgb\(0 0 0 \/ calc\(7% \* var\(--fl-control-depth, 1\)\)\),\s*var\(--fl-control-shadow, 0 0 #0000\);/

    # Subtle keeps the neutral off state; only the pressed state carries the
    # tinted surface.
    refute css =~
             ~r/\[data-element="toggle"\]\[data-variant="subtle"\] \{\s*background: var\(--fl-color-surface-strong\);/

    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant="subtle"\]\[data-state="on"\] \{[^}]*background: color-mix\(\s*in oklab,\s*var\(\s*--fl-toggle-soft,/

    # Both controls expose the depth flattening hook.
    assert css =~
             ~r/\[data-element="toggle"\]:not\(\[data-depth\]\)\[data-variant\] \{\s*--fl-control-depth: 0;/

    assert css =~
             ~r/\[data-element="toggle"\]\[data-variant\]:is\(\s*\[data-variant="solid"\],/
  end

  test "button and toggle expose only public color inputs", %{css: css} do
    refute css =~ "--_fl-button-"
    refute css =~ "--_fl-toggle-"
    refute css =~ "--fl-button-surface"
    refute css =~ "--fl-toggle-surface"

    assert css =~ "--fl-button-color: var(--fl-color-primary);"
    assert css =~ "--fl-toggle-color: var(--fl-color-primary);"
    assert css =~ "--fl-focus-ring-color: var(--fl-color-primary);"
    refute css =~ "--fl-focus-ring-color: var(--fl-button-color"
    refute css =~ "--fl-focus-ring-color: var(--fl-toggle-color"
    refute css =~ "--fl-focus-ring-color: var(--fl-tabs-color"

    assert css =~ "var(--fl-control-shadow, 0 0 #0000)"
    assert css =~ "var(--fl-control-press, none)"

    assert css =~
             ~r/\[data-element="button"\]:not\(\[data-depth\]\)\[data-variant\] \{\s*--fl-control-depth: 0;/

    refute css =~
             ~r/\[data-element="button"\]\[data-depth\] \{\s*--fl-control-depth: 1;/
  end

  test "focus pairs a full-color border with the shared ring", %{css: css} do
    assert css =~ "--fl-focus-border-color: var(--fl-focus-ring-color);"
    assert css =~ "--fl-focus-color-error: var(--fl-color-error);"
    assert css =~ "--fl-focus-border-color: initial;"
    assert css =~ "border-color: var(--fl-focus-border-color, revert-layer);"

    assert css =~
             ~s|[data-element="button"][data-variant]:focus-visible:not([data-disabled])|

    assert css =~
             ~s|[data-element="toggle"][data-variant]:focus-visible:not([data-disabled])|

    assert css =~ ~s([data-element="badge"][data-part][data-variant]:focus-visible)

    assert css =~
             ~s([data-element="card"][data-card][data-link][data-outline]:focus-visible)
  end

  test "square and wide buttons are boxed and full-width", %{css: css} do
    assert css =~ ~s([data-element="button"][data-square])
    assert css =~ "aspect-ratio: 1;"
    assert css =~ "padding-inline: 0;"
    assert css =~ ~s([data-element="button"][data-wide])
    assert css =~ "width: 100%;"
  end

  test "justify buttons distribute their content within the available width", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-justify="start"\] \{\s*justify-content: flex-start;/

    assert css =~
             ~r/\[data-element="button"\]\[data-justify="end"\] \{\s*justify-content: flex-end;/

    assert css =~
             ~r/\[data-element="button"\]\[data-justify="between"\] \{\s*justify-content: space-between;/
  end

  test "square buttons keep their icon at full strength", %{css: css} do
    assert css =~
             ~r/\[data-element="button"\]\[data-variant\]:not\(\[data-square\]\)\s*>\s*:is\(\[data-element="icon"\], \[data-element="loading"\]\) \{\s*color: color-mix\(in oklab, currentColor 70%, transparent\);/
  end

  test "inset buttons negate only the requested sides", %{css: css} do
    for size <- ~w(xs sm md lg xl) do
      assert css =~
               ~r/\[data-element="button"\]\[data-size="#{size}"\] \{[^}]*--_inset-inline: calc\(\s*-1 \* \(var\(--fl-control-padding-x-#{size}\) \+ 1px\)/

      assert css =~
               ~r/\[data-element="button"\]\[data-size="#{size}"\] \{[^}]*--_inset-block: calc\(\s*-1 \* \(\(var\(--fl-control-height-#{size}\) - var\(--fl-control-line-height-#{size}\)\) \/ 2\)/

      assert css =~
               ~r/\[data-element="button"\]\[data-inset\]\[data-square\]:not\(\s*\[data-variant="link"\]\s*\)\[data-size="#{size}"\] \{[^}]*--_inset-inline: calc\(\s*-1 \* \(\(var\(--fl-control-height-#{size}\) - var\(--fl-control-icon-#{size}\)\) \/ 2\)/
    end

    for side <- ~w(top bottom left right) do
      assert css =~ ~s([data-element="button"][data-inset~="#{side}"])
    end

    assert css =~ ~s([data-element="button"][data-inset=""])
    assert css =~ ~s([data-element="button"][data-inset~="all"])

    assert css =~ ~r/\[data-element="button"\]\[data-variant="link"\] \{\s*--_inset-block: 0;/
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
    assert css =~ ~s|[data-element="card"][data-card][data-link]|
    assert css =~ "background: var(--fl-card-surface, var(--fl-color-surface));"
    assert css =~ "border: 1px solid var(--fl-card-border, var(--fl-color-border));"
    assert css =~ "box-shadow: var(--fl-card-shadow, var(--fl-shadow-base));"
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
end
