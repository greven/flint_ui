defmodule FlintUIDocsWeb.KnownDateSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "the known date page renders its parts, order, and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/known_date")

    assert has_element?(
             view,
             "#usage-known-date-basic [data-element='known_date'][data-known_date][data-order='dmy'][data-size='md'][data-radius='md']"
           )

    assert has_element?(
             view,
             "#usage-known-date-basic [data-part='field'][data-field='day'] label[for='known-date-basic-day']"
           )

    assert has_element?(
             view,
             "#usage-known-date-basic [data-part='value'][name='date_of_birth'][value='2007-03-27']"
           )

    view
    |> element("#usage-known-date-basic-controls")
    |> render_change(%{"size" => "lg", "radius" => "xl"})

    assert has_element?(
             view,
             "#usage-known-date-basic [data-element='known_date'][data-size='lg'][data-radius='xl']"
           )
  end

  test "the locale examples change the field order", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/known_date")

    assert has_element?(
             view,
             "#usage-known-date-locale [data-element='known_date'][data-order='mdy']"
           )

    assert has_element?(
             view,
             "#usage-known-date-locale [data-element='known_date'][data-order='ymd']"
           )
  end

  test "the validation examples link the hint and multiple errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/known_date")

    assert has_element?(
             view,
             "#usage-known-date-validation [data-element='known_date'][data-invalid][data-max]"
           )

    assert has_element?(
             view,
             "#usage-known-date-validation [data-part='control'][aria-invalid='true']"
           )

    assert has_element?(view, "#usage-known-date-validation [data-part='hint']")

    assert has_element?(
             view,
             "#usage-known-date-validation [data-part='error']",
             "is not a real date"
           )

    assert has_element?(
             view,
             "#usage-known-date-validation [data-part='error']",
             "must be in the past"
           )

    assert has_element?(
             view,
             "#usage-known-date-validation #known-date-validation-expiry[data-element='known_date'][data-min]"
           )

    assert has_element?(
             view,
             "#usage-known-date-validation #known-date-validation-expiry [data-part='control'][required]"
           )
  end
end
