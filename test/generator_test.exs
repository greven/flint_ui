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
    assert source =~ "values: ~w(solid soft subtle outline dashed ghost link)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-color={@data_color}"
    assert source =~ "data-size={@size}"
    assert source =~ "data-square={@square}"
    assert source =~ "data-wide={@wide}"
    assert source =~ "data-depth={@depth}"
    assert source =~ "attr(:square, :boolean"
    assert source =~ "attr(:wide, :boolean"
    assert source =~ "attr(:depth, :boolean"
    assert source =~ "attr(:inset, :boolean"
    assert source =~ "data-inset={@inset}"
    assert source =~ "<FlintUI.button"
    assert source =~ "render_slot(@inner_block)"
    refute source =~ "to_string(@"
  end

  test "free-form color props omit the enum and resolve at runtime" do
    for name <- [:button, :toggle, :tabs, :loading, :loading_text] do
      source = Generator.component_source(name)

      assert source =~ "attr(:color, :string, default:"
      refute source =~ "attr(:color, :string, values:"
      assert source =~ "FlintUI.Styled.Color.apply"
      assert source =~ "data-color={@data_color}"
    end
  end

  test "boolean props are presence hooks, not string values" do
    source = Generator.component_source(:button)

    # `data-wide={@wide}` renders a bare attribute when true and omits it when
    # false, so there is never a `data-wide="false"` in the markup.
    for prop <- ~w(square wide depth inset) do
      assert source =~ "data-#{prop}={@#{prop}}"
      refute source =~ "data-#{prop}={to_string(@#{prop})}"
    end
  end

  test "card forwards its action, section, and footer slots" do
    source = Generator.component_source(:card)

    assert source =~ "include: ~w(as orientation padded title_id)"
    assert source =~ "attr(:body, :string"
    assert source =~ "values: ~w(solid soft accented ghost)"

    assert source =~
             "values: ~w(seamless inset flush divided separated separated-header separated-footer)"

    assert source =~ "data-body={@body}"

    assert source =~
             ~s{slot(:section, doc: "An additional body section rendered after the implicit first section.")}

    refute source =~ "attr(:divider, :boolean"
    refute source =~ "attr(:padded, :boolean"

    assert source =~ "<:section :for={section <- @section}>"
    assert source =~ "{render_slot(section)}"
    refute source =~ "divider={section[:divider]}"
    refute source =~ "padded={section[:padded]}"
    assert source =~ "<:footer>{render_slot(@footer)}</:footer>"
    refute source =~ "<:footer divider="
    assert source =~ "<:header_actions>{render_slot(@header_actions)}</:header_actions>"
    assert source =~ "<:footer_actions>{render_slot(@footer_actions)}</:footer_actions>"
  end

  test "collapsible forwards its trigger and content slots" do
    source = Generator.component_source(:collapsible)

    assert source =~ ~s{slot(:content, required: true, doc: "The content to show or hide.")}
    assert source =~ "slot(:trigger, required: true,"
    assert source =~ "render_slot(@trigger, attrs)"
  end

  test "tabs forwards custom triggers and panels" do
    source = Generator.component_source(:tabs)

    assert source =~ "attr(:custom, :boolean"
    assert source =~ "values: ~w(outlined segmented minimal)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-color={@data_color}"
    assert source =~ "data-size={@size}"
    assert source =~ "attr(:grow, :boolean"
    assert source =~ "attr(:align, :string"
    assert source =~ "values: ~w(start center end spaced)"
    assert source =~ "data-grow={@grow}"
    assert source =~ "data-align={@align}"

    assert source =~
             "include: ~w(id activation_mode change_event disabled fadable findable label loop orientation scrollable value)"

    assert source =~ "<:tab"
    assert source =~ ":let={attrs}"
    assert source =~ "{render_slot(tab, attrs)}"
    assert source =~ "<:panel"
    assert source =~ "focusable={Map.get(panel, :focusable, true)}"
  end

  test "button merges the base inner_block with its extra slots" do
    source = Generator.component_source(:button)

    assert source =~ ~s{slot(:inner_block, required: true, doc: "The content of the button.")}

    assert source =~
             ~s{slot(:leading, doc: "Optional content rendered before the button's content.")}

    assert source =~
             ~s{slot(:trailing, doc: "Optional content rendered after the button's content.")}
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
    assert bridge =~ "--text-color-highlighted: var(--fl-color-text-highlighted);"
    assert bridge =~ "--text-color-default: var(--fl-color-text);"
    assert bridge =~ "--text-color-toned: var(--fl-color-text-toned);"
    assert bridge =~ "--text-color-muted: var(--fl-color-text-muted);"
    assert bridge =~ "--text-color-dimmed: var(--fl-color-text-dimmed);"
    assert bridge =~ "--background-color-default: var(--fl-color-background);"
    assert bridge =~ "--background-color-muted: var(--fl-color-surface-muted);"
    assert bridge =~ "--background-color-accented: var(--fl-color-surface-accented);"
    assert bridge =~ "--background-color-control: var(--fl-color-control);"
    assert bridge =~ "--border-color-default: var(--fl-color-border);"
    assert bridge =~ "--divide-color-default: var(--fl-color-border);"
    assert bridge =~ "--ring-color-default: var(--fl-color-ring);"
    assert bridge =~ "--text-color-primary: var(--fl-color-primary-text);"
    assert bridge =~ "--text-color-primary-content: var(--fl-color-primary-content);"
    assert bridge =~ "--background-color-primary: var(--fl-color-primary);"
    refute bridge =~ "--color-foreground"
    refute bridge =~ "--text-color-soft"
    refute bridge =~ "--color-border:"
    refute bridge =~ "--color-disabled"
    refute bridge =~ "--color-input"
    assert bridge =~ "--shadow-base: var(--fl-shadow-base);"
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
