defmodule FlintUIDocsWeb.KbdSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "kbd page renders the variants, sizes, and examples", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/kbd")

    assert has_element?(
             view,
             "#usage-kbd-basic [data-element='kbd'][data-variant='raised'][data-size='md']",
             "⌘"
           )

    for variant <- ~w(raised subtle outline) do
      assert has_element?(
               view,
               "#usage-kbd-variants [data-element='kbd'][data-variant='#{variant}']",
               "K"
             )
    end

    for size <- ~w(xs sm md lg xl) do
      assert has_element?(
               view,
               "#usage-kbd-size [data-element='kbd'][data-size='#{size}']",
               "K"
             )
    end

    assert has_element?(
             view,
             "#example-kbd-shortcuts-preview [data-element='kbd'][data-variant='subtle'][data-size='sm']",
             "⌘"
           )

    assert has_element?(view, "#example-kbd-shortcuts-preview", "Command palette")
    assert has_element?(view, "#example-kbd-inline-preview", "to search")

    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "the variant control applies every variant", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/kbd")

    for variant <- ~w(raised subtle outline) do
      view
      |> element("#usage-kbd-basic-controls")
      |> render_change(%{"variant" => variant})

      assert has_element?(
               view,
               "#usage-kbd-basic [data-element='kbd'][data-variant='#{variant}']"
             )
    end
  end

  test "kbd base tab renders the headless contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/kbd?tab=base")

    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#api")
  end

  test "kbd css tab renders the contract", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/kbd?tab=css")

    assert has_element?(view, "#css-parts")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#selectors")
  end
end
