defmodule FlintUI.Base.ContainerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.container>
        <p>First</p>
        <p>Second</p>
      </.container>
      """
    end

    def section(assigns) do
      ~H"""
      <.container
        as="section"
        id="intro"
        role="region"
        aria-labelledby="intro-title"
        class="custom"
        data-testid="container"
      >
        <h2 id="intro-title">Intro</h2>
      </.container>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="container"]))

  test "renders a plain root container with the container hooks" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.tag(root) == ["div"]
    assert LazyHTML.attribute(root, "data-element") == ["container"]
    assert LazyHTML.attribute(root, "data-part") == ["root"]
  end

  test "renders the inner block" do
    document = render(&TestComponent.plain/1)

    assert root(document) |> LazyHTML.text() |> String.split() == ["First", "Second"]
  end

  test "is a generic container with no role by default" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.attribute(root, "role") == []
    assert LazyHTML.attribute(root, "aria-label") == []
  end

  test "renders the element chosen by as" do
    document = render(&TestComponent.section/1)

    assert LazyHTML.tag(root(document)) == ["section"]
  end

  test "forwards rest attributes and classes" do
    document = render(&TestComponent.section/1)

    assert attr(document, "id") == ["intro"]
    assert attr(document, "role") == ["region"]
    assert attr(document, "aria-labelledby") == ["intro-title"]
    assert attr(document, "class") == ["custom"]
    assert attr(document, "data-testid") == ["container"]
  end

  defp attr(document, name) do
    document |> root() |> LazyHTML.attribute(name)
  end
end
