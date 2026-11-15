defmodule FlintUI.Styled.DropdownGroupTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_group, ~S'''
      def example(assigns) do
        ~H"""
        <.dropdown_group label="Session" class="extra" data-role="test">
          <FlintUI.dropdown_item>Log out</FlintUI.dropdown_item>
        </.dropdown_group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the group wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    group = part(document, "group")

    assert attr(document, :dropdown_group, "data-dropdown_group") == [""]
    assert LazyHTML.attribute(group, "role") == ["group"]
    assert LazyHTML.attribute(group, "aria-label") == ["Session"]
    assert LazyHTML.attribute(group, "class") == ["extra"]
    assert LazyHTML.attribute(group, "data-role") == ["test"]
    assert LazyHTML.text(group) =~ "Log out"
  end
end
