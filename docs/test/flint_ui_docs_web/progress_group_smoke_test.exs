defmodule FlintUIDocsWeb.ProgressGroupSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "progress group page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_group")

    assert has_element?(
             view,
             "#usage-progress-group-basic [data-element='progress_group'][data-progress_group][data-size='md'][data-color='primary'][data-radius='full']"
           )

    assert has_element?(
             view,
             "#usage-progress-group-basic [role='progressbar'][aria-valuemax='128'][aria-valuenow='69'][aria-valuetext='54%']"
           )

    assert has_element?(view, "#usage-progress-group-basic [data-part='status']", "54%")

    assert has_element?(
             view,
             "#usage-progress-group-basic [data-part='segment'][style='inline-size: 32.8125%']"
           )

    assert has_element?(
             view,
             "#usage-progress-group-basic [data-part='item'][data-color='info']"
           )

    assert has_element?(view, "#usage-progress-group-basic [data-part='label']", "Compute")

    view
    |> element("#usage-progress-group-basic-controls")
    |> render_change(%{
      "size" => "lg",
      "color" => "success",
      "radius" => "md",
      "show_status" => "false"
    })

    assert has_element?(
             view,
             "#usage-progress-group-basic [data-element='progress_group'][data-size='lg'][data-color='success'][data-radius='md']"
           )

    refute has_element?(view, "#usage-progress-group-basic [data-part='status']")
    assert has_element?(view, "#usage-progress-group-basic-code", ~s(size="lg"))
    assert has_element?(view, "#usage-progress-group-basic-code", ~s(color="success"))
  end

  test "status aligns with the last segment and accepts custom content", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_group")

    assert has_element?(
             view,
             "#usage-progress-group-basic [data-part='status'][aria-hidden='true'][style='inline-size: 53.90625%']",
             "54%"
           )

    assert has_element?(
             view,
             "#usage-progress-group-status [data-part='status']",
             "69 GB of 128 GB used"
           )

    refute has_element?(view, "#usage-progress-group-status [data-part='status'][aria-hidden]")

    assert has_element?(
             view,
             "#usage-progress-group-status-code",
             "69 GB of 128 GB used"
           )
  end

  test "the icon and vertical examples render their legend", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_group")

    assert has_element?(
             view,
             "#usage-progress-group-icons [data-part='icon'][class='lucide-cpu']"
           )

    assert has_element?(
             view,
             "#usage-progress-group-icons [data-part='icon'][class='lucide-database']"
           )

    refute has_element?(view, "#usage-progress-group-icons [data-part='dot']")
    assert has_element?(view, "#usage-progress-group-icons-code", ~s(icon="lucide-cpu"))

    assert has_element?(
             view,
             "#usage-progress-group-vertical [data-element='progress_group'][data-orientation='vertical'][aria-orientation='vertical']"
           )

    assert has_element?(
             view,
             "#usage-progress-group-vertical [data-part='segment'][style='block-size: 32.8125%']"
           )

    view
    |> element("#usage-progress-group-vertical-controls")
    |> render_change(%{"orientation" => "horizontal"})

    assert has_element?(
             view,
             "#usage-progress-group-vertical [data-element='progress_group'][data-orientation='horizontal']"
           )
  end

  test "the custom color example shows the breakdown", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_group")

    assert has_element?(
             view,
             "#example-progress-group-custom-colors-preview [role='progressbar'][aria-valuetext='54%']"
           )

    assert has_element?(
             view,
             "#example-progress-group-custom-colors-preview [data-part='item']",
             "Compute"
           )

    assert has_element?(
             view,
             "#example-progress-group-custom-colors-preview [data-part='value']",
             "33%"
           )

    assert has_element?(
             view,
             "#example-progress-group-custom-colors-preview-code",
             ~s(color="cyan")
           )
  end
end
