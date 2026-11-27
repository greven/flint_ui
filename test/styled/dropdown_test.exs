defmodule FlintUI.Styled.DropdownTest do
  use FlintUI.StyledCase, async: true

  alias FlintUI.TestDOM

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown, ~S'''
      def defaults(assigns) do
        ~H"""
        <.dropdown id="menu" label="Actions">
          <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        </.dropdown>
        """
      end

      def configured(assigns) do
        ~H"""
        <.dropdown
          id="menu"
          label="Actions"
          placement="top"
          align="end"
          offset={12}
          arrow
          max_height={280}
          open_on_hover
          open_delay={120}
          close_delay={80}
          class="extra"
          data-role="test"
        >
          <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
          <:submenu id="more">
            <FlintUI.dropdown_item>Documentation</FlintUI.dropdown_item>
          </:submenu>
          <FlintUI.dropdown_sub menu="more">More</FlintUI.dropdown_sub>
        </.dropdown>
        """
      end

      def custom_trigger(assigns) do
        ~H"""
        <.dropdown id="menu">
          <:trigger :let={attrs}>
            <button {attrs} class="trigger-extra">Custom</button>
          </:trigger>
          <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        </.dropdown>
        """
      end

      def generated(assigns) do
        ~H"""
        <.dropdown label="Actions">
          <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        </.dropdown>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :dropdown, "data-dropdown") == [""]
    assert attr(document, :dropdown, "data-element") == ["dropdown"]
    assert attr(document, :dropdown, "data-placement") == ["bottom"]
    assert attr(document, :dropdown, "data-align") == ["start"]

    content = part(document, "content")
    assert LazyHTML.text(content) =~ "Settings"
  end

  test "forwards the configured positioning and hover options", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :dropdown, "data-placement") == ["top"]
    assert attr(document, :dropdown, "data-align") == ["end"]
    assert attr(document, :dropdown, "data-offset") == ["12"]
    assert attr(document, :dropdown, "data-open-on-hover") == [""]
    assert attr(document, :dropdown, "data-open-delay") == ["120"]
    assert attr(document, :dropdown, "data-close-delay") == ["80"]
    assert attr(document, :dropdown, "class") == ["extra"]
    assert attr(document, :dropdown, "data-role") == ["test"]
    assert count_part(document, "arrow") == 1

    assert TestDOM.style_vars(document, ~s([data-part="list"]))["--fl-dropdown-max-height"] ==
             "280px"
  end

  test "forwards the conditional trigger slot", %{wrapper: wrapper} do
    document = render(wrapper, :custom_trigger)
    trigger = part(document, "trigger")

    assert LazyHTML.text(trigger) |> String.trim() == "Custom"
    assert LazyHTML.attribute(trigger, "class") == ["trigger-extra"]
    assert LazyHTML.attribute(trigger, "aria-haspopup") == ["menu"]
  end

  test "forwards the submenu slot", %{wrapper: wrapper} do
    document = render(wrapper, :configured)
    submenu = part(document, "submenu")

    assert LazyHTML.attribute(submenu, "id") == ["more"]
    assert LazyHTML.attribute(submenu, "role") == ["menu"]
    assert LazyHTML.text(submenu) =~ "Documentation"
    assert part(document, "submenu-trigger") |> LazyHTML.text() =~ "More"
  end

  test "generates an id when none is given", %{wrapper: wrapper} do
    document = render(wrapper, :generated)
    [id] = attr(document, :dropdown, "id")

    assert id =~ ~r/^fl-dropdown-/
    assert part_attr(document, "content", "id") == ["#{id}-content"]
  end
end
