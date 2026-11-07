defmodule FlintUI.Styled.IndicatorTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:indicator, ~S'''
      def defaults(assigns) do
        ~H"""
        <.indicator label="3">
          <button id="anchor">Inbox</button>
        </.indicator>
        """
      end

      def positioned(assigns) do
        ~H"""
        <.indicator label="3" position="bottom-left" inset ring class="custom" id="indicator">
          <button id="anchor">Inbox</button>
        </.indicator>
        """
      end

      def badge_props(assigns) do
        ~H"""
        <.indicator label="12" variant="soft" color="info" size="lg" radius="md">
          <button id="anchor">Inbox</button>
        </.indicator>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.indicator label="3" color="#1D72FE">
          <button id="anchor">Inbox</button>
        </.indicator>
        """
      end

      def live(assigns) do
        ~H"""
        <.indicator label="3" badge_label="3 unread messages" status>
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

      def dot(assigns) do
        ~H"""
        <.indicator>
          <button id="anchor">Inbox</button>
        </.indicator>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp badge(document), do: LazyHTML.query(document, ~s([data-element="badge"]))
  defp badge_attr(document, name), do: LazyHTML.attribute(badge(document), name)

  test "renders the default notification badge", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :indicator)) == ["span"]
    assert attr(document, :indicator, "data-position") == ["top-right"]
    assert attr(document, :indicator, "data-inset") == []
    assert attr(document, :indicator, "data-ring") == []
    assert attr(document, :indicator, "data-indicator") == [""]

    assert badge_attr(document, "data-element") == ["badge"]
    assert badge_attr(document, "data-part") == ["root"]
    assert badge_attr(document, "data-variant") == ["solid"]
    assert badge_attr(document, "data-color") == ["error"]
    assert badge_attr(document, "data-size") == ["xs"]
    assert badge_attr(document, "data-radius") == ["full"]
    assert badge_attr(document, "aria-hidden") == ["true"]
    assert badge(document) |> LazyHTML.text() |> String.trim() == "3"
  end

  test "maps position, inset, and ring onto the root", %{wrapper: wrapper} do
    document = render(wrapper, :positioned)

    assert attr(document, :indicator, "data-position") == ["bottom-left"]
    assert attr(document, :indicator, "data-inset") == [""]
    assert attr(document, :indicator, "data-ring") == [""]
    assert attr(document, :indicator, "class") == ["custom"]
    assert attr(document, :indicator, "id") == ["indicator"]
  end

  test "forwards the badge props to the nested badge", %{wrapper: wrapper} do
    document = render(wrapper, :badge_props)

    assert badge_attr(document, "data-variant") == ["soft"]
    assert badge_attr(document, "data-color") == ["info"]
    assert badge_attr(document, "data-size") == ["lg"]
    assert badge_attr(document, "data-radius") == ["md"]
    assert badge(document) |> LazyHTML.text() |> String.trim() == "12"
  end

  test "expands a raw color into the badge inputs on the root", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)

    assert badge_attr(document, "data-color") == []
    assert attr(document, :indicator, "style") |> List.first() =~ "--fl-badge-color: #1D72FE"
  end

  test "exposes a live badge with its accessible name", %{wrapper: wrapper} do
    document = render(wrapper, :live)

    assert badge_attr(document, "role") == ["status"]
    assert badge_attr(document, "aria-label") == ["3 unread messages"]
    assert badge_attr(document, "aria-hidden") == []
  end

  test "keeps the anchor and chooses the root element", %{wrapper: wrapper} do
    document = render(wrapper, :as_div)

    assert LazyHTML.tag(root(document, :indicator)) == ["div"]
    assert LazyHTML.query(document, "#anchor") |> LazyHTML.text() |> String.trim() == "Inbox"
  end

  test "renders a dot when the label is omitted", %{wrapper: wrapper} do
    document = render(wrapper, :dot)

    assert badge(document) |> LazyHTML.text() |> String.trim() == ""
    assert badge_attr(document, "data-radius") == ["full"]
    assert badge_attr(document, "aria-hidden") == ["true"]
  end
end
