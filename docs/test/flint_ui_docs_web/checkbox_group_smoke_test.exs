defmodule FlintUIDocsWeb.CheckboxGroupSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "checkbox group page renders its options and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox_group")

    assert has_element?(
             view,
             "#usage-checkbox-group-basic fieldset[data-element='checkbox_group'][data-orientation='vertical'][data-variant='simple']"
           )

    assert has_element?(view, "#usage-checkbox-group-basic legend", "Programming languages")

    assert has_element?(
             view,
             "#usage-checkbox-group-basic input[type='hidden'][name='languages[]'][value='']"
           )

    assert has_element?(
             view,
             "#usage-checkbox-group-basic [data-part='control'][name='languages[]'][value='elixir'][checked]"
           )

    view
    |> element("#usage-checkbox-group-basic-controls")
    |> render_change(%{
      "orientation" => "horizontal",
      "variant" => "card",
      "size" => "lg",
      "radius" => "xl"
    })

    assert has_element?(
             view,
             "#usage-checkbox-group-basic fieldset[data-orientation='horizontal'][data-variant='card']"
           )

    assert has_element?(
             view,
             "#usage-checkbox-group-basic [data-element='checkbox'][data-variant='card'][data-size='lg'][data-radius='xl']"
           )
  end

  test "validation, disabled, and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox_group")

    assert has_element?(
             view,
             "#usage-checkbox-group-validation fieldset[aria-invalid='true'][aria-required='true']"
           )

    assert has_element?(view, "#usage-checkbox-group-validation [data-part='error']")

    assert has_element?(view, "#usage-checkbox-group-disabled fieldset[disabled]")

    assert has_element?(
             view,
             "#usage-checkbox-group-disabled [data-part='control'][value='rust'][disabled]"
           )

    assert has_element?(
             view,
             "#usage-checkbox-group-field input[name='user[languages][]'][type='checkbox']"
           )
  end

  test "card options and the complete form render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/checkbox_group")

    assert has_element?(
             view,
             "#example-checkbox-group-cards-preview fieldset[data-variant='card']"
           )

    assert has_element?(
             view,
             "#example-checkbox-group-cards-preview [data-element='checkbox'][data-variant='card']"
           )

    assert has_element?(
             view,
             "#example-checkbox-group-form-preview input[name='user[terms]'][type='checkbox']"
           )

    assert has_element?(
             view,
             "#example-checkbox-group-form-preview input[name='user[languages][]']"
           )
  end
end
