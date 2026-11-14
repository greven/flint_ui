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
          toggled
          variant="outline"
          active_variant="soft"
          color="primary"
          active_color="success"
          size="lg"
          pill
          square
          wide
          justify="end"
          depth={false}
          inset="top"
          class="extra"
          data-role="test"
        >
          <:leading><span id="lead">L</span></:leading>
          Bold
          <:trailing><span id="trail">T</span></:trailing>
        </.toggle>
        """
      end

      def inherit_active(assigns) do
        ~H"""
        <.toggle variant="soft" color="primary">Bold</.toggle>
        """
      end

      def state_slots(assigns) do
        ~H"""
        <.toggle variant="ghost" toggled>
          <:on><span id="on">Muted</span></:on>
          <:off><span id="off">Sound on</span></:off>
        </.toggle>
        """
      end

      def icon_and_text(assigns) do
        ~H"""
        <.toggle icon="lucide-letter-b" text="Bold" />
        """
      end

      def loading(assigns) do
        ~H"""
        <.toggle loading>Save</.toggle>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.toggle color="#1D72FE">Bold</.toggle>
        """
      end

      def raw_active_color(assigns) do
        ~H"""
        <.toggle color="primary" active_color="#1D72FE">Bold</.toggle>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :toggle)) == ["button"]
    assert attr(document, :toggle, "data-toggle") == [""]
    assert attr(document, :toggle, "data-variant") == ["ghost"]
    assert attr(document, :toggle, "data-active-variant") == ["soft"]
    assert attr(document, :toggle, "data-color") == ["neutral"]
    assert attr(document, :toggle, "data-active-color") == []
    assert attr(document, :toggle, "data-size") == ["md"]
    assert attr(document, :toggle, "data-radius") == ["md"]
    assert attr(document, :toggle, "data-pill") == []
    assert attr(document, :toggle, "data-square") == []
    assert attr(document, :toggle, "data-wide") == []
    assert attr(document, :toggle, "data-justify") == ["center"]
    assert attr(document, :toggle, "data-depth") == [""]
    assert attr(document, :toggle, "data-inset") == []
    assert attr(document, :toggle, "aria-pressed") == ["false"]
  end

  test "maps every override and renders the slots in order", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :toggle, "data-variant") == ["outline"]
    assert attr(document, :toggle, "data-active-variant") == ["soft"]
    assert attr(document, :toggle, "data-color") == ["primary"]
    assert attr(document, :toggle, "data-active-color") == ["success"]
    assert attr(document, :toggle, "data-size") == ["lg"]
    assert attr(document, :toggle, "data-pill") == [""]
    assert attr(document, :toggle, "data-square") == [""]
    assert attr(document, :toggle, "data-wide") == [""]
    assert attr(document, :toggle, "data-justify") == ["end"]
    assert attr(document, :toggle, "data-depth") == []
    assert attr(document, :toggle, "data-inset") == ["top"]
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

  test "an inherited active variant follows the variant", %{wrapper: wrapper} do
    document = render(wrapper, :inherit_active)

    assert attr(document, :toggle, "data-variant") == ["soft"]
    assert attr(document, :toggle, "data-active-variant") == ["soft"]
    assert attr(document, :toggle, "data-color") == ["primary"]
    assert attr(document, :toggle, "data-active-color") == []
  end

  test "state slots render in the DOM for the theme to reveal", %{wrapper: wrapper} do
    document = render(wrapper, :state_slots)

    assert attr(document, :toggle, "data-state") == ["on"]
    assert part_attr(document, "on-state", "data-part") == ["on-state"]
    assert part_attr(document, "off-state", "data-part") == ["off-state"]

    assert LazyHTML.query(document, ~s([data-part="on-state"])) |> LazyHTML.text() == "Muted"

    assert LazyHTML.query(document, ~s([data-part="off-state"])) |> LazyHTML.text() ==
             "Sound on"
  end

  test "icon and text are content shortcuts", %{wrapper: wrapper} do
    document = render(wrapper, :icon_and_text)

    assert LazyHTML.query(document, ~s([data-element="icon"])) |> LazyHTML.attribute("class") ==
             ["lucide-letter-b"]

    assert root(document, :toggle) |> LazyHTML.text() |> String.trim() == "Bold"
  end

  test "a pending toggle keeps the state hooks and sits in the tab order", %{wrapper: wrapper} do
    document = render(wrapper, :loading)

    assert attr(document, :toggle, "data-loading") == [""]
    assert attr(document, :toggle, "aria-busy") == ["true"]
    assert attr(document, :toggle, "aria-disabled") == ["true"]
    assert attr(document, :toggle, "disabled") == []
  end

  test "a raw color sets the toggle public inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:toggle, "style") |> List.first()

    assert attr(document, :toggle, "data-color") == []
    assert style =~ "--fl-toggle-color: #1D72FE"
    assert style =~ "--fl-toggle-color-content:"
    assert style =~ "--fl-toggle-text: light-dark("
  end

  test "a raw active color sets the active inputs only", %{wrapper: wrapper} do
    document = render(wrapper, :raw_active_color)
    style = document |> attr(:toggle, "style") |> List.first()

    assert attr(document, :toggle, "data-color") == ["primary"]
    assert attr(document, :toggle, "data-active-color") == []
    assert style =~ "--fl-toggle-active-color: #1D72FE"
    assert style =~ "--fl-toggle-active-color-content:"
    assert style =~ "--fl-toggle-active-text: light-dark("
    assert style =~ "--fl-toggle-active-soft: color-mix("
    assert style =~ "--fl-toggle-active-soft-border: color-mix("
    refute style =~ "--fl-toggle-color: "
  end
end
