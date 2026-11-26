defmodule FlintUI.Styled.NavbarTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    module = Module.concat([FlintUITest, Styled, NavbarSet])

    Code.compile_string(~s'''
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{FlintUI.Generator.component_source(:navbar)}
      #{FlintUI.Generator.component_source(:navbar_item)}
      #{FlintUI.Generator.component_source(:navbar_menu)}
      #{FlintUI.Generator.component_source(:navbar_menu_item)}

      def defaults(assigns) do
        ~H"""
        <.navbar>
          <.navbar_item navigate="/">Home</.navbar_item>
          <.navbar_item navigate="/projects" active>Projects</.navbar_item>
          <.navbar_menu label="Products">
            <.navbar_menu_item navigate="/products">Overview</.navbar_menu_item>
          </.navbar_menu>
        </.navbar>
        """
      end

      def icons(assigns) do
        ~H"""
        <.navbar>
          <.navbar_item icon="lucide-house" trailing_icon="lucide-arrow-up-right" text="Home" />
          <.navbar_item>
            <:leading><span class="lead">Lead</span></:leading>
            Label
            <:trailing><span class="trail">Trail</span></:trailing>
          </.navbar_item>
        </.navbar>
        """
      end

      def open_menu(assigns) do
        ~H"""
        <.navbar>
          <.navbar_menu
            id="products"
            label="Products"
            icon="lucide-box"
            trailing_icon="lucide-sparkles"
            open
            active
            open_on_hover
            position="end"
            class="extra"
            data-role="test"
          >
            <.navbar_menu_item icon="lucide-box" active text="Overview" />
          </.navbar_menu>
        </.navbar>
        """
      end

      def custom_indicator(assigns) do
        ~H"""
        <.navbar>
          <.navbar_menu label="Products">
            <:indicator class="caret"><span>v</span></:indicator>
            <.navbar_menu_item text="Overview" />
          </.navbar_menu>
        </.navbar>
        """
      end

      def props(assigns) do
        ~H"""
        <.navbar
          variant="outlined"
          color="primary"
          size="lg"
          grow
          justify="between"
          disabled
          loop={false}
          scrollable
          fadable
        >
          <.navbar_item navigate="/" disabled>Home</.navbar_item>
        </.navbar>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.navbar color="#1D72FE">
          <.navbar_item navigate="/">Home</.navbar_item>
        </.navbar>
        """
      end
    end
    ''')

    %{wrapper: module}
  end

  test "maps the default navbar hooks and items", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :navbar, "data-navbar") == [""]
    assert attr(document, :navbar, "aria-label") == ["Primary"]

    assert attr(document, :navbar_item, "data-navbar_item") == ["", ""]
    assert List.last(attr(document, :navbar_item, "data-active")) == ""
    assert attr(document, :navbar_menu, "data-navbar_menu") == [""]
    assert attr(document, :navbar_menu_item, "data-navbar_menu_item") == [""]
  end

  test "renders leading and trailing icons plus slot content", %{wrapper: wrapper} do
    document = render(wrapper, :icons)
    item = LazyHTML.query(document, ~s|[data-element="navbar_item"]:nth-child(1)|)

    assert LazyHTML.query(item, "[data-element='icon'].lucide-house")
    assert LazyHTML.query(item, "[data-element='icon'].lucide-arrow-up-right")
    assert LazyHTML.text(item) |> String.trim() == "Home"

    second = LazyHTML.query(document, ~s|[data-element="navbar_item"]:nth-child(2)|)
    assert LazyHTML.query(second, ".lead")
    assert LazyHTML.query(second, ".trail")
  end

  test "forwards the menu state, icons, and rest attributes", %{wrapper: wrapper} do
    document = render(wrapper, :open_menu)
    menu = root(document, :navbar_menu)
    trigger = LazyHTML.query(menu, ~s([data-part="trigger"]))

    assert LazyHTML.attribute(menu, "id") == ["products"]
    assert LazyHTML.attribute(menu, "data-state") == ["open"]
    assert LazyHTML.attribute(menu, "data-active") == [""]
    assert LazyHTML.attribute(menu, "data-open-on-hover") == [""]
    assert LazyHTML.attribute(menu, "data-position") == ["end"]
    assert LazyHTML.attribute(menu, "class") == ["extra"]
    assert LazyHTML.attribute(menu, "data-role") == ["test"]

    assert LazyHTML.query(trigger, "[data-element='icon'].lucide-box")
    assert LazyHTML.query(trigger, "[data-element='icon'].lucide-sparkles")
    assert LazyHTML.text(trigger) =~ "Products"
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["true"]
  end

  test "renders menu items with icon and text fallback", %{wrapper: wrapper} do
    document = render(wrapper, :open_menu)
    item = root(document, :navbar_menu_item)

    assert LazyHTML.query(item, "[data-element='icon'].lucide-box")
    assert LazyHTML.text(item) |> String.trim() == "Overview"
    assert LazyHTML.attribute(item, "data-active") == [""]
  end

  test "forwards a custom indicator and its attributes", %{wrapper: wrapper} do
    document = render(wrapper, :custom_indicator)
    indicator = LazyHTML.query(document, ~s([data-element="navbar_menu"] [data-part="indicator"]))

    assert LazyHTML.attribute(indicator, "class") == ["caret"]
    assert LazyHTML.text(indicator) |> String.trim() == "v"
  end

  test "maps the variant, color, size, grow, and justify props", %{wrapper: wrapper} do
    document = render(wrapper, :props)
    root = root(document, :navbar)

    assert LazyHTML.attribute(root, "data-variant") == ["outlined"]
    assert LazyHTML.attribute(root, "data-color") == ["primary"]
    assert LazyHTML.attribute(root, "data-size") == ["lg"]
    assert LazyHTML.attribute(root, "data-grow") == [""]
    assert LazyHTML.attribute(root, "data-justify") == ["between"]
  end

  test "forwards disabled base attributes and item state", %{wrapper: wrapper} do
    document = render(wrapper, :props)
    root = root(document, :navbar)
    item = root(document, :navbar_item)
    content = LazyHTML.query(item, ~s([data-part="content"]))

    assert LazyHTML.attribute(root, "data-disabled") == [""]
    assert LazyHTML.attribute(root, "inert") == [""]
    assert LazyHTML.attribute(root, "data-loop") == ["false"]
    assert LazyHTML.attribute(root, "data-scrollable") == [""]
    assert LazyHTML.attribute(root, "data-fadable") == [""]

    assert LazyHTML.attribute(item, "data-disabled") == [""]
    assert LazyHTML.tag(content) == ["span"]
    assert LazyHTML.attribute(content, "aria-disabled") == ["true"]
  end

  test "a raw color writes the navbar public inputs inline", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    root = root(document, :navbar)

    assert LazyHTML.attribute(root, "data-color") == []

    style = LazyHTML.attribute(root, "style") |> List.first()
    assert style =~ "--fl-navbar-color: #1D72FE"
    assert style =~ "--fl-navbar-text-active:"
    assert style =~ "--fl-navbar-active:"
  end
end
