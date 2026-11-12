defmodule FlintUI.Base.AccordionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def accordion_example(assigns) do
      assigns =
        assigns
        |> assign_new(:multiple, fn -> false end)
        |> assign_new(:require_open, fn -> false end)
        |> assign_new(:disabled, fn -> false end)

      ~H"""
      <.accordion
        id="test"
        multiple={@multiple}
        require_open={@require_open}
        disabled={@disabled}
      >
        <p>Items</p>
      </.accordion>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.accordion_example/1, assigns)
    |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))

  describe "root" do
    test "identifies the component and wires the accordion hook" do
      html = root(render())

      assert LazyHTML.attribute(html, "id") == ["test"]
      assert LazyHTML.attribute(html, "phx-hook") == ["FlintUI.Accordion"]
      assert LazyHTML.attribute(html, "data-element") == ["accordion"]
      assert LazyHTML.attribute(html, "data-part") == ["root"]
    end

    test "flags multiple, require_open, and disabled as presence hooks" do
      html = render()

      for name <- ~w(data-multiple data-require-open data-disabled) do
        assert LazyHTML.attribute(root(html), name) == []
      end

      html = render(multiple: true, require_open: true, disabled: true)
      root = root(html)

      assert LazyHTML.attribute(root, "data-multiple") == [""]
      assert LazyHTML.attribute(root, "data-require-open") == [""]
      assert LazyHTML.attribute(root, "data-disabled") == [""]
    end

    test "renders the inner block" do
      assert render() |> LazyHTML.text() |> String.trim() == "Items"
    end
  end

  describe "metadata" do
    test "declares a stable, documented contract" do
      assert %FlintUI.Meta{name: :accordion, type: :action, status: :draft} =
               FlintUI.Base.Accordion.meta()

      parts = FlintUI.Base.Accordion.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "FlintUI.Accordion"} =
               Enum.find(parts.root, &(&1.name == "phx-hook"))

      assert %FlintUI.Meta.PartAttr{value: "accordion"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))
    end

    test "documents keyboard interactions" do
      keys = Enum.map(FlintUI.Base.Accordion.keyboard(), & &1.keys)

      assert keys == ["Tab / Shift+Tab", "ArrowDown / ArrowUp", "Home / End", "Enter / Space"]
    end
  end

  describe "JS helpers" do
    test "dispatch the matching collapsible events to the item" do
      assert %Phoenix.LiveView.JS{ops: ops} =
               FlintUI.Base.Accordion.open_accordion_item("item")

      assert ops == [["dispatch", %{to: "#item", event: "fl:collapsible:open"}]]

      assert %Phoenix.LiveView.JS{
               ops: [["dispatch", %{to: "#item", event: "fl:collapsible:close"}]]
             } = FlintUI.Base.Accordion.close_accordion_item("item")

      assert %Phoenix.LiveView.JS{
               ops: [["dispatch", %{to: "#item", event: "fl:collapsible:toggle"}]]
             } = FlintUI.Base.Accordion.toggle_accordion_item("item")
    end

    test "composes onto an existing JS command" do
      js = Phoenix.LiveView.JS.set_attribute(%Phoenix.LiveView.JS{}, {"data-x", "1"})
      %Phoenix.LiveView.JS{ops: ops} = FlintUI.Base.Accordion.open_accordion_item(js, "item")

      assert length(ops) == 2
      assert List.last(ops) == ["dispatch", %{to: "#item", event: "fl:collapsible:open"}]
    end
  end
end
