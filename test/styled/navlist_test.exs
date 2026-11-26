defmodule FlintUI.Styled.NavlistTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    module = Module.concat([FlintUITest, Styled, NavlistSet])

    Code.compile_string(~s'''
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{FlintUI.Generator.component_source(:navlist)}
      #{FlintUI.Generator.component_source(:navlist_item)}
      #{FlintUI.Generator.component_source(:navlist_group)}

      def plain(assigns) do
        ~H"""
        <.navlist>
          <.navlist_item navigate="/docs">Overview</.navlist_item>
          <.navlist_item navigate="/docs/install" active>Install</.navlist_item>
        </.navlist>
        """
      end

      def railed(assigns) do
        ~H"""
        <.navlist label="Docs" rail class="extra" data-role="test">
          <.navlist_group label="Guides" icon="lucide-book" open>
            <.navlist_item navigate="/guides">Theming</.navlist_item>
          </.navlist_group>
        </.navlist>
        """
      end

      def static_group(assigns) do
        ~H"""
        <.navlist>
          <.navlist_group label="Overview" collapsible={false}>
            <.navlist_item navigate="/docs">Introduction</.navlist_item>
          </.navlist_group>
        </.navlist>
        """
      end

      def icon_item(assigns) do
        ~H"""
        <.navlist>
          <.navlist_item icon="lucide-house" trailing_icon="lucide-arrow-up-right" text="Home" />
        </.navlist>
        """
      end

      def disabled_item(assigns) do
        ~H"""
        <.navlist>
          <.navlist_item navigate="/docs" disabled>Overview</.navlist_item>
        </.navlist>
        """
      end
    end
    ''')

    %{wrapper: module}
  end

  test "maps items without a rail by default", %{wrapper: wrapper} do
    document = render(wrapper, :plain)

    assert attr(document, :navlist, "data-navlist") == [""]
    assert attr(document, :navlist, "data-rail") == []
    assert attr(document, :navlist_item, "data-navlist_item") == ["", ""]
    assert List.last(attr(document, :navlist_item, "data-active")) == ""
  end

  test "maps rail, label, rest, and an open collapsible group", %{wrapper: wrapper} do
    document = render(wrapper, :railed)
    root = root(document, :navlist)
    group = root(document, :navlist_group)
    trigger = LazyHTML.query(group, ~s([data-part="trigger"]))

    assert LazyHTML.attribute(root, "data-rail") == [""]
    assert LazyHTML.attribute(root, "aria-label") == ["Docs"]
    assert LazyHTML.attribute(root, "class") == ["extra"]
    assert LazyHTML.attribute(root, "data-role") == ["test"]

    assert LazyHTML.attribute(group, "data-navlist_group") == [""]
    assert LazyHTML.attribute(group, "data-state") == ["open"]
    assert LazyHTML.query(trigger, "[data-element='icon'].lucide-book")
    assert LazyHTML.text(trigger) =~ "Guides"
  end

  test "renders a static group without a trigger", %{wrapper: wrapper} do
    document = render(wrapper, :static_group)
    group = root(document, :navlist_group)
    header = LazyHTML.query(group, ~s([data-part="header"]))

    assert LazyHTML.attribute(group, "data-static") == [""]
    assert LazyHTML.tag(header) == ["div"]
    assert LazyHTML.text(header) =~ "Overview"
  end

  test "renders item icons and the text fallback", %{wrapper: wrapper} do
    document = render(wrapper, :icon_item)
    item = root(document, :navlist_item)

    assert LazyHTML.query(item, "[data-element='icon'].lucide-house")
    assert LazyHTML.query(item, "[data-element='icon'].lucide-arrow-up-right")
    assert LazyHTML.text(item) |> String.trim() == "Home"
  end

  test "forwards a disabled item", %{wrapper: wrapper} do
    document = render(wrapper, :disabled_item)
    item = root(document, :navlist_item)
    content = LazyHTML.query(item, ~s([data-part="content"]))

    assert LazyHTML.attribute(item, "data-disabled") == [""]
    assert LazyHTML.tag(content) == ["span"]
    assert LazyHTML.attribute(content, "aria-disabled") == ["true"]
  end
end
