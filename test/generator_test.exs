defmodule FlintUI.GeneratorTest do
  use ExUnit.Case, async: true

  alias FlintUI.{Generator, Styled}

  test "every registered component renders a wrapper source" do
    for name <- Styled.names() do
      source = Generator.component_source(name)
      entry = Styled.get(name)

      assert source =~ "def #{name}(assigns) do"

      if FlintUI.Styled.Entry.prop(entry, :size) do
        assert source =~ "data-size={@size}"
      end
    end
  end

  test "button maps its variant and size props" do
    source = Generator.component_source(:button)

    assert source =~ "attr(:variant, :string"
    assert source =~ "values: ~w(solid secondary outline ghost destructive link)"
    assert source =~ "data-variant={@variant}"
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

  test "assembles the theme from tokens then each component part" do
    [first | _] = Generator.part_paths()
    assert first =~ "tokens.css"

    css = Generator.theme_source()
    assert css =~ "--fl-color-primary:"

    for entry <- Styled.entries() do
      assert css =~ ~s([data-element="#{entry.name}"]),
             "expected the assembled theme to style #{entry.name}"
    end
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
