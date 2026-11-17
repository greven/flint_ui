defmodule FlintUIDocsWeb.RadioSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "radio page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio")

    assert has_element?(
             view,
             "#usage-radio-basic [data-element='radio'][data-variant='simple'][data-size='md'][data-radius='sm'][data-color='primary']"
           )

    assert has_element?(view, "#usage-radio-basic label", "Enable notifications")
    assert has_element?(view, "#usage-radio-basic [data-part='sublabel']", "Recommended")
    assert has_element?(view, "#usage-radio-basic input[type='radio'][checked]")
    refute has_element?(view, "#usage-radio-basic [data-element='radio'] input[type='hidden']")

    view
    |> element("#usage-radio-basic-controls")
    |> render_change(%{
      "variant" => "card",
      "size" => "lg",
      "radius" => "xl",
      "color" => "error"
    })

    assert has_element?(
             view,
             "#usage-radio-basic [data-element='radio'][data-variant='card'][data-size='lg'][data-radius='xl'][data-color='error']"
           )
  end

  test "radio card and validation examples render their states", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio")

    assert has_element?(
             view,
             "#usage-radio-card [data-element='radio'][data-variant='card'] input[type='radio'][checked]"
           )

    assert has_element?(
             view,
             "#usage-radio-validation [data-element='radio'][data-invalid] input[aria-invalid='true']"
           )

    assert has_element?(view, "#plan-radio-errors-error-1", "is not available in your region")
  end

  test "radio disabled and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/radio")

    assert has_element?(view, "#usage-radio-disabled input[type='radio'][disabled]")
    assert has_element?(view, "#usage-radio-disabled input[type='radio'][required]")

    assert has_element?(
             view,
             "#usage-radio-field form#radio-field-form input[name='user[plan]'][type='radio']"
           )

    assert has_element?(view, "#example-radio-form-preview input[type='radio']")
    assert has_element?(view, "#example-radio-group-preview fieldset")
  end
end
