defmodule FlintUI.Base.IndicatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.indicator label="3" data-role="test">
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def styled_badge(assigns) do
      ~H"""
      <.indicator
        label="3"
        badge_attrs={
          %{
            "data-variant" => "solid",
            "data-color" => "error",
            "data-size" => "xs",
            "data-pill" => true
          }
        }
      >
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def labelled_badge(assigns) do
      ~H"""
      <.indicator label="3" badge_label="3 unread messages">
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def status_badge(assigns) do
      ~H"""
      <.indicator label="3" badge_label="3 unread messages" status>
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def dot(assigns) do
      ~H"""
      <.indicator>
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def blank_label(assigns) do
      ~H"""
      <.indicator label="   ">
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end

    def as_div(assigns) do
      ~H"""
      <.indicator as="div" label="3">
        <button id="anchor">Inbox</button>
      </.indicator>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="indicator"]))

  defp badge(document),
    do: LazyHTML.query(document, ~s([data-part="badge"] [data-element="badge"]))

  defp attr(node, name), do: LazyHTML.attribute(node, name)

  test "renders a span root with the indicator hooks" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert attr(root(document), "data-element") == ["indicator"]
    assert attr(root(document), "data-part") == ["root"]
    assert attr(root(document), "data-role") == ["test"]
  end

  test "renders the anchor and a nested badge" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.query(document, "#anchor") |> LazyHTML.text() |> String.trim() == "Inbox"
    assert LazyHTML.tag(badge(document)) == ["span"]
    assert attr(badge(document), "data-element") == ["badge"]
    assert attr(badge(document), "data-part") == ["root"]
    assert attr(badge(document), "data-dot") == []
    assert badge(document) |> LazyHTML.text() |> String.trim() == "3"
  end

  test "the badge is decorative by default" do
    document = render(&TestComponent.plain/1)

    assert attr(badge(document), "aria-hidden") == ["true"]
    assert attr(badge(document), "role") == []
    assert attr(badge(document), "aria-label") == []
  end

  test "renders a dot when label is omitted" do
    document = render(&TestComponent.dot/1)

    assert badge(document) |> LazyHTML.text() |> String.trim() == ""
    assert attr(badge(document), "aria-hidden") == ["true"]
    assert attr(badge(document), "data-dot") == [""]
  end

  test "treats a whitespace-only label as a dot" do
    document = render(&TestComponent.blank_label/1)

    assert attr(badge(document), "data-dot") == [""]
  end

  test "spreads the nested badge hooks" do
    document = render(&TestComponent.styled_badge/1)

    assert attr(badge(document), "data-variant") == ["solid"]
    assert attr(badge(document), "data-color") == ["error"]
    assert attr(badge(document), "data-size") == ["xs"]
    assert attr(badge(document), "data-pill") == [""]
  end

  test "a badge_label exposes the badge as an image" do
    document = render(&TestComponent.labelled_badge/1)

    assert attr(badge(document), "role") == ["img"]
    assert attr(badge(document), "aria-label") == ["3 unread messages"]
    assert attr(badge(document), "aria-hidden") == []
  end

  test "status exposes the badge as a live region" do
    document = render(&TestComponent.status_badge/1)

    assert attr(badge(document), "role") == ["status"]
    assert attr(badge(document), "aria-label") == ["3 unread messages"]
    assert attr(badge(document), "aria-hidden") == []
  end

  test "chooses the root element with the as attribute" do
    document = render(&TestComponent.as_div/1)

    assert LazyHTML.tag(root(document)) == ["div"]
  end

  test "declares its type and documented parts" do
    assert %FlintUI.Meta{name: :indicator, type: :feedback, status: :draft} =
             FlintUI.Base.Indicator.meta()

    parts = FlintUI.Base.Indicator.parts_attrs()
    assert parts.root |> Enum.any?(&(&1.name == "[data-element]"))
    assert parts.badge |> Enum.any?(&(&1.name == "[data-part]"))
    assert parts.badge |> Enum.any?(&(&1.name == "[data-dot]"))
  end
end
