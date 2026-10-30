defmodule FlintUIDocsWeb.GuideLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "landing links into every section", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "a[href='/getting-started/introduction']")
    assert has_element?(view, "a[href='/guides/theming']")
    assert has_element?(view, "a[href='/components']")
  end

  test "header links to the themes page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "header a[href='/themes']", "Themes")
  end

  test "themes page is a placeholder for the theme editor", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/themes")

    assert has_element?(view, "h1", "Themes")
    assert has_element?(view, "header a[href='/themes'][aria-current='page']", "Themes")
    assert has_element?(view, "a[href='/guides/theming']", "Theming guide")
    refute has_element?(view, "aside")
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

  test "pages render the on-this-page outline", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    assert has_element?(view, "#on-this-page", "On this page")
    assert has_element?(view, "#on-this-page .lucide-menu")
    assert has_element?(view, "#on-this-page-nav[phx-hook]")
    assert has_element?(view, "#install h2[data-toc='section']", "1. Add the dependency")
  end

  test "styling page maps needs onto the available mechanisms", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/styling")

    assert has_element?(view, "#scope")
    assert has_element?(view, "#class")
    assert has_element?(view, "#style")
    assert has_element?(view, "#parts")
    assert has_element?(view, "#state")
    assert has_element?(view, "#utilities")
    assert has_element?(view, "#attributes")
    assert has_element?(view, "#components")
    assert has_element?(view, "#button")
    assert has_element?(view, "#section-getting-started[aria-current='page']")
  end

  test "theming page documents tokens and custom themes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming")

    assert has_element?(view, "#how")
    assert has_element?(view, "#tokens")
    assert has_element?(view, "#surfaces")
    assert has_element?(view, "#light-dark")
    assert has_element?(view, "#custom")
    assert has_element?(view, "#palette")
    assert has_element?(view, "#tailwind")
    assert has_element?(view, "header a[href='/themes']", "Themes")
    refute has_element?(view, "header a[href='/themes'][aria-current='page']")

    html = render(view)
    assert html =~ "--fl-color-primary"
    assert html =~ "--fl-color-surface-muted"
    assert html =~ "--fl-disabled-opacity"
    assert html =~ "data-theme"
    refute html =~ "mix flint.palette"
  end

  test "installation page shows its section breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    breadcrumb = "nav[aria-label='Breadcrumb']"
    assert has_element?(view, "#{breadcrumb} a[href='/getting-started']", "Get Started")
    assert has_element?(view, "#{breadcrumb} span", "Overview")
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
