defmodule FlintUI.Base.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.badge data-role="test">New</.badge>
      """
    end

    def as_div(assigns) do
      ~H"""
      <.badge as="div">3</.badge>
      """
    end

    def href(assigns) do
      ~H"""
      <.badge href="/releases">v1.2.0</.badge>
      """
    end

    def navigate(assigns) do
      ~H"""
      <.badge navigate="/releases">v1.2.0</.badge>
      """
    end

    def patch(assigns) do
      ~H"""
      <.badge patch="/releases?tab=notes">v1.2.0</.badge>
      """
    end

    def as_and_href(assigns) do
      ~H"""
      <.badge as="div" href="/releases">v1.2.0</.badge>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="badge"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)

  test "renders a span root by default" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert attr(document, "data-element") == ["badge"]
    assert attr(document, "data-part") == ["root"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "New"
  end

  test "chooses the root element with the as attribute" do
    document = render(&TestComponent.as_div/1)

    assert LazyHTML.tag(root(document)) == ["div"]
  end

  test "passes global attributes through" do
    document = render(&TestComponent.plain/1)

    assert attr(document, "data-role") == ["test"]
  end

  test "renders a link when href is given" do
    document = render(&TestComponent.href/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert attr(document, "href") == ["/releases"]
    assert attr(document, "data-element") == ["badge"]
  end

  test "renders a LiveView navigate link" do
    document = render(&TestComponent.navigate/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert attr(document, "href") == ["/releases"]
    assert attr(document, "data-phx-link") == ["redirect"]
  end

  test "renders a LiveView patch link" do
    document = render(&TestComponent.patch/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert attr(document, "data-phx-link") == ["patch"]
  end

  test "a link destination wins over as" do
    document = render(&TestComponent.as_and_href/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert attr(document, "href") == ["/releases"]
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :badge, type: :feedback, status: :draft} =
               FlintUI.Base.Badge.meta()

      parts = FlintUI.Base.Badge.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "badge"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:root], &(&1.name == "[data-part]"))
    end
  end
end
