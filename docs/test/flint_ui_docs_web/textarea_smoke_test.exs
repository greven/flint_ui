defmodule FlintUIDocsWeb.TextareaSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "textarea page renders its field, control, and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/textarea")

    assert has_element?(
             view,
             "#usage-textarea-basic [data-element='textarea'][data-textarea][data-size='md'][data-radius='md'][data-resize='vertical']"
           )

    assert has_element?(view, "#usage-textarea-basic label[for='textarea-basic-bio']", "Bio")
    assert has_element?(view, "#usage-textarea-basic [data-part='sublabel']", "Optional")

    assert has_element?(
             view,
             "#usage-textarea-basic textarea[name='bio'][rows='4']"
           )

    assert has_element?(view, "#usage-textarea-basic [data-part='description']")

    view
    |> element("#usage-textarea-basic-controls")
    |> render_change(%{"size" => "lg", "radius" => "xl", "resize" => "both"})

    assert has_element?(
             view,
             "#usage-textarea-basic [data-element='textarea'][data-size='lg'][data-radius='xl'][data-resize='both']"
           )
  end

  test "description, validation, disabled, and field examples render", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/textarea")

    assert has_element?(
             view,
             "#usage-textarea-description textarea[name='username'][aria-invalid='true']"
           )

    assert has_element?(
             view,
             "#usage-textarea-description [data-part='description']"
           )

    assert has_element?(view, "#usage-textarea-description [data-part='hint']")
    assert has_element?(view, "#usage-textarea-description [data-part='error']")

    assert has_element?(view, "#usage-textarea-disabled textarea[disabled]")
    assert has_element?(view, "#usage-textarea-disabled textarea[readonly]")

    assert has_element?(
             view,
             "#usage-textarea-field textarea[name='user[bio]'][rows='4']"
           )
  end

  test "the autogrow example writes its limits and rows fallback", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/textarea")

    assert has_element?(
             view,
             "#usage-textarea-autogrow [data-element='textarea'][data-autogrow]"
           )

    assert has_element?(
             view,
             "#usage-textarea-autogrow textarea[name='autogrow_message'][rows='2']"
           )

    assert has_element?(
             view,
             "#usage-textarea-autogrow textarea[style*='--fl-textarea-min-rows: 2']"
           )

    assert has_element?(
             view,
             "#usage-textarea-autogrow textarea[style*='--fl-textarea-max-rows: 8']"
           )
  end

  test "the complete form example binds a textarea field", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/textarea")

    assert has_element?(
             view,
             "#example-textarea-form-preview textarea[name='profile[bio]'][rows='6']"
           )
  end
end
