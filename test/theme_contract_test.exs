defmodule FlintUI.ThemeContractTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled
  alias FlintUI.Styled.Prop

  # Props whose values are handled structurally rather than by a selector
  # (e.g. the loading shape is inherent to the SVG markup).
  @selector_exceptions [{:loading, :variant}]

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

  test "every registry token namespace is defined in the theme", %{css: css} do
    for entry <- Styled.entries(), namespace <- entry.tokens do
      assert css =~ "--fl-#{namespace}-",
             "expected flint.css to define --fl-#{namespace}-* (used by #{entry.name})"
    end
  end
end
