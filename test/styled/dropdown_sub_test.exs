defmodule FlintUI.Styled.DropdownSubTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_sub, ~S'''
      def example(assigns) do
        ~H"""
        <.dropdown_sub menu="more" class="extra" data-role="test">More</.dropdown_sub>
        """
      end

      def disabled(assigns) do
        ~H"""
        <.dropdown_sub menu="more" disabled>More</.dropdown_sub>
        """
      end

      def no_hover(assigns) do
        ~H"""
        <.dropdown_sub menu="more" open_on_hover={false}>More</.dropdown_sub>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the submenu wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    trigger = part(document, "submenu-trigger")

    assert attr(document, :dropdown_sub, "data-dropdown_sub") == [""]
    assert LazyHTML.attribute(trigger, "role") == ["menuitem"]
    assert LazyHTML.attribute(trigger, "data-menu") == ["more"]
    assert LazyHTML.attribute(trigger, "aria-haspopup") == ["menu"]
    assert LazyHTML.attribute(trigger, "aria-controls") == ["more"]
    assert LazyHTML.attribute(trigger, "class") == ["extra"]
    assert LazyHTML.attribute(trigger, "data-role") == ["test"]
    assert LazyHTML.text(trigger) =~ "More"
  end

  test "forwards disabled", %{wrapper: wrapper} do
    trigger = render(wrapper, :disabled) |> part("submenu-trigger")

    assert LazyHTML.attribute(trigger, "disabled") == [""]
    assert LazyHTML.attribute(trigger, "aria-disabled") == ["true"]
  end

  test "opens on hover by default", %{wrapper: wrapper} do
    trigger = render(wrapper, :example) |> part("submenu-trigger")

    assert LazyHTML.attribute(trigger, "data-open-on-hover") == [""]
  end

  test "forwards the hover opt-out", %{wrapper: wrapper} do
    trigger = render(wrapper, :no_hover) |> part("submenu-trigger")

    assert LazyHTML.attribute(trigger, "data-open-on-hover") == []
  end
end
