defmodule FlintUIDocsWeb.TextSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "text page renders the tiers, inline form, and links", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/text")

    assert has_element?(
             view,
             "#usage-text-basic [data-element='text'][data-size='md'][data-color='default']"
           )

    assert has_element?(
             view,
             "#usage-text-inline [data-element='text'][data-size='md'][data-color='primary']",
             "installation guide"
           )

    assert has_element?(
             view,
             "#usage-text-links a[data-element='text'][href='/components/heading']",
             "Read the heading guide"
           )

    assert has_element?(
             view,
             "#usage-text-links a[data-element='text'][href='/components/button']",
             "Go to the button component"
           )

    assert has_element?(
             view,
             "#usage-text-truncation [data-element='text'][data-truncate]"
           )

    assert has_element?(
             view,
             "#usage-text-truncation [data-element='text'][data-line-clamp='2']"
           )

    assert has_element?(view, "#example-text-article-lede-preview", "Designing a component layer")
    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "the text controls update the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/text")

    view
    |> element("#usage-text-basic-controls")
    |> render_change(%{
      "size" => "2xl",
      "color" => "toned",
      "weight" => "bold",
      "align" => "center"
    })

    assert has_element?(
             view,
             "#usage-text-basic [data-element='text'][data-size='2xl'][data-color='toned'][data-weight='bold'][data-align='center']"
           )
  end

  test "text base and css tabs render the contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/text?tab=base")

    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#api")

    {:ok, view, _html} = live(conn, ~p"/components/text?tab=css")

    assert has_element?(view, "#css-parts")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#selectors")
  end
end
