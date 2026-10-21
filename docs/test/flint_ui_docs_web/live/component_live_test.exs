defmodule FlintUIDocsWeb.ComponentLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "components index renders a section per component type", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    assert has_element?(view, "h1", "Components")

    for {type, components} <- FlintUI.Docs.grouped_components() do
      assert has_element?(view, "#components-#{type}", FlintUIDocsWeb.Nav.type_label(type))

      for name <- components do
        assert has_element?(view, "#components-#{type} a[href='/components/#{name}']")
      end
    end
  end

  test "the components section link points at the landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#section-components[href='/components']")
  end

  test "component page defaults to the styled tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#tab-styled[aria-selected='true']")
    assert has_element?(view, "#tab-base[aria-selected='false']")
    assert has_element?(view, "#panel-styled")
    assert has_element?(view, "#playground-button [data-element='button']")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#usage-variant")
    assert has_element?(view, "#setup")
    refute has_element?(view, "#usage-disabled")
    refute has_element?(view, "#panel-base")
  end

  test "the base tab is deep-linkable", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#tab-base[aria-selected='true']")
    assert has_element?(view, "#panel-base")
    assert has_element?(view, "#anatomy")
    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#api")
    assert has_element?(view, "#data-attributes")
    assert has_element?(view, "#css-variables")
    refute has_element?(view, "#panel-styled")
  end

  test "the css tab holds the styled contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=css")

    assert has_element?(view, "#tab-css[aria-selected='true']")
    assert has_element?(view, "#panel-css")
    assert has_element?(view, "#styling-contract")
    assert has_element?(view, "#theme")
    assert has_element?(view, "#selectors")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#css-variables code", "--fl-collapsible-duration")
    assert has_element?(view, "#customization")
    refute has_element?(view, "#setup")
  end

  test "legacy tabs land on the styled tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=styled")

    assert has_element?(view, "#tab-styled[aria-selected='true']")
    assert has_element?(view, "#panel-styled")

    {:ok, view, _html} = live(conn, ~p"/components/button?tab=api")

    assert has_element?(view, "#tab-styled[aria-selected='true']")
    assert has_element?(view, "#panel-styled")
  end

  test "the styled tab merges the generated component API", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#api #attributes")
    assert has_element?(view, "#api #slots")
    assert has_element?(view, "#api #events")
    assert has_element?(view, "#attributes code", "variant")
    assert has_element?(view, "#attributes code", "disabled")
    assert has_element?(view, "#api code", "data-variant")
    assert has_element?(view, "#api a[href='/components/button?tab=base#data-attributes']")
    refute has_element?(view, "#theme")
  end

  test "the API table folds data attributes and defaults into descriptions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#attributes thead th", "Attr")
    assert has_element?(view, "#attributes thead th", "Layer")
    assert has_element?(view, "#attributes thead th", "Type")
    assert has_element?(view, "#attributes thead th", "Description")
    refute has_element?(view, "#attributes thead th", "Default")

    assert has_element?(view, "#attributes tbody tr", "Data attribute:")
    assert has_element?(view, "#attributes tbody tr", "Default:")
    assert has_element?(view, "#attributes tbody tr code", "data-variant")
    assert has_element?(view, "#attributes tbody tr code", "subtle")
    assert has_element?(view, "#attributes tbody tr code", "'button'")
    assert has_element?(view, "#attributes tbody tr code", "'submit'")
    assert has_element?(view, "#attributes tbody tr code", "'reset'")
    assert has_element?(view, "#attributes tbody tr code", "boolean")
    refute has_element?(view, "#attributes tbody tr code", "'true'")
    refute has_element?(view, "#attributes tbody tr code", "string —")
  end

  test "the base tab documents base-specific content", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#usage-disabled")
    refute has_element?(view, "#usage-variant")
    assert has_element?(view, "#anatomy")
    assert has_element?(view, "#examples")
    assert has_element?(view, "#data-attributes")
    assert has_element?(view, "#data-attributes code", "data-element")
    assert has_element?(view, "#data-attributes code", "data-part")
    refute has_element?(view, "#data-attributes code", "[data-element]")
    refute has_element?(view, "#data-attributes code", "[data-part]")
    assert has_element?(view, "#panel-base #attributes code", "disabled")
    refute has_element?(view, "#panel-base #attributes code", "variant")
  end

  test "the anatomy labels parts and groups attributes by kind", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#anatomy [data-anatomy-legend]")
    assert has_element?(view, "#anatomy [data-anatomy-part='root']")
    assert has_element?(view, "#anatomy [data-anatomy-group='data']", "data-disabled")
    assert has_element?(view, "#anatomy [data-anatomy-group='aria']", "aria-busy")
    assert has_element?(view, "#anatomy [data-anatomy-group='html']", "type")
  end

  test "the anatomy renders every part of a multi-part component", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card?tab=base")

    for part <-
          ~w(root header title description header-actions header-content body section footer footer-content footer-actions) do
      assert has_element?(view, "#anatomy [data-anatomy-part='#{part}']")
    end
  end

  test "collapsible previews wire the hook and disable the trigger", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#playground-collapsible [data-element='collapsible']")
    assert has_element?(view, "#playground-collapsible .border-dashed")

    view |> element("#playground-collapsible button[phx-value-key='disabled']") |> render_click()

    assert has_element?(view, "#playground-collapsible [data-part='trigger'][disabled]")

    {:ok, base, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(base, "#usage-open pre.highlight")
    refute has_element?(base, "#usage-open [data-element='collapsible']")
  end

  test "collapsible usage previews render the styled component with a placeholder", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#usage-collapsible-reveal [data-collapsible]")
    assert has_element?(view, "#usage-collapsible-reveal [data-variant='outline']")
    assert has_element?(view, "#usage-collapsible-reveal .border-dashed")
  end

  test "reveal transition preview customizes the timing", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#usage-collapsible-reveal [data-element='collapsible'][style]")

    view |> element("#usage-collapsible-reveal button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#usage-collapsible-reveal-code", "--fl-collapsible-duration")
    assert has_element?(view, "#usage-collapsible-reveal-code", "cubic-bezier")
  end

  test "collapsible base usage renders code without a preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#usage-open pre.highlight")
    refute has_element?(view, "#usage-open [data-element='collapsible']")
  end

  test "server event usage entries render code only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#usage-toggle_event pre.highlight", "toggle_event")
    refute has_element?(view, "#usage-toggle_event button[phx-value-tab]")
    refute has_element?(view, "#usage-toggle_event [data-part='trigger']")
  end

  test "example code offers Tailwind and CSS flavors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    view
    |> element("#example-collapsible-repos button[phx-value-tab='code']")
    |> render_click()

    assert has_element?(view, "#example-collapsible-repos code", "max-w-74")

    view
    |> element("#example-collapsible-repos button[phx-value-index='1']")
    |> render_click()

    assert has_element?(view, "#example-collapsible-repos code", "repo-card")
    assert has_element?(view, "#example-collapsible-repos-styles", ".repo-list")
  end

  test "find in page example keeps a stable, top-aligned width", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#example-collapsible-find_in_page .self-start")

    assert has_element?(
             view,
             "#example-collapsible-find_in_page [data-element='collapsible'].flex"
           )
  end

  test "card page renders the generated card", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-variant='solid'][data-body='seamless'][data-orientation='vertical'][data-spacing='md'][data-outline='true']"
           )

    assert has_element?(view, "#playground-card [data-part='title']", "Starred repositories")
  end

  test "card omits empty header and footer regions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    refute has_element?(view, "#example-card-collapsible [data-part='header']")
    refute has_element?(view, "#example-card-collapsible [data-part='footer']")

    assert has_element?(view, "#playground-card [data-part='header']")
    assert has_element?(view, "#playground-card [data-part='header-actions']")
    assert has_element?(view, "#playground-card [data-part='footer-actions']")
  end

  test "card body control changes the body treatment", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-body='seamless']"
           )

    view
    |> element("#playground-card-controls")
    |> render_change(%{"body" => "inset"})

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-body='inset']"
           )
  end

  test "card body examples render each treatment", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    for body <- ~w(separated divided inset flush) do
      assert has_element?(
               view,
               "#example-card-body_#{body} [data-element='card'][data-body='#{body}']"
             )
    end

    assert has_element?(
             view,
             "#example-card-body_separated_footer [data-element='card'][data-body='separated-footer']"
           )

    assert has_element?(
             view,
             "#example-card-body_separated_muted [data-element='card'][data-body='separated'][data-variant='muted']"
           )

    assert has_element?(
             view,
             "#example-card-body_inset_well [data-element='card'][data-body='inset'][data-variant='solid']"
           )
  end

  test "card orientation control lays sections out in a row", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-orientation='vertical']"
           )

    view
    |> element("#playground-card-controls")
    |> render_change(%{"orientation" => "horizontal"})

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-orientation='horizontal']"
           )
  end

  test "card examples expose divided and padded body hooks", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#example-card-sectioned [data-element='card'][data-body='divided'] [data-part='section'][data-padded='true']"
           )

    assert has_element?(
             view,
             "#example-card-horizontal [data-element='card'][data-body='divided'] [data-part='section'][data-padded='true']"
           )

    assert has_element?(
             view,
             "#example-card-collapsible [data-part='section'][data-padded='false']"
           )
  end

  test "card shadow control toggles the default", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-shadow='true']"
           )

    view
    |> element("#playground-card button[phx-value-key='shadow']")
    |> render_click()

    assert has_element?(
             view,
             "#playground-card [data-element='card'][data-shadow='false']"
           )
  end

  test "icon page renders a FlintUI icon", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/icon")

    assert has_element?(view, "#playground-icon [data-element='icon']")
  end

  test "loading page renders a FlintUI loading indicator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")

    assert has_element?(view, "#playground-loading [data-element='loading']")
  end

  test "toggle page renders a FlintUI toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/toggle")

    assert has_element?(view, "#playground-toggle [data-element='toggle'][aria-pressed='false']")

    view |> element("button[phx-value-key='pressed']") |> render_click()

    assert has_element?(view, "#playground-toggle [data-element='toggle'][aria-pressed='true']")
  end

  test "toggle click usage renders code only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/toggle?tab=base")

    assert has_element?(view, "#usage-on_click pre.highlight", "on_click")
    refute has_element?(view, "#usage-on_click button[phx-value-tab]")
    refute has_element?(view, "#usage-on_click [data-element='toggle']")
  end

  test "collapsible page documents keyboard interactions on the base tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#keyboard code", "Enter")
    assert has_element?(view, "#keyboard code", "Space")
  end

  test "toggling the disabled control updates the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    refute has_element?(view, "#playground-button [data-disabled]")

    view |> element("button[phx-value-key='disabled']") |> render_click()

    assert has_element?(view, "#playground-button [data-disabled]")
  end

  test "the styled controls offer variant and size selects", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#playground-button-controls select[name='variant']")
    assert has_element?(view, "#playground-button-controls select[name='size']")
  end

  test "switching tabs resets the playground to its defaults", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    view |> element("button[phx-value-key='disabled']") |> render_click()
    assert has_element?(view, "#playground-button [data-disabled]")

    view |> element("#tab-base") |> render_click()

    assert has_element?(view, "#panel-base")
    refute has_element?(view, "#playground-button [data-disabled]")

    view |> element("#tab-styled") |> render_click()

    refute has_element?(view, "#playground-button [data-disabled]")
  end

  test "the playground code tab reflects the current props", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    view |> element("#playground-button button[phx-value-tab='code']") |> render_click()
    assert has_element?(view, "#playground-button-code", "<.button")

    refute has_element?(view, "#playground-button [data-element='button']")

    view |> element("#playground-button button[phx-value-tab='preview']") |> render_click()
    view |> element("button[phx-value-key='disabled']") |> render_click()

    view |> element("#playground-button button[phx-value-tab='code']") |> render_click()
    assert has_element?(view, "#playground-button-code", "disabled")
  end

  test "the playground code tab offers a copy button", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    view |> element("#playground-button button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#playground-button-copy[phx-hook]")
    assert has_element?(view, "#playground-button-copy .lucide-copy")
    assert has_element?(view, "#playground-button-copy .lucide-check")
  end

  test "select and number controls update the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")
    assert has_element?(view, "#playground-loading [data-element='loading']")

    view
    |> element("#playground-loading-controls")
    |> render_change(%{"variant" => "dots-fade"})

    assert has_element?(
             view,
             "#playground-loading [data-element='loading'][data-variant='dots-fade']"
           )
  end

  test "code blocks are syntax highlighted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#setup pre.highlight code span")
  end

  test "usage subsections expose a preview and code tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-variant [data-element='button']")
    assert has_element?(view, "#usage-button-variant button[phx-value-tab='code']")

    view |> element("#usage-button-variant button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#usage-button-variant-code span")
  end

  test "example cards expose a code tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#example-button-icon button[phx-value-tab='code']")

    view |> element("#example-button-icon button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#example-button-icon-code span")
  end

  test "the destructive confirm example renders and its event is tolerated", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(
             view,
             "#example-button-destructive_confirm [data-element='button'][data-confirm='Delete item?'][phx-value-id='67']"
           )

    # The confirm dialog is client-side, so the click lands here directly; the
    # docs swallow the event instead of crashing on an unknown one.
    view
    |> element("#example-button-destructive_confirm [data-element='button']")
    |> render_click()

    assert has_element?(view, "#example-button-destructive_confirm [data-element='button']")
  end

  test "the component page shows a section and type breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    breadcrumb = "nav[aria-label='Breadcrumb']"
    assert has_element?(view, "#{breadcrumb} a[href='/components']", "Components")
    assert has_element?(view, "#{breadcrumb} span", "Element")
  end

  test "the components index has no breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    refute has_element?(view, "nav[aria-label='Breadcrumb']")
  end

  test "unknown component redirects to the components index", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/components"}}} = live(conn, ~p"/components/nope")
  end

  test "every component renders its styled, base, and css tabs", %{conn: conn} do
    for name <- FlintUI.components() do
      {:ok, docs, _html} = live(conn, ~p"/components/#{name}")
      assert has_element?(docs, "#panel-styled")
      assert has_element?(docs, "#playground-#{name} [data-element]")

      {:ok, base, _html} = live(conn, ~p"/components/#{name}?tab=base")
      assert has_element?(base, "#panel-base")
      assert has_element?(base, "#usage pre.highlight")
      refute has_element?(base, "#playground-#{name}")

      {:ok, css, _html} = live(conn, ~p"/components/#{name}?tab=css")
      assert has_element?(css, "#panel-css")
      assert has_element?(css, "#theme")
      assert has_element?(css, "#styling-contract")
    end
  end
end
