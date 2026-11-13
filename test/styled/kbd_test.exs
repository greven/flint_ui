defmodule FlintUI.Styled.KbdTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:kbd, ~S'''
      def defaults(assigns) do
        ~H"""
        <.kbd>K</.kbd>
        """
      end

      def subtle(assigns) do
        ~H"""
        <.kbd variant="subtle" size="xl" id="escape" class="uppercase" aria-label="Escape key">
          Esc
        </.kbd>
        """
      end

      def outline(assigns) do
        ~H"""
        <.kbd variant="outline" size="sm">Tab</.kbd>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the raised keycap by default", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :kbd)) == ["kbd"]
    assert attr(document, :kbd, "data-variant") == ["raised"]
    assert attr(document, :kbd, "data-size") == ["md"]
    assert root(document, :kbd) |> LazyHTML.text() |> String.trim() == "K"
  end

  test "maps variant, size, and forwarded attributes", %{wrapper: wrapper} do
    document = render(wrapper, :subtle)

    assert LazyHTML.tag(root(document, :kbd)) == ["kbd"]
    assert attr(document, :kbd, "data-variant") == ["subtle"]
    assert attr(document, :kbd, "data-size") == ["xl"]
    assert attr(document, :kbd, "id") == ["escape"]
    assert attr(document, :kbd, "aria-label") == ["Escape key"]
    assert attr(document, :kbd, "class") == ["uppercase"]
    assert root(document, :kbd) |> LazyHTML.text() |> String.trim() == "Esc"
  end

  test "maps the outline variant", %{wrapper: wrapper} do
    document = render(wrapper, :outline)

    assert attr(document, :kbd, "data-variant") == ["outline"]
    assert attr(document, :kbd, "data-size") == ["sm"]
    assert root(document, :kbd) |> LazyHTML.text() |> String.trim() == "Tab"
  end
end
