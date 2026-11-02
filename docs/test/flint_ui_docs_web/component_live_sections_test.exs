defmodule FlintUIDocsWeb.ComponentLiveSectionsTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders authored sections from the outline and render clauses", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage h2 a[href='#usage']", "Usage")
    assert has_element?(view, "#usage-button-basic [data-element='button']", "Unbound")
    assert has_element?(view, "#usage-button-basic-code")
    assert has_element?(view, "#usage-color h3 a[href='#usage-color']", "Color")
  end

  test "section controls update the preview and its snippet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-color-controls select[name='color']")

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
