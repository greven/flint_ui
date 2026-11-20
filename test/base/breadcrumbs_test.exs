defmodule FlintUI.Base.BreadcrumbsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.breadcrumbs>
        <.breadcrumbs_item navigate="/">Home</.breadcrumbs_item>
        <.breadcrumbs_item navigate="/blog">Blog</.breadcrumbs_item>
        <.breadcrumbs_item current>Post</.breadcrumbs_item>
      </.breadcrumbs>
      """
    end

    def labelled(assigns) do
      ~H"""
      <.breadcrumbs label="You are here">
        <.breadcrumbs_item navigate="/">Home</.breadcrumbs_item>
      </.breadcrumbs>
      """
    end

    def linked_current(assigns) do
      ~H"""
      <.breadcrumbs>
        <.breadcrumbs_item href="/post" current>Post</.breadcrumbs_item>
      </.breadcrumbs>
      """
    end

    def with_dropdown(assigns) do
      ~H"""
      <.breadcrumbs>
        <.breadcrumbs_item>
          <button type="button">More</button>
        </.breadcrumbs_item>
      </.breadcrumbs>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="breadcrumbs"]))
  defp items(document), do: LazyHTML.query(document, ~s([data-element="breadcrumbs_item"]))
  defp count(document), do: document |> items() |> Enum.count()

  defp item_at(document, index) do
    LazyHTML.query(document, ~s|[data-element="breadcrumbs_item"]:nth-child(#{index + 1})|)
  end

  defp item_attr(document, index, name) do
    document |> item_at(index) |> LazyHTML.attribute(name)
  end

  defp content(document, index) do
    LazyHTML.query(
      document,
      ~s|[data-element="breadcrumbs_item"]:nth-child(#{index + 1}) [data-part="content"]|
    )
  end

  test "renders a labelled navigation landmark around an ordered list" do
    document = render(&TestComponent.plain/1)
    root = root(document)

    assert LazyHTML.tag(root) == ["nav"]
    assert LazyHTML.attribute(root, "aria-label") == ["Breadcrumb"]

    list = LazyHTML.query(root, ~s([data-part="list"]))
    assert LazyHTML.tag(list) == ["ol"]
    assert count(document) == 3
    assert Enum.all?(0..2, &(document |> item_at(&1) |> LazyHTML.tag() == ["li"]))
  end

  test "the label names the navigation landmark" do
    root = root(render(&TestComponent.labelled/1))

    assert LazyHTML.attribute(root, "aria-label") == ["You are here"]
  end

  test "a destination renders a link and plain text renders a container" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(content(document, 0)) == ["a"]
    assert LazyHTML.attribute(content(document, 0), "data-part") == ["content"]
    assert LazyHTML.tag(content(document, 2)) == ["span"]
    assert LazyHTML.text(content(document, 2)) |> String.trim() == "Post"
  end

  test "the current crumb marks its content with aria-current" do
    document = render(&TestComponent.plain/1)

    assert item_attr(document, 2, "data-current") == [""]
    assert LazyHTML.attribute(content(document, 2), "aria-current") == ["page"]
    assert item_attr(document, 0, "data-current") == []
    assert LazyHTML.attribute(content(document, 0), "aria-current") == []
  end

  test "a current link keeps link semantics and adds aria-current" do
    document = render(&TestComponent.linked_current/1)
    content = content(document, 0)

    assert LazyHTML.tag(content) == ["a"]
    assert LazyHTML.attribute(content, "href") == ["/post"]
    assert LazyHTML.attribute(content, "aria-current") == ["page"]
  end

  test "renders an aria-hidden separator part before each crumb" do
    document = render(&TestComponent.plain/1)

    for index <- 0..2 do
      item = item_at(document, index)
      separator = LazyHTML.query(item, ~s([data-part="separator"]))

      assert LazyHTML.attribute(separator, "aria-hidden") == ["true"]
      assert LazyHTML.text(separator) |> String.trim() == ""
    end
  end

  test "a crumb without a destination exposes arbitrary content" do
    document = render(&TestComponent.with_dropdown/1)
    content = content(document, 0)

    assert LazyHTML.tag(content) == ["div"]
    assert LazyHTML.query(content, "button") |> LazyHTML.text() |> String.trim() == "More"
    assert LazyHTML.attribute(content, "aria-current") == []
  end

  test "declares its type and documented parts" do
    assert %FlintUI.Meta{name: :breadcrumbs, type: :navigation, status: :draft} =
             FlintUI.Base.Breadcrumbs.meta()

    assert %FlintUI.Meta{name: :breadcrumbs_item, type: :navigation, status: :draft} =
             FlintUI.Base.BreadcrumbsItem.meta()

    parts = FlintUI.Base.BreadcrumbsItem.parts_attrs()
    assert parts[:root] |> Enum.any?(&(&1.name == "[data-current]"))
    assert parts[:separator] |> Enum.any?(&(&1.name == "aria-hidden"))
    assert parts[:content] |> Enum.any?(&(&1.name == "aria-current"))
  end
end
