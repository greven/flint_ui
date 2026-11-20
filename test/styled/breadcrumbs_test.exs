defmodule FlintUI.Styled.BreadcrumbsTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    # The trail needs both generated wrappers in one module so the examples can
    # compose them the way a host app does.
    module = Module.concat([FlintUITest, Styled, BreadcrumbsTrail])

    Code.compile_string(~s'''
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{FlintUI.Generator.component_source(:breadcrumbs)}
      #{FlintUI.Generator.component_source(:breadcrumbs_item)}

      def defaults(assigns) do
        ~H"""
        <.breadcrumbs>
          <.breadcrumbs_item navigate="/" icon="lucide-house" aria-label="Home" />
          <.breadcrumbs_item navigate="/blog" separator="slash">Blog</.breadcrumbs_item>
          <.breadcrumbs_item current separator="slash">Post</.breadcrumbs_item>
        </.breadcrumbs>
        """
      end

      def separators(assigns) do
        ~H"""
        <.breadcrumbs label="Trail">
          <.breadcrumbs_item separator="slash" text="Home" />
          <.breadcrumbs_item separator="arrow" text="Blog" />
          <.breadcrumbs_item separator="dot" text="Team" />
          <.breadcrumbs_item separator="none" text="Post" current />
        </.breadcrumbs>
        """
      end

      def with_dropdown(assigns) do
        ~H"""
        <.breadcrumbs>
          <.breadcrumbs_item navigate="/">Home</.breadcrumbs_item>
          <.breadcrumbs_item>
            <FlintUI.dropdown label="More">
              <FlintUI.dropdown_item>Client</FlintUI.dropdown_item>
            </FlintUI.dropdown>
          </.breadcrumbs_item>
          <.breadcrumbs_item current>Post</.breadcrumbs_item>
        </.breadcrumbs>
        """
      end
    end
    ''')

    item =
      compile_wrapper!(:breadcrumbs_item, ~S'''
      def plain(assigns) do
        ~H"""
        <.breadcrumbs_item class="crumb" data-role="test">Home</.breadcrumbs_item>
        """
      end

      def current(assigns) do
        ~H"""
        <.breadcrumbs_item current text="Post" />
        """
      end
      ''')

    %{wrapper: module, item: item}
  end

  test "maps the default trail onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :breadcrumbs, "data-breadcrumbs") == [""]
    assert attr(document, :breadcrumbs, "aria-label") == ["Breadcrumb"]

    list = LazyHTML.query(document, ~s([data-part="list"]))
    assert LazyHTML.tag(list) == ["ol"]
    assert Enum.count(item_nodes(document)) == 3

    assert Enum.map(0..2, &item_attribute(document, &1, "data-breadcrumbs_item")) ==
             [[""], [""], [""]]

    assert Enum.map(0..2, &item_attribute(document, &1, "data-separator")) ==
             [["chevron"], ["slash"], ["slash"]]

    assert Enum.map(0..2, &item_attribute(document, &1, "data-current")) == [[], [], [""]]
  end

  test "renders an icon-only crumb as a named link", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)
    first = item_at(document, 0)

    assert LazyHTML.query(first, "a[href='/']")
    assert LazyHTML.attribute(first, "aria-label") == []

    link = LazyHTML.query(first, ~s([data-part="content"]))
    assert LazyHTML.attribute(link, "aria-label") == ["Home"]
    assert LazyHTML.query(link, "[data-element='icon'].lucide-house")
  end

  test "maps every separator value and forwards the landmark label", %{wrapper: wrapper} do
    document = render(wrapper, :separators)

    assert attr(document, :breadcrumbs, "aria-label") == ["Trail"]

    assert Enum.map(0..3, &item_attribute(document, &1, "data-separator")) ==
             [["slash"], ["arrow"], ["dot"], ["none"]]

    last = item_at(document, 3)
    assert LazyHTML.text(last) |> String.trim() == "Post"
    assert LazyHTML.attribute(last, "data-current") == [""]
  end

  test "renders arbitrary crumb content inside the content part", %{wrapper: wrapper} do
    document = render(wrapper, :with_dropdown)
    middle = item_at(document, 1)

    assert LazyHTML.query(middle, ~s([data-part="content"] [data-element="dropdown"]))
  end

  test "forwards classes and data attributes to the item root", %{item: item} do
    document = render(item, :plain)

    assert attr(document, :breadcrumbs_item, "class") == ["crumb"]
    assert attr(document, :breadcrumbs_item, "data-role") == ["test"]
    assert attr(document, :breadcrumbs_item, "data-separator") == ["chevron"]
  end

  test "fills content from text and marks the current item", %{item: item} do
    document = render(item, :current)

    assert attr(document, :breadcrumbs_item, "data-current") == [""]
    assert LazyHTML.text(document) |> String.trim() == "Post"

    content = LazyHTML.query(document, ~s([data-part="content"]))
    assert LazyHTML.attribute(content, "aria-current") == ["page"]
  end

  defp item_nodes(document) do
    LazyHTML.query(document, ~s([data-element="breadcrumbs_item"]))
  end

  defp item_at(document, index) do
    LazyHTML.query(document, ~s|[data-element="breadcrumbs_item"]:nth-child(#{index + 1})|)
  end

  defp item_attribute(document, index, name) do
    document |> item_at(index) |> LazyHTML.attribute(name)
  end
end
