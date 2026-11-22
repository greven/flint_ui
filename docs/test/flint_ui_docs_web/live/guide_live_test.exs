defmodule FlintUIDocsWeb.GuideLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Theme.Tokens

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
               "#{meta.label} #{FlintUI.Icons.version_label(set)}"
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

  test "theming overview routes into the guide", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming")

    assert has_element?(view, "#how")
    assert has_element?(view, "#layers")
    assert has_element?(view, "#start")
    assert has_element?(view, "aside a[href='/guides/theming'][aria-current='page']")

    for path <- [
          "/guides/theming/color",
          "/guides/theming/themes",
          "/guides/theming/tokens",
          "/guides/theming/customizing",
          "/guides/theming/css-utilities"
        ] do
      assert has_element?(view, "a[href='#{path}']")
    end

    html = render(view)
    assert html =~ "--fl-color-primary"
    assert html =~ "color-scheme"
  end

  test "color page documents palettes and roles", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/color")

    assert has_element?(view, "#palettes")
    assert has_element?(view, "#palette-colors")
    assert has_element?(view, "#semantic-colors")
    assert has_element?(view, "#absolute")
    assert has_element?(view, "aside a[href='/guides/theming/color'][aria-current='page']")

    # The default palette is the Tailwind source, listed once as "default".
    assert has_element?(view, "[data-phx-palette='default']")
    assert has_element?(view, "[data-phx-palette='pastel']")
    refute has_element?(view, "[data-phx-palette='tailwind']")

    # Every hue gets a main swatch plus its full 50..950 scale.
    assert has_element?(view, "[data-color-swatch='rose'] [data-swatch-main]")
    assert has_element?(view, "[data-color-swatch='rose'] [data-shade='50']")
    assert has_element?(view, "[data-color-swatch='rose'] [data-shade='950']")
    assert has_element?(view, "[data-color-swatch='amber'] [data-swatch-core]", "500")
    assert has_element?(view, "[data-color-swatch='green'] [data-swatch-core]", "700")

    # Selecting a palette re-renders the swatches against that palette's ramps.
    assert has_element?(view, "#color-swatches[data-active-palette='default']")

    render_click(view, "set-palette", %{"palette" => "pastel"})

    assert has_element?(view, "#color-swatches[data-active-palette='pastel']")
    assert has_element?(view, "[data-color-swatch='amber'] [data-swatch-core]", "400")
    assert has_element?(view, "[data-color-swatch='gray'] [data-swatch-core]", "600")

    # The neutral ramps sit under the hue grid as fixed Tailwind source ramps.
    assert has_element?(view, "#neutral-ramps")
    assert has_element?(view, "[data-color-swatch='neutral-neutral']", "default")
    assert has_element?(view, "[data-color-swatch='neutral-neutral'] [data-shade='950']")
    assert has_element?(view, "[data-color-swatch='neutral-zinc'] [data-swatch-core]", "600")

    html = render(view)
    assert html =~ ~s|data-copy-value="var(--fl-color-rose)"|
    assert html =~ ~s|aria-label="Copy var(--fl-color-rose)"|
    assert html =~ ~s|data-copy-value="var(--fl-color-rose-300)"|
  end

  test "themes page documents presets, schemes, and custom themes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/themes")

    assert has_element?(view, "#presets")
    assert has_element?(view, "#light-dark")
    assert has_element?(view, "#custom-themes")
    assert has_element?(view, "a[href='/themes']", "Themes page")
    assert has_element?(view, "header a[href='/themes']", "Themes")
    refute has_element?(view, "header a[href='/themes'][aria-current='page']")
  end

  test "design tokens grid links to every token page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/tokens")

    assert has_element?(view, "#groups")
    assert has_element?(view, "#component-inputs")
    assert has_element?(view, "#override")

    for page <- Tokens.pages() do
      assert has_element?(view, "a[href='#{page.path}']"),
             "expected the token grid to link to #{page.path}"
    end
  end

  test "every token page renders its reference", %{conn: conn} do
    for page <- Tokens.pages() do
      {:ok, view, _html} = live(conn, page.path)

      assert has_element?(view, "h1", page.title)
      assert has_element?(view, "aside a[href='#{page.path}'][aria-current='page']")

      token_prefix = String.replace(page.namespace, "*", "")
      assert render(view) =~ token_prefix
    end
  end

  test "animations token page separates shared and component keyframes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/tokens/animations")

    assert has_element?(view, "#shared")
    assert has_element?(view, "#composing")
    assert has_element?(view, "#component-animations")
    assert render(view) =~ "@keyframes fl-pop-in"
    assert render(view) =~ "@keyframes fl-shake"
    assert has_element?(view, "a[href='/components/indicator']")
  end

  test "color token reference includes the neutral role", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/tokens/colors")

    assert has_element?(view, "td", "neutral")
    assert render(view) =~ "--fl-color-neutral"
  end

  test "customizing page collects the override recipes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/customizing")

    assert has_element?(view, "#tokens")
    assert has_element?(view, "#color-instance")
    assert has_element?(view, "#chrome")
    assert has_element?(view, "#remapping-a-hue")
    assert has_element?(view, "#role-remap")
    assert has_element?(view, "#custom-hues")

    html = render(view)
    assert html =~ "--fl-surface-base"
    assert html =~ "--fl-surface-page-tint"
    assert html =~ "--fl-surface-page-lift"
    assert html =~ "--fl-surface-page-light"
    assert html =~ "--fl-surface-page-dark"
    assert html =~ "--fl-text-base"
    assert html =~ "mix flint.palette"
    assert html =~ "color-rose"
  end

  test "css utilities page documents the included utility layer", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/css-utilities")

    assert has_element?(view, "h1", "CSS Utilities")
    assert has_element?(view, "#included")
    assert has_element?(view, "#layers")
    assert has_element?(view, "#layout")
    assert has_element?(view, "#motion")
    assert has_element?(view, "#responsive")
    assert has_element?(view, "#reference")
    assert has_element?(view, "#tailwind")

    html = render(view)
    assert html =~ "mix flint.utilities"
    assert html =~ "flint.setup"
    assert html =~ "no-utilities"
    assert html =~ "fl-stack"
    assert html =~ "fl-grid"
    assert html =~ "fl-flex"
    assert html =~ "fl-animate-pulse"
    assert html =~ "prefers-reduced-motion"
    refute html =~ "Planned"
  end

  test "css utilities reference filters by class or declaration", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/css-utilities")

    html =
      view
      |> element("#utility-search-form")
      |> render_change(%{"query" => "grid-cols"})

    assert html =~ "fl-grid-cols-12"
    refute html =~ "fl-cursor-wait"
  end

  test "css utilities reference includes the motion family", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guides/theming/css-utilities")

    html =
      view
      |> element("#utility-search-form")
      |> render_change(%{"query" => "animate-"})

    assert html =~ "fl-animate-pulse"
    assert html =~ "fl-animate-fade-in"
    assert html =~ "fl-duration-slow"
    assert html =~ "fl-ease-linear"
  end

  test "installation page shows its section breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started/installation")

    breadcrumb = "nav[aria-label='Breadcrumb']"

    assert has_element?(
             view,
             "#{breadcrumb} a[href='/getting-started/introduction']",
             "Get Started"
           )

    assert has_element?(
             view,
             "#{breadcrumb} a[href='/getting-started/introduction']",
             "Overview"
           )

    assert has_element?(view, "#{breadcrumb} span", "Installation")
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
