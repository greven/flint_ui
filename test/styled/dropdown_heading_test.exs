defmodule FlintUI.Styled.DropdownHeadingTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:dropdown_heading, ~S'''
      def example(assigns) do
        ~H"""
        <.dropdown_heading color="error" class="extra" data-role="test">Account</.dropdown_heading>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the heading wiring", %{wrapper: wrapper} do
    document = render(wrapper, :example)
    heading = part(document, "heading")

    assert attr(document, :dropdown_heading, "data-dropdown_heading") == [""]
    assert LazyHTML.attribute(heading, "role") == ["presentation"]
    assert LazyHTML.attribute(heading, "data-color") == ["error"]
    assert LazyHTML.attribute(heading, "class") == ["extra"]
    assert LazyHTML.attribute(heading, "data-role") == ["test"]
    assert LazyHTML.text(heading) =~ "Account"
  end
end
