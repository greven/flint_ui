defmodule FlintUI.Base.StackTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.stack>
        <p>First</p>
        <p>Second</p>
      </.stack>
      """
    end

    def section(assigns) do
      ~H"""
      <.stack as="section" aria-labelledby="intro-title">
        <h2 id="intro-title">Intro</h2>
      </.stack>
      """
    end

    def attributed(assigns) do
      ~H"""
      <.stack
        id="actions"
        role="group"
        aria-label="Actions"
        class="custom"
        data-testid="stack"
      >
        <p>First</p>
      </.stack>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="stack"]))

  test "renders a plain root container with the stack hooks" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.tag(root) == ["div"]
    assert LazyHTML.attribute(root, "data-element") == ["stack"]
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
    assert root(document) |> LazyHTML.attribute("aria-labelledby") == ["intro-title"]
  end

  test "forwards rest attributes and classes" do
    document = render(&TestComponent.attributed/1)

    assert attr(document, "id") == ["actions"]
    assert attr(document, "role") == ["group"]
    assert attr(document, "aria-label") == ["Actions"]
    assert attr(document, "class") == ["custom"]
    assert attr(document, "data-testid") == ["stack"]
  end

  defp attr(document, name) do
    document |> root() |> LazyHTML.attribute(name)
  end
end
