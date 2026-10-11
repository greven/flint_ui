defmodule FlintUIDocsWeb.GuideLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "getting started page walks through setup", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/getting-started")

    assert has_element?(view, "#install")
    assert has_element?(view, "#setup")
    assert has_element?(view, "#generate")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#commands")
    assert render(view) =~ "mix flint.setup"
    assert render(view) =~ "mix flint.add"
  end

  test "theming page documents tokens and custom themes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/theming")

    assert has_element?(view, "#how")
    assert has_element?(view, "#tokens")
    assert has_element?(view, "#light-dark")
    assert has_element?(view, "#custom")
    assert has_element?(view, "#tailwind")

    html = render(view)
    assert html =~ "--fl-color-primary"
    assert html =~ "data-theme"
  end
end
