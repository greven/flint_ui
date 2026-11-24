defmodule FlintUI.Styled.StackTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:stack, ~S'''
      def defaults(assigns) do
        ~H"""
        <.stack>
          <p>First</p>
          <p>Second</p>
        </.stack>
        """
      end

      def semantic(assigns) do
        ~H"""
        <.stack as="section" aria-labelledby="stack-title" class="custom">
          <h2 id="stack-title">Intro</h2>
        </.stack>
        """
      end

      def custom(assigns) do
        ~H"""
        <.stack
          align="center"
          gap="lg"
          justify="between"
          class="custom"
          id="stack"
          role="group"
          aria-label="Actions"
        >
          <p>First</p>
        </.stack>
        """
      end

      def piled(assigns) do
        ~H"""
        <.stack pile limit="2" gap="sm">
          <p>First</p>
          <p>Second</p>
          <p>Third</p>
        </.stack>
        """
      end

      def reversed(assigns) do
        ~H"""
        <.stack pile limit="4" direction="down" shrink="lg">
          <p>First</p>
          <p>Second</p>
        </.stack>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the stack with the default layout hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :stack)) == ["div"]
    assert attr(document, :stack, "data-stack") == [""]
    assert attr(document, :stack, "data-align") == ["stretch"]
    assert attr(document, :stack, "data-gap") == ["md"]
    assert attr(document, :stack, "data-justify") == ["start"]
    assert attr(document, :stack, "data-pile") == []
    assert attr(document, :stack, "data-limit") == ["3"]
    assert attr(document, :stack, "class") == []
  end

  test "maps align, gap, and justify onto their hooks", %{wrapper: wrapper} do
    document = render(wrapper, :custom)

    assert attr(document, :stack, "data-align") == ["center"]
    assert attr(document, :stack, "data-gap") == ["lg"]
    assert attr(document, :stack, "data-justify") == ["between"]
  end

  test "renders the element chosen by as and keeps the stack hooks", %{wrapper: wrapper} do
    document = render(wrapper, :semantic)

    assert LazyHTML.tag(root(document, :stack)) == ["section"]
    assert attr(document, :stack, "data-stack") == [""]
    assert attr(document, :stack, "data-align") == ["stretch"]
    assert attr(document, :stack, "aria-labelledby") == ["stack-title"]
  end

  test "forwards class and rest attributes", %{wrapper: wrapper} do
    document = render(wrapper, :custom)

    assert attr(document, :stack, "class") == ["custom"]
    assert attr(document, :stack, "id") == ["stack"]
    assert attr(document, :stack, "role") == ["group"]
    assert attr(document, :stack, "aria-label") == ["Actions"]
  end

  test "renders the stacked children", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert root(document, :stack) |> LazyHTML.text() |> String.split() == ["First", "Second"]
  end

  test "maps pile and limit onto their hooks", %{wrapper: wrapper} do
    document = render(wrapper, :piled)

    assert attr(document, :stack, "data-pile") == [""]
    assert attr(document, :stack, "data-limit") == ["2"]
    assert attr(document, :stack, "data-direction") == ["up"]
    assert attr(document, :stack, "data-shrink") == ["sm"]
    assert attr(document, :stack, "data-gap") == ["sm"]
  end

  test "maps direction and shrink onto their hooks", %{wrapper: wrapper} do
    document = render(wrapper, :reversed)

    assert attr(document, :stack, "data-limit") == ["4"]
    assert attr(document, :stack, "data-direction") == ["down"]
    assert attr(document, :stack, "data-shrink") == ["lg"]
  end

  test "keeps every layer in the DOM so the theme can cap them", %{wrapper: wrapper} do
    document = render(wrapper, :piled)

    assert root(document, :stack) |> LazyHTML.text() |> String.split() == [
             "First",
             "Second",
             "Third"
           ]
  end
end
