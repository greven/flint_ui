defmodule FlintUIDocsWeb.ProgressRingSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "progress ring page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_ring")

    assert has_element?(
             view,
             "#usage-progress-ring-basic [data-element='progress_ring'][data-progress_ring][data-size='md'][data-thickness='md'][data-color='primary']"
           )

    assert has_element?(
             view,
             "#usage-progress-ring-basic [role='progressbar'][aria-valuenow='72'][aria-valuemax='100'][aria-valuetext='72%']"
           )

    assert has_element?(view, "#usage-progress-ring-basic [data-part='status']", "72%")

    assert has_element?(
             view,
             "#usage-progress-ring-basic [data-part='segment'][style='stroke-dashoffset: 28']"
           )

    view
    |> element("#usage-progress-ring-basic-controls")
    |> render_change(%{
      "size" => "lg",
      "thickness" => "xl",
      "color" => "success",
      "show_status" => "false"
    })

    assert has_element?(
             view,
             "#usage-progress-ring-basic [data-element='progress_ring'][data-size='lg'][data-thickness='xl'][data-color='success']"
           )

    refute has_element?(view, "#usage-progress-ring-basic [data-part='status']")
    assert has_element?(view, "#usage-progress-ring-basic-code", ~s(size="lg"))
    assert has_element?(view, "#usage-progress-ring-basic-code", ~s(thickness="xl"))
    assert has_element?(view, "#usage-progress-ring-basic-code", ~s(color="success"))
  end

  test "the size and thickness examples cover their scales", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_ring")

    assert has_element?(view, "#usage-progress-ring-sizes [data-size='xs']")
    assert has_element?(view, "#usage-progress-ring-sizes [data-size='xl']")
    assert has_element?(view, "#usage-progress-ring-sizes-code", ~s(size="xl"))

    assert has_element?(view, "#usage-progress-ring-thickness [data-thickness='xs']")
    assert has_element?(view, "#usage-progress-ring-thickness [data-thickness='xl']")

    assert has_element?(
             view,
             "#usage-progress-ring-thickness-code",
             ~s(thickness="xl")
           )
  end

  test "the steps example shows the active label", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_ring")

    assert has_element?(
             view,
             "#usage-progress-ring-steps [role='progressbar'][aria-valuemax='4'][aria-valuenow='3'][aria-valuetext='Deploying']"
           )

    assert has_element?(view, "#usage-progress-ring-steps [data-part='steps']")

    assert has_element?(
             view,
             "#usage-progress-ring-steps [data-part='step'][data-active]",
             "Deploying"
           )

    assert has_element?(
             view,
             "#usage-progress-ring-steps [data-part='step']:first-child",
             "Waiting"
           )

    assert has_element?(
             view,
             "#usage-progress-ring-steps-code",
             ~s(max={["Waiting", "Cloning", "Migrating", "Deploying", "Done"]})
           )

    view
    |> element("#usage-progress-ring-steps-controls")
    |> render_change(%{"value" => "0"})

    assert has_element?(
             view,
             "#usage-progress-ring-steps [role='progressbar'][aria-valuenow='0'][aria-valuetext='Waiting']"
           )

    assert has_element?(
             view,
             "#usage-progress-ring-steps [data-part='step'][data-active]",
             "Waiting"
           )
  end

  test "the indeterminate example renders both motions", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_ring")

    assert has_element?(
             view,
             "#usage-progress-ring-indeterminate [data-element='progress_ring'][data-state='indeterminate'][data-indeterminate='spin']"
           )

    refute has_element?(view, "#usage-progress-ring-indeterminate [aria-valuenow]")

    view
    |> element("#usage-progress-ring-indeterminate-controls")
    |> render_change(%{"indeterminate" => "sweep"})

    assert has_element?(
             view,
             "#usage-progress-ring-indeterminate [data-element='progress_ring'][data-state='indeterminate'][data-indeterminate='sweep']"
           )

    assert has_element?(
             view,
             "#usage-progress-ring-indeterminate-code",
             ~s(indeterminate="sweep")
           )
  end

  test "the dashboard example mixes percentages and steps", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/progress_ring")

    assert has_element?(
             view,
             "#example-progress-ring-dashboard-preview [data-element='progress_ring'][data-color='warning'][data-size='lg']"
           )

    assert has_element?(
             view,
             "#example-progress-ring-dashboard-preview [data-part='status']",
             "82%"
           )

    assert has_element?(
             view,
             "#example-progress-ring-dashboard-preview [data-part='step'][data-active]",
             "Deploying"
           )

    assert has_element?(
             view,
             "#example-progress-ring-dashboard-preview [role='progressbar'][aria-valuenow='100']"
           )

    assert has_element?(
             view,
             "#example-progress-ring-dashboard-preview-code",
             ~s(max={["Waiting", "Cloning", "Migrating", "Deploying", "Done"]})
           )
  end
end
