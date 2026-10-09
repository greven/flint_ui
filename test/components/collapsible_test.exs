defmodule FlintUI.CollapsibleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def collapsible_example(assigns) do
      assigns =
        assigns
        |> assign_new(:open, fn -> false end)
        |> assign_new(:disabled, fn -> false end)
        |> assign_new(:hidden_until_found, fn -> false end)
        |> assign_new(:open_event, fn -> nil end)
        |> assign_new(:close_event, fn -> nil end)
        |> assign_new(:toggle_event, fn -> nil end)

      ~H"""
      <.collapsible
        id="test"
        open={@open}
        disabled={@disabled}
        hidden_until_found={@hidden_until_found}
        open_event={@open_event}
        close_event={@close_event}
        toggle_event={@toggle_event}
      >
        <:trigger :let={attrs}>
          <button {attrs}>Toggle</button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>Content</div>
        </:content>
      </.collapsible>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.collapsible_example/1, assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  describe "root" do
    test "identifies the component and wires the namespaced hook" do
      root = part(render(), "root")

      assert LazyHTML.attribute(root, "id") == ["test"]
      assert LazyHTML.attribute(root, "phx-hook") == ["FlintUI.Collapsible"]
      assert LazyHTML.attribute(root, "data-element") == ["collapsible"]
      assert LazyHTML.attribute(root, "data-part") == ["root"]
    end

    test "reflects the open state" do
      assert attr(render(), ~s([data-part="root"]), "data-state") == ["closed"]
      assert attr(render(open: true), ~s([data-part="root"]), "data-state") == ["open"]
    end

    test "exposes the server event names only when set" do
      root = render()
      assert LazyHTML.attribute(root, "data-open-event") == []
      assert LazyHTML.attribute(root, "data-close-event") == []
      assert LazyHTML.attribute(root, "data-toggle-event") == []

      root = render(open_event: "opened", close_event: "closed", toggle_event: "toggled")
      assert LazyHTML.attribute(root, "data-open-event") == ["opened"]
      assert LazyHTML.attribute(root, "data-close-event") == ["closed"]
      assert LazyHTML.attribute(root, "data-toggle-event") == ["toggled"]
    end

    test "flags hidden_until_found for the hook" do
      root = ~s([data-part="root"])

      assert attr(render(), root, "data-hidden-until-found") == []

      assert attr(render(hidden_until_found: true), root, "data-hidden-until-found") ==
               [""]
    end
  end

  describe "trigger" do
    test "is a native button that cannot submit a form" do
      trigger = part(render(), "trigger")

      assert LazyHTML.tag(trigger) == ["button"]
      assert LazyHTML.attribute(trigger, "type") == ["button"]
      assert LazyHTML.attribute(trigger, "aria-controls") == ["test-content"]
    end

    test "always renders an explicit aria-expanded string" do
      assert attr(render(), ~s([data-part="trigger"]), "aria-expanded") == ["false"]
      assert attr(render(open: true), ~s([data-part="trigger"]), "aria-expanded") == ["true"]
    end

    test "reflects the disabled state" do
      trigger = part(render(disabled: true), "trigger")

      assert LazyHTML.attribute(trigger, "disabled") == [""]
      assert LazyHTML.attribute(trigger, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(trigger, "data-disabled") == [""]
    end
  end

  describe "content" do
    test "is hidden and linked to the trigger while closed" do
      content = part(render(), "content")

      assert LazyHTML.attribute(content, "id") == ["test-content"]
      assert LazyHTML.attribute(content, "hidden") == [""]
    end

    test "is visible while open" do
      content = part(render(open: true), "content")

      assert LazyHTML.attribute(content, "hidden") == []
    end

    test "uses hidden=until-found when requested" do
      content = part(render(hidden_until_found: true), "content")

      assert LazyHTML.attribute(content, "hidden") == ["until-found"]
    end
  end

  describe "metadata" do
    test "declares a stable, documented contract" do
      assert %FlintUI.Meta{name: :collapsible, status: :draft} = FlintUI.Collapsible.meta()

      parts = FlintUI.Collapsible.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "FlintUI.Collapsible"} =
               Enum.find(parts.root, &(&1.name == "phx-hook"))

      assert %FlintUI.Meta.PartAttr{value: "button"} =
               Enum.find(parts.trigger, &(&1.name == "type"))

      refute Enum.any?(parts.trigger, &(&1.name == "aria-role"))
    end

    test "documents keyboard interactions" do
      assert [%FlintUI.Meta.Keyboard{keys: "Enter"}, %FlintUI.Meta.Keyboard{keys: "Space"}] =
               FlintUI.Collapsible.keyboard()
    end
  end

  describe "JS helpers" do
    test "dispatch the matching client events to the component root" do
      assert %Phoenix.LiveView.JS{ops: ops} = FlintUI.Collapsible.open_collapsible("test")
      assert ops == [["dispatch", %{to: "#test", event: "fl:collapsible:open"}]]

      assert %Phoenix.LiveView.JS{
               ops: [["dispatch", %{to: "#test", event: "fl:collapsible:close"}]]
             } = FlintUI.Collapsible.close_collapsible("test")

      assert %Phoenix.LiveView.JS{
               ops: [["dispatch", %{to: "#test", event: "fl:collapsible:toggle"}]]
             } = FlintUI.Collapsible.toggle_collapsible("test")
    end

    test "composes onto an existing JS command" do
      js = Phoenix.LiveView.JS.set_attribute(%Phoenix.LiveView.JS{}, {"data-x", "1"})
      %Phoenix.LiveView.JS{ops: ops} = FlintUI.Collapsible.open_collapsible(js, "test")

      assert length(ops) == 2
      assert List.last(ops) == ["dispatch", %{to: "#test", event: "fl:collapsible:open"}]
    end
  end
end
