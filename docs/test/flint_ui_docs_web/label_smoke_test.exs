defmodule FlintUIDocsWeb.LabelSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "label page renders the basic example and size control", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/label")

    assert has_element?(
             view,
             "#usage-label-basic [data-element='label'][data-size='md'] label[for='label-basic-email']",
             "Email"
           )

    view
    |> element("#usage-label-basic-controls")
    |> render_change(%{"size" => "lg"})

    assert has_element?(
             view,
             "#usage-label-basic [data-element='label'][data-size='lg'] label[for='label-basic-email']"
           )
  end

  test "description examples expose the derived id", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/label")

    assert has_element?(
             view,
             "#usage-label-description [data-part='description']#label-description-email-description",
             "We only use this for receipts."
           )

    assert has_element?(
             view,
             "#usage-label-description input#label-description-email[aria-describedby='label-description-email-description']"
           )
  end

  test "required marker and input state render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/label")

    assert has_element?(
             view,
             "#usage-label-required [data-element='label'][data-required] [data-part='required'][aria-hidden='true']",
             "*"
           )

    assert has_element?(view, "#usage-label-required input#label-required-email[required]")
  end

  test "sublabel and form examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/label")

    assert has_element?(
             view,
             "#usage-label-sublabel [data-part='sublabel']",
             "Optional"
           )

    assert has_element?(
             view,
             "#example-label-form-preview form#label-form-example label[for='user_name']",
             "Name"
           )

    assert has_element?(
             view,
             "#example-label-form-preview input[name='user[email]'][aria-describedby='user_email-description']"
           )
  end
end
