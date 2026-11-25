defmodule FlintUIDocsWeb.ComponentLiveSectionsTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders authored sections from the outline and render clauses", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage h2 a[href='#usage']", "Usage")
    assert has_element?(view, "#usage-button-basic [data-element='button']", "Button")
    assert has_element?(view, "#usage-button-basic-code")
    assert has_element?(view, "#usage-color h3 a[href='#usage-color']", "Color")
  end

  test "renders the progress example idle with a reset affordance", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#example-button-progress-preview")
    assert has_element?(view, "#button-progress-download[aria-label='Download']")
    refute has_element?(view, "#button-progress-download[data-loading]")
    assert has_element?(view, "#button-progress-download [data-progress-bar]")
    assert has_element?(view, "#button-progress-reset", "Reset")
    assert has_element?(view, "#button-progress-status[role='status']")
  end

  test "section controls update the preview and its snippet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(
             view,
             "#usage-button-color-controls select#usage-button-color-control-color[name='color']"
           )

    assert has_element?(
             view,
             "#usage-button-color-controls [data-part='outer_prefix'] > label[for='usage-button-color-control-color']",
             "Color"
           )

    view
    |> element("#usage-button-color-controls")
    |> render_change(%{"color" => "primary"})

    assert has_element?(
             view,
             "#usage-button-color [data-element='button'][data-color='primary']"
           )

    assert has_element?(view, "#usage-button-color-code", ~s(color="primary"))
  end
end
