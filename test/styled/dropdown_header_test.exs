defmodule FlintUI.Styled.DropdownHeaderTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_header, ~S'''
      def example(assigns) do
        ~H"""
        <.dropdown_header color="error" class="extra" data-role="test">Account</.dropdown_header>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the header wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    header = part(document, "header")

    assert attr(document, :dropdown_header, "data-dropdown_header") == [""]
    assert LazyHTML.tag(header) == ["header"]
    assert LazyHTML.attribute(header, "role") == ["presentation"]
    assert LazyHTML.attribute(header, "data-color") == ["error"]
    assert LazyHTML.attribute(header, "class") == ["extra"]
    assert LazyHTML.attribute(header, "data-role") == ["test"]
    assert LazyHTML.text(header) =~ "Account"
  end
end
