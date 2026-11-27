defmodule FlintUI.Theme.CSSTest do
  @moduledoc """
  Documents the stable theme contracts only.

  Visual treatments change often; exact declarations are intentionally not
  asserted here. Registry-to-selector coverage lives in
  `test/theme/contract_test.exs`, and accessibility ratios live in
  `test/theme/contrast_test.exs`.
  """

  use ExUnit.Case, async: true

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "declares the shared cascade order", %{css: css} do
    assert css =~ "@layer base, components, utilities, focus;"
  end

  test "defines prefixed tokens with automatic light/dark", %{css: css} do
    assert css =~ "color-scheme: light dark;"
    assert token(css, "--fl-color-primary") == "var(--fl-color-neutral)"
    assert token(css, "--fl-color-primary-on") == "var(--fl-color-neutral-on)"
    assert token(css, "--fl-radius-md")
    assert token(css, "--fl-font-sans")
    refute css =~ "--fl-palette-"
  end

  test "defines eighteen palette hues with a complete scale", %{css: css} do
    for hue <- FlintUI.Palette.hue_names() do
      assert token(css, "--fl-color-#{hue}-50"), "expected a 50 shade for #{hue}"
      assert token(css, "--fl-color-#{hue}-950"), "expected a 950 shade for #{hue}"
      assert token(css, "--fl-color-#{hue}"), "expected a base alias for #{hue}"
    end
  end

  test "maps semantic roles onto palette hues instead of shipping role scales", %{css: css} do
    aliases = %{
      "primary" => "neutral",
      "secondary" => "gray",
      "info" => "blue",
      "success" => "green",
      "warning" => "yellow",
      "danger" => "red"
    }

    for {role, hue} <- aliases do
      assert token(css, "--fl-color-#{role}") == "var(--fl-color-#{hue})"
    end

    for role <- ~w(primary secondary neutral success info warning danger dark light) do
      for suffix <- ["", "-on", "-on-soft", "-on-surface", "-soft", "-soft-border"] do
        assert token(css, "--fl-color-#{role}#{suffix}"),
               "expected --fl-color-#{role}#{suffix} in the theme"
      end
    end

    refute token(css, "--fl-color-primary-50")
    refute token(css, "--fl-color-danger-950")
  end

  test "the chrome ladder matches the documented percentages", %{css: css} do
    for {name, percent} <- [
          {"surface-subtle", "3%"},
          {"surface-strong", "6%"},
          {"border-subtle", "7%"},
          {"border", "10%"},
          {"border-strong", "18%"}
        ] do
      assert token(css, "--fl-color-#{name}") ==
               "color-mix(in oklab, var(--fl-surface-ink) #{percent}, var(--fl-color-surface))",
             "expected --fl-color-#{name} to use #{percent}"
    end

    raised = token(css, "--fl-color-surface-raised")

    assert raised =~ "calc(100% - var(--fl-surface-page-tint))"
    assert raised =~ "calc(12% + var(--fl-surface-page-lift))"
  end

  test "text tiers derive from one anchor", %{css: css} do
    assert token(css, "--fl-text-base")
    assert token(css, "--fl-color-text") == "var(--fl-text-base)"

    for tier <- ~w(text-highlighted text-toned text-muted text-dimmed) do
      assert token(css, "--fl-color-#{tier}") =~ "--fl-text-base"
    end
  end

  test "controls expose public color inputs only", %{css: css} do
    for input <- ~w(
          --fl-control-color
          --fl-control-color-content
          --fl-control-text
          --fl-control-soft
          --fl-control-soft-text
          --fl-control-soft-border
        ) do
      assert token(css, input), "expected #{input} in the control primitive"
    end

    assert token(css, "--fl-focus-ring-color") =~ "var(--fl-color-"
    refute token(css, "--fl-focus-ring-color") =~ "--fl-control-color"

    refute css =~ "--_fl-button-"
    refute css =~ "--_fl-toggle-"
    refute css =~ "--fl-button-surface"
    refute css =~ "--fl-toggle-surface"
  end

  test "responsive parts use the shared breakpoint scale", %{css: css} do
    for {_name, width} <- FlintUI.Utilities.breakpoints() do
      {rem, _rest} = Float.parse(width)
      max = rem - 0.001

      assert css =~ "@media (min-width: #{width})" or
               css =~ "@media (max-width: #{max}rem)",
             "expected #{width} to appear in a component media query"
    end
  end

  defp token(css, name) do
    case Regex.run(~r/#{Regex.escape(name)}:\s*([^;]+);/, css) do
      [_, value] -> value |> String.replace(~r/\s+/, " ") |> String.trim()
      nil -> nil
    end
  end
end
