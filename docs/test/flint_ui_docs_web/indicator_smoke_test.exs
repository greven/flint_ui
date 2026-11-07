defmodule FlintUIDocsWeb.IndicatorSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "indicator page renders the examples", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    assert has_element?(
             view,
             "#main-indicator [data-element='indicator'][data-position='top-right']"
           )

    assert has_element?(
             view,
             "#main-indicator [data-element='badge'][data-variant='solid'][data-color='error'][data-size='xs']",
             "3"
           )

    assert has_element?(
             view,
             "#example-indicator-label-preview [data-element='badge'][data-radius='full']",
             "3"
           )

    assert has_element?(
             view,
             "#example-indicator-color-preview [data-element='badge'][data-color='info']"
           )

    assert has_element?(
             view,
             "#example-indicator-ring-preview [data-element='indicator'][data-ring]"
           )

    assert has_element?(
             view,
             "#example-indicator-live-preview [data-element='badge'][role='status'][aria-label='3 unread messages']"
           )

    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end
end
