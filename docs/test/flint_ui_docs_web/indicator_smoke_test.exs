defmodule FlintUIDocsWeb.IndicatorSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "indicator page renders the usage attributes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    assert has_element?(
             view,
             "#usage-indicator-basic [data-element='indicator'][data-position='top-right']"
           )

    assert has_element?(
             view,
             "#usage-indicator-basic [data-element='badge'][data-variant='solid'][data-color='error'][data-size='xs']",
             "3"
           )

    assert has_element?(view, "#usage-label h3 a[href='#usage-label']", "Label")
    assert has_element?(view, "#usage-indicator-label [data-element='badge']", "1")

    assert has_element?(
             view,
             "#usage-indicator-color [data-element='badge'][data-color='error'][data-variant='solid']"
           )

    assert has_element?(view, "#usage-indicator-position [data-element='indicator']")
    assert has_element?(view, "#usage-indicator-attention [data-element='indicator']")
    assert has_element?(view, "#usage-indicator-ring [data-element='indicator'][data-ring]")
  end

  test "indicator page renders the examples", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    assert has_element?(
             view,
             "#example-indicator-dot-preview [data-element='badge'][data-radius='full']"
           )

    assert has_element?(
             view,
             "#example-indicator-live-preview [data-element='badge'][role='status'][aria-label='3 unread messages']"
           )

    assert has_element?(view, "#example-indicator-inline-preview [data-element='badge']", "3")

    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "the position controls update the badge and its snippet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    view
    |> element("#usage-indicator-position-controls")
    |> render_change(%{"position" => "bottom-left", "offset" => "4"})

    assert has_element?(
             view,
             "#usage-indicator-position [data-element='indicator'][data-position='bottom-left'][style*='--fl-indicator-offset: 4px']"
           )

    assert has_element?(view, "#usage-indicator-position-code", "offset={4}")
  end

  test "the attention section shows each animation and its snippet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    assert has_element?(view, "#usage-indicator-attention [data-attention='ping']")
    assert has_element?(view, "#usage-indicator-attention [data-attention='pulse']")
    assert has_element?(view, "#usage-indicator-attention [data-attention='bounce']")
    assert has_element?(view, "#usage-indicator-attention [data-attention='heartbeat']")

    assert has_element?(view, "#usage-indicator-attention-code", ~s(attention="ping"))
    assert has_element?(view, "#usage-indicator-attention-code", ~s(attention="pulse"))
    assert has_element?(view, "#usage-indicator-attention-code", ~s(attention="bounce"))
    assert has_element?(view, "#usage-indicator-attention-code", ~s(attention="heartbeat"))
  end

  test "the color controls update the badge and its snippet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/indicator")

    view
    |> element("#usage-indicator-color-controls")
    |> render_change(%{"color" => "info", "variant" => "outline"})

    assert has_element?(
             view,
             "#usage-indicator-color [data-element='badge'][data-color='info'][data-variant='outline']"
           )

    assert has_element?(view, "#usage-indicator-color-code", ~s(color="info"))
    assert has_element?(view, "#usage-indicator-color-code", ~s(variant="outline"))
  end
end
