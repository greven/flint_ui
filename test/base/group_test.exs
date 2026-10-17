defmodule FlintUI.Base.GroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.group>
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.group>
      """
    end

    def vertical(assigns) do
      ~H"""
      <.group orientation="vertical">
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.group>
      """
    end

    def labelled(assigns) do
      ~H"""
      <.group label="Text formatting">
        <.button>Copy</.button>
      </.group>
      """
    end

    def toolbar(assigns) do
      ~H"""
      <.group role="toolbar" label="Text formatting" orientation="vertical">
        <.button>Copy</.button>
      </.group>
      """
    end

    def as_section(assigns) do
      ~H"""
      <.group as="section" label="Tools">
        <.button>Copy</.button>
      </.group>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="group"]))

  test "renders a root container with the group hooks" do
    document = render(&TestComponent.plain/1)
    root = root(document)

    assert LazyHTML.attribute(root, "data-element") == ["group"]
    assert LazyHTML.attribute(root, "data-orientation") == ["horizontal"]
    assert LazyHTML.tag(root) == ["div"]
  end

  test "reports a vertical orientation" do
    document = render(&TestComponent.vertical/1)

    assert root(document) |> LazyHTML.attribute("data-orientation") == ["vertical"]
  end

  test "is a plain container with no role by default" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.attribute(root, "role") == []
    assert LazyHTML.attribute(root, "aria-label") == []
  end

  test "a label exposes a named group" do
    root = root(render(&TestComponent.labelled/1))

    assert LazyHTML.attribute(root, "role") == ["group"]
    assert LazyHTML.attribute(root, "aria-label") == ["Text formatting"]
  end

  test "an explicit role wins over the labelled default" do
    root = root(render(&TestComponent.toolbar/1))

    assert LazyHTML.attribute(root, "role") == ["toolbar"]
    assert LazyHTML.attribute(root, "aria-label") == ["Text formatting"]
  end

  test "chooses the root element with the as attribute" do
    document = render(&TestComponent.as_section/1)

    assert LazyHTML.tag(root(document)) == ["section"]
  end

  test "declares its element type and documented parts" do
    assert %FlintUI.Meta{name: :group, type: :element, status: :draft} = FlintUI.Base.Group.meta()

    parts = FlintUI.Base.Group.parts_attrs()
    assert parts.root |> Enum.any?(&(&1.name == "[data-element]"))
    assert parts.root |> Enum.any?(&(&1.name == "[data-orientation]"))
  end
end
