defmodule FlintUI.GeneratorTest do
  use ExUnit.Case, async: true

  alias FlintUI.{Generator, Styled}

  test "every registered component renders a wrapper source" do
    for name <- Styled.names() do
      source = Generator.component_source(name)
      entry = Styled.get(name)

      assert source =~ "def #{name}(assigns) do"

      assert source =~ "data-#{name}"

      if FlintUI.Styled.Entry.prop(entry, :size) do
        assert source =~ "data-size={@size}"
      end
    end
  end

  test "button maps its variant and size props" do
    source = Generator.component_source(:button)

    assert source =~ "attr(:variant, :string"
    assert source =~ "values: ~w(solid subtle outline ghost dashed link)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-color={@color}"
    assert source =~ "data-size={@size}"
    assert source =~ "data-depth={to_string(@depth)}"
    assert source =~ "attr(:depth, :boolean"
    assert source =~ "<FlintUI.button"
    assert source =~ "render_slot(@inner_block)"
  end

  test "collapsible forwards its trigger and content slots" do
    source = Generator.component_source(:collapsible)

    assert source =~ ~s{slot(:content, required: true, doc: "The content to show or hide.")}
    assert source =~ "slot(:trigger, required: true,"
    assert source =~ "render_slot(@trigger, attrs)"
  end

  test "button merges the base inner_block with its extra slots" do
    source = Generator.component_source(:button)

    assert source =~ ~s{slot(:inner_block, required: true, doc: "The content of the button.")}
    assert source =~ ~s{slot(:leading, doc: "Optional content rendered before the label.")}
    assert source =~ ~s{slot(:trailing, doc: "Optional content rendered after the label.")}
  end

  test "assembles the theme from tokens, base rules, then each component part" do
    [first, second | _] = Generator.part_paths()
    assert first =~ "tokens.css"
    assert second =~ "base.css"

    css = Generator.theme_source()
    assert css =~ "--fl-color-primary:"
    assert css =~ "--fl-focus-ring-color:"
    assert css =~ "outline: var(--fl-focus-ring-width) solid var(--fl-focus-ring-color);"

    for theme <- FlintUI.Theme.themes() do
      assert css =~ ~s([data-theme="#{theme.name}"]),
             "expected the assembled theme to include the #{theme.name} preset"
    end

    for entry <- Styled.entries() do
      assert css =~ ~s([data-element="#{entry.name}"]),
             "expected the assembled theme to style #{entry.name}"
    end
  end

  test "tailwind bridge exposes role scales and radius" do
    bridge = Generator.tailwind_bridge_source()

    assert bridge =~ "@theme inline {"
    assert bridge =~ "--color-primary-50: var(--fl-color-primary-50);"
    assert bridge =~ "--color-error-950: var(--fl-color-error-950);"
    assert bridge =~ "--radius-md: var(--fl-radius-md);"
    assert bridge =~ "--font-sans: var(--fl-font-sans);"
    assert bridge =~ "--font-mono: var(--fl-font-mono);"
    assert bridge =~ "--spacing: var(--fl-spacing);"
    assert bridge =~ "--spacing-lg: var(--fl-spacing-lg);"
    assert bridge =~ "--text-sm: var(--fl-font-size-sm);"
    assert bridge =~ "--shadow-md: var(--fl-shadow-md);"
    assert bridge =~ "--ease-out: var(--fl-ease-out);"
  end

  test "writes the assembled theme to priv/static/flint.css idempotently" do
    assert Generator.aggregate_path() |> String.ends_with?("priv/static/flint.css")

    assert Generator.write_aggregate!() in [:ok, :noop]
    assert Generator.write_aggregate!() == :noop
    assert File.read!(Generator.aggregate_path()) == Generator.theme_source()
  end

  test "the combined generated module compiles" do
    functions =
      Styled.names()
      |> Enum.map_join("\n\n", &Generator.component_source/1)

    source = """
    defmodule FlintUI.GeneratedComponentsCompileTest do
      use Phoenix.Component

      #{functions}
    end
    """

    assert [{_module, _} | _] = Code.compile_string(source)
  end
end
