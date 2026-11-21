defmodule FlintUI.Theme.ContractTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled
  alias FlintUI.Styled.Prop

  @color_roles ~w(primary secondary neutral success info warning error dark light)
  @color_shades [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]
  @tone_values @color_roles ++ ~w(red orange yellow green cyan blue indigo purple pink gray)

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "every registry entry points at an existing theme part", %{} do
    for entry <- Styled.entries() do
      if entry.css do
        path = FlintUI.Generator.part_path(entry.css)
        assert File.exists?(path), "expected theme part #{entry.css} to exist"
        assert File.read!(path) =~ ~s([data-element="#{entry.name}"])
      else
        assert entry.primitives != [],
               "expected #{entry.name} to declare a css part or a primitive"

        for primitive <- entry.primitives do
          primitive = Styled.get_primitive(primitive)
          path = FlintUI.Generator.part_path(primitive.css)
          assert File.exists?(path), "expected primitive part #{primitive.css} to exist"
          assert File.read!(path) =~ "[#{primitive.marker}]"
        end
      end
    end
  end

  test "every non-default registry prop value has a matching hook in flint.css", %{css: css} do
    # The default value is the base treatment, so it may be expressed by the
    # absence of an override (e.g. `depth: true` or `inverted: false`).
    for entry <- Styled.entries(),
        prop <- entry.props,
        value <- prop.values,
        value != prop.default,
        value not in prop.resolved do
      selector = prop_selector(entry, prop, value)

      assert css =~ selector,
             "expected flint.css to style #{selector} (from #{entry.name}.#{prop.name})"
    end
  end

  # Boolean hooks are presence/absence: true adds the attribute, false removes
  # it, so there are no `="true"`/`="false"` selectors to match. A forwarded
  # prop is rendered on a nested component, so its selectors are checked against
  # that component's `data-element`.
  defp prop_selector(entry, prop, value) do
    cond do
      prop.name == :color and value in @tone_values ->
        ~s|:where([data-color="#{value}"])|

      prop.name == :active_color and value in @tone_values ->
        ~s|:where([data-active-color="#{value}"])|

      prop.name == :success_color and value in @tone_values ->
        ~s|:where([data-active-color="#{value}"])|

      true ->
        component_prop_selector(entry, prop, value)
    end
  end

  defp component_prop_selector(entry, prop, value) do
    root =
      cond do
        prop.primitive ->
          primitive = Styled.get_primitive(prop.primitive)
          "[#{primitive.marker}]"

        prop.forwarded_to ->
          ~s([data-element="#{prop.forwarded_to}"])

        true ->
          ~s([data-element="#{entry.name}"])
      end

    root = if prop.state, do: root <> ~s([data-state="#{prop.state}"]), else: root
    attribute = Prop.attribute(prop)

    cond do
      Prop.multi?(prop) -> ~s|#{root}[#{attribute}~="#{value}"]|
      not Prop.boolean?(prop) -> ~s|#{root}[#{attribute}="#{value}"]|
      value -> ~s|#{root}[#{attribute}]|
      true -> ~s|#{root}:not([#{attribute}])|
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

  test "every palette ships eighteen hues and a complete 50..950 scale" do
    for palette <- FlintUI.Palette.palettes(),
        hue <- FlintUI.Palette.hues(),
        shade <- @color_shades do
      shades = palette.module.shades(hue)

      assert Map.has_key?(shades, shade),
             "expected #{palette.name} to define #{hue}-#{shade}"
    end
  end

  test "every semantic role resolves the five tone tokens", %{css: css} do
    for role <- @color_roles, suffix <- ["", "-on", "-on-soft", "-soft", "-soft-border"] do
      assert css =~ "--fl-color-#{role}#{suffix}:",
             "expected --fl-color-#{role}#{suffix} in the theme"
    end
  end

  test "every palette hue has a color hook", %{css: css} do
    for hue <- FlintUI.Palette.hue_names() do
      assert css =~ ~s|:where([data-color="#{hue}"])|
      assert css =~ ~s|:where([data-active-color="#{hue}"])|
      assert css =~ "--fl-color-#{hue}:"
    end
  end

  test "components use the shared radius scale, not per-component radius tokens" do
    for entry <- Styled.entries(), entry.css do
      source = File.read!(FlintUI.Generator.part_path(entry.css))

      refute source =~ "--fl-#{entry.name}-radius",
             "#{entry.name} should read the shared radius scale"
    end
  end

  test "every registry token namespace is defined in the theme", %{css: css} do
    for entry <- Styled.entries(), namespace <- entry.tokens do
      assert css =~ "--fl-#{namespace}-",
             "expected flint.css to define --fl-#{namespace}-* (used by #{entry.name})"
    end
  end

  test "tinted alerts elevate the inherited tone for nested controls" do
    source = File.read!(FlintUI.Generator.part_path("styled/alert.css"))

    assert source =~ ~s([data-color] > *),
           "expected a tinted alert to elevate its nested tone"

    assert source =~ "--fl-tone-soft: color-mix(",
           "expected a tinted alert to elevate --fl-tone-soft"
  end
end
