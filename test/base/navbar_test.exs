defmodule FlintUI.Base.NavbarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def items(assigns) do
      ~H"""
      <.navbar>
        <.navbar_item navigate="/">Home</.navbar_item>
        <.navbar_item navigate="/projects" active>Projects</.navbar_item>
        <.navbar_item>Soon</.navbar_item>
      </.navbar>
      """
    end

    def labelled(assigns) do
      ~H"""
      <.navbar label="Site">
        <.navbar_item href="https://example.com">Example</.navbar_item>
      </.navbar>
      """
    end

    def menu(assigns) do
      ~H"""
      <.navbar>
        <.navbar_menu label="Products">
          <.navbar_menu_item navigate="/products">Overview</.navbar_menu_item>
          <.navbar_menu_item navigate="/pricing" active>Pricing</.navbar_menu_item>
        </.navbar_menu>
      </.navbar>
      """
    end

    def open_menu(assigns) do
      ~H"""
      <.navbar>
        <.navbar_menu id="products-menu" label="Products" open active>
          <.navbar_menu_item navigate="/products">Overview</.navbar_menu_item>
        </.navbar_menu>
      </.navbar>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="navbar"]))
  defp items(document), do: LazyHTML.query(document, ~s([data-element="navbar_item"]))

  defp item_at(document, index),
    do: LazyHTML.query(document, ~s|[data-element="navbar_item"]:nth-child(#{index + 1})|)

  defp item_content(document, index) do
    LazyHTML.query(
      document,
      ~s|[data-element="navbar_item"]:nth-child(#{index + 1}) [data-part="content"]|
    )
  end

  test "renders a labelled navigation landmark around an unordered list" do
    document = render(&TestComponent.items/1)
    root = root(document)

    assert LazyHTML.tag(root) == ["nav"]
    assert LazyHTML.attribute(root, "aria-label") == ["Primary"]
    assert LazyHTML.attribute(root, "phx-hook") == ["FlintUI.Navbar"]
    assert [id] = LazyHTML.attribute(root, "id")
    assert id =~ ~r/^fl-navbar-/

    list = LazyHTML.query(root, ~s([data-part="list"]))
    assert LazyHTML.tag(list) == ["ul"]
    assert items(document) |> Enum.count() == 3
  end

  test "the label names the navigation landmark" do
    root = render(&TestComponent.labelled/1) |> root()

    assert LazyHTML.attribute(root, "aria-label") == ["Site"]
  end

  test "a destination renders a link and plain text renders a container" do
    document = render(&TestComponent.items/1)

    assert LazyHTML.tag(item_content(document, 0)) == ["a"]
    assert LazyHTML.attribute(item_content(document, 0), "href") == ["/"]
    assert LazyHTML.tag(item_content(document, 2)) == ["span"]
    assert LazyHTML.text(item_content(document, 2)) |> String.trim() == "Soon"
  end

  test "the active item marks its content with aria-current" do
    document = render(&TestComponent.items/1)

    assert item_at(document, 1) |> LazyHTML.attribute("data-active") == [""]
    assert LazyHTML.attribute(item_content(document, 1), "aria-current") == ["page"]

    assert item_at(document, 0) |> LazyHTML.attribute("data-active") == []
    assert LazyHTML.attribute(item_content(document, 0), "aria-current") == []
  end

  test "a menu is a disclosure with a hidden nested list" do
    document = render(&TestComponent.menu/1)
    menu = LazyHTML.query(document, ~s([data-element="navbar_menu"]))
    trigger = LazyHTML.query(menu, ~s([data-part="trigger"]))
    content = LazyHTML.query(menu, ~s([data-part="content"]))

    assert LazyHTML.tag(menu) == ["li"]
    assert LazyHTML.attribute(menu, "data-state") == ["closed"]

    assert LazyHTML.tag(trigger) == ["button"]
    assert LazyHTML.attribute(trigger, "type") == ["button"]
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["false"]

    assert LazyHTML.attribute(trigger, "aria-controls") == [
             LazyHTML.attribute(content, "id") |> List.first()
           ]

    assert LazyHTML.text(trigger) =~ "Products"

    assert LazyHTML.attribute(content, "hidden") == [""]
    assert LazyHTML.tag(LazyHTML.query(content, ~s([data-part="list"]))) == ["ul"]

    menu_items = LazyHTML.query(document, ~s([data-element="navbar_menu_item"]))
    assert Enum.count(menu_items) == 2

    pricing = LazyHTML.query(document, ~s|[data-element="navbar_menu_item"][data-active]|)
    assert LazyHTML.text(pricing) |> String.trim() == "Pricing"
  end

  test "an open menu renders expanded and visible" do
    document = render(&TestComponent.open_menu/1)
    menu = LazyHTML.query(document, ~s([data-element="navbar_menu"]))
    trigger = LazyHTML.query(menu, ~s([data-part="trigger"]))
    content = LazyHTML.query(menu, ~s([data-part="content"]))

    assert LazyHTML.attribute(menu, "data-state") == ["open"]
    assert LazyHTML.attribute(menu, "data-active") == [""]
    assert LazyHTML.attribute(menu, "id") == ["products-menu"]
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["true"]
    assert LazyHTML.attribute(content, "hidden") == []
    assert LazyHTML.attribute(content, "data-state") == ["open"]
  end

  test "declares its type and documented parts" do
    assert %FlintUI.Meta{name: :navbar, type: :navigation, status: :draft} =
             FlintUI.Base.Navbar.meta()

    assert %FlintUI.Meta{name: :navbar_menu, type: :navigation, status: :draft} =
             FlintUI.Base.NavbarMenu.meta()

    assert FlintUI.Base.NavbarItem.parts_attrs()[:root]
           |> Enum.any?(&(&1.name == "[data-active]"))

    assert FlintUI.Base.NavbarMenu.parts_attrs()[:trigger]
           |> Enum.any?(&(&1.name == "aria-expanded"))
  end
end
