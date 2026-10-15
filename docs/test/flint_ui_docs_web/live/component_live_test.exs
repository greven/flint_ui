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

  test "component page defaults to the base tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#tab-base[aria-selected='true']")
    assert has_element?(view, "#tab-api[aria-selected='false']")
    assert has_element?(view, "#panel-base")
    assert has_element?(view, "#preview [data-element='button']")
    assert has_element?(view, "#usage")
    refute has_element?(view, "#api")
  end

  test "the api tab is deep-linkable", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=api")

    assert has_element?(view, "#tab-api[aria-selected='true']")
    assert has_element?(view, "#api")
    assert has_element?(view, "#attributes")
    assert has_element?(view, "#styled-attributes")
    assert has_element?(view, "#styled-slots")
    assert has_element?(view, "#slots")
    assert has_element?(view, "#events")
    refute has_element?(view, "#preview")
  end

  test "the base tab documents usage and styling", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage")
    assert has_element?(view, "#structure")
    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#styling")
    refute has_element?(view, "#examples")
  end

  test "the styled tab documents the generated component", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=styled")

    assert has_element?(view, "#tab-styled[aria-selected='true']")
    assert has_element?(view, "#panel-styled")
    assert has_element?(view, "#styled")
    assert has_element?(view, "#styled-preview [data-element='button'][data-variant='solid']")
    assert has_element?(view, "#examples")
    assert has_element?(view, "#styled code", "mix flint.add button")
    refute has_element?(view, "#preview")
  end

  test "icon page renders a FlintUI icon", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/icon")

    assert has_element?(view, "#preview [data-element='icon']")
    assert has_element?(view, "#accessibility code", "lucide-circle-alert")
  end

  test "loading page renders a FlintUI loading indicator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")

    assert has_element?(view, "#preview [data-element='loading']")
  end

  test "toggle page renders a FlintUI toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/toggle")

    assert has_element?(view, "#preview [data-element='toggle'][aria-pressed='false']")

    view |> element("button[phx-value-key='pressed']") |> render_click()

    assert has_element?(view, "#preview [data-element='toggle'][aria-pressed='true']")
  end

  test "collapsible page documents keyboard interactions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#keyboard code", "Enter")
    assert has_element?(view, "#keyboard code", "Space")
  end

  test "toggling the disabled control updates the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    refute has_element?(view, "#preview [data-disabled]")

    view |> element("button[phx-value-key='disabled']") |> render_click()

    assert has_element?(view, "#preview [data-disabled]")
  end

  test "switching tabs resets the playground to its defaults", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    view |> element("button[phx-value-key='disabled']") |> render_click()
    assert has_element?(view, "#preview [data-disabled]")

    view |> element("#tab-api") |> render_click()

    assert has_element?(view, "#api")

    view |> element("#tab-base") |> render_click()

    refute has_element?(view, "#preview [data-disabled]")
  end

  test "the playground code tab reflects the current props", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    view |> element("button[phx-value-tab='code']") |> render_click()
    assert has_element?(view, "#playground-button-code", "<.button")

    refute has_element?(view, "#preview [data-element='button']")

    view |> element("button[phx-value-tab='preview']") |> render_click()
    view |> element("button[phx-value-key='disabled']") |> render_click()

    view |> element("button[phx-value-tab='code']") |> render_click()
    assert has_element?(view, "#playground-button-code", "disabled")
  end

  test "the playground code tab offers a copy button", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    view |> element("button[phx-value-tab='code']") |> render_click()

    assert has_element?(view, "#playground-button-copy[phx-hook]")
  end

  test "select and number controls update the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")
    assert has_element?(view, "#preview [data-element='loading']")

    view
    |> element("#playground-loading-controls")
    |> render_change(%{"variant" => "dots-fade"})

    assert has_element?(view, "#preview [data-element='loading'][data-variant='dots-fade']")
  end

  test "code blocks are syntax highlighted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#structure pre.highlight code span")
  end

  test "example cards expose a code tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=styled")

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

  test "every component renders its base and styled tabs", %{conn: conn} do
    for name <- FlintUI.components() do
      {:ok, base, _html} = live(conn, ~p"/components/#{name}")
      assert has_element?(base, "#panel-base")
      assert has_element?(base, "#preview [data-element]")

      {:ok, styled, _html} = live(conn, ~p"/components/#{name}?tab=styled")
      assert has_element?(styled, "#panel-styled")
      assert has_element?(styled, "#styled-preview")
    end
  end
end
