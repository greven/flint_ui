defmodule FlintUIDocsWeb.ProgressSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "progress page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress")

    assert has_element?(
             view,
             "#usage-progress-basic [data-element='progress'][data-progress][data-size='md'][data-color='primary'][data-radius='full']"
           )

    assert has_element?(
             view,
             "#usage-progress-basic [role='progressbar'][aria-valuenow='40'][aria-valuemax='100'][aria-valuetext='40%'][aria-labelledby]"
           )

    assert has_element?(view, "#usage-progress-basic [data-part='label']", "Upload progress")
    assert has_element?(view, "#usage-progress-basic [data-part='status']", "40%")

    assert has_element?(
             view,
             "#usage-progress-basic [data-part='segment'][style='inline-size: 40%']"
           )

    view
    |> element("#usage-progress-basic-controls")
    |> render_change(%{
      "size" => "lg",
      "color" => "success",
      "radius" => "md",
      "show_status" => "false"
    })

    assert has_element?(
             view,
             "#usage-progress-basic [data-element='progress'][data-size='lg'][data-color='success'][data-radius='md']"
           )

    refute has_element?(view, "#usage-progress-basic [data-part='status']")
    assert has_element?(view, "#usage-progress-basic-code", ~s(size="lg"))
    assert has_element?(view, "#usage-progress-basic-code", ~s(color="success"))
    assert has_element?(view, "#usage-progress-basic-code", ~s(radius="md"))
  end

  test "the steps example shows the active label", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress")

    assert has_element?(
             view,
             "#usage-progress-steps [role='progressbar'][aria-valuemax='4'][aria-valuenow='3'][aria-valuetext='Deploying'][aria-label='Deployment']"
           )

    refute has_element?(view, "#usage-progress-steps [data-part='label']")
    assert has_element?(view, "#usage-progress-steps [data-part='steps']")

    assert has_element?(
             view,
             "#usage-progress-steps [data-part='step'][data-active]",
             "Deploying"
           )

    assert has_element?(
             view,
             "#usage-progress-steps [data-part='step']:first-child",
             "Waiting"
           )

    assert has_element?(
             view,
             "#usage-progress-steps-code",
             ~s(max={["Waiting", "Cloning", "Migrating", "Deploying", "Done"]})
           )

    view
    |> element("#usage-progress-steps-controls")
    |> render_change(%{"value" => "0"})

    assert has_element?(
             view,
             "#usage-progress-steps [role='progressbar'][aria-valuenow='0'][aria-valuetext='Waiting']"
           )

    assert has_element?(
             view,
             "#usage-progress-steps [data-part='step'][data-active]",
             "Waiting"
           )
  end

  test "striped and indeterminate examples render their states", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress")

    assert has_element?(
             view,
             "#usage-progress-striped [data-element='progress'][data-striped][data-indeterminate='carousel']"
           )

    assert has_element?(
             view,
             "#usage-progress-striped [role='progressbar'][aria-label='Uploading']"
           )

    refute has_element?(view, "#usage-progress-striped [data-part='label']")

    refute has_element?(view, "#usage-progress-striped [data-element='progress'][data-animated]")

    view
    |> element("#usage-progress-striped-controls")
    |> render_change(%{"striped" => "false", "animated" => "true"})

    assert has_element?(view, "#usage-progress-striped [data-element='progress'][data-animated]")
    refute has_element?(view, "#usage-progress-striped [data-element='progress'][data-striped]")
    assert has_element?(view, "#usage-progress-striped-code", "animated")

    assert has_element?(
             view,
             "#usage-progress-indeterminate [data-element='progress'][data-state='indeterminate'][data-indeterminate='swing']"
           )

    refute has_element?(view, "#usage-progress-indeterminate [aria-valuenow]")
    assert has_element?(view, "#usage-progress-indeterminate-code", ~s(indeterminate="swing"))

    view
    |> element("#usage-progress-indeterminate-controls")
    |> render_change(%{"indeterminate" => "elastic"})

    assert has_element?(
             view,
             "#usage-progress-indeterminate [data-element='progress'][data-state='indeterminate'][data-indeterminate='elastic']"
           )

    assert has_element?(view, "#usage-progress-indeterminate-code", ~s(indeterminate="elastic"))
  end

  test "the vertical example and status section render their geometry", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress")

    assert has_element?(
             view,
             "#usage-progress-orientation [data-element='progress'][data-orientation='vertical'][aria-orientation='vertical']"
           )

    assert has_element?(
             view,
             "#usage-progress-orientation [data-part='segment'][style='block-size: 72%']"
           )

    assert has_element?(
             view,
             "#usage-progress-orientation [data-part='status']",
             "72%"
           )

    assert has_element?(view, "#usage-progress-status [data-part='label']", "Starting")
    assert has_element?(view, "#usage-progress-status [data-part='status']", "0%")
    assert has_element?(view, "#usage-progress-status [data-part='status']", "35%")
    assert has_element?(view, "#usage-progress-status [data-part='status']", "100%")

    assert has_element?(
             view,
             "#usage-progress-status [data-color='success'][data-element='progress']"
           )

    assert has_element?(view, "#usage-progress-status-code", ~s(value="35"))
  end

  test "the upload queue example mixes determinate and indeterminate bars", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress")

    assert has_element?(
             view,
             "#example-progress-uploads-preview [data-element='progress'][data-color='success'][data-striped]"
           )

    assert has_element?(
             view,
             "#example-progress-uploads-preview [data-element='progress'][data-animated]"
           )

    assert has_element?(
             view,
             "#example-progress-uploads-preview [data-element='progress'][data-state='indeterminate'][data-indeterminate='swing']"
           )

    assert has_element?(view, "#example-progress-uploads-preview [data-part='status']", "62%")
    refute has_element?(view, "#example-progress-uploads-preview [data-part='label']")

    assert has_element?(
             view,
             "#example-progress-uploads-preview-code",
             ~s(indeterminate="swing")
           )
  end
end
