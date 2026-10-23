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

  test "code blocks expose the dev-only source toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#playground-button-source-toggle", "Source")
    assert has_element?(view, "#usage-button-variant-source-toggle")
    assert has_element?(view, "#example-button-icon-source-toggle")
  end

  test "the source toggle swaps the code block to the render source", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#playground-button-code", "<.button")

    view |> element("#playground-button-source-toggle") |> render_click()

    assert has_element?(view, "#playground-button", "render_playground/1")
    assert has_element?(view, "#playground-button-code", "<Components.button")
    assert has_element?(view, "#playground-button-source-toggle", "Code")
    assert has_element?(view, "#playground-button-copy[phx-hook]")

    view |> element("#playground-button-source-toggle") |> render_click()

    assert has_element?(view, "#playground-button-code", "<.button")
    assert has_element?(view, "#playground-button-source-toggle", "Source")
  end

  test "preview-only cards have no code block", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-color [data-element='button']")
    refute has_element?(view, "#usage-button-color-code")
    refute has_element?(view, "#usage-button-color-source-toggle")
  end

  test "the source toggle reveals the full render composition", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/group")

    assert has_element?(view, "#usage-group-variant-code", "flex flex-col")
    refute has_element?(view, "#usage-group-variant-code", "ghost")

    view |> element("#usage-group-variant-source-toggle") |> render_click()

    assert has_element?(view, "#usage-group-variant", "render_usage/1")
    assert has_element?(view, "#usage-group-variant-code", "ghost")
  end

  test "the source toggle is hidden when dev tools are off", %{conn: conn} do
    Application.put_env(:flint_ui_docs, :dev_tools, false)

    {:ok, view, _html} = live(conn, ~p"/components/button")

    refute has_element?(view, "#playground-button-source-toggle")
    refute has_element?(view, "#usage-button-variant-source-toggle")
  end
end
