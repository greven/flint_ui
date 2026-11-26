defmodule FlintUI.Styled.DropdownHeaderTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_header, ~S'''
      def default(assigns) do
        ~H"""
        <.dropdown_header class="extra">Account</.dropdown_header>
        """
      end

      def example(assigns) do
        ~H"""
        <.dropdown_header color="danger" class="extra" data-role="test">Account</.dropdown_header>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "leaves the muted default without a color hook", %{wrapper: wrapper} do
    document = render(wrapper, :default)
    header = part(document, "header")

    assert attr(document, :dropdown_header, "data-dropdown_header") == [""]
    assert LazyHTML.attribute(header, "data-color") == []
    assert LazyHTML.attribute(header, "class") == ["extra"]
  end

  test "adds the presence hook and forwards the header wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    header = part(document, "header")

    assert attr(document, :dropdown_header, "data-dropdown_header") == [""]
    assert LazyHTML.tag(header) == ["header"]
    assert LazyHTML.attribute(header, "role") == ["presentation"]
    assert LazyHTML.attribute(header, "data-color") == ["danger"]
    assert LazyHTML.attribute(header, "class") == ["extra"]
    assert LazyHTML.attribute(header, "data-role") == ["test"]
    assert LazyHTML.text(header) =~ "Account"
  end
end
