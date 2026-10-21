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

  test "defines a 50..950 scale and an alias per semantic role", %{css: css} do
    for role <- ~w(primary secondary neutral success info warning error) do
      assert css =~ "--fl-color-#{role}-50:"
      assert css =~ "--fl-color-#{role}-950:"
      assert css =~ "--fl-color-#{role}: light-dark("
      assert css =~ "--fl-color-#{role}-foreground: light-dark("
      assert css =~ "--fl-color-#{role}-text: light-dark("
    end
  end

  test "defines semantic surface, text, border, and disabled tokens", %{css: css} do
    assert css =~ "--fl-color-elevated:"
    assert css =~ "--fl-color-dimmed:"
    assert css =~ "--fl-color-inverted:"
    assert css =~ "--fl-color-border:"
    assert css =~ "--fl-color-border-muted:"
    assert css =~ "--fl-color-border-accented:"
    assert css =~ "--fl-color-disabled:"
    assert css =~ "--fl-color-disabled-foreground:"
    assert css =~ "--fl-color-disabled-border:"
    assert css =~ "--fl-disabled-opacity: 0.5;"
  end

  test "border weight is a theme knob instead of a token per role", %{css: css} do
    assert css =~ "--fl-border-strength: 50%;"
    assert css =~ "--fl-border-strength-soft: 25%;"

    for role <- ~w(primary secondary neutral success info warning error) do
      refute css =~ "--fl-color-#{role}-border:"
      refute css =~ "--fl-color-#{role}-border-soft:"
    end
  end

  test "surface steps are opaque and move toward the elevated step", %{css: css} do
    assert css =~
             ~r/--fl-color-surface-soft: color-mix\(\s*in oklab,\s*var\(--fl-color-elevated\) 50%,\s*var\(--fl-color-surface\)\s*\)/

    assert css =~ "--fl-color-surface-muted: var(--fl-color-muted);"
    assert css =~ "--fl-color-disabled: var(--fl-color-surface-muted);"
    assert css =~ "--fl-color-disabled-foreground: var(--fl-color-dimmed);"
    assert css =~ "--fl-color-surface: light-dark(oklch(1 0 0), var(--fl-color-neutral-800));"
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
    assert css =~ ~s([data-element="group"][data-variant="attached"])
    assert css =~ ~s([data-element="group"][data-variant="framed"])
    assert css =~ "--fl-color-primary:"
    assert css =~ ~s([data-element="toggle"][data-variant])
    assert css =~ ~s([data-element="toggle"][data-variant] > [data-element="icon"])
    assert css =~ ~s([data-element="toggle"][data-color="neutral"])
    assert css =~ ~s([data-element="loading"][data-size])
    assert css =~ ~s([data-element="icon"][data-size])
    assert css =~ "--fl-icon-size:"
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
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
             ~r/\[data-element="button"\]\[data-depth="false"\] \{\s*--fl-control-depth: 0;/

    refute css =~
             ~r/\[data-element="button"\]\[data-depth="true"\] \{\s*--fl-control-depth: 1;/
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

    assert css =~ ~s([data-element="card"][data-outline="true"])
    assert css =~ ~s([data-element="card"][data-outline="false"])
    assert css =~ ~s([data-element="card"][data-shadow="true"])
    assert css =~ ~s([data-element="card"][data-shadow="false"])
    assert css =~ ~s([data-element="card"][data-inverted="true"])
    assert css =~ "background: var(--fl-card-surface, var(--fl-color-surface));"
    assert css =~ "border: 1px solid var(--fl-card-border, var(--fl-color-border));"
    assert css =~ "box-shadow: var(--fl-card-shadow, var(--fl-shadow-base));"
  end

  test "collapsible exposes timing inputs and runtime-only size hooks", %{css: css} do
    assert css =~ "--fl-collapsible-duration, var(--fl-duration-base)"
    assert css =~ "--fl-collapsible-easing, var(--fl-ease-in-out)"
    assert css =~ "var(--_fl-collapsible-height, auto)"
    refute css =~ "var(--fl-collapsible-height"
  end
end
