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
        # Forwarded props land on a nested element, so the wrapper writes them
        # into a hook map instead of the root template. Avatar, icon, and flag
        # sizes may pass through a helper that separates scale names from
        # numeric values.
        assert source =~ "data-size={@size}" or
                 source =~ "data-size={@data_size}" or
                 source =~ ~s("data-size" => assigns.size) or
                 source =~ ~s("data-size" => assigns.data_size) or
                 Regex.match?(~r/data-size=\{.*@(data_)?size.*\}/, source) or
                 Regex.match?(~r/"data-size" => .*assigns\.(data_)?size/, source)
      end
    end
  end

  test "button maps its variant and size props" do
    source = Generator.component_source(:button)

    assert source =~ "attr(:variant, :string"
    assert source =~ "values: ~w(solid soft subtle surface outline ghost link)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-dashed={@dashed}"
    assert source =~ "data-color={@data_color}"
    assert source =~ "data-size={@size}"
    assert source =~ "data-radius={@radius}"
    assert source =~ "data-pill={@pill}"
    assert source =~ "data-square={@square}"
    assert source =~ "data-wide={@wide}"
    assert source =~ "attr(:justify, :string"
    assert source =~ "values: ~w(start center end between)"
    assert source =~ "data-justify={@justify}"
    assert source =~ "data-depth={@depth}"
    assert source =~ "attr(:square, :boolean"
    assert source =~ "attr(:wide, :boolean"
    assert source =~ "attr(:depth, :boolean"
    assert source =~ "attr(:inset, :any"
    assert source =~ "data-inset={@inset}"
    assert source =~ "<FlintUI.button"
    assert source =~ "render_slot(@inner_block)"
    refute source =~ "to_string(@"
  end

  test "toggle maps its variant, size, radius, and depth props" do
    source = Generator.component_source(:toggle)

    assert source =~ "values: ~w(solid subtle surface outline ghost)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-dashed={@dashed}"
    assert source =~ "data-color={@data_color}"
    assert source =~ "data-size={@size}"
    assert source =~ "data-radius={@radius}"
    assert source =~ "data-pill={@pill}"
    assert source =~ "data-depth={@depth}"
    assert source =~ "attr(:depth, :boolean"
  end

  test "free-form color props omit the enum and resolve at runtime" do
    for name <- [:badge, :button, :toggle, :tabs, :loading, :loading_text] do
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
    for prop <- ~w(square wide depth) do
      assert source =~ "data-#{prop}={@#{prop}}"
      refute source =~ "data-#{prop}={to_string(@#{prop})}"
    end
  end

  test "card forwards its action, section, and footer slots" do
    source = Generator.component_source(:card)

    assert source =~
             "include: ~w(as orientation padded title_id href navigate patch replace method csrf_token target rel download hreflang referrerpolicy)"

    assert source =~ "attr(:body, :string"
    assert source =~ "values: ~w(solid soft strong ghost)"

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
    assert source =~ "attr(:justify, :string"
    assert source =~ "values: ~w(start center end between)"
    assert source =~ "data-grow={@grow}"
    assert source =~ "data-justify={@justify}"

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

    assert source =~ ~s{slot(:inner_block, doc: "The content of the button.")}

    assert source =~
             ~s{slot(:leading, doc: "Optional content rendered before the button's content.")}

    assert source =~
             ~s{slot(:trailing, doc: "Optional content rendered after the button's content.")}
  end

  test "wrapper slots relax inner_block only when content attrs can fill it" do
    assert %{required: false} =
             :button
             |> Generator.wrapper_slots()
             |> Enum.find(&(&1.name == :inner_block))

    assert %{required: true} =
             :toggle
             |> Generator.wrapper_slots()
             |> Enum.find(&(&1.name == :inner_block))

    # The indicator's offset input is read by the wrapper but cannot fill the
    # anchor slot, so the anchor stays required.
    assert %{required: true} =
             :indicator
             |> Generator.wrapper_slots()
             |> Enum.find(&(&1.name == :inner_block))
  end

  test "button declares content attributes separately from its data hooks" do
    source = Generator.component_source(:button)

    assert source =~ "attr(:icon, :string, default: nil"
    assert source =~ "attr(:text, :string, default: nil"
    assert source =~ ~s(<FlintUI.icon :if={@icon} name={@icon} />)
    assert source =~ "{render_slot(@inner_block) || @text}"
    refute source =~ "data-text"
    refute source =~ "data-icon={@icon}"
  end

  test "a base without extra attributes omits the rest include" do
    source = Generator.component_source(:kbd)

    assert source =~ "def kbd(assigns) do"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-size={@size}"

    assert source =~
             ~s{attr(:rest, :global, doc: "Additional HTML attributes, forwarded to the headless component.")}

    refute source =~ "include:"
  end

  test "badge maps its label props and forwards the polymorphic root" do
    source = Generator.component_source(:badge)

    assert source =~ "def badge(assigns) do"
    assert source =~ "data-badge"
    assert source =~ "attr(:variant, :string"
    assert source =~ "values: ~w(solid soft subtle surface outline ghost dot)"
    assert source =~ "default: \"subtle\""
    assert source =~ "data-dashed={@dashed}"
    assert source =~ "data-radius={@radius}"
    assert source =~ "data-pill={@pill}"
    assert source =~ "data-uppercase={@uppercase}"
    assert source =~ "attr(:uppercase, :boolean"
    refute source =~ "data-inset={@inset}"

    assert source =~
             "include: ~w(as href navigate patch replace method csrf_token target rel download hreflang referrerpolicy)"
  end

  test "assembles the theme from tokens, base rules, then each component part" do
    [first, second | _] = Generator.part_paths()
    assert first =~ "tokens.css"
    assert second =~ "base.css"
    assert List.last(Generator.part_paths()) =~ "focus.css"

    css = Generator.theme_source()
    assert css =~ "--fl-color-primary:"
    assert css =~ "--fl-focus-ring-color:"
    assert css =~ "--fl-focus-ring-alpha:"
    assert css =~ "--fl-focus-border-color:"
    assert css =~ "outline: var(--fl-focus-ring-width) var(--fl-focus-ring-style)"
    assert css =~ "@layer focus {"
    assert css =~ "border-color: var(--fl-focus-border-color, revert-layer);"
    assert css =~ ~s([data-focus="ring"])
    assert css =~ ~s([data-focus="outline"])
    assert css =~ ~s([data-focus="inset"])

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
    assert bridge =~ "--radius-full: var(--fl-radius-full);"
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
    assert bridge =~ "--background-color-subtle: var(--fl-color-surface-subtle);"
    assert bridge =~ "--background-color-strong: var(--fl-color-surface-strong);"
    refute bridge =~ "--background-color-control"
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

  test "the alert wrapper keeps the runtime intent icon names literal for Tailwind" do
    source = Generator.component_source(:alert)

    for intent <- ~w(neutral info success warning error) do
      assert source =~ FlintUI.Base.Alert.intent_icon(intent)
    end
  end

  test "accordion maps its layout props and duration" do
    source = Generator.component_source(:accordion)

    assert source =~ "attr(:variant, :string"
    assert source =~ "values: ~w(simple contained separated)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "attr(:surface, :string"
    assert source =~ "values: ~w(solid soft strong ghost)"
    assert source =~ "data-surface={@surface}"
    assert source =~ "data-indicator-position={@indicator_position}"
    assert source =~ "data-transition={@transition}"
    assert source =~ "attr(:duration, :integer"
  end

  test "accordion item keeps its permissive header and indicator slots" do
    source = Generator.component_source(:accordion_item)

    assert source =~ "slot(:header,"
    assert source =~ "slot(:indicator,"
    assert source =~ "slot(:panel, required: true"
    assert source =~ "validate_attrs: false"
    assert source =~ "Map.drop(header"
    assert source =~ "Map.get(panel, :class)"
  end

  test "separator maps its props and converts a numeric size" do
    source = Generator.component_source(:separator)

    assert source =~ "values: ~w(solid dashed dotted)"
    assert source =~ "values: ~w(subtle default strong)"
    assert source =~ "values: ~w(center start end)"
    assert source =~ "attr(:size, :any"
    assert source =~ "FlintUI.Styled.Size.scale(assigns.size)"
    assert source =~ "FlintUI.Styled.Size.style(assigns.size, \"--fl-separator-size\")"
    assert source =~ "data-size={@data_size}"
    assert source =~ "attr(:label, :string, default: nil"
    assert source =~ "attr(:icon, :string, default: nil"
    assert source =~ "{render_slot(@inner_block) || @label}"
    assert source =~ "<FlintUI.icon :if={@icon && is_nil(@label) && @inner_block == []}"
    assert source =~ "include: ~w(as decorative orientation)"
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
