defmodule FlintUIDocsWeb.CopyButtonSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the copy button page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/copy_button")

    assert has_element?(
             view,
             "#usage-copy-button-basic [data-element='copy_button'][data-copy][aria-label='Copy install command']"
           )

    assert has_element?(view, "#usage-copy-button-basic", "mix flint.add copy_button")
    assert has_element?(view, "#usage-copy-button-basic [data-copy-from='install-command']")
    assert has_element?(view, "#usage-copy-button-basic [data-control]")
    assert has_element?(view, "#usage-copy-button-sources [data-copy-attribute='href']")
    assert has_element?(view, "#usage-copy-button-sources [data-copy-property='value']")
    assert has_element?(view, "#usage-copy-button-variant [data-variant='solid']")
    assert has_element?(view, "#usage-copy-button-color [data-color='primary']")
    assert has_element?(view, "#usage-copy-button-feedback [data-copy-duration='4000']")
    assert has_element?(view, "#usage-copy-button-success [data-success-color='success']")
    assert has_element?(view, "#usage-copy-button-success [aria-label='Copy']")
    assert has_element?(view, "#usage-copy-button-success [data-part='copy_state']", "Copy")
    assert has_element?(view, "#usage-copy-button-success [data-part='success_state']", "Copied")
    assert has_element?(view, "#usage-copy-button-icons .lucide-clipboard")
    assert has_element?(view, "#usage-copy-button-tooltip [data-element='tooltip']")
    assert has_element?(view, "#usage-copy-button-tooltip [data-placement='top']")
    assert has_element?(view, "#usage-copy-button-tooltip [data-placement='right']")

    assert has_element?(
             view,
             "#usage-copy-button-tooltip [data-element='copy_button'][data-copy]"
           )

    assert has_element?(
             view,
             "#usage-copy-button-tooltip [data-copy-tooltip-text='success']",
             "Copied"
           )

    assert has_element?(view, "#usage-copy-button-sizing [data-size='xl']")
    assert has_element?(view, "#usage-copy-button-disabled [data-disabled]")
    assert has_element?(view, "#example-copy-button-group-preview [data-element='group']")

    assert has_element?(
             view,
             "#example-copy-button-group-preview [data-element='copy_button'][data-variant='surface']"
           )
  end
end
