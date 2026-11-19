defmodule FlintUI.Styled.HeadingTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:heading, ~S'''
      def defaults(assigns) do
        ~H"""
        <.heading>Release notes</.heading>
        """
      end

      def full(assigns) do
        ~H"""
        <.heading
          as="h1"
          size="6xl"
          color="primary"
          weight="bold"
          align="center"
          id="release-title"
          class="max-w-xl"
          style="margin-top: 2rem"
          data-test="heading"
        >
          <:kicker>Changelog</:kicker>
          Release notes
          <:subtitle>Everything new.</:subtitle>
        </.heading>
        """
      end

      def levels(assigns) do
        ~H"""
        <.heading as="h1">One</.heading>
        <.heading as="h3">Three</.heading>
        <.heading as="h6">Six</.heading>
        """
      end

      def truncate(assigns) do
        ~H"""
        <.heading truncate>Truncated title</.heading>
        """
      end

      def clamp(assigns) do
        ~H"""
        <.heading line_clamp={3} truncate>Clamped title</.heading>
        """
      end

      def custom_clamp(assigns) do
        ~H"""
        <.heading line_clamp={10}>Long title</.heading>
        """
      end

      def raw(assigns) do
        ~H"""
        <.heading color="#1D72FE">Raw color</.heading>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the default hooks and auto size for an h2", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :heading)) == ["div"]
    assert attr(document, :heading, "data-part") == ["root"]
    assert attr(document, :heading, "data-typography") == [""]
    assert attr(document, :heading, "data-size") == ["4xl"]
    assert attr(document, :heading, "data-color") == ["highlighted"]
    assert attr(document, :heading, "data-weight") == ["semibold"]
    assert attr(document, :heading, "data-align") == ["start"]
    assert attr(document, :heading, "data-truncate") == []
    assert attr(document, :heading, "data-line-clamp") == []

    assert LazyHTML.tag(part(document, "heading")) == ["h2"]
    assert part_attr(document, "heading", "data-level") == ["h2"]
  end

  test "maps every styled prop and keeps class/style on the root", %{wrapper: wrapper} do
    document = render(wrapper, :full)

    assert attr(document, :heading, "data-size") == ["6xl"]
    assert attr(document, :heading, "data-color") == ["primary"]
    assert attr(document, :heading, "data-weight") == ["bold"]
    assert attr(document, :heading, "data-align") == ["center"]
    assert attr(document, :heading, "class") == ["max-w-xl"]
    assert attr(document, :heading, "style") == ["margin-top: 2rem"]

    assert part_attr(document, "heading", "id") == ["release-title"]
    assert part_attr(document, "heading", "data-test") == ["heading"]
    assert part_attr(document, "heading", "class") == []

    assert part(document, "kicker") |> LazyHTML.text() |> String.trim() == "Changelog"
    assert part(document, "subtitle") |> LazyHTML.text() |> String.trim() == "Everything new."
  end

  test "resolves auto size from the semantic level", %{wrapper: wrapper} do
    document = render(wrapper, :levels)

    assert attr(document, :heading, "data-size") == ["5xl", "3xl", "lg"]

    assert LazyHTML.query(document, ~s([data-part="heading"][data-level="h1"]))
           |> LazyHTML.tag() == ["h1"]

    assert LazyHTML.query(document, ~s([data-part="heading"][data-level="h3"]))
           |> LazyHTML.tag() == ["h3"]

    assert LazyHTML.query(document, ~s([data-part="heading"][data-level="h6"]))
           |> LazyHTML.tag() == ["h6"]
  end

  test "truncate targets the title hook", %{wrapper: wrapper} do
    document = render(wrapper, :truncate)

    assert attr(document, :heading, "data-truncate") == [""]
    assert attr(document, :heading, "data-line-clamp") == []
  end

  test "line_clamp wins over truncate and writes the input", %{wrapper: wrapper} do
    document = render(wrapper, :clamp)

    assert attr(document, :heading, "data-line-clamp") == ["3"]
    assert attr(document, :heading, "data-truncate") == []
    assert attr(document, :heading, "style") |> Enum.join() =~ "--fl-heading-line-clamp: 3"
  end

  test "a custom line clamp count writes the same input", %{wrapper: wrapper} do
    document = render(wrapper, :custom_clamp)

    assert attr(document, :heading, "data-line-clamp") == ["10"]
    assert attr(document, :heading, "style") |> Enum.join() =~ "--fl-heading-line-clamp: 10"
  end

  test "raw colors write the typography input instead of a hook", %{wrapper: wrapper} do
    document = render(wrapper, :raw)

    assert attr(document, :heading, "data-color") == []
    assert attr(document, :heading, "style") |> Enum.join() =~ "--fl-typography-color:"
  end
end
