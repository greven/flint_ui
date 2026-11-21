defmodule FlintUI.Styled.DropdownItemTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_item, ~S'''
      def defaults(assigns) do
        ~H"""
        <.dropdown_item>Settings</.dropdown_item>
        """
      end

      def icon_and_text(assigns) do
        ~H"""
        <.dropdown_item icon="lucide-settings" text="Settings" />
        """
      end

      def configured(assigns) do
        ~H"""
        <.dropdown_item intent="danger" disabled class="extra" data-role="test">Log out</.dropdown_item>
        """
      end

      def link(assigns) do
        ~H"""
        <.dropdown_item href="https://example.com" target="_blank">Billing</.dropdown_item>
        """
      end

      def custom(assigns) do
        ~H"""
        <.dropdown_item custom>
          <p>Signed in as ada@example.com</p>
        </.dropdown_item>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and renders the item", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)
    item = part(document, "item")

    assert attr(document, :dropdown_item, "data-dropdown_item") == [""]
    assert LazyHTML.tag(item) == ["button"]
    assert LazyHTML.attribute(item, "role") == ["menuitem"]
    assert LazyHTML.text(item) |> String.trim() == "Settings"
  end

  test "renders the icon shortcut and the text fallback", %{wrapper: wrapper} do
    document = render(wrapper, :icon_and_text)
    item = part(document, "item")
    icon = LazyHTML.query(item, ~s([data-element="icon"]))

    assert LazyHTML.attribute(icon, "class") == ["lucide-settings"]
    assert LazyHTML.text(item) |> String.trim() == "Settings"
  end

  test "forwards intent, disabled, class, and rest", %{wrapper: wrapper} do
    item = render(wrapper, :configured) |> part("item")

    assert LazyHTML.attribute(item, "data-intent") == ["danger"]
    assert LazyHTML.attribute(item, "disabled") == [""]
    assert LazyHTML.attribute(item, "data-disabled") == [""]
    assert LazyHTML.attribute(item, "class") == ["extra"]
    assert LazyHTML.attribute(item, "data-role") == ["test"]
  end

  test "forwards the link form", %{wrapper: wrapper} do
    item = render(wrapper, :link) |> part("item")

    assert LazyHTML.tag(item) == ["a"]
    assert LazyHTML.attribute(item, "href") == ["https://example.com"]
    assert LazyHTML.attribute(item, "target") == ["_blank"]
    assert LazyHTML.attribute(item, "role") == ["menuitem"]
  end

  test "forwards a custom content block", %{wrapper: wrapper} do
    item = render(wrapper, :custom) |> part("item")

    assert LazyHTML.attribute(item, "data-custom") == [""]
    assert LazyHTML.attribute(item, "role") == []
    assert LazyHTML.text(item) =~ "Signed in as ada@example.com"
  end
end
