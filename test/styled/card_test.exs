defmodule FlintUI.Styled.CardTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:card, ~S'''
      def defaults(assigns) do
        ~H"""
        <.card>
          <:title>Repositories</:title>
          <p>Body</p>
        </.card>
        """
      end

      def treatment(assigns) do
        ~H"""
        <.card variant="soft" body="divided" spacing="lg" outline={false} shadow={false} inverted>
          <:title>Title</:title>
          <p>Body</p>
        </.card>
        """
      end

      def forwarded(assigns) do
        ~H"""
        <.card
          as="section"
          orientation="horizontal"
          padded={false}
          title_id="card-title"
          class="extra"
          data-role="test"
        >
          <:title>Title</:title>
          <p>Body</p>
        </.card>
        """
      end

      def linked(assigns) do
        ~H"""
        <.card href="/repositories" title_id="repo-title">
          <:title>Repositories</:title>
          <p>Body</p>
        </.card>
        """
      end

      def regions(assigns) do
        ~H"""
        <.card>
          <:title>Title</:title>
          <:description>Description</:description>
          <:header_actions><button type="button">Edit</button></:header_actions>
          <:header>Header extra</:header>
          <p>Body</p>
          <:section>Extra section</:section>
          <:footer>Footer</:footer>
          <:footer_actions><button type="button">View</button></:footer_actions>
        </.card>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp text(document) do
    document
    |> root(:card)
    |> LazyHTML.text()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :card)) == ["div"]
    assert attr(document, :card, "data-card") == [""]
    assert attr(document, :card, "data-variant") == ["solid"]
    assert attr(document, :card, "data-body") == ["seamless"]
    assert attr(document, :card, "data-spacing") == ["md"]
    assert attr(document, :card, "data-outline") == [""]
    assert attr(document, :card, "data-shadow") == [""]
    assert attr(document, :card, "data-inverted") == []
  end

  test "maps every treatment override, including false booleans", %{wrapper: wrapper} do
    document = render(wrapper, :treatment)

    assert attr(document, :card, "data-variant") == ["soft"]
    assert attr(document, :card, "data-body") == ["divided"]
    assert attr(document, :card, "data-spacing") == ["lg"]
    assert attr(document, :card, "data-outline") == []
    assert attr(document, :card, "data-shadow") == []
    assert attr(document, :card, "data-inverted") == [""]
  end

  test "forwards the element, orientation, padding, and global attributes", %{
    wrapper: wrapper
  } do
    document = render(wrapper, :forwarded)

    assert LazyHTML.tag(root(document, :card)) == ["section"]
    assert attr(document, :card, "data-orientation") == ["horizontal"]
    assert attr(document, :card, "class") == ["extra"]
    assert attr(document, :card, "data-role") == ["test"]
    assert part_attr(document, "title", "id") == ["card-title"]
    assert part_attr(document, "section", "data-padded") == []
  end

  test "a link destination renders a linked root", %{wrapper: wrapper} do
    document = render(wrapper, :linked)

    assert LazyHTML.tag(root(document, :card)) == ["a"]
    assert attr(document, :card, "href") == ["/repositories"]
    assert attr(document, :card, "data-link") == [""]
    assert attr(document, :card, "aria-labelledby") == ["repo-title"]
  end

  test "forwards every card slot into its region", %{wrapper: wrapper} do
    document = render(wrapper, :regions)

    assert text(document) ==
             "Title Description Edit Header extra Body Extra section Footer View"

    assert count_part(document, "section") == 2
  end
end
