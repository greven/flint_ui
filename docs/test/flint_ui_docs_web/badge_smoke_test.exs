defmodule FlintUIDocsWeb.BadgeSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "badge page renders the basic example", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/badge")

    assert has_element?(view, "#usage-badge-basic [data-element='badge'][data-variant='subtle']")
    assert has_element?(view, "#usage-badge-basic", "Badge")
    assert has_element?(view, "#usage-badge-dot [data-variant='dot'][data-color='success']")
    assert has_element?(view, "#usage-badge-dot", "Online")
    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "badge base tab renders the headless contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/badge?tab=base")

    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#api")
  end

  test "badge css tab renders the contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/badge?tab=css")

    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#selectors")
    assert has_element?(view, "#theme")
  end
end
