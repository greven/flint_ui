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
    assert has_element?(view, "#usage-copy-button-sources [data-copy-attribute='href']")
    assert has_element?(view, "#usage-copy-button-sources [data-copy-property='value']")
    assert has_element?(view, "#usage-copy-button-feedback [data-copy-duration='4000']")
    assert has_element?(view, "#usage-copy-button-icons .lucide-clipboard")
    assert has_element?(view, "#usage-copy-button-sizing [data-size='xl']")
    assert has_element?(view, "#usage-copy-button-disabled [data-disabled]")
    assert has_element?(view, "#example-copy-button-group-preview [data-element='group']")
  end
end
