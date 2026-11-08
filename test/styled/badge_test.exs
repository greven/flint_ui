defmodule FlintUI.Styled.BadgeTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:badge, ~S'''
      def defaults(assigns) do
        ~H"""
        <.badge>New</.badge>
        """
      end

      def content(assigns) do
        ~H"""
        <.badge as="div" icon="lucide-sparkles" text="Ignored" uppercase>
          <:leading><span id="lead">L</span></:leading>
          Beta
          <:trailing><span id="trail">T</span></:trailing>
        </.badge>
        """
      end

      def link(assigns) do
        ~H"""
        <.badge as="div" href="/releases">v1.2.0</.badge>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.badge color="#1D72FE">New</.badge>
        """
      end

      def dot(assigns) do
        ~H"""
        <.badge variant="dot" color="success">Online</.badge>
        """
      end

      def pill(assigns) do
        ~H"""
        <.badge pill>New</.badge>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the subtle defaults", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :badge)) == ["span"]
    assert attr(document, :badge, "data-variant") == ["subtle"]
    assert attr(document, :badge, "data-size") == ["md"]
    assert attr(document, :badge, "data-radius") == ["md"]
    assert attr(document, :badge, "data-pill") == []
    assert attr(document, :badge, "data-uppercase") == []
    assert attr(document, :badge, "data-wide") == []
    assert attr(document, :badge, "data-leading") == []
    assert attr(document, :badge, "data-trailing") == []
  end

  test "renders leading, icon, content, and trailing in order", %{wrapper: wrapper} do
    document = render(wrapper, :content)

    text =
      document
      |> root(:badge)
      |> LazyHTML.text()
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    assert LazyHTML.tag(root(document, :badge)) == ["div"]
    assert attr(document, :badge, "data-uppercase") == [""]
    assert attr(document, :badge, "data-leading") == [""]
    assert attr(document, :badge, "data-trailing") == [""]
    assert text == "L Beta T"
    refute text =~ "Ignored"
    assert LazyHTML.query(document, ~s(#lead)) |> LazyHTML.text() == "L"
    assert LazyHTML.query(document, ~s(#trail)) |> LazyHTML.text() == "T"

    assert LazyHTML.query(document, ~s(#lead + [data-element="icon"]))
           |> LazyHTML.attribute("class") == ["lucide-sparkles"]
  end

  test "a link destination wins over as", %{wrapper: wrapper} do
    document = render(wrapper, :link)

    assert LazyHTML.tag(root(document, :badge)) == ["a"]
    assert attr(document, :badge, "href") == ["/releases"]
  end

  test "a raw color sets the badge public inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:badge, "style") |> List.first()

    assert attr(document, :badge, "data-color") == []
    assert style =~ "--fl-badge-color: #1D72FE"
    assert style =~ "--fl-badge-color-content:"
    assert style =~ "--fl-badge-text: light-dark("
  end

  test "renders the dot variant with its role color", %{wrapper: wrapper} do
    document = render(wrapper, :dot)

    assert attr(document, :badge, "data-variant") == ["dot"]
    assert attr(document, :badge, "data-color") == ["success"]
    assert root(document, :badge) |> LazyHTML.text() |> String.trim() == "Online"
  end

  test "maps pill onto its own hook", %{wrapper: wrapper} do
    document = render(wrapper, :pill)

    assert attr(document, :badge, "data-pill") == [""]
  end
end
