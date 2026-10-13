defmodule FlintUIDocsWeb.GuideLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "landing links into every section", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "a[href='/getting-started/introduction']")
    assert has_element?(view, "a[href='/guides/theming']")
    assert has_element?(view, "a[href='/components']")
  end

  test "introduction page explains the two layers", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/introduction")

    assert has_element?(view, "#base")
    assert has_element?(view, "#styled")
    assert has_element?(view, "#theming")
    assert has_element?(view, "#section-getting-started[aria-current='page']")
  end

  test "installation page walks through setup", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    assert has_element?(view, "#install")
    assert has_element?(view, "#setup")
    assert has_element?(view, "#generate")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#commands")
    assert render(view) =~ "mix flint.setup"
    assert render(view) =~ "mix flint.add"
  end

  test "theming page documents tokens and custom themes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming")

    assert has_element?(view, "#how")
    assert has_element?(view, "#tokens")
    assert has_element?(view, "#light-dark")
    assert has_element?(view, "#custom")
    assert has_element?(view, "#tailwind")

    html = render(view)
    assert html =~ "--fl-color-primary"
    assert html =~ "data-theme"
  end

  test "the sidebar lists only the active section", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming")

    assert has_element?(view, "#section-guides[aria-current='page']")
    assert has_element?(view, "aside a[href='/guides/theming']")
    refute has_element?(view, "aside a[href='/components/button']")
    refute has_element?(view, "aside a[href='/getting-started/introduction']")
  end

  test "section roots redirect to their first page", %{conn: conn} do
    assert redirected_to(get(conn, ~p"/getting-started")) == "/getting-started/introduction"
    assert redirected_to(get(conn, ~p"/guides")) == "/guides/theming"
  end
end
