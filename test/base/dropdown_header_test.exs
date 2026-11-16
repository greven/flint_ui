defmodule FlintUI.Base.DropdownHeaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      assigns = assign_new(assigns, :color, fn -> "neutral" end)

      ~H"""
      <.dropdown_header color={@color} class="extra" data-role="test">Account</.dropdown_header>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.example/1, assigns)
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(~s([data-element="dropdown_header"]))
  end

  test "is a presentational label" do
    header = render()

    assert LazyHTML.tag(header) == ["header"]
    assert LazyHTML.attribute(header, "role") == ["presentation"]
    assert LazyHTML.attribute(header, "data-part") == ["header"]
    assert LazyHTML.attribute(header, "data-color") == ["neutral"]
    assert LazyHTML.attribute(header, "class") == ["extra"]
    assert LazyHTML.attribute(header, "data-role") == ["test"]
    assert LazyHTML.text(header) =~ "Account"
  end

  test "forwards the semantic color" do
    assert LazyHTML.attribute(render(color: "error"), "data-color") == ["error"]
  end
end
