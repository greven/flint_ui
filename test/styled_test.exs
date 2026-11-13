defmodule FlintUI.StyledTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled
  alias FlintUI.Styled.{Entry, Prop, Slot}

  test "names/0 covers every component that ships a styled entry" do
    assert Enum.sort(Styled.names()) ==
             Enum.sort([
               :accordion,
               :accordion_item,
               :alert,
               :avatar,
               :avatar_group,
               :badge,
               :button,
               :card,
               :collapsible,
               :flag,
               :group,
               :icon,
               :indicator,
               :kbd,
               :loading,
               :loading_text,
               :tabs,
               :toggle
             ])
  end

  test "every entry is valid" do
    assert Styled.validate_all() == :ok
  end

  test "every public CSS variable is present in the component stylesheet" do
    for entry <- Styled.entries(), var <- entry.vars do
      css = File.read!(FlintUI.Generator.part_path(entry.css))

      assert css =~ var.name,
             "expected #{entry.name} to declare #{var.name} in #{entry.css}"
    end
  end

  test "each entry points at the matching headless base module" do
    for entry <- Styled.entries() do
      assert entry.base == FlintUI.API.component_module(entry.name)
      assert entry.install =~ "mix flint.add"
      assert is_binary(entry.target)
    end
  end

  test "get/1 returns the entry for a component" do
    entry = Styled.get(:button)
    assert %Entry{name: :button, base: FlintUI.Base.Button} = entry
    assert Styled.get(:nope) == nil
  end

  test "entry props carry values and a matching default" do
    entry = Styled.get(:button)

    variant = Entry.prop(entry, :variant)
    assert variant.values == ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"]
    assert variant.default == "surface"
    assert variant.default in variant.values

    color = Entry.prop(entry, :color)

    assert color.values == [
             "neutral",
             "info",
             "success",
             "warning",
             "error",
             "primary",
             "secondary"
           ]

    assert color.default == "neutral"

    size = Entry.prop(entry, :size)
    assert size.values == ["xs", "sm", "md", "lg", "xl"]
    assert size.default == "md"
  end

  test "color props list roles in the canonical docs order" do
    canonical = ~w(neutral info success warning error primary secondary)

    for entry <- Styled.entries(), color <- List.wrap(Entry.prop(entry, :color)) do
      values = Enum.reject(color.values, &(&1 == "inherit"))

      assert values == canonical,
             "expected #{entry.name}.color to follow #{inspect(canonical)}, got #{inspect(color.values)}"
    end
  end

  test "badge defaults to the subtle treatment" do
    entry = Styled.get(:badge)

    variant = Entry.prop(entry, :variant)
    assert variant.default == "subtle"
    assert "dot" in variant.values

    radius = Entry.prop(entry, :radius)
    assert radius.values == ["none", "xs", "sm", "md", "lg", "xl"]
    assert radius.default == "md"

    pill = Entry.prop(entry, :pill)
    assert Prop.boolean?(pill)
    assert pill.default == false

    uppercase = Entry.prop(entry, :uppercase)
    assert Prop.boolean?(uppercase)
    assert uppercase.default == false
  end

  test "every radius control uses the shared scale with a pill modifier" do
    for name <- [:badge, :button, :toggle] do
      entry = Styled.get(name)
      radius = Entry.prop(entry, :radius)
      pill = Entry.prop(entry, :pill)

      assert radius.values == ["none", "xs", "sm", "md", "lg", "xl"]
      assert radius.default == "md"
      assert Prop.boolean?(pill)
      assert pill.default == false
    end
  end

  test "raw color props declare the public inputs they populate" do
    for name <- [:alert, :avatar, :badge, :button, :toggle, :tabs, :loading, :loading_text] do
      entry = Styled.get(name)
      color = Entry.prop(entry, :color)

      assert color.allow_custom, "expected #{name}.color to allow raw colors"
      assert entry.color_vars != [], "expected #{name} to map its color inputs"
    end

    assert Entry.prop(Styled.get(:card), :color) == nil
  end

  test "content attributes stay out of the data hooks" do
    entry = Styled.get(:button)

    assert Enum.map(entry.content_attrs, & &1.name) == [:icon, :text]
    refute Map.has_key?(Entry.hooks(entry), :icon)
    refute Map.has_key?(Entry.hooks(entry), :text)
  end

  test "props map to the data attribute hooks a wrapper sets" do
    entry = Styled.get(:button)

    assert Entry.hooks(entry) == %{
             variant: "data-variant",
             dashed: "data-dashed",
             color: "data-color",
             size: "data-size",
             radius: "data-radius",
             pill: "data-pill",
             square: "data-square",
             wide: "data-wide",
             justify: "data-justify",
             depth: "data-depth",
             inset: "data-inset"
           }

    assert Prop.attribute(Entry.prop(entry, :variant)) == "data-variant"
    assert Prop.attribute(Entry.prop(entry, :color)) == "data-color"

    assert Prop.boolean?(Entry.prop(entry, :square))
    assert Prop.boolean?(Entry.prop(entry, :wide))
    assert Prop.multi?(Entry.prop(entry, :inset))
    refute Prop.multi?(Entry.prop(entry, :depth))
  end

  test "Prop.new/1 allows a false default for a multi prop" do
    assert %Prop{default: false} =
             Prop.new(name: :inset, values: ["top", "bottom"], default: false, multi: true)
  end

  test "Prop.new/1 allows a nil default for a custom prop" do
    assert %Prop{default: nil} =
             Prop.new(name: :color, values: ["neutral"], default: nil, allow_custom: true)
  end

  test "Prop.new/1 rejects a nil default for a non-custom prop" do
    assert_raise ArgumentError, fn ->
      Prop.new(name: :color, values: ["neutral"], default: nil)
    end
  end

  test "Prop.new/1 rejects a default outside its values" do
    assert_raise ArgumentError, fn ->
      Prop.new(name: :size, values: [:sm, :md], default: :xl)
    end
  end

  test "Prop.new/1 rejects missing fields" do
    assert_raise ArgumentError, fn -> Prop.new(name: :size) end
  end

  test "entry slots are Slot structs" do
    entry = Styled.get(:button)

    assert [%Slot{name: :leading}, %Slot{name: :trailing}] = entry.slots
    assert Enum.all?(entry.slots, &is_boolean(&1.required))
  end

  test "Slot.new/1 rejects missing fields" do
    assert_raise ArgumentError, fn -> Slot.new([]) end
  end

  test "related components are registered and never point at themselves" do
    for entry <- Styled.entries() do
      for name <- Entry.related(entry) do
        assert name in FlintUI.components()
        refute name == entry.name
      end
    end
  end

  test "dependencies are registered and never point at themselves" do
    for entry <- Styled.entries() do
      for name <- Entry.dependencies(entry) do
        assert name in FlintUI.components()
        refute name == entry.name
      end
    end
  end

  test "only related components can nest in the docs navigation" do
    for entry <- Styled.entries(), name <- Entry.nav_related(entry) do
      assert name in Entry.related(entry)
    end
  end

  test "avatar and avatar group are related, and only avatar owns the nav group" do
    avatar = Styled.get(:avatar)
    avatar_group = Styled.get(:avatar_group)

    assert Entry.related(avatar) == [:avatar_group]
    assert Entry.related(avatar_group) == [:avatar]
    assert Entry.nav_related(avatar) == [:avatar_group]
    assert Entry.nav_related(avatar_group) == []
  end

  test "button and toggle relate to group without making it a nav child" do
    button = Styled.get(:button)
    group = Styled.get(:group)
    toggle = Styled.get(:toggle)

    assert Entry.related(button) == [:group]
    assert Entry.related(group) == [:button, :toggle]
    assert Entry.related(toggle) == [:group]
    assert Entry.nav_related(button) == []
    assert Entry.nav_related(group) == []
    assert Entry.nav_related(toggle) == []
  end

  test "icon is a dependency of the components that render an icon shortcut" do
    expected_related = %{
      avatar: [:avatar_group],
      badge: [],
      button: [:group]
    }

    for {name, related} <- expected_related do
      entry = Styled.get(name)

      assert Entry.dependencies(entry) == [:icon]
      assert Entry.related(entry) == related
    end
  end

  test "loading and loading text are related" do
    assert Entry.related(Styled.get(:loading)) == [:loading_text]
    assert Entry.related(Styled.get(:loading_text)) == [:loading]
  end

  test "indicator depends on badge without relating to it" do
    indicator = Styled.get(:indicator)

    assert Entry.dependencies(indicator) == [:badge]
    assert Entry.related(indicator) == []
  end
end
