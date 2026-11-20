defmodule FlintUI.Base.DropdownSubTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      assigns =
        assigns
        |> assign_new(:disabled, fn -> false end)
        |> assign_new(:open_on_hover, fn -> false end)

      ~H"""
      <.dropdown_sub
        menu="more"
        disabled={@disabled}
        open_on_hover={@open_on_hover}
        class="extra"
        data-role="test"
      >
        More
      </.dropdown_sub>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.example/1, assigns)
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(~s([data-element="dropdown_sub"]))
  end

  test "is a submenu trigger linked to its menu" do
    trigger = render()

    assert LazyHTML.tag(trigger) == ["button"]
    assert LazyHTML.attribute(trigger, "type") == ["button"]
    assert LazyHTML.attribute(trigger, "id") == ["more-trigger"]
    assert LazyHTML.attribute(trigger, "role") == ["menuitem"]
    assert LazyHTML.attribute(trigger, "tabindex") == ["-1"]
    assert LazyHTML.attribute(trigger, "data-part") == ["submenu-trigger"]
    assert LazyHTML.attribute(trigger, "data-menu") == ["more"]
    assert LazyHTML.attribute(trigger, "aria-haspopup") == ["menu"]
    assert LazyHTML.attribute(trigger, "aria-expanded") == ["false"]
    assert LazyHTML.attribute(trigger, "aria-controls") == ["more"]
    assert LazyHTML.attribute(trigger, "class") == ["extra"]
    assert LazyHTML.attribute(trigger, "data-role") == ["test"]
    assert LazyHTML.text(trigger) =~ "More"
  end

  test "opts into hover opening with data-open-on-hover" do
    assert LazyHTML.attribute(render(), "data-open-on-hover") == []

    trigger = render(open_on_hover: true)

    assert LazyHTML.attribute(trigger, "data-open-on-hover") == [""]
  end

  test "renders the decorative chevron" do
    trigger = render()
    indicator = LazyHTML.query(trigger, ~s([data-part="submenu-indicator"]))

    assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]
  end

  test "a disabled trigger renders the native state" do
    trigger = render(disabled: true)

    assert LazyHTML.attribute(trigger, "disabled") == [""]
    assert LazyHTML.attribute(trigger, "aria-disabled") == ["true"]
    assert LazyHTML.attribute(trigger, "data-disabled") == [""]
  end
end
