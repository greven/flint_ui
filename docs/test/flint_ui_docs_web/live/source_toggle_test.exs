defmodule FlintUIDocsWeb.SourceToggleTest do
  use FlintUIDocsWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup do
    previous = Application.get_env(:flint_ui_docs, :dev_tools)
    Application.put_env(:flint_ui_docs, :dev_tools, true)

    on_exit(fn ->
      case previous do
        nil -> Application.delete_env(:flint_ui_docs, :dev_tools)
        value -> Application.put_env(:flint_ui_docs, :dev_tools, value)
      end
    end)

    :ok
  end

  test "the first section preview exposes the dev-only source toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "##{preview_id()}-source-toggle", "Source")
  end

  test "the source toggle swaps the code block to the render source", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")
    id = preview_id()

    assert has_element?(view, "##{id}-code", "<.button")

    view |> element("##{id}-source-toggle") |> render_click()

    assert has_element?(view, "##{id}", "render_section/1")
    assert has_element?(view, "##{id}-code", "<Components.button")
    assert has_element?(view, "##{id}-source-toggle", "Code")
    assert has_element?(view, "##{id}-copy[phx-hook]")

    view |> element("##{id}-source-toggle") |> render_click()

    assert has_element?(view, "##{id}-code", "<.button")
    assert has_element?(view, "##{id}-source-toggle", "Source")
  end

  test "the source toggle is hidden when dev tools are off", %{conn: conn} do
    Application.put_env(:flint_ui_docs, :dev_tools, false)

    {:ok, view, _html} = live(conn, ~p"/components/button")

    refute has_element?(view, "##{preview_id()}-source-toggle")
  end

  defp preview_id do
    first = hd(FlintUIDocsWeb.Docs.sections(:button, :styled))
    FlintUIDocsWeb.Docs.preview_id(:button, first)
  end
end
