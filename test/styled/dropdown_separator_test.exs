defmodule FlintUI.Styled.DropdownSeparatorTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_separator, ~S'''
      def example(assigns) do
        ~H"""
        <.dropdown_separator class="extra" data-role="test" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the separator wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    separator = part(document, "separator")

    assert attr(document, :dropdown_separator, "data-dropdown_separator") == [""]
    assert LazyHTML.attribute(separator, "role") == ["separator"]
    assert LazyHTML.attribute(separator, "class") == ["extra"]
    assert LazyHTML.attribute(separator, "data-role") == ["test"]
  end
end
