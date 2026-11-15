defmodule FlintUI.Base.DropdownHeadingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      assigns = assign_new(assigns, :color, fn -> "neutral" end)

      ~H"""
      <.dropdown_heading color={@color} class="extra" data-role="test">Account</.dropdown_heading>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.example/1, assigns)
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(~s([data-element="dropdown_heading"]))
  end

  test "is a presentational label" do
    heading = render()

    assert LazyHTML.tag(heading) == ["div"]
    assert LazyHTML.attribute(heading, "role") == ["presentation"]
    assert LazyHTML.attribute(heading, "data-part") == ["heading"]
    assert LazyHTML.attribute(heading, "data-color") == ["neutral"]
    assert LazyHTML.attribute(heading, "class") == ["extra"]
    assert LazyHTML.attribute(heading, "data-role") == ["test"]
    assert LazyHTML.text(heading) =~ "Account"
  end

  test "forwards the semantic color" do
    assert LazyHTML.attribute(render(color: "error"), "data-color") == ["error"]
  end
end
