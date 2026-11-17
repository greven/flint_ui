defmodule FlintUIDocsWeb.CheckboxSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "checkbox page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox")

    assert has_element?(
             view,
             "#usage-checkbox-basic [data-element='checkbox'][data-variant='simple'][data-size='md'][data-radius='sm'][data-color='primary']"
           )

    assert has_element?(view, "#usage-checkbox-basic label", "Enable notifications")
    assert has_element?(view, "#usage-checkbox-basic [data-part='sublabel']", "Recommended")

    assert has_element?(
             view,
             "#usage-checkbox-basic input[type='hidden'][name='notifications'][value='false']"
           )

    view
    |> element("#usage-checkbox-basic-controls")
    |> render_change(%{
      "variant" => "card",
      "size" => "lg",
      "radius" => "xl",
      "color" => "error"
    })

    assert has_element?(
             view,
             "#usage-checkbox-basic [data-element='checkbox'][data-variant='card'][data-size='lg'][data-radius='xl'][data-color='error']"
           )
  end

  test "checkbox card and validation examples render their states", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox")

    assert has_element?(
             view,
             "#usage-checkbox-card [data-element='checkbox'][data-variant='card'] input[type='checkbox'][checked]"
           )

    assert has_element?(
             view,
             "#usage-checkbox-card [data-part='indicator'] [data-part='check'][aria-hidden='true'] path[data-mark='check']"
           )

    assert has_element?(
             view,
             "#usage-checkbox-validation [data-element='checkbox'][data-invalid] input[aria-invalid='true']"
           )

    assert has_element?(view, "#terms-checkbox-error-1", "must be accepted")
  end

  test "checkbox indeterminate example is visual only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox")

    assert has_element?(
             view,
             "#usage-checkbox-indeterminate input#select-all-checkbox[data-indeterminate='true']:not([checked])"
           )

    assert has_element?(
             view,
             "#usage-checkbox-indeterminate input[type='hidden'][name='select_all'][value='false']"
           )
  end

  test "checkbox disabled and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox")

    assert has_element?(view, "#usage-checkbox-disabled input[type='checkbox'][disabled]")
    assert has_element?(view, "#usage-checkbox-disabled input[type='checkbox'][required]")

    assert has_element?(
             view,
             "#usage-checkbox-field form#checkbox-field-form input[name='user[terms]'][type='checkbox']"
           )

    assert has_element?(view, "#example-checkbox-form-preview input[type='checkbox']")
    assert has_element?(view, "#example-checkbox-group-preview fieldset")
  end
end
