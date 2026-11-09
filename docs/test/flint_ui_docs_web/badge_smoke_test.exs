defmodule FlintUIDocsWeb.BadgeSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "badge page renders the basic example", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/badge")

    assert has_element?(
             view,
             "#usage-badge-basic [data-element='badge'][data-variant='solid']",
             "Solid"
           )

    assert has_element?(
             view,
             "#usage-badge-basic [data-element='badge'][data-variant='soft']",
             "Soft"
           )

    assert has_element?(
             view,
             "#example-badge-status-dot-preview [data-variant='dot'][data-color='success']"
           )

    assert has_element?(view, "#example-badge-status-dot-preview", "Online")

    assert has_element?(
             view,
             "#example-badge-custom-color-preview-gradient [data-variant='subtle'][data-color='primary']",
             "Pink"
           )

    assert has_element?(
             view,
             "#example-badge-custom-color-preview-gradient [data-variant='subtle'][data-color='warning']",
             "Pony"
           )

    assert has_element?(
             view,
             "#example-badge-custom-color-preview-gradient [data-variant='subtle'][data-color='success']",
             "Club"
           )

    assert has_element?(
             view,
             "#example-badge-removable-badge-preview [data-element='badge'][data-variant='surface'][data-dashed] [data-element='button'][aria-label='Remove Elixir']"
           )

    assert has_element?(
             view,
             "#example-badge-icon-only-preview [data-element='badge'][role='img'][aria-label='Verified']"
           )

    assert has_element?(
             view,
             "#example-badge-icon-only-preview [data-element='badge'][role='status'][aria-label='7 unread notifications']"
           )

    assert has_element?(
             view,
             "#example-badge-inside-button-preview [data-element='button'] [data-element='badge'][data-size='xs']",
             "Pro+"
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
