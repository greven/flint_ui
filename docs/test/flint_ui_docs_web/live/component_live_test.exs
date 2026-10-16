defmodule FlintUIDocsWeb.ComponentLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "components index renders a section per component type", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    assert has_element?(view, "h1", "Components")

    for {type, _components} <- FlintUI.Docs.grouped_components() do
      assert has_element?(view, "#components-#{type}", FlintUIDocsWeb.Nav.type_label(type))
    end
  end

  test "the components section link points at the landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#section-components[href='/components']")
  end

  test "component page defaults to the docs tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#tab-docs[aria-selected='true']")
    assert has_element?(view, "#tab-base[aria-selected='false']")
    assert has_element?(view, "#panel-docs")
    assert has_element?(view, "#playground-button [data-element='button']")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#usage-disabled")
    assert has_element?(view, "#usage-variant")
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
    refute has_element?(view, "#css-variables")
    refute has_element?(view, "#panel-docs")
  end

  test "the styles tab holds theme and css variables", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=styles")

    assert has_element?(view, "#tab-styles[aria-selected='true']")
    assert has_element?(view, "#panel-styles")
    assert has_element?(view, "#theme")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#css-variables code", "--fl-collapsible-height")
  end

  test "legacy tabs land on the docs tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=styled")

    assert has_element?(view, "#tab-docs[aria-selected='true']")
    assert has_element?(view, "#panel-docs")

    {:ok, view, _html} = live(conn, ~p"/components/button?tab=api")

    assert has_element?(view, "#tab-docs[aria-selected='true']")
    assert has_element?(view, "#panel-docs")
  end

  test "the docs tab merges the generated component API", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#api #attributes")
    assert has_element?(view, "#api #slots")
    assert has_element?(view, "#api #events")
    assert has_element?(view, "#attributes code", "variant")
    assert has_element?(view, "#attributes code", "disabled")
    assert has_element?(view, "#api code", "data-variant")
    assert has_element?(view, "#api a[href='/components/button?tab=base#data-attributes']")
    assert has_element?(view, "#changelog")
    refute has_element?(view, "#theme")
  end

  test "the base tab documents base-specific content", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#usage-disabled")
    refute has_element?(view, "#usage-variant")
    assert has_element?(view, "#anatomy")
    assert has_element?(view, "#data-attributes")
    assert has_element?(view, "#panel-base #attributes code", "disabled")
    refute has_element?(view, "#panel-base #attributes code", "variant")
  end

  test "collapsible previews wire the hook and disable the trigger", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#playground-collapsible [data-collapsible]")
    assert has_element?(view, "#playground-collapsible .border-dashed")
    assert has_element?(view, "#usage-collapsible-open [phx-hook='FlintUI.Collapsible']")
    assert has_element?(view, "#usage-collapsible-open [data-part='trigger']")

    view |> element("#playground-collapsible button[phx-value-key='disabled']") |> render_click()

    assert has_element?(view, "#playground-collapsible [data-part='trigger'][disabled]")
  end

  test "collapsible usage previews render the styled component with a placeholder", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#usage-collapsible-open [data-collapsible]")
    assert has_element?(view, "#usage-collapsible-open [data-variant='outline']")
    assert has_element?(view, "#usage-collapsible-open .border-dashed")

    assert has_element?(view, "#usage-collapsible-disabled [data-collapsible]")
    assert has_element?(view, "#usage-collapsible-disabled [data-part='trigger'][disabled]")
  end

  test "reveal transition preview customizes the timing", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#usage-collapsible-reveal [data-element='collapsible'][style]")

    view |> element("#usage-collapsible-reveal button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#usage-collapsible-reveal-code", "--fl-collapsible-duration")
    assert has_element?(view, "#usage-collapsible-reveal-code", "cubic-bezier")
  end

  test "collapsible base usage previews stay headless", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#usage-collapsible-open [data-element='collapsible']")
    refute has_element?(view, "#usage-collapsible-open [data-collapsible]")
  end

  test "server events usage entry renders code only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#usage-collapsible-events-code", "toggle_event")
    refute has_element?(view, "#usage-collapsible-events button[phx-value-tab]")
    refute has_element?(view, "#usage-collapsible-events [data-part='trigger']")
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
             "#playground-card [data-element='card'][data-variant='outline'][data-size='md']"
           )

    assert has_element?(view, "#playground-card [data-part='title']", "Starred repositories")
  end

  test "card omits empty header and footer regions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    refute has_element?(view, "#usage-card-flush [data-part='header']")
    refute has_element?(view, "#usage-card-flush [data-part='footer']")

    assert has_element?(view, "#playground-card [data-part='header']")
  end

  test "card flush control removes spacing", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    refute has_element?(view, "#playground-card [data-element='card'][data-flush]")

    view |> element("#playground-card button[phx-value-key='flush']") |> render_click()

    assert has_element?(view, "#playground-card [data-element='card'][data-flush]")
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

  test "toggle click example renders code only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/toggle")

    refute has_element?(view, "#usage-toggle-on_click")
    assert has_element?(view, "#example-toggle-on_click-code", "on_click")
    refute has_element?(view, "#example-toggle-on_click button[phx-value-tab]")
    refute has_element?(view, "#example-toggle-on_click [data-element='toggle']")
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

    view |> element("#tab-docs") |> render_click()

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
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#anatomy pre.highlight code span")
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

  test "the component page shows a section breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "nav[aria-label='Breadcrumb'] span", "Components")
  end

  test "the components index has no breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    refute has_element?(view, "nav[aria-label='Breadcrumb']")
  end

  test "unknown component redirects to the components index", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/components"}}} = live(conn, ~p"/components/nope")
  end

  test "every component renders its docs, base, and styles tabs", %{conn: conn} do
    for name <- FlintUI.components() do
      {:ok, docs, _html} = live(conn, ~p"/components/#{name}")
      assert has_element?(docs, "#panel-docs")
      assert has_element?(docs, "#playground-#{name} [data-element]")

      {:ok, base, _html} = live(conn, ~p"/components/#{name}?tab=base")
      assert has_element?(base, "#panel-base")
      assert has_element?(base, "#playground-#{name} [data-element]")

      {:ok, styles, _html} = live(conn, ~p"/components/#{name}?tab=styles")
      assert has_element?(styles, "#panel-styles")
      assert has_element?(styles, "#theme")
    end
  end
end
