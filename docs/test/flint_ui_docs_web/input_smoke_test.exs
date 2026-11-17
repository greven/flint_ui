defmodule FlintUIDocsWeb.InputSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "input page renders the basic example", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(
             view,
             "#usage-input-basic [data-element='input'][data-type='email'] input[name='email'][placeholder='you@example.com']"
           )

    assert has_element?(view, "#usage-input-basic label", "Email")
  end

  test "form fields derive their ids and values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(
             view,
             "#usage-input-field input#user_email[name='user[email]'][value='ada@example.com']"
           )
  end

  test "hint is linked to the control", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(
             view,
             "#usage-input-hint [data-part='hint']",
             "We only use this for receipts."
           )
  end

  test "prefix and suffix slots render around the control", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(
             view,
             "#usage-input-affixes [data-part='outer_prefix']",
             "https://"
           )

    assert has_element?(
             view,
             "#usage-input-affixes [data-part='inner_prefix'] [data-element='icon']"
           )

    assert has_element?(
             view,
             "#usage-input-affixes [data-part='inner_suffix']",
             "USD"
           )

    assert has_element?(
             view,
             "#usage-input-affixes [data-part='outer_suffix']",
             ".example.com"
           )

    assert has_element?(
             view,
             "#usage-input-affixes [data-part='outer_suffix'] [data-element='button']",
             "Copy"
           )
  end

  test "types render their native controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#usage-input-types input[type='email']")
    assert has_element?(view, "#usage-input-types input[type='date']")
    assert has_element?(view, "#usage-input-types input[type='file']")
    assert has_element?(view, "#usage-input-types input[type='color']")
  end

  test "select and textarea render their native controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#usage-input-select select[name='role']")
    assert has_element?(view, "#usage-input-select select[name='roles[]'][multiple]")
    assert has_element?(view, "#usage-input-textarea textarea[name='bio'][rows='4']")
  end

  test "checkbox renders the hidden false input and the indicator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(
             view,
             "#usage-input-checkbox [data-type='checkbox'] input[type='hidden'][name='remember_me'][value='false']"
           )

    assert has_element?(
             view,
             "#usage-input-checkbox [data-type='checkbox'] [data-part='indicator'] input[type='checkbox']"
           )

    assert has_element?(
             view,
             "#usage-input-checkbox [data-part='indicator'] [data-part='check'][aria-hidden='true'] path[data-mark='check']"
           )
  end

  test "invalid fields expose their errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#usage-input-validation [data-invalid]")

    assert has_element?(
             view,
             "#usage-input-validation input#validation-email[aria-invalid='true'][aria-describedby]"
           )

    assert has_element?(view, "#validation-email-error-1", "is invalid")
    assert has_element?(view, "#validation-email-error-2", "is already taken")

    assert has_element?(
             view,
             "#validation-email-error-1 [data-part='error_icon'][aria-hidden='true']"
           )
  end

  test "size control updates the field size", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#usage-input-size [data-element='input'][data-size='md']")

    view
    |> element("#usage-input-size-controls")
    |> render_change(%{"size" => "lg"})

    assert has_element?(view, "#usage-input-size [data-element='input'][data-size='lg']")
  end

  test "radius control updates the field radius", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#usage-input-radius [data-element='input'][data-radius='md']")

    view
    |> element("#usage-input-radius-controls")
    |> render_change(%{"radius" => "xl"})

    assert has_element?(view, "#usage-input-radius [data-element='input'][data-radius='xl']")
  end

  test "the complete form example renders every field", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#example-input-form-preview input[name='profile-name']")
    assert has_element?(view, "#example-input-form-preview select[name='profile-role']")
    assert has_element?(view, "#example-input-form-preview textarea[name='profile-bio']")

    assert has_element?(
             view,
             "#example-input-form-preview input[name='profile-terms'][type='checkbox']"
           )
  end

  test "the migration example is code only", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/input")

    assert has_element?(view, "#example-input-migration-preview")
    refute has_element?(view, "#example-input-migration-preview [data-element='input']")
  end
end
