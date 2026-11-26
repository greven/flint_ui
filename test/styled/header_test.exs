defmodule FlintUI.Styled.HeaderTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:header, ~S'''
      def defaults(assigns) do
        ~H"""
        <.header>
          <:brand>Acme</:brand>
          <:nav><nav aria-label="Primary"><a href="/">Home</a></nav></:nav>
          <:actions><button type="button">Sign in</button></:actions>
        </.header>
        """
      end

      def props(assigns) do
        ~H"""
        <.header
          id="site-header"
          open
          sticky={false}
          nav_position="start"
          collapse="always"
          container
          toggle_label="Open menu"
          toggle_icon="lucide-x"
          class="custom"
          data-testid="header"
        >
          <:brand>Acme</:brand>
          <:nav><a href="/">Home</a></:nav>
          <:mobile><a href="/mobile">Mobile</a></:mobile>
          <:secondary><p>Secondary row</p></:secondary>
        </.header>
        """
      end

      def icon_empty(assigns) do
        ~H"""
        <.header toggle_icon="">
          <:nav><a href="/">Home</a></:nav>
        </.header>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default header hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :header, "data-header") == [""]
    assert attr(document, :header, "data-sticky") == [""]
    assert attr(document, :header, "data-nav-position") == ["center"]
    assert attr(document, :header, "data-collapse") == ["lg"]
    assert attr(document, :header, "data-container") == []
    assert attr(document, :header, "data-state") == ["closed"]
    assert attr(document, :header, "data-mobile") == []
  end

  test "renders the icon in the mobile toggle", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)
    toggle = part(document, "toggle")

    icon = LazyHTML.query(toggle, ~s([data-element="icon"]))

    assert LazyHTML.attribute(icon, "class") == ["lucide-menu"]
    assert LazyHTML.attribute(icon, "aria-hidden") == ["true"]
  end

  test "maps every styled prop and forwards the base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :props)

    assert attr(document, :header, "data-sticky") == []
    assert attr(document, :header, "data-nav-position") == ["start"]
    assert attr(document, :header, "data-collapse") == ["always"]
    assert attr(document, :header, "data-container") == [""]
    assert attr(document, :header, "data-state") == ["open"]
    assert attr(document, :header, "data-mobile") == [""]
    assert attr(document, :header, "id") == ["site-header"]
    assert attr(document, :header, "class") == ["custom"]
    assert attr(document, :header, "data-testid") == ["header"]

    toggle = part(document, "toggle")
    assert LazyHTML.attribute(toggle, "aria-controls") == ["site-header-mobile"]
    assert LazyHTML.attribute(toggle, "aria-expanded") == ["true"]
    assert LazyHTML.attribute(toggle, "aria-label") == ["Open menu"]

    icon = LazyHTML.query(toggle, ~s([data-element="icon"]))
    assert LazyHTML.attribute(icon, "class") == ["lucide-x"]
  end

  test "renders the mobile and secondary slots", %{wrapper: wrapper} do
    document = render(wrapper, :props)

    assert part(document, "mobile") |> LazyHTML.text() |> String.trim() == "Mobile"

    assert part(document, "secondary") |> LazyHTML.text() |> String.trim() ==
             "Secondary row"
  end

  test "uses the headless fallback icon when toggle_icon is empty", %{wrapper: wrapper} do
    document = render(wrapper, :icon_empty)
    toggle = part(document, "toggle")

    assert LazyHTML.query(toggle, "svg[data-default]") |> LazyHTML.to_html() =~ "M4 7h16"
  end

  test "the theme part uses the shared breakpoints" do
    css = File.read!(FlintUI.Generator.part_path("styled/header.css"))

    for {_name, width} <- FlintUI.Utilities.breakpoints() do
      {rem, _} = Float.parse(width)
      max = rem - 0.001
      assert css =~ "@media (max-width: #{max}rem)"
    end
  end
end
