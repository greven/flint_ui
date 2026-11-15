defmodule FlintUI.Base.PopoverTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def popover_example(assigns) do
      assigns =
        assigns
        |> assign_new(:opened, fn -> false end)
        |> assign_new(:modal, fn -> false end)
        |> assign_new(:dismissible, fn -> true end)
        |> assign_new(:open_on_hover, fn -> false end)
        |> assign_new(:placement, fn -> "bottom" end)
        |> assign_new(:align, fn -> "center" end)
        |> assign_new(:offset, fn -> 8 end)
        |> assign_new(:open_delay, fn -> 0 end)
        |> assign_new(:close_delay, fn -> 0 end)
        |> assign_new(:arrow, fn -> false end)
        |> assign_new(:portal, fn -> false end)
        |> assign_new(:portal_target, fn -> "body" end)
        |> assign_new(:aria_label, fn -> nil end)
        |> assign_new(:aria_labelledby, fn -> nil end)

      ~H"""
      <.popover
        id="pop"
        opened={@opened}
        modal={@modal}
        dismissible={@dismissible}
        open_on_hover={@open_on_hover}
        placement={@placement}
        align={@align}
        offset={@offset}
        open_delay={@open_delay}
        close_delay={@close_delay}
        arrow={@arrow}
        portal={@portal}
        portal_target={@portal_target}
        aria_label={@aria_label}
        aria_labelledby={@aria_labelledby}
        class="extra"
        data-role="test"
      >
        <button type="button">Open</button>
        <:content>
          <p>Account settings</p>
        </:content>
      </.popover>
      """
    end

    def generated_example(assigns) do
      ~H"""
      <.popover>
        <button type="button">Open</button>
        <:content>Generated</:content>
      </.popover>
      """
    end

    def portal_example(assigns) do
      ~H"""
      <.popover id="pop" portal portal_target="#portal-root">
        <button type="button">Open</button>
        <:content>Portalled</:content>
      </.popover>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.popover_example/1, assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  defp part_attr(html, name, attribute) do
    html |> part(name) |> LazyHTML.attribute(attribute)
  end

  defp root(_html), do: ~s([data-part="root"])

  describe "root" do
    test "identifies the component and wires the namespaced hook" do
      doc = render()

      assert attr(doc, root(doc), "id") == ["pop"]
      assert attr(doc, root(doc), "phx-hook") == ["FlintUI.Popover"]
      assert attr(doc, root(doc), "data-element") == ["popover"]
      assert attr(doc, root(doc), "data-part") == ["root"]
      assert attr(doc, root(doc), "data-state") == ["closed"]
      assert attr(doc, root(doc), "data-opened") == ["false"]
    end

    test "generates an id when none is given" do
      doc =
        render_component(&TestComponent.generated_example/1, %{})
        |> LazyHTML.from_fragment()

      root_id = attr(doc, root(doc), "id") |> List.first()

      assert root_id =~ ~r/^fl-popover-[A-Za-z0-9_-]+$/
      assert part_attr(doc, "content", "id") == ["#{root_id}-content"]
      assert attr(doc, root(doc), "phx-hook") == ["FlintUI.Popover"]
    end

    test "generates a new id on every render" do
      ids =
        for _ <- 1..2 do
          render_component(&TestComponent.generated_example/1, %{})
          |> LazyHTML.from_fragment()
          |> attr(root(nil), "id")
          |> List.first()
        end

      assert length(Enum.uniq(ids)) == 2
    end

    test "forwards the positioning and timing options as data hooks" do
      doc =
        render(
          placement: "top",
          align: "end",
          offset: 12,
          open_delay: 120,
          close_delay: 80,
          open_on_hover: true
        )

      assert attr(doc, root(doc), "data-placement") == ["top"]
      assert attr(doc, root(doc), "data-align") == ["end"]
      assert attr(doc, root(doc), "data-offset") == ["12"]
      assert attr(doc, root(doc), "data-open-delay") == ["120"]
      assert attr(doc, root(doc), "data-close-delay") == ["80"]
      assert attr(doc, root(doc), "data-open-on-hover") == [""]
    end

    test "marks dismissible and modal only when they are set" do
      doc = render()

      assert attr(doc, root(doc), "data-dismissible") == [""]
      assert attr(doc, root(doc), "data-modal") == []

      doc = render(modal: true, dismissible: false)

      assert attr(doc, root(doc), "data-dismissible") == []
      assert attr(doc, root(doc), "data-modal") == [""]
    end

    test "forwards class and rest attributes" do
      doc = render()

      assert attr(doc, root(doc), "class") == ["extra"]
      assert attr(doc, root(doc), "data-role") == ["test"]
    end
  end

  describe "content" do
    test "is a dialog in the top layer" do
      doc = render()

      assert part_attr(doc, "content", "id") == ["pop-content"]
      assert part_attr(doc, "content", "role") == ["dialog"]
      assert part_attr(doc, "content", "popover") == ["manual"]
      assert part_attr(doc, "content", "tabindex") == ["-1"]
      assert part_attr(doc, "content", "data-state") == ["closed"]
      assert part_attr(doc, "content", "data-popover-content") == [""]
    end

    test "publishes the requested side and alignment before positioning" do
      doc = render(placement: "left", align: "start")

      assert part_attr(doc, "content", "data-side") == ["left"]
      assert part_attr(doc, "content", "data-align") == ["start"]
    end

    test "adds aria-modal only in modal mode" do
      assert part_attr(render(), "content", "aria-modal") == []
      assert part_attr(render(modal: true), "content", "aria-modal") == ["true"]
      assert part_attr(render(modal: true), "content", "data-modal") == [""]
    end

    test "forwards explicit accessible names" do
      doc = render(aria_label: "Account")

      assert part_attr(doc, "content", "aria-label") == ["Account"]

      doc = render(aria_labelledby: "account-heading")

      assert part_attr(doc, "content", "aria-labelledby") == ["account-heading"]
    end

    test "renders the content slot" do
      doc = render()

      assert part(doc, "content") |> LazyHTML.text() |> String.trim() ==
               "Account settings"
    end
  end

  describe "trigger" do
    test "renders the default slot as the first child and leaves the wiring to the hook" do
      doc = render()

      assert LazyHTML.query(doc, ~s([data-part="root"] > button)) |> LazyHTML.text() == "Open"
      assert count_part(doc, "trigger") == 0
      assert count_part(doc, "content") == 1
    end
  end

  describe "arrow" do
    test "omits the arrow by default" do
      assert count_part(render(), "arrow") == 0
    end

    test "renders a decorative arrow when enabled" do
      assert part_attr(render(arrow: true), "arrow", "aria-hidden") == ["true"]
    end
  end

  describe "portal" do
    test "renders the content through a Phoenix portal" do
      doc =
        render_component(&TestComponent.portal_example/1, %{})
        |> LazyHTML.from_fragment()

      assert attr(doc, ~s(template[data-phx-portal]), "data-phx-portal") == ["#portal-root"]
      assert attr(doc, ~s(template[data-phx-portal]), "id") == ["pop-portal"]

      assert LazyHTML.query(doc, ~s([data-part="root"] > [data-part="content"]))
             |> LazyHTML.to_html() == ""

      template = LazyHTML.query(doc, "template[data-phx-portal]") |> LazyHTML.to_html()
      assert template =~ ~s(id="pop-content")
      assert template =~ ~s(data-part="content")
      assert template =~ ~s(data-state="closed")
    end

    test "keeps the content inside the root without a portal" do
      doc = render()

      assert LazyHTML.query(doc, "template[data-phx-portal]")
             |> LazyHTML.to_html() == ""

      assert LazyHTML.query(doc, ~s([data-part="root"] > [data-part="content"]))
             |> LazyHTML.to_html() != ""
    end
  end

  describe "metadata" do
    test "declares the parts in DOM order" do
      assert Enum.map(FlintUI.Base.Popover.parts_attrs(), &elem(&1, 0)) ==
               [:root, :trigger, :content, :arrow]
    end

    test "describes the dialog states, events, and runtime variables" do
      assert Enum.any?(FlintUI.Base.Popover.states(), &(&1.name == "open"))
      assert Enum.any?(FlintUI.Base.Popover.states(), &(&1.name == "modal"))
      assert Enum.any?(FlintUI.Base.Popover.events(), &(&1.name == "fl:popover:open"))
      assert Enum.any?(FlintUI.Base.Popover.events(), &(&1.name == "fl:popover:change"))

      assert Enum.map(FlintUI.Base.Popover.css_vars(), & &1.name) == [
               "--_fl-popover-arrow-x",
               "--_fl-popover-arrow-y"
             ]
    end
  end

  defp count_part(doc, name) do
    doc
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(~r/data-part="#{name}"/, &1)))
  end
end
