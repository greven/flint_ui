defmodule FlintUIDocsWeb.HeadingSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "heading page renders the scale, slots, and truncation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/heading")

    assert has_element?(
             view,
             "#usage-heading-basic [data-element='heading'][data-size='4xl'][data-color='highlighted']"
           )

    assert has_element?(
             view,
             "#usage-heading-levels [data-element='heading'][data-size='5xl']"
           )

    assert has_element?(
             view,
             "#usage-heading-kicker-subtitle [data-part='kicker']",
             "Release notes"
           )

    assert has_element?(
             view,
             "#usage-heading-kicker-subtitle [data-part='subtitle']",
             "A headless component layer"
           )

    assert has_element?(
             view,
             "#usage-heading-truncation [data-element='heading'][data-truncate]"
           )

    assert has_element?(
             view,
             "#usage-heading-truncation [data-element='heading'][data-line-clamp='2']"
           )

    assert has_element?(view, "#example-heading-page-header-preview", "Build interfaces")
    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "the heading controls update the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/heading")

    view
    |> element("#usage-heading-basic-controls")
    |> render_change(%{
      "size" => "6xl",
      "color" => "primary",
      "weight" => "bold",
      "align" => "center"
    })

    assert has_element?(
             view,
             "#usage-heading-basic [data-element='heading'][data-size='6xl'][data-color='primary'][data-weight='bold'][data-align='center']"
           )
  end

  test "heading base and css tabs render the contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/heading?tab=base")

    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#api")

    {:ok, view, _html} = live(conn, ~p"/components/heading?tab=css")

    assert has_element?(view, "#css-parts")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#selectors")
  end
end
