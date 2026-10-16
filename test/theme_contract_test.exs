defmodule FlintUI.ThemeContractTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled
  alias FlintUI.Styled.Prop

  # Props whose values are handled structurally rather than by a selector
  # (e.g. the loading shape is inherent to the SVG markup).
  @selector_exceptions [{:loading, :variant}]

  @color_roles ~w(primary secondary neutral success info warning error)
  @color_shades ~w(50 100 200 300 400 500 600 700 800 900 950)

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "every registry entry points at an existing theme part", %{} do
    for entry <- Styled.entries() do
      assert entry.css, "expected #{entry.name} to declare a css part"

      path = FlintUI.Generator.part_path(entry.css)
      assert File.exists?(path), "expected theme part #{entry.css} to exist"
      assert File.read!(path) =~ ~s([data-element="#{entry.name}"])
    end
  end

  test "every registry prop value has a matching hook in flint.css", %{css: css} do
    for entry <- Styled.entries(),
        prop <- entry.props,
        value <- prop.values,
        {entry.name, prop.name} not in @selector_exceptions do
      selector = ~s([data-element="#{entry.name}"][#{Prop.attribute(prop)}="#{value}"])

      assert css =~ selector,
             "expected flint.css to style #{selector} (from #{entry.name}.#{prop.name})"
    end
  end

  test "every theme preset points at an existing part that selects its name", %{css: css} do
    for theme <- FlintUI.Theme.themes() do
      path = FlintUI.Generator.part_path(theme.css)
      assert File.exists?(path), "expected theme part #{theme.css} to exist"
      assert File.read!(path) =~ ~s([data-theme="#{theme.name}"])
      assert css =~ ~s([data-theme="#{theme.name}"])
    end
  end

  test "every semantic role ships a complete 50..950 scale", %{css: css} do
    for role <- @color_roles, shade <- @color_shades do
      assert css =~ "--fl-color-#{role}-#{shade}:",
             "expected --fl-color-#{role}-#{shade} in the theme"
    end
  end

  test "every per-component radius token a stylesheet uses is defined", %{css: css} do
    for entry <- Styled.entries() do
      source = File.read!(FlintUI.Generator.part_path(entry.css))

      if source =~ "--fl-#{entry.name}-radius" do
        assert css =~ "--fl-#{entry.name}-radius:",
               "expected --fl-#{entry.name}-radius to be defined for #{entry.name}"
      end
    end
  end

  test "every registry token namespace is defined in the theme", %{css: css} do
    for entry <- Styled.entries(), namespace <- entry.tokens do
      assert css =~ "--fl-#{namespace}-",
             "expected flint.css to define --fl-#{namespace}-* (used by #{entry.name})"
    end
  end
end
