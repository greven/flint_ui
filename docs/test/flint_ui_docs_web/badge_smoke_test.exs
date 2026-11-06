defmodule FlintUIDocsWeb.BadgeSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "badge page renders the basic example", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/badge")

    assert has_element?(view, "#usage-badge-basic [data-element='badge'][data-variant='subtle']")
    assert has_element?(view, "#usage-badge-basic", "Badge")

    assert has_element?(
             view,
             "#example-badge-status_dot [data-variant='dot'][data-color='success']"
           )

    assert has_element?(view, "#example-badge-status_dot", "Online")

    assert has_element?(
             view,
             "#example-badge-custom_color-gradient [data-variant='subtle'][data-color='primary']",
             "New"
           )

    assert has_element?(
             view,
             "#example-badge-custom_color-gradient [data-variant='subtle'][data-color='warning']",
             "Beta"
           )

    assert has_element?(
             view,
             "#example-badge-custom_color-gradient [data-variant='subtle'][data-color='success']",
             "Fresh"
           )

    assert has_element?(
             view,
             "#example-badge-removable_chip [data-element='badge'][data-variant='dashed'] [data-element='button'][aria-label='Remove Elixir filter']"
           )

    assert has_element?(
             view,
             "#example-badge-icon_only [data-element='badge'][role='img'][aria-label='Verified']"
           )

    assert has_element?(
             view,
             "#example-badge-icon_only [data-element='badge'][role='status'][aria-label='3 unread notifications']"
           )

    assert has_element?(
             view,
             "#example-badge-inside_button [data-element='button'] [data-element='badge'][data-size='xs']",
             "3 new"
           )

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
