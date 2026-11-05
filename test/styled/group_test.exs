defmodule FlintUI.Styled.GroupTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:group, ~S'''
      def defaults(assigns) do
        ~H"""
        <.group>
          <button type="button">Copy</button>
          <button type="button">Paste</button>
        </.group>
        """
      end

      def framed(assigns) do
        ~H"""
        <.group
          variant="framed"
          size="lg"
          orientation="vertical"
          label="Actions"
          class="extra"
          data-role="test"
        >
          <button type="button">Copy</button>
        </.group>
        """
      end

      def as_section(assigns) do
        ~H"""
        <.group as="section" label="Tools">
          <button type="button">Copy</button>
        </.group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :group)) == ["div"]
    assert attr(document, :group, "data-group") == [""]
    assert attr(document, :group, "data-variant") == ["attached"]
    assert attr(document, :group, "data-size") == ["md"]
    assert attr(document, :group, "data-orientation") == ["horizontal"]
    assert root(document, :group) |> LazyHTML.text() |> String.split() == ["Copy", "Paste"]
  end

  test "maps the variant and size overrides and forwards the label", %{wrapper: wrapper} do
    document = render(wrapper, :framed)

    assert attr(document, :group, "data-variant") == ["framed"]
    assert attr(document, :group, "data-size") == ["lg"]
    assert attr(document, :group, "data-orientation") == ["vertical"]
    assert attr(document, :group, "role") == ["group"]
    assert attr(document, :group, "aria-label") == ["Actions"]
    assert attr(document, :group, "class") == ["extra"]
    assert attr(document, :group, "data-role") == ["test"]
  end

  test "forwards the root element", %{wrapper: wrapper} do
    document = render(wrapper, :as_section)

    assert LazyHTML.tag(root(document, :group)) == ["section"]
  end
end
