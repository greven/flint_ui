defmodule FlintUI.Base.HeadingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def defaults(assigns) do
      ~H"""
      <.heading id="release-title" class="base-class" data-test="heading">
        Release notes
      </.heading>
      """
    end

    def full(assigns) do
      ~H"""
      <.heading as="h1" id="release-title" aria-describedby="release-subtitle">
        <:kicker>Changelog</:kicker>
        Release notes
        <:subtitle>Everything new in this version.</:subtitle>
      </.heading>
      """
    end

    def levels(assigns) do
      ~H"""
      <.heading :for={level <- ~w(h1 h2 h3 h4 h5 h6)} as={level}>Level</.heading>
      """
    end
  end

  defp render(fun), do: render_component(fun, %{}) |> LazyHTML.from_fragment()
  defp root(document), do: LazyHTML.query(document, ~s([data-element="heading"]))
  defp root_attr(document, name), do: LazyHTML.attribute(root(document), name)
  defp part(document, name), do: LazyHTML.query(document, ~s([data-part="#{name}"]))

  defp part_attr(document, name, attribute),
    do: LazyHTML.attribute(part(document, name), attribute)

  test "renders an h2 in a root wrapper by default" do
    document = render(&TestComponent.defaults/1)

    assert root_attr(document, "data-part") == ["root"]
    assert LazyHTML.tag(root(document)) == ["div"]
    assert LazyHTML.tag(part(document, "heading")) == ["h2"]
    assert part_attr(document, "heading", "data-level") == ["h2"]
    assert part(document, "heading") |> LazyHTML.text() |> String.trim() == "Release notes"
  end

  test "puts global attributes on the native heading, not the wrapper" do
    document = render(&TestComponent.defaults/1)

    assert root_attr(document, "id") == []
    assert root_attr(document, "class") == []
    assert root_attr(document, "data-test") == []

    assert part_attr(document, "heading", "id") == ["release-title"]
    assert part_attr(document, "heading", "class") == ["base-class"]
    assert part_attr(document, "heading", "data-test") == ["heading"]
  end

  test "renders the kicker before the heading and the subtitle after it" do
    document = render(&TestComponent.full/1)
    html = LazyHTML.to_html(document)

    kicker = LazyHTML.text(part(document, "kicker")) |> String.trim()
    title = LazyHTML.text(part(document, "heading")) |> String.trim()
    subtitle = LazyHTML.text(part(document, "subtitle")) |> String.trim()

    assert kicker == "Changelog"
    assert title == "Release notes"
    assert subtitle == "Everything new in this version."

    assert :binary.match(html, "Changelog") < :binary.match(html, "Release notes")
    assert :binary.match(html, "Release notes") < :binary.match(html, "Everything new")
  end

  test "keeps the kicker and subtitle outside the heading element" do
    document = render(&TestComponent.full/1)

    assert LazyHTML.tag(part(document, "heading")) == ["h1"]
    assert LazyHTML.text(part(document, "heading")) |> String.trim() == "Release notes"
    assert part_attr(document, "heading", "aria-describedby") == ["release-subtitle"]

    assert part(document, "kicker") |> LazyHTML.text() |> String.trim() == "Changelog"

    assert part(document, "subtitle") |> LazyHTML.text() |> String.trim() ==
             "Everything new in this version."
  end

  test "renders every semantic level through as" do
    document = render(&TestComponent.levels/1)

    for level <- ~w(h1 h2 h3 h4 h5 h6) do
      assert LazyHTML.query(document, ~s([data-part="heading"][data-level="#{level}"]))
             |> LazyHTML.tag() == [level]
    end
  end

  test "sets data-element only on the root" do
    document = render(&TestComponent.full/1)

    assert root_attr(document, "data-element") == ["heading"]
    assert part_attr(document, "heading", "data-element") == []
  end

  test "declares a documented contract in DOM order" do
    assert %FlintUI.Meta{name: :heading, type: :typography, status: :draft} =
             FlintUI.Base.Heading.meta()

    assert [:root, :kicker, :heading, :subtitle] ==
             FlintUI.Base.Heading.parts_attrs() |> Enum.map(&elem(&1, 0))
  end
end
