defmodule FlintUI.Base.DropdownGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      ~H"""
      <.dropdown_group label="Session" class="extra" data-role="test">
        <button>Log out</button>
      </.dropdown_group>
      """
    end

    def aria_label(assigns) do
      ~H"""
      <.dropdown_group aria-label="Actions">Item</.dropdown_group>
      """
    end

    def caller_wins(assigns) do
      ~H"""
      <.dropdown_group label="Label" aria-label="Caller">Item</.dropdown_group>
      """
    end
  end

  defp render(function) do
    render_component(&apply(TestComponent, function, [&1]), %{})
    |> LazyHTML.from_fragment()
  end

  defp group(document), do: LazyHTML.query(document, ~s([data-element="dropdown_group"]))

  test "is a named group" do
    document = group(render(:example))

    assert LazyHTML.attribute(document, "role") == ["group"]
    assert LazyHTML.attribute(document, "data-part") == ["group"]
    assert LazyHTML.attribute(document, "aria-label") == ["Session"]
    assert LazyHTML.attribute(document, "class") == ["extra"]
    assert LazyHTML.attribute(document, "data-role") == ["test"]
    assert LazyHTML.text(document) =~ "Log out"
  end

  test "accepts aria-label directly" do
    assert LazyHTML.attribute(group(render(:aria_label)), "aria-label") == ["Actions"]
  end

  test "a caller aria-label wins over label" do
    assert LazyHTML.attribute(group(render(:caller_wins)), "aria-label") == ["Caller"]
  end
end
