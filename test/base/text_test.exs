defmodule FlintUI.Base.TextTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def defaults(assigns) do
      ~H"""
      <.text id="intro" class="base-class" data-test="text">
        Body copy
      </.text>
      """
    end

    def inline(assigns) do
      ~H"""
      <.text as="span">Inline text</.text>
      """
    end

    def link(assigns) do
      ~H"""
      <.text href="/pricing" class="link-class" data-test="link">View pricing</.text>
      """
    end

    def navigate(assigns) do
      ~H"""
      <.text navigate="/settings">Settings</.text>
      """
    end

    def trailing(assigns) do
      ~H"""
      <.text href="/docs">
        Read the docs
        <:trailing><span data-test="arrow">↗</span></:trailing>
      </.text>
      """
    end
  end

  defp render(fun), do: render_component(fun, %{}) |> LazyHTML.from_fragment()
  defp root(document), do: LazyHTML.query(document, ~s([data-element="text"]))
  defp root_attr(document, name), do: LazyHTML.attribute(root(document), name)

  test "renders a paragraph by default" do
    document = render(&TestComponent.defaults/1)

    assert LazyHTML.tag(root(document)) == ["p"]
    assert root_attr(document, "data-part") == ["root"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "Body copy"
  end

  test "forwards global attributes to the text root" do
    document = render(&TestComponent.defaults/1)

    assert root_attr(document, "id") == ["intro"]
    assert root_attr(document, "class") == ["base-class"]
    assert root_attr(document, "data-test") == ["text"]
  end

  test "renders the requested element through as" do
    document = render(&TestComponent.inline/1)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "Inline text"
  end

  test "renders a native link when an href is given" do
    document = render(&TestComponent.link/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert root_attr(document, "href") == ["/pricing"]
    assert root_attr(document, "class") == ["link-class"]
    assert root_attr(document, "data-test") == ["link"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "View pricing"
  end

  test "renders a native link for navigate" do
    document = render(&TestComponent.navigate/1)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert root_attr(document, "href") == ["/settings"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "Settings"
  end

  test "renders the trailing slot inside the link" do
    document = render(&TestComponent.trailing/1)
    trailing = LazyHTML.query(document, ~s([data-element="text"] [data-part="trailing"]))

    assert LazyHTML.tag(root(document)) == ["a"]
    assert LazyHTML.attribute(trailing, "data-part") == ["trailing"]
    assert LazyHTML.text(trailing) |> String.trim() == "↗"

    link_text = root(document) |> LazyHTML.text()
    assert link_text =~ "Read the docs"
    assert link_text =~ "↗"
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :text, type: :typography, status: :draft} =
             FlintUI.Base.Text.meta()

    assert [:root, :trailing] == FlintUI.Base.Text.parts_attrs() |> Enum.map(&elem(&1, 0))
  end
end
