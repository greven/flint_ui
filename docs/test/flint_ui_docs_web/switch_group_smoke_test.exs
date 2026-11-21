defmodule FlintUIDocsWeb.SwitchGroupSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "switch group page renders its legends, options, and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch_group")

    assert has_element?(
             view,
             "#usage-switch-group-basic fieldset[data-element='switch_group'][data-orientation='vertical']"
           )

    assert has_element?(view, "#usage-switch-group-basic legend", "Notifications")
    assert has_element?(view, "#usage-switch-group-basic [data-part='description']")

    assert has_element?(
             view,
             "#usage-switch-group-basic [data-element='switch'] input[role='switch'][name='notifications[email]'][checked]"
           )

    assert has_element?(
             view,
             "#usage-switch-group-basic [data-element='switch'] input[role='switch'][name='notifications[sms]']"
           )

    view
    |> element("#usage-switch-group-basic-controls")
    |> render_change(%{"orientation" => "horizontal", "size" => "lg", "color" => "danger"})

    assert has_element?(
             view,
             "#usage-switch-group-basic fieldset[data-orientation='horizontal']"
           )

    assert has_element?(
             view,
             "#usage-switch-group-basic [data-element='switch'][data-size='lg'][data-color='danger']"
           )
  end

  test "validation, disabled, and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch_group")

    assert has_element?(
             view,
             "#usage-switch-group-validation fieldset[aria-invalid='true'][aria-required='true']"
           )

    assert has_element?(view, "#usage-switch-group-validation [data-part='error']")

    assert has_element?(view, "#usage-switch-group-disabled fieldset[disabled]")
    assert has_element?(view, "#usage-switch-group-disabled [data-part='control'][disabled]")

    assert has_element?(
             view,
             "#usage-switch-group-field input[name='user[email_alerts]'][role='switch'][checked]"
           )
  end

  test "the settings example renders independent switches", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/switch_group")

    assert has_element?(
             view,
             "#example-switch-group-settings-preview input[name='notifications[email]'][role='switch']"
           )

    assert has_element?(
             view,
             "#example-switch-group-settings-preview input[name='privacy[profile]'][role='switch']"
           )
  end
end
