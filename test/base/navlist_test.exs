defmodule FlintUI.Base.NavlistTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def items(assigns) do
      ~H"""
      <.navlist>
        <.navlist_item navigate="/docs">Overview</.navlist_item>
        <.navlist_item navigate="/docs/install" active>Install</.navlist_item>
        <.navlist_item>Soon</.navlist_item>
      </.navlist>
      """
    end

    def grouped(assigns) do
      ~H"""
      <.navlist label="Docs">
        <.navlist_group label="Guides">
          <.navlist_item navigate="/guides">Theming</.navlist_item>
          <.navlist_item navigate="/guides/icons">Icons</.navlist_item>
        </.navlist_group>
      </.navlist>
      """
    end

    def open_group(assigns) do
      ~H"""
      <.navlist>
        <.navlist_group id="guides-group" label="Guides" open>
          <.navlist_item navigate="/guides">Theming</.navlist_item>
        </.navlist_group>
      </.navlist>
      """
    end

    def static_group(assigns) do
      ~H"""
      <.navlist>
        <.navlist_group label="Overview" collapsible={false}>
          <.navlist_item navigate="/docs">Introduction</.navlist_item>
        </.navlist_group>
      </.navlist>
      """
    end

    def disabled_item(assigns) do
      ~H"""
      <.navlist>
        <.navlist_item navigate="/docs" disabled>Overview</.navlist_item>
      </.navlist>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="navlist"]))
  defp items(document), do: LazyHTML.query(document, ~s([data-element="navlist_item"]))

  defp group(document), do: LazyHTML.query(document, ~s([data-element="navlist_group"]))

  test "renders a labelled navigation landmark around an unordered list" do
    document = render(&TestComponent.items/1)
    root = root(document)

    assert LazyHTML.tag(root) == ["nav"]
    assert LazyHTML.attribute(root, "aria-label") == ["Navigation"]

    list = LazyHTML.query(root, ~s([data-part="list"]))
    assert LazyHTML.tag(list) == ["ul"]
    assert items(document) |> Enum.count() == 3
  end

  test "the label names the navigation landmark" do
    root = render(&TestComponent.grouped/1) |> root()

    assert LazyHTML.attribute(root, "aria-label") == ["Docs"]
  end

  test "a destination renders a link and plain text renders a container" do
    document = render(&TestComponent.items/1)

    content =
      LazyHTML.query(
        document,
        ~s|[data-element="navlist_item"]:nth-child(1) [data-part="content"]|
      )

    plain =
      LazyHTML.query(
        document,
        ~s|[data-element="navlist_item"]:nth-child(3) [data-part="content"]|
      )

    assert LazyHTML.tag(content) == ["a"]
    assert LazyHTML.attribute(content, "href") == ["/docs"]
    assert LazyHTML.tag(plain) == ["span"]
    assert LazyHTML.text(plain) |> String.trim() == "Soon"
  end

  test "the active item marks its content with aria-current" do
    document = render(&TestComponent.items/1)
    active = LazyHTML.query(document, ~s|[data-element="navlist_item"][data-active]|)

    assert LazyHTML.attribute(active, "data-active") == [""]

    assert LazyHTML.attribute(LazyHTML.query(active, ~s([data-part="content"])), "aria-current") ==
             [
               "page"
             ]
  end

  test "a collapsible group renders a button header and a hidden nested list" do
    document = render(&TestComponent.grouped/1)
    group = group(document)
    trigger = LazyHTML.query(group, ~s([data-part="trigger"]))
    content = LazyHTML.query(group, ~s([data-part="content"]))

    assert LazyHTML.attribute(group, "data-collapsible") == [""]
    assert LazyHTML.attribute(group, "data-state") == ["closed"]
    assert LazyHTML.tag(trigger) == ["button"]
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["false"]

    assert LazyHTML.attribute(trigger, "aria-controls") == [
             LazyHTML.attribute(content, "id") |> List.first()
           ]

    assert LazyHTML.text(trigger) =~ "Guides"
    assert LazyHTML.attribute(content, "hidden") == [""]
    assert LazyHTML.query(content, ~s([data-element="navlist_item"])) |> Enum.count() == 2
  end

  test "an open group renders expanded and visible" do
    document = render(&TestComponent.open_group/1)
    group = group(document)
    trigger = LazyHTML.query(group, ~s([data-part="trigger"]))
    content = LazyHTML.query(group, ~s([data-part="content"]))

    assert LazyHTML.attribute(group, "id") == ["guides-group"]
    assert LazyHTML.attribute(group, "data-state") == ["open"]
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["true"]
    assert LazyHTML.attribute(content, "hidden") == []
    assert LazyHTML.attribute(content, "data-state") == ["open"]
  end

  test "a static group renders a non-interactive header and visible content" do
    document = render(&TestComponent.static_group/1)
    group = group(document)
    header = LazyHTML.query(group, ~s([data-part="header"]))
    content = LazyHTML.query(group, ~s([data-part="content"]))

    assert LazyHTML.attribute(group, "data-static") == [""]
    assert LazyHTML.attribute(group, "data-collapsible") == []
    assert LazyHTML.attribute(group, "data-state") == []
    assert LazyHTML.tag(header) == ["div"]
    assert LazyHTML.attribute(header, "aria-expanded") == []
    assert LazyHTML.attribute(content, "hidden") == []
    assert LazyHTML.query(content, "button") |> Enum.count() == 0
  end

  test "a disabled item renders non-focusable text and drops its destination" do
    document = render(&TestComponent.disabled_item/1)
    item = LazyHTML.query(document, ~s([data-element="navlist_item"]))
    content = LazyHTML.query(item, ~s([data-part="content"]))

    assert LazyHTML.attribute(item, "data-disabled") == [""]
    assert LazyHTML.tag(content) == ["span"]
    assert LazyHTML.attribute(content, "href") == []
    assert LazyHTML.attribute(content, "aria-disabled") == ["true"]
  end

  test "declares its type and documented parts" do
    assert %FlintUI.Meta{name: :navlist, type: :navigation, status: :draft} =
             FlintUI.Base.Navlist.meta()

    assert %FlintUI.Meta{name: :navlist_group, type: :navigation, status: :draft} =
             FlintUI.Base.NavlistGroup.meta()

    assert FlintUI.Base.NavlistItem.parts_attrs()[:root]
           |> Enum.any?(&(&1.name == "[data-active]"))

    assert FlintUI.Base.NavlistItem.parts_attrs()[:content]
           |> Enum.any?(&(&1.name == "aria-disabled"))

    assert FlintUI.Base.NavlistItem.states()
           |> Enum.any?(&(&1.selector =~ ~s([data-disabled])))

    assert FlintUI.Base.NavlistGroup.parts_attrs()[:root]
           |> Enum.any?(&(&1.name in ["[data-collapsible]", "[data-static]"]))
  end
end
