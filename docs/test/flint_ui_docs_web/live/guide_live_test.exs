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

  test "guides use the shared page header and link treatment", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    assert has_element?(view, "main h1.text-4xl", "Installation")
    assert has_element?(view, "main a[href='/components'].docs-link")
    assert has_element?(view, "main .docs-prose code.docs-code", "mix deps.get")
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
    assert has_element?(view, "#scope h2 a[href='#scope']", "Where a change belongs")
    assert has_element?(view, "#class")
    assert has_element?(view, "#style")
    assert has_element?(view, "#parts")
    assert has_element?(view, "#state")
    assert has_element?(view, "#utilities")
    assert has_element?(view, "#attributes")
    assert has_element?(view, "#section-getting-started[aria-current='page']")
  end

  test "icons guide documents both install modes and every icon set", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/icons")

    assert has_element?(view, "#install")
    assert has_element?(view, "#sets")
    assert has_element?(view, "#tailwind")
    assert has_element?(view, "#css")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#licenses")
    assert has_element?(view, "#section-guides[aria-current='page']")
    assert has_element?(view, "aside a[href='/guides/icons']")

    # Every class-based set links to its upstream source, straight from the
    # set metadata so the table cannot drift from what the task installs.
    for set <- FlintUI.Icons.sets(), set != :flag_icons do
      meta = FlintUI.Icons.get!(set)

      assert has_element?(
               view,
               "#sets a[href='#{FlintUI.Icons.source_url(set)}'][target='_blank'][rel='noopener']",
               "#{meta.label} #{meta.version}"
             )
    end

    html = render(view)
    assert html =~ "flint.icons"
    assert html =~ "--tailwind"
    assert html =~ "--css"
    assert html =~ "hero-x-mark-mini"
    assert html =~ "lucide-house"
    assert html =~ "si-github"
    refute html =~ "/images/flags/pt.svg"
  end

  test "flags guide documents assets, dynamic codes, shapes, and raw classes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/flags")

    assert has_element?(view, "#install")
    assert has_element?(view, "#assets")
    assert has_element?(view, "#dynamic")
    assert has_element?(view, "#shapes")
    assert has_element?(view, "#classes")
    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#licenses")
    assert has_element?(view, "#section-guides[aria-current='page']")
    assert has_element?(view, "aside a[href='/guides/flags']")

    html = render(view)
    assert html =~ "--assets"
    assert html =~ "flint.icons.copy_flags"
    assert html =~ "/images/flags/pt.svg"
    assert html =~ "/images/flags/pt-square.svg"
    assert html =~ "flag-icons"
    assert html =~ "flag-pt-square"
  end

  test "theming page documents tokens and custom themes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming")

    assert has_element?(view, "#how")
    assert has_element?(view, "#tokens")
    assert has_element?(view, "#focus")
    assert has_element?(view, "#surfaces")
    assert has_element?(view, "#borders")
    assert has_element?(view, "#light-dark")
    assert has_element?(view, "#absolute")
    assert has_element?(view, "#custom")
    assert has_element?(view, "#palette")
    assert has_element?(view, "#tailwind")
    assert has_element?(view, "header a[href='/themes']", "Themes")
    refute has_element?(view, "header a[href='/themes'][aria-current='page']")

    html = render(view)
    assert html =~ "--fl-color-primary"
    assert html =~ "--fl-color-surface-subtle"
    assert html =~ "--fl-color-border-strong"
    assert html =~ "--fl-surface-step"
    assert html =~ "--fl-disabled-opacity"
    assert html =~ "data-theme"
    assert html =~ "data-focus"
    assert html =~ "--fl-focus-border-color"
    assert html =~ "--fl-focus-color-error"
    refute html =~ "mix flint.palette"
  end

  test "installation page shows its section breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    breadcrumb = "nav[aria-label='Breadcrumb']"

    assert has_element?(
             view,
             "#{breadcrumb} a[href='/getting-started/introduction']",
             "Get Started"
           )

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
