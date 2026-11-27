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
          surface="strong"
          blur
          nav_position="start"
          toggle_position="start"
          collapse="always"
          container
          toggle_label="Open menu"
          toggle_icon="lucide-x"
          toggle_icon_open="lucide-check"
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

      def icon_open_empty(assigns) do
        ~H"""
        <.header toggle_icon="lucide-menu" toggle_icon_open="">
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
    assert attr(document, :header, "data-surface") == ["solid"]
    assert attr(document, :header, "data-blur") == []
    assert attr(document, :header, "data-nav-position") == ["center"]
    assert attr(document, :header, "data-toggle-position") == ["end"]
    assert attr(document, :header, "data-collapse") == ["lg"]
    assert attr(document, :header, "data-container") == []
    assert attr(document, :header, "data-state") == ["closed"]
    assert attr(document, :header, "data-mobile") == []
  end

  test "renders the built-in toggle mark by default", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)
    toggle = part(document, "toggle")
    mark = LazyHTML.query(toggle, ~s([data-part="toggle-icon"]))

    assert LazyHTML.attribute(mark, "data-default") == [""]
    assert LazyHTML.attribute(mark, "aria-hidden") == ["true"]
    assert LazyHTML.query(toggle, "[data-toggle-icon]") |> LazyHTML.to_html() == ""
  end

  test "maps every styled prop and forwards the base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :props)

    assert attr(document, :header, "data-sticky") == []
    assert attr(document, :header, "data-surface") == ["strong"]
    assert attr(document, :header, "data-blur") == [""]
    assert attr(document, :header, "data-nav-position") == ["start"]
    assert attr(document, :header, "data-toggle-position") == ["start"]
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

    closed = LazyHTML.query(toggle, ~s([data-toggle-icon="closed"]))
    open = LazyHTML.query(toggle, ~s([data-toggle-icon="open"]))
    assert LazyHTML.attribute(closed, "class") == ["lucide-x"]
    assert LazyHTML.attribute(closed, "hidden") == [""]
    assert LazyHTML.attribute(open, "class") == ["lucide-check"]
    assert LazyHTML.attribute(open, "hidden") == []
  end

  test "renders the mobile and secondary slots", %{wrapper: wrapper} do
    document = render(wrapper, :props)

    assert part(document, "mobile") |> LazyHTML.text() |> String.trim() == "Mobile"

    assert part(document, "secondary") |> LazyHTML.text() |> String.trim() ==
             "Secondary row"
  end

  test "keeps only the closed icon when toggle_icon_open is empty", %{wrapper: wrapper} do
    document = render(wrapper, :icon_open_empty)
    toggle = part(document, "toggle")

    assert LazyHTML.query(toggle, ~s([data-toggle-icon="closed"])) |> LazyHTML.to_html() =~
             "lucide-menu"

    assert LazyHTML.query(toggle, ~s([data-toggle-icon="open"])) |> LazyHTML.to_html() == ""
  end
end
