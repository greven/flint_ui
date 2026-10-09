defmodule FlintUIDocsWeb.ComponentLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "overview lists the registered components", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "FlintUI"
    assert html =~ ~p"/components/button"
    assert html =~ ~p"/components/collapsible"
    assert html =~ ~p"/components/icon"
    assert html =~ ~p"/components/loading"
  end

  test "component page renders the preview and API reference", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#preview")
    assert has_element?(view, "#api")
    assert has_element?(view, "#preview [data-element='button']")
  end

  test "icon page renders a FlintUI icon", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/icon")

    assert has_element?(view, "#preview [data-element='icon']")
  end

  test "loading page renders a FlintUI loading indicator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")

    assert has_element?(view, "#preview [data-element='loading']")
  end

  test "toggling the disabled control updates the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    refute has_element?(view, "#preview [data-disabled]")

    view |> element("button[phx-value-key='disabled']") |> render_click()

    assert has_element?(view, "#preview [data-disabled]")
  end

  test "unknown component redirects to the overview", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/"}}} = live(conn, ~p"/components/nope")
  end
end
