defmodule FlintUI.StyledTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled
  alias FlintUI.Styled.{Entry, Prop, Slot}

  test "names/0 covers every component that ships a styled entry" do
    assert Enum.sort(Styled.names()) ==
             Enum.sort([:button, :card, :collapsible, :group, :icon, :loading, :toggle])
  end

  test "every entry is valid" do
    assert Styled.validate_all() == :ok
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
    assert variant.values == ["subtle", "solid", "outline", "ghost", "dashed", "link"]
    assert variant.default == "subtle"
    assert variant.default in variant.values

    color = Entry.prop(entry, :color)

    assert color.values == [
             "primary",
             "secondary",
             "success",
             "info",
             "warning",
             "error",
             "neutral"
           ]

    assert color.default == "neutral"

    size = Entry.prop(entry, :size)
    assert size.values == ["xs", "sm", "md", "lg", "xl"]
    assert size.default == "md"
  end

  test "props map to the data attribute hooks a wrapper sets" do
    entry = Styled.get(:button)

    assert Entry.hooks(entry) == %{
             variant: "data-variant",
             color: "data-color",
             size: "data-size",
             depth: "data-depth"
           }

    assert Prop.attribute(Entry.prop(entry, :variant)) == "data-variant"
    assert Prop.attribute(Entry.prop(entry, :color)) == "data-color"
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
end
