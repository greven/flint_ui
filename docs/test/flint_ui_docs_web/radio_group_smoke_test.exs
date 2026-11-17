defmodule FlintUIDocsWeb.RadioGroupSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "radio group page renders its options and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio_group")

    assert has_element?(
             view,
             "#usage-radio-group-basic fieldset[data-element='radio_group'][data-orientation='vertical'][data-variant='simple']"
           )

    assert has_element?(view, "#usage-radio-group-basic legend", "Plan")
    refute has_element?(view, "#usage-radio-group-basic fieldset input[type='hidden']")

    assert has_element?(
             view,
             "#usage-radio-group-basic [data-part='control'][name='plan'][value='pro'][checked]"
           )

    view
    |> element("#usage-radio-group-basic-controls")
    |> render_change(%{
      "orientation" => "horizontal",
      "variant" => "card",
      "size" => "lg",
      "radius" => "xl"
    })

    assert has_element?(
             view,
             "#usage-radio-group-basic fieldset[data-orientation='horizontal'][data-variant='card']"
           )

    assert has_element?(
             view,
             "#usage-radio-group-basic [data-element='radio'][data-variant='card'][data-size='lg'][data-radius='xl']"
           )
  end

  test "validation, disabled, and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio_group")

    assert has_element?(
             view,
             "#usage-radio-group-validation fieldset[aria-invalid='true'][aria-required='true']"
           )

    assert has_element?(view, "#usage-radio-group-validation [data-part='error']")

    assert has_element?(view, "#usage-radio-group-disabled fieldset[disabled]")

    assert has_element?(
             view,
             "#usage-radio-group-disabled [data-part='control'][value='pro'][disabled]"
           )

    assert has_element?(
             view,
             "#usage-radio-group-field input[name='user[plan]'][type='radio']"
           )
  end

  test "card options and the complete form render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio_group")

    assert has_element?(
             view,
             "#example-radio-group-cards-preview fieldset[data-variant='card']"
           )

    assert has_element?(
             view,
             "#example-radio-group-cards-preview [data-element='radio'][data-variant='card']"
           )

    assert has_element?(
             view,
             "#example-radio-group-form-preview input[name='user[plan]'][type='radio']"
           )
  end
end
