defmodule FlintUI.Base.ClusterTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.cluster>
        <span>Design</span>
        <span>Shipped</span>
      </.cluster>
      """
    end

    def list(assigns) do
      ~H"""
      <.cluster as="ul" aria-label="Statuses">
        <li>Design</li>
        <li>Shipped</li>
      </.cluster>
      """
    end

    def ordered(assigns) do
      ~H"""
      <.cluster as="ol" aria-label="Steps">
        <li>Design</li>
        <li>Shipped</li>
      </.cluster>
      """
    end

    def attributed(assigns) do
      ~H"""
      <.cluster
        id="statuses"
        role="group"
        aria-label="Statuses"
        class="custom"
        data-testid="cluster"
      >
        <span>Design</span>
      </.cluster>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="cluster"]))

  test "renders a plain root container with the cluster hooks" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.tag(root) == ["div"]
    assert LazyHTML.attribute(root, "data-element") == ["cluster"]
    assert LazyHTML.attribute(root, "data-part") == ["root"]
    assert LazyHTML.attribute(root, "data-list") == []
  end

  test "renders the inner block" do
    document = render(&TestComponent.plain/1)

    assert root(document) |> LazyHTML.text() |> String.split() == ["Design", "Shipped"]
  end

  test "is a generic container with no role by default" do
    root = root(render(&TestComponent.plain/1))

    assert LazyHTML.attribute(root, "role") == []
    assert LazyHTML.attribute(root, "aria-label") == []
  end

  test "renders the element chosen by as" do
    document = render(&TestComponent.list/1)

    assert LazyHTML.tag(root(document)) == ["ul"]
    assert root(document) |> LazyHTML.attribute("aria-label") == ["Statuses"]
    assert LazyHTML.tag(LazyHTML.query(document, "ul > li")) == ["li", "li"]
  end

  test "marks ul and ol roots for the list reset" do
    for fun <- [&TestComponent.list/1, &TestComponent.ordered/1] do
      document = render(fun)

      assert LazyHTML.attribute(root(document), "data-list") == [""]
    end
  end

  test "forwards rest attributes and classes" do
    document = render(&TestComponent.attributed/1)

    assert attr(document, "id") == ["statuses"]
    assert attr(document, "role") == ["group"]
    assert attr(document, "aria-label") == ["Statuses"]
    assert attr(document, "class") == ["custom"]
    assert attr(document, "data-testid") == ["cluster"]
  end

  defp attr(document, name) do
    document |> root() |> LazyHTML.attribute(name)
  end
end
