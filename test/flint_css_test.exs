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

  test "defines semantic surface, text, and border emphasis tokens", %{css: css} do
    assert css =~ "--fl-color-elevated:"
    assert css =~ "--fl-color-dimmed:"
    assert css =~ "--fl-color-inverted:"
    assert css =~ "--fl-color-border-muted:"
    assert css =~ "--fl-color-border-accented:"
  end

  test "components expose public color inputs and tint focus", %{css: css} do
    assert css =~ "--fl-button-color: var(--fl-color-inverted);"
    assert css =~ "--fl-toggle-color: var(--fl-color-inverted);"
    assert css =~ "--fl-focus-ring-color: var(--_fl-button-color);"
    assert css =~ "--fl-focus-ring-color: var(--_fl-toggle-color);"
  end

  test "exposes depth, elevation, and press inputs", %{css: css} do
    assert css =~ "--fl-button-depth: 1;"
    assert css =~ "--fl-button-sheen-stop: 100%;"
    assert css =~ "--fl-button-highlight: rgb(255 255 255 /"
    assert css =~ "--fl-button-inner-line:"
    assert css =~ "--fl-button-shadow: var(--fl-shadow-xs);"
    assert css =~ "--fl-button-press:"

    assert css =~ ~s([data-element="button"][data-variant]::before)
    assert css =~ "--fl-button-sheen: var(--fl-button-highlight);"
    assert css =~ "mask-image: linear-gradient("

    for value <- ~w(true false) do
      assert css =~ ~s([data-element="button"][data-depth="#{value}"])
    end

    refute css =~ ~s([data-element="button"][data-shadow=])
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

  test "control heights follow the Nuxt-style 4px grid scale", %{css: css} do
    heights = %{
      "xs" => "1.5rem",
      "sm" => "1.75rem",
      "md" => "2rem",
      "lg" => "2.25rem",
      "xl" => "2.5rem"
    }

    for {size, height} <- heights do
      assert css =~ "--fl-control-height-#{size}: #{height};"
    end
  end

  test "exposes shared and per-component radius tokens", %{css: css} do
    assert css =~ "--fl-radius: 0.25rem;"
    assert css =~ "--fl-radius-md: calc(var(--fl-radius) * 1.5);"
    assert css =~ "--fl-button-radius: var(--fl-radius-md);"
    assert css =~ "--fl-toggle-radius: var(--fl-radius-md);"
    assert css =~ "--fl-card-radius: var(--fl-radius-xl);"
  end

  test "controls the scheme through data-color-scheme", %{css: css} do
    assert css =~ ~s([data-color-scheme="light"])
    assert css =~ ~s([data-color-scheme="dark"])
  end

  test "ships named theme presets selectable through data-theme", %{css: css} do
    assert css =~ ~s([data-theme="pastel"])
    assert css =~ ~s([data-theme="modern"])
  end

  test "card variants are neutral surfaces with no semantic color", %{css: css} do
    assert css =~ "--fl-color-surface:"
    assert css =~ "--fl-color-surface-foreground:"
    assert css =~ ~s([data-element="card"][data-variant="solid"])

    refute File.read!(FlintUI.Generator.part_path("styled/card.css")) =~ "--fl-color-primary"
  end

  test "styles each component behind its wrapper hook", %{css: css} do
    assert css =~ "@layer components {"
    assert css =~ ~s([data-element="button"][data-variant])
    assert css =~ ~s([data-element="button"][data-color="neutral"])
    assert css =~ ~s{:is([data-element="icon"], [data-element="loading"])}
    assert css =~ ~s([data-element="card"][data-card])
    assert css =~ ~s([data-element="card"][data-variant="soft"])
    assert css =~ ~s([data-element="card"][data-divided="true"])
    assert css =~ ~s([data-element="group"][data-variant="attached"])
    assert css =~ ~s([data-element="group"][data-variant="framed"])
    assert css =~ ~s([data-element="group"][data-size="md"])
    assert css =~ ~s([data-element="toggle"][data-variant])
    assert css =~ ~s([data-element="toggle"][data-variant] > [data-element="icon"])
    assert css =~ ~s([data-element="toggle"][data-color="neutral"])
    assert css =~ ~s([data-element="loading"][data-size])
    assert css =~ ~s([data-element="icon"][data-size])
    assert css =~ "--fl-icon-size:"
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
  end
end
