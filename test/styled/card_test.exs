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
          title_as="h3"
          description_id="card-description"
          class="extra"
          data-role="test"
        >
          <:title>Title</:title>
          <:description>Description</:description>
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

      def indicator(assigns) do
        ~H"""
        <.card href="https://hexdocs.pm/phoenix" indicator title_id="indicator-title">
          <:title>Phoenix</:title>
          <p>Body</p>
        </.card>
        """
      end

      def indicator_custom(assigns) do
        ~H"""
        <.card
          href="https://hexdocs.pm/phoenix"
          indicator
          indicator_icon="ph-arrow-up-right"
          title_id="indicator-title"
        >
          <:title>Phoenix</:title>
          <p>Body</p>
        </.card>
        """
      end

      def indicator_no_icon(assigns) do
        ~H"""
        <.card href="https://hexdocs.pm/phoenix" indicator indicator_icon="" title_id="indicator-title">
          <:title>Phoenix</:title>
          <p>Body</p>
        </.card>
        """
      end

      def indicator_not_linked(assigns) do
        ~H"""
        <.card indicator>
          <:title>Phoenix</:title>
          <p>Body</p>
        </.card>
        """
      end

      def corner(assigns) do
        ~H"""
        <.card href="/repositories" title_id="corner-title">
          <:corner><span data-test="marker">!</span></:corner>
          <:title>Repositories</:title>
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
    assert attr(document, :card, "data-elevation") == [""]
    assert attr(document, :card, "data-indicator") == []
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
    assert LazyHTML.tag(part(document, "title")) == ["h3"]
    assert part_attr(document, "description", "id") == ["card-description"]
    assert part_attr(document, "section", "data-padded") == []
  end

  test "a link destination renders a linked root", %{wrapper: wrapper} do
    document = render(wrapper, :linked)

    assert LazyHTML.tag(root(document, :card)) == ["a"]
    assert attr(document, :card, "href") == ["/repositories"]
    assert attr(document, :card, "data-link") == [""]
    assert attr(document, :card, "aria-labelledby") == ["repo-title"]
  end

  test "indicator adds the hook and a dimmed corner arrow", %{wrapper: wrapper} do
    document = render(wrapper, :indicator)

    assert attr(document, :card, "data-indicator") == [""]
    assert part_attr(document, "corner", "data-part") == ["corner"]

    icon = LazyHTML.query(document, ~s([data-part="corner"] [data-element="icon"]))
    assert LazyHTML.attribute(icon, "class") == ["lucide-arrow-up-right"]
    assert LazyHTML.attribute(icon, "aria-hidden") == ["true"]
  end

  test "indicator_icon swaps the corner arrow class", %{wrapper: wrapper} do
    document = render(wrapper, :indicator_custom)

    icon = LazyHTML.query(document, ~s([data-part="corner"] [data-element="icon"]))
    assert LazyHTML.attribute(icon, "class") == ["ph-arrow-up-right"]
  end

  test "an empty indicator_icon keeps the hook without an arrow", %{wrapper: wrapper} do
    document = render(wrapper, :indicator_no_icon)

    assert attr(document, :card, "data-indicator") == [""]
    assert LazyHTML.to_html(LazyHTML.query(document, ~s([data-element="icon"]))) == ""
    assert LazyHTML.to_html(LazyHTML.query(document, ~s([data-part="corner"]))) == ""
  end

  test "indicator is ignored on a card without a link", %{wrapper: wrapper} do
    document = render(wrapper, :indicator_not_linked)

    assert LazyHTML.tag(root(document, :card)) == ["div"]
    assert attr(document, :card, "data-indicator") == []
    assert LazyHTML.to_html(LazyHTML.query(document, ~s([data-part="corner"]))) == ""
  end

  test "forwards a caller corner slot", %{wrapper: wrapper} do
    document = render(wrapper, :corner)

    corner = LazyHTML.query(document, ~s([data-part="corner"]))
    assert LazyHTML.attribute(corner, "data-part") == ["corner"]
    assert LazyHTML.text(corner) =~ "!"
  end

  test "forwards every card slot into its region", %{wrapper: wrapper} do
    document = render(wrapper, :regions)

    assert text(document) ==
             "Title Description Edit Header extra Body Extra section Footer View"

    assert count_part(document, "section") == 2
  end
end
