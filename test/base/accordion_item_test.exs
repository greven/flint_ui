defmodule FlintUI.Base.AccordionItemTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def item_example(assigns) do
      assigns =
        assigns
        |> assign_new(:label, fn -> "Shipping" end)
        |> assign_new(:expanded, fn -> false end)
        |> assign_new(:disabled, fn -> false end)
        |> assign_new(:heading, fn -> "h3" end)

      ~H"""
      <.accordion_item
        id="item"
        label={@label}
        expanded={@expanded}
        disabled={@disabled}
        heading={@heading}
      >
        <:panel>Body</:panel>
      </.accordion_item>
      """
    end

    def header_example(assigns) do
      ~H"""
      <.accordion_item id="item" label="Fallback">
        <:header class="header-extra" phx-click="go" data-role="test">Custom</:header>
        <:panel class="panel-extra">Body</:panel>
      </.accordion_item>
      """
    end

    def custom_indicator_example(assigns) do
      ~H"""
      <.accordion_item id="item" label="Shipping">
        <:indicator class="indicator-extra"><span>+</span></:indicator>
        <:panel>Body</:panel>
      </.accordion_item>
      """
    end

    def empty_indicator_example(assigns) do
      ~H"""
      <.accordion_item id="item" label="Shipping">
        <:indicator></:indicator>
        <:panel>Body</:panel>
      </.accordion_item>
      """
    end
  end

  defp render(function \\ :item_example, assigns \\ []) do
    render_component(&apply(TestComponent, function, [&1]), assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  describe "root" do
    test "identifies the item and wires the collapsible hook" do
      root = part(render(), "root")

      assert LazyHTML.attribute(root, "id") == ["item"]
      assert LazyHTML.attribute(root, "phx-hook") == ["FlintUI.Collapsible"]
      assert LazyHTML.attribute(root, "data-element") == ["accordion_item"]
      assert LazyHTML.attribute(root, "data-part") == ["root"]
    end

    test "reflects the expanded state" do
      assert attr(render(), ~s([data-part="root"]), "data-state") == ["closed"]

      assert attr(render(:item_example, expanded: true), ~s([data-part="root"]), "data-state") ==
               ["open"]
    end

    test "reflects the disabled state" do
      root = part(render(:item_example, disabled: true), "root")
      assert LazyHTML.attribute(root, "data-disabled") == [""]
    end
  end

  describe "header" do
    test "is a native button with the header id and ARIA wiring" do
      header = part(render(), "trigger")

      assert LazyHTML.tag(header) == ["button"]
      assert LazyHTML.attribute(header, "type") == ["button"]
      assert LazyHTML.attribute(header, "id") == ["item-header"]
      assert LazyHTML.attribute(header, "aria-controls") == ["item-content"]
      assert LazyHTML.attribute(header, "aria-expanded") == ["false"]
      assert LazyHTML.attribute(header, "aria-disabled") == ["false"]
      assert LazyHTML.attribute(header, "data-part") == ["trigger"]
    end

    test "reflects expanded and disabled state" do
      html = render(:item_example, expanded: true, disabled: true)
      header = part(html, "trigger")

      assert LazyHTML.attribute(header, "aria-expanded") == ["true"]
      assert LazyHTML.attribute(header, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(header, "disabled") == [""]
      assert LazyHTML.attribute(header, "data-disabled") == [""]
    end

    test "uses the label when no header slot is given" do
      assert part(render(), "trigger") |> LazyHTML.text() |> String.trim() == "Shipping"
    end

    test "a header slot overrides the label and forwards attributes to the button" do
      header = part(render(:header_example), "trigger")

      assert LazyHTML.text(header) |> String.trim() == "Custom"
      assert LazyHTML.attribute(header, "class") == ["header-extra"]
      assert LazyHTML.attribute(header, "phx-click") == ["go"]
      assert LazyHTML.attribute(header, "data-role") == ["test"]
    end
  end

  describe "heading" do
    test "wraps the trigger in the requested heading level" do
      html = render(:item_example, heading: "h2")
      heading = part(html, "heading")

      assert LazyHTML.tag(heading) == ["h2"]
      assert LazyHTML.query(heading, ~s([data-part="trigger"])) != []
    end

    test "omits the heading wrapper with none" do
      html = render(:item_example, heading: "none")

      assert html |> part("heading") |> LazyHTML.to_html() == ""

      assert LazyHTML.query(html, ~s([data-part="root"] > [data-part="trigger"])) != []
    end
  end

  describe "indicator" do
    test "renders the default chevron" do
      html = render()
      indicator = part(html, "indicator")

      assert LazyHTML.tag(indicator) == ["svg"]
      assert LazyHTML.attribute(indicator, "data-default") == [""]
      assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]
    end

    test "renders a custom indicator with its attributes" do
      html = render(:custom_indicator_example)
      indicator = part(html, "indicator")

      assert LazyHTML.tag(indicator) == ["span"]
      assert LazyHTML.attribute(indicator, "class") == ["indicator-extra"]
      assert LazyHTML.attribute(indicator, "data-default") == []
      assert LazyHTML.text(indicator) |> String.trim() == "+"
    end

    test "renders no indicator for an empty slot" do
      assert render(:empty_indicator_example) |> part("indicator") |> LazyHTML.to_html() == ""
    end
  end

  describe "panel" do
    test "is a labelled region linked to the header" do
      content = part(render(), "content")

      assert LazyHTML.attribute(content, "id") == ["item-content"]
      assert LazyHTML.attribute(content, "role") == ["region"]
      assert LazyHTML.attribute(content, "aria-labelledby") == ["item-header"]
      assert LazyHTML.attribute(content, "hidden") == [""]
    end

    test "is visible while expanded" do
      content = part(render(:item_example, expanded: true), "content")
      assert LazyHTML.attribute(content, "hidden") == []
    end

    test "applies the panel class to the padded body" do
      panel = part(render(:header_example), "panel")
      assert LazyHTML.attribute(panel, "class") == ["panel-extra"]
    end
  end

  describe "metadata" do
    test "declares a stable, documented contract" do
      assert %FlintUI.Meta{name: :accordion_item, type: :action, status: :draft} =
               FlintUI.Base.AccordionItem.meta()

      parts = FlintUI.Base.AccordionItem.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "FlintUI.Collapsible"} =
               Enum.find(parts.root, &(&1.name == "phx-hook"))

      assert %FlintUI.Meta.PartAttr{value: "region"} =
               Enum.find(parts.content, &(&1.name == "role"))
    end

    test "documents keyboard interactions" do
      assert [%FlintUI.Meta.Keyboard{keys: "Enter"}, %FlintUI.Meta.Keyboard{keys: "Space"}] =
               FlintUI.Base.AccordionItem.keyboard()
    end
  end
end
