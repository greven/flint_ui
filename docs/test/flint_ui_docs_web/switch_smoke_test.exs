defmodule FlintUIDocsWeb.SwitchSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "switch page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch")

    assert has_element?(
             view,
             "#usage-switch-basic [data-element='switch'][data-switch][data-size='md'][data-color='primary']"
           )

    assert has_element?(view, "#usage-switch-basic label", "Enable notifications")
    assert has_element?(view, "#usage-switch-basic [data-part='sublabel']", "Recommended")

    assert has_element?(
             view,
             "#usage-switch-basic input[type='checkbox'][role='switch'][checked]"
           )

    assert has_element?(
             view,
             "#usage-switch-basic [data-part='indicator'] [data-part='thumb'][aria-hidden='true']"
           )

    assert has_element?(
             view,
             "#usage-switch-basic input[type='hidden'][name='notifications'][value='false']"
           )

    view
    |> element("#usage-switch-basic-controls")
    |> render_change(%{"size" => "lg", "color" => "danger"})

    assert has_element?(
             view,
             "#usage-switch-basic [data-element='switch'][data-size='lg'][data-color='danger']"
           )
  end

  test "switch state labels render inside the track", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch")

    assert has_element?(
             view,
             "#usage-switch-labels [data-part='indicator'] > [data-part='on-state'][aria-hidden='true']",
             "ON"
           )

    assert has_element?(
             view,
             "#usage-switch-labels [data-part='indicator'] > [data-part='off-state'][aria-hidden='true']",
             "OFF"
           )

    # Both labels stay in the DOM for every switch; the theme hides the one
    # that does not match the checked state.
    document =
      view
      |> element("#usage-switch-labels")
      |> render()
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(document, ~s([data-part="on-state"]))) == 2
    assert Enum.count(LazyHTML.query(document, ~s([data-part="off-state"]))) == 2
  end

  test "switch validation and disabled examples render their states", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch")

    assert has_element?(
             view,
             "#usage-switch-validation [data-element='switch'][data-invalid] input[role='switch'][aria-invalid='true']"
           )

    assert has_element?(view, "#two-factor-switch-error-1", "must be enabled for admin accounts")

    assert has_element?(view, "#usage-switch-disabled input[role='switch'][disabled]")
    assert has_element?(view, "#usage-switch-disabled input[role='switch'][required]")
  end

  test "switch field and example previews render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch")

    assert has_element?(
             view,
             "#usage-switch-field form#switch-field-form input[name='user[notifications]'][role='switch']"
           )

    assert has_element?(view, "#example-switch-settings-preview input[role='switch']")
    assert has_element?(view, "#example-switch-form-preview input[role='switch']")
  end
end
