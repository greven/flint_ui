defmodule FlintUI.Base.HeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.header id="site-header">
        <:brand><a href="/">Acme</a></:brand>
        <:nav>
          <nav aria-label="Primary"><a href="/docs">Docs</a></nav>
        </:nav>
        <:actions><button type="button">Sign in</button></:actions>
      </.header>
      """
    end

    def with_mobile(assigns) do
      ~H"""
      <.header id="site-header" open toggle_label="Open menu">
        <:brand>Acme</:brand>
        <:nav><a href="/docs">Docs</a></:nav>
        <:mobile><a href="/mobile">Mobile</a></:mobile>
        <:secondary>
          <p>Secondary row</p>
        </:secondary>
      </.header>
      """
    end

    def toggle_start(assigns) do
      ~H"""
      <.header id="site-header" toggle_position="start">
        <:brand>Acme</:brand>
        <:nav><a href="/docs">Docs</a></:nav>
        <:actions><button type="button">Sign in</button></:actions>
      </.header>
      """
    end

    def as_div(assigns) do
      ~H"""
      <.header
        as="div"
        id="site-header"
        class="custom"
        data-testid="header"
        aria-label="Site"
      >
        <:nav><a href="/docs">Docs</a></:nav>
      </.header>
      """
    end

    def bare(assigns) do
      ~H"""
      <.header id="site-header">
        <:brand>Acme</:brand>
      </.header>
      """
    end

    def custom_toggle(assigns) do
      ~H"""
      <.header id="site-header">
        <:brand>Acme</:brand>
        <:nav><a href="/docs">Docs</a></:nav>
        <:toggle>
          <span data-toggle-icon="closed">Menu</span>
          <span data-toggle-icon="open" hidden>Close</span>
        </:toggle>
      </.header>
      """
    end
  end

  defp render(fun, assigns \\ %{}) do
    render_component(fun, assigns) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="header"]))

  defp attr(document, name), do: document |> root() |> LazyHTML.attribute(name)

  defp part(document, name), do: LazyHTML.query(document, ~s([data-part="#{name}"]))

  defp bar_parts(document) do
    document
    |> LazyHTML.query(~s([data-part="bar"] > [data-part]))
    |> LazyHTML.attribute("data-part")
  end

  test "renders a header root with the header hooks" do
    document = render(&TestComponent.plain/1)
    root = root(document)

    assert LazyHTML.tag(root) == ["header"]
    assert attr(document, "data-element") == ["header"]
    assert attr(document, "data-part") == ["root"]
    assert attr(document, "data-state") == ["closed"]
    assert attr(document, "data-mobile") == []
    assert attr(document, "id") == ["site-header"]
    assert attr(document, "phx-hook") == ["FlintUI.Header"]
  end

  test "renders the brand, nav, and actions zones" do
    document = render(&TestComponent.plain/1)

    assert part(document, "brand") |> LazyHTML.text() |> String.trim() == "Acme"
    assert part(document, "nav") |> LazyHTML.text() |> String.trim() == "Docs"
    assert part(document, "actions") |> LazyHTML.text() |> String.trim() == "Sign in"
    assert part(document, "secondary") |> LazyHTML.to_html() == ""
  end

  test "places the toggle after the actions by default" do
    document = render(&TestComponent.plain/1)

    assert bar_parts(document) == ["brand", "nav", "actions", "toggle"]
  end

  test "places the toggle before the brand when toggle_position is start" do
    document = render(&TestComponent.toggle_start/1)

    assert bar_parts(document) == ["toggle", "brand", "nav", "actions"]
  end

  test "renders the built-in animated toggle mark" do
    document = render(&TestComponent.plain/1)
    toggle = part(document, "toggle")
    mark = LazyHTML.query(toggle, ~s([data-part="toggle-icon"]))

    assert LazyHTML.attribute(mark, "data-default") == [""]
    assert LazyHTML.attribute(mark, "aria-hidden") == ["true"]
    assert LazyHTML.query(toggle, "[data-toggle-icon]") |> LazyHTML.to_html() == ""
  end

  test "keeps custom state icons swappable" do
    document = render(&TestComponent.custom_toggle/1)
    toggle = part(document, "toggle")
    closed = LazyHTML.query(toggle, ~s([data-toggle-icon="closed"]))
    open = LazyHTML.query(toggle, ~s([data-toggle-icon="open"]))

    assert LazyHTML.attribute(closed, "hidden") == []
    assert LazyHTML.attribute(open, "hidden") == [""]
    assert LazyHTML.query(toggle, ~s([data-part="toggle-icon"])) |> LazyHTML.to_html() == ""
  end

  test "makes the panel programmatically focusable" do
    document = render(&TestComponent.plain/1)
    assert LazyHTML.attribute(part(document, "nav"), "tabindex") == ["-1"]

    mobile_document = render(&TestComponent.with_mobile/1)
    assert LazyHTML.attribute(part(mobile_document, "mobile"), "tabindex") == ["-1"]
  end

  test "renders a mobile toggle with ARIA wiring" do
    document = render(&TestComponent.plain/1)
    toggle = part(document, "toggle")

    assert LazyHTML.tag(toggle) == ["button"]
    assert LazyHTML.attribute(toggle, "type") == ["button"]
    assert LazyHTML.attribute(toggle, "aria-controls") == ["site-header-nav"]
    assert LazyHTML.attribute(toggle, "aria-expanded") == ["false"]
    assert LazyHTML.attribute(toggle, "aria-label") == ["Menu"]
  end

  test "uses the mobile slot as the panel and renders the secondary row" do
    document = render(&TestComponent.with_mobile/1)
    toggle = part(document, "toggle")

    assert attr(document, "data-state") == ["open"]
    assert attr(document, "data-mobile") == [""]
    assert LazyHTML.attribute(toggle, "aria-controls") == ["site-header-mobile"]
    assert LazyHTML.attribute(toggle, "aria-expanded") == ["true"]
    assert LazyHTML.attribute(toggle, "aria-label") == ["Open menu"]
    assert part(document, "mobile") |> LazyHTML.text() |> String.trim() == "Mobile"

    assert part(document, "secondary") |> LazyHTML.text() |> String.trim() ==
             "Secondary row"
  end

  test "renders the element chosen by as and forwards rest attributes" do
    document = render(&TestComponent.as_div/1)

    assert LazyHTML.tag(root(document)) == ["div"]
    assert attr(document, "class") == ["custom"]
    assert attr(document, "data-testid") == ["header"]
    assert attr(document, "aria-label") == ["Site"]
  end

  test "omits the toggle when there is no nav or mobile panel" do
    document = render(&TestComponent.bare/1)

    assert part(document, "toggle") |> LazyHTML.to_html() == ""
    assert attr(document, "phx-hook") == []
  end
end
