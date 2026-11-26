defmodule FlintUI.Base.DropdownHeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def default(assigns) do
      ~H"""
      <.dropdown_header class="extra" data-role="test">Account</.dropdown_header>
      """
    end

    def colored(assigns) do
      ~H"""
      <.dropdown_header color={@color} class="extra" data-role="test">Account</.dropdown_header>
      """
    end
  end

  defp render do
    render_component(&TestComponent.default/1, [])
    |> header()
  end

  defp render_colored(color) do
    render_component(&TestComponent.colored/1, %{color: color})
    |> header()
  end

  defp header(html) do
    html
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(~s([data-element="dropdown_header"]))
  end

  test "is a presentational label" do
    header = render()

    assert LazyHTML.tag(header) == ["header"]
    assert LazyHTML.attribute(header, "role") == ["presentation"]
    assert LazyHTML.attribute(header, "data-part") == ["header"]
    assert LazyHTML.attribute(header, "data-color") == []
    assert LazyHTML.attribute(header, "class") == ["extra"]
    assert LazyHTML.attribute(header, "data-role") == ["test"]
    assert LazyHTML.text(header) =~ "Account"
  end

  test "forwards the semantic color" do
    assert LazyHTML.attribute(render_colored("danger"), "data-color") == ["danger"]
  end

  test "an explicit neutral is a tone, not the muted default" do
    assert LazyHTML.attribute(render_colored("neutral"), "data-color") == ["neutral"]
  end
end
