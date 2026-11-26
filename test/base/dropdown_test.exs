defmodule FlintUI.Base.DropdownTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def example(assigns) do
      assigns =
        assigns
        |> assign_new(:label, fn -> "Actions" end)
        |> assign_new(:placement, fn -> "bottom" end)
        |> assign_new(:align, fn -> "start" end)
        |> assign_new(:offset, fn -> 4 end)
        |> assign_new(:arrow, fn -> false end)
        |> assign_new(:max_height, fn -> nil end)
        |> assign_new(:open_on_hover, fn -> false end)
        |> assign_new(:open_delay, fn -> 0 end)
        |> assign_new(:close_delay, fn -> 0 end)

      ~H"""
      <.dropdown
        id="menu"
        label={@label}
        placement={@placement}
        align={@align}
        offset={@offset}
        arrow={@arrow}
        max_height={@max_height}
        open_on_hover={@open_on_hover}
        open_delay={@open_delay}
        close_delay={@close_delay}
        class="extra"
        data-role="test"
      >
        <.dropdown_item>Settings</.dropdown_item>
        <:submenu id="more">
          <.dropdown_item>Documentation</.dropdown_item>
        </:submenu>
      </.dropdown>
      """
    end

    def custom_trigger(assigns) do
      ~H"""
      <.dropdown id="menu" label="Ignored">
        <:trigger :let={attrs}>
          <button {attrs} class="trigger-extra" data-role="trigger">Custom</button>
        </:trigger>
        <.dropdown_item>Settings</.dropdown_item>
      </.dropdown>
      """
    end

    def generated(assigns) do
      ~H"""
      <.dropdown label="Actions">
        <.dropdown_item>Settings</.dropdown_item>
      </.dropdown>
      """
    end
  end

  defp render(function \\ :example, assigns \\ []) do
    render_component(&apply(TestComponent, function, [&1]), assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  defp part_attr(html, name, attribute) do
    html |> part(name) |> LazyHTML.attribute(attribute)
  end

  describe "root" do
    test "identifies the component and wires the hook" do
      document = render()

      assert attr(document, ~s([data-part="root"]), "id") == ["menu"]
      assert attr(document, ~s([data-part="root"]), "phx-hook") == ["FlintUI.Dropdown"]
      assert attr(document, ~s([data-part="root"]), "data-element") == ["dropdown"]
      assert attr(document, ~s([data-part="root"]), "data-part") == ["root"]
      assert attr(document, ~s([data-part="root"]), "data-state") == ["closed"]
    end

    test "forwards the positioning and hover options" do
      document =
        render(:example,
          placement: "top",
          align: "end",
          offset: 12,
          open_on_hover: true,
          open_delay: 120,
          close_delay: 80
        )

      assert attr(document, ~s([data-part="root"]), "data-placement") == ["top"]
      assert attr(document, ~s([data-part="root"]), "data-align") == ["end"]
      assert attr(document, ~s([data-part="root"]), "data-offset") == ["12"]
      assert attr(document, ~s([data-part="root"]), "data-open-on-hover") == [""]
      assert attr(document, ~s([data-part="root"]), "data-open-delay") == ["120"]
      assert attr(document, ~s([data-part="root"]), "data-close-delay") == ["80"]
    end

    test "forwards class and rest attributes" do
      document = render()

      assert attr(document, ~s([data-part="root"]), "class") == ["extra"]
      assert attr(document, ~s([data-part="root"]), "data-role") == ["test"]
    end

    test "defaults the offset to the base gap" do
      document = render(:generated)

      assert attr(document, ~s([data-part="root"]), "data-offset") == ["4"]
    end

    test "defaults the hover open delay to an intent delay" do
      document = render(:generated)

      assert attr(document, ~s([data-part="root"]), "data-open-delay") == ["100"]
    end

    test "generates an id when none is given" do
      document = render(:generated)
      [id] = attr(document, ~s([data-part="root"]), "id")

      assert id =~ ~r/^fl-dropdown-/
      assert part_attr(document, "content", "id") == ["#{id}-content"]
      assert part_attr(document, "trigger", "id") == ["#{id}-trigger"]
    end
  end

  describe "trigger" do
    test "renders the label in a native button with the menu wiring" do
      document = render()
      trigger = part(document, "trigger")

      assert LazyHTML.tag(trigger) == ["button"]
      assert LazyHTML.attribute(trigger, "type") == ["button"]
      assert LazyHTML.attribute(trigger, "id") == ["menu-trigger"]
      assert LazyHTML.attribute(trigger, "data-dropdown-trigger") == [""]
      assert LazyHTML.attribute(trigger, "aria-haspopup") == ["menu"]
      assert LazyHTML.attribute(trigger, "aria-expanded") == ["false"]
      assert LazyHTML.attribute(trigger, "aria-controls") == ["menu-content"]
      assert LazyHTML.text(trigger) =~ "Actions"
    end

    test "a trigger slot overrides the label and receives the trigger attributes" do
      document = render(:custom_trigger)
      trigger = part(document, "trigger")

      assert LazyHTML.tag(trigger) == ["button"]
      assert LazyHTML.attribute(trigger, "id") == ["menu-trigger"]
      assert LazyHTML.attribute(trigger, "aria-haspopup") == ["menu"]
      assert LazyHTML.attribute(trigger, "aria-controls") == ["menu-content"]
      assert LazyHTML.attribute(trigger, "class") == ["trigger-extra"]
      assert LazyHTML.attribute(trigger, "data-dropdown-trigger") == []
      assert LazyHTML.attribute(trigger, "data-role") == ["trigger"]
      assert LazyHTML.text(trigger) |> String.trim() == "Custom"
      refute LazyHTML.text(trigger) =~ "Ignored"
    end
  end

  describe "content" do
    test "is a menu in the top layer wired to the trigger" do
      document = render()

      assert part_attr(document, "content", "role") == ["menu"]
      assert part_attr(document, "content", "aria-labelledby") == ["menu-trigger"]
      assert part_attr(document, "content", "tabindex") == ["-1"]
      assert part_attr(document, "content", "popover") == ["manual"]
      assert part_attr(document, "content", "data-state") == ["closed"]
      assert part_attr(document, "content", "data-dropdown-content") == [""]
      assert part_attr(document, "content", "data-elevation") == [""]
      assert part_attr(document, "content", "data-side") == ["bottom"]
      assert part_attr(document, "content", "data-align") == ["start"]
    end

    test "caps the height only when max_height is set" do
      assert part_attr(render(), "list", "style") == []

      assert part_attr(render(:example, max_height: 280), "list", "style") == [
               "--fl-dropdown-max-height: 280px",
               "--fl-dropdown-max-height: 280px"
             ]
    end

    test "renders the arrow only when asked" do
      assert count_part(render(), "arrow") == 0
      assert count_part(render(:example, arrow: true), "arrow") == 1
    end
  end

  describe "submenu" do
    test "renders each submenu as a labelled menu linked to its trigger" do
      submenu = part(render(), "submenu")

      assert LazyHTML.attribute(submenu, "id") == ["more"]
      assert LazyHTML.attribute(submenu, "role") == ["menu"]
      assert LazyHTML.attribute(submenu, "aria-labelledby") == ["more-trigger"]
      assert LazyHTML.attribute(submenu, "tabindex") == ["-1"]
      assert LazyHTML.attribute(submenu, "popover") == ["manual"]
      assert LazyHTML.attribute(submenu, "data-state") == ["closed"]
      assert LazyHTML.attribute(submenu, "data-dropdown-submenu") == [""]
      assert LazyHTML.attribute(submenu, "data-elevation") == [""]
      assert LazyHTML.text(submenu) =~ "Documentation"
    end

    test "caps the submenu height with the same max_height" do
      list =
        render(:example, max_height: 240)
        |> part("submenu")
        |> LazyHTML.query(~s([data-part="list"]))

      assert LazyHTML.attribute(list, "style") == ["--fl-dropdown-max-height: 240px"]
    end
  end

  defp count_part(document, name) do
    pattern = ~r/data-part="#{Regex.escape(name)}"/

    document
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(pattern, &1)))
  end
end
