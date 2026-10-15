defmodule FlintUIDocsWeb.ComponentLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "components index lists the registered components", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/components")

    assert html =~ "Components"
    assert html =~ ~p"/components/button"
    assert html =~ ~p"/components/collapsible"
    assert html =~ ~p"/components/icon"
    assert html =~ ~p"/components/loading"
    assert html =~ ~p"/components/toggle"
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
