defmodule FlintUIDocsWeb.CardSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "card page renders the link example", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#usage-card-link a[data-element='card'][data-link][aria-labelledby='card-link-title']"
           )

    assert has_element?(view, "#usage-card-link", "Browse components")
    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end
end
