defmodule FlintUI.Styled.TextTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:text, ~S'''
      def defaults(assigns) do
        ~H"""
        <.text>Body copy</.text>
        """
      end

      def inline(assigns) do
        ~H"""
        <.text as="span" size="xl" color="toned" weight="semibold" align="center">
          Inline text
        </.text>
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

      def truncate(assigns) do
        ~H"""
        <.text truncate>Truncated text</.text>
        """
      end

      def clamp(assigns) do
        ~H"""
        <.text line_clamp={2} truncate>Clamped text</.text>
        """
      end

      def raw(assigns) do
        ~H"""
        <.text color="#1D72FE">Raw color</.text>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders a paragraph with the default hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :text)) == ["p"]
    assert attr(document, :text, "data-part") == ["root"]
    assert attr(document, :text, "data-typography") == [""]
    assert attr(document, :text, "data-size") == ["md"]
    assert attr(document, :text, "data-color") == ["default"]
    assert attr(document, :text, "data-weight") == ["normal"]
    assert attr(document, :text, "data-align") == ["start"]
    assert attr(document, :text, "data-truncate") == []
    assert attr(document, :text, "data-line-clamp") == []
  end

  test "maps the size, color, weight, and align props", %{wrapper: wrapper} do
    document = render(wrapper, :inline)

    assert LazyHTML.tag(root(document, :text)) == ["span"]
    assert attr(document, :text, "data-size") == ["xl"]
    assert attr(document, :text, "data-color") == ["toned"]
    assert attr(document, :text, "data-weight") == ["semibold"]
    assert attr(document, :text, "data-align") == ["center"]
  end

  test "renders a link and forwards its attributes", %{wrapper: wrapper} do
    document = render(wrapper, :link)

    assert LazyHTML.tag(root(document, :text)) == ["a"]
    assert attr(document, :text, "href") == ["/pricing"]
    assert attr(document, :text, "class") == ["link-class"]
    assert attr(document, :text, "data-test") == ["link"]
    assert root(document, :text) |> LazyHTML.text() |> String.trim() == "View pricing"
  end

  test "renders a link for navigate", %{wrapper: wrapper} do
    document = render(wrapper, :navigate)

    assert LazyHTML.tag(root(document, :text)) == ["a"]
    assert attr(document, :text, "href") == ["/settings"]
  end

  test "truncate targets the root", %{wrapper: wrapper} do
    document = render(wrapper, :truncate)

    assert attr(document, :text, "data-truncate") == [""]
    assert attr(document, :text, "data-line-clamp") == []
  end

  test "line_clamp wins over truncate and writes the input", %{wrapper: wrapper} do
    document = render(wrapper, :clamp)

    assert attr(document, :text, "data-line-clamp") == ["2"]
    assert attr(document, :text, "data-truncate") == []
    assert attr(document, :text, "style") |> Enum.join() =~ "--fl-text-line-clamp: 2"
  end

  test "raw colors write the typography input instead of a hook", %{wrapper: wrapper} do
    document = render(wrapper, :raw)

    assert attr(document, :text, "data-color") == []
    assert attr(document, :text, "style") |> Enum.join() =~ "--fl-typography-color:"
  end
end
