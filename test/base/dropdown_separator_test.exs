defmodule FlintUI.Base.DropdownSeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      ~H"""
      <.dropdown_separator class="extra" data-role="test" />
      """
    end
  end

  test "is a static separator" do
    separator =
      render_component(&TestComponent.example/1, %{})
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s([data-element="dropdown_separator"]))

    assert LazyHTML.tag(separator) == ["div"]
    assert LazyHTML.attribute(separator, "role") == ["separator"]
    assert LazyHTML.attribute(separator, "data-part") == ["separator"]
    assert LazyHTML.attribute(separator, "class") == ["extra"]
    assert LazyHTML.attribute(separator, "data-role") == ["test"]
  end
end
