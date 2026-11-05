defmodule FlintUI.Styled.ToggleTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:toggle, ~S'''
      def defaults(assigns) do
        ~H"""
        <.toggle>Bold</.toggle>
        """
      end

      def configured(assigns) do
        ~H"""
        <.toggle
          pressed
          variant="outline"
          color="primary"
          size="lg"
          radius="full"
          depth={false}
          class="extra"
          data-role="test"
        >
          <:leading><span id="lead">L</span></:leading>
          Bold
          <:trailing><span id="trail">T</span></:trailing>
        </.toggle>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.toggle color="#1D72FE">Bold</.toggle>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :toggle)) == ["button"]
    assert attr(document, :toggle, "data-toggle") == [""]
    assert attr(document, :toggle, "data-variant") == ["solid"]
    assert attr(document, :toggle, "data-color") == ["neutral"]
    assert attr(document, :toggle, "data-size") == ["md"]
    assert attr(document, :toggle, "data-radius") == ["md"]
    assert attr(document, :toggle, "data-depth") == [""]
    assert attr(document, :toggle, "aria-pressed") == ["false"]
  end

  test "maps every override and renders the slots in order", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :toggle, "data-variant") == ["outline"]
    assert attr(document, :toggle, "data-color") == ["primary"]
    assert attr(document, :toggle, "data-size") == ["lg"]
    assert attr(document, :toggle, "data-radius") == ["full"]
    assert attr(document, :toggle, "data-depth") == []
    assert attr(document, :toggle, "aria-pressed") == ["true"]
    assert attr(document, :toggle, "class") == ["extra"]
    assert attr(document, :toggle, "data-role") == ["test"]

    text =
      document
      |> root(:toggle)
      |> LazyHTML.text()
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    assert text == "L Bold T"
    assert LazyHTML.query(document, ~s(#lead)) |> LazyHTML.text() == "L"
    assert LazyHTML.query(document, ~s(#trail)) |> LazyHTML.text() == "T"
  end

  test "a raw color sets the toggle public inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:toggle, "style") |> List.first()

    assert attr(document, :toggle, "data-color") == []
    assert style =~ "--fl-toggle-color: #1D72FE"
    assert style =~ "--fl-toggle-color-content:"
    assert style =~ "--fl-toggle-text: light-dark("
  end
end
