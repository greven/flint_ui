defmodule FlintUI.Base.TooltipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def tooltip_example(assigns) do
      assigns =
        assigns
        |> assign_new(:text, fn -> "Save changes" end)
        |> assign_new(:placement, fn -> "top" end)
        |> assign_new(:align, fn -> "center" end)
        |> assign_new(:offset, fn -> 6 end)
        |> assign_new(:delay, fn -> 200 end)
        |> assign_new(:arrow, fn -> true end)
        |> assign_new(:disabled, fn -> false end)

      ~H"""
      <.tooltip
        id="tip"
        text={@text}
        placement={@placement}
        align={@align}
        offset={@offset}
        delay={@delay}
        arrow={@arrow}
        disabled={@disabled}
        class="extra"
        data-role="test"
      >
        <button type="button">Save</button>
      </.tooltip>
      """
    end

    def slot_example(assigns) do
      ~H"""
      <.tooltip id="tip">
        <button type="button">Help</button>
        <:content>
          Hints are shown on <strong>hover</strong> and on focus.
        </:content>
      </.tooltip>
      """
    end

    def text_wins_example(assigns) do
      ~H"""
      <.tooltip id="tip" text="From the attribute">
        <button type="button">Help</button>
        <:content>From the slot</:content>
      </.tooltip>
      """
    end

    def paragraph_example(assigns) do
      ~H"""
      <p>
        Tax identification number
        <.tooltip id="tip" text="Nine digits">
          <button type="button">?</button>
        </.tooltip>
      </p>
      """
    end

    def generated_example(assigns) do
      ~H"""
      <.tooltip text="Save changes">
        <button type="button">Save</button>
      </.tooltip>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.tooltip_example/1, assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  describe "root" do
    test "identifies the component and wires the namespaced hook" do
      doc = render()

      assert attr(doc, ~s([data-part="root"]), "id") == ["tip"]
      assert attr(doc, ~s([data-part="root"]), "phx-hook") == ["FlintUI.Tooltip"]
      assert attr(doc, ~s([data-part="root"]), "data-element") == ["tooltip"]
      assert attr(doc, ~s([data-part="root"]), "data-state") == ["closed"]
    end

    test "generates an id when none is given" do
      doc =
        render_component(&TestComponent.generated_example/1, %{})
        |> LazyHTML.from_fragment()

      root_id = attr(doc, ~s([data-part="root"]), "id") |> List.first()

      assert root_id =~ ~r/^fl-tooltip-[A-Za-z0-9_-]+$/
      assert part_attr(doc, "content", "id") == ["#{root_id}-content"]
      assert attr(doc, ~s([data-part="root"]), "phx-hook") == ["FlintUI.Tooltip"]
    end

    test "generates a new id on every render" do
      ids =
        for _ <- 1..2 do
          render_component(&TestComponent.generated_example/1, %{})
          |> LazyHTML.from_fragment()
          |> attr(~s([data-part="root"]), "id")
          |> List.first()
        end

      assert length(Enum.uniq(ids)) == 2
    end

    test "forwards the positioning options as data hooks" do
      doc = render(placement: "bottom", align: "end", offset: 12, delay: 0)

      assert attr(doc, ~s([data-part="root"]), "data-placement") == ["bottom"]
      assert attr(doc, ~s([data-part="root"]), "data-align") == ["end"]
      assert attr(doc, ~s([data-part="root"]), "data-offset") == ["12"]
      assert attr(doc, ~s([data-part="root"]), "data-delay") == ["0"]
    end

    test "forwards class and rest attributes" do
      doc = render()

      assert attr(doc, ~s([data-part="root"]), "class") == ["extra"]
      assert attr(doc, ~s([data-part="root"]), "data-role") == ["test"]
    end
  end

  describe "trigger" do
    test "renders the default slot as the first child and leaves the wiring to the hook" do
      doc = render()

      assert LazyHTML.query(doc, ~s([data-part="root"] > button)) |> LazyHTML.text() == "Save"

      assert LazyHTML.query(doc, ~s([data-part="root"] > [data-part="content"]))
             |> LazyHTML.to_html() != ""

      # The trigger hooks are applied on mount, so the server markup stays
      # attribute-free and there is nothing for the caller to spread.
      assert count_part(doc, "trigger") == 0

      html = LazyHTML.to_html(doc)
      {trigger_at, _} = :binary.match(html, "<button")
      {content_at, _} = :binary.match(html, ~s(data-part="content"))
      assert trigger_at < content_at
    end

    test "keeps the disabled state on the root only" do
      doc = render(disabled: true)

      assert attr(doc, ~s([data-part="root"]), "data-disabled") == [""]

      assert LazyHTML.query(doc, ~s([data-part="root"] > button[aria-describedby]))
             |> LazyHTML.to_html() == ""
    end
  end

  describe "content" do
    test "is a tooltip in the top layer" do
      doc = render()

      assert part_attr(doc, "content", "id") == ["tip-content"]
      assert part_attr(doc, "content", "role") == ["tooltip"]
      assert part_attr(doc, "content", "popover") == ["manual"]
      assert part_attr(doc, "content", "data-state") == ["closed"]
    end

    test "publishes the requested side and alignment before positioning" do
      doc = render(placement: "left", align: "start")

      assert part_attr(doc, "content", "data-side") == ["left"]
      assert part_attr(doc, "content", "data-align") == ["start"]
    end

    test "renders the text attribute" do
      doc = render(text: "Save changes")

      assert part(doc, "content") |> LazyHTML.text() |> String.trim() == "Save changes"
    end

    test "renders the content slot" do
      doc =
        render_component(&TestComponent.slot_example/1, %{})
        |> LazyHTML.from_fragment()

      assert part(doc, "content") |> LazyHTML.text() |> String.trim() ==
               "Hints are shown on hover and on focus."

      assert part(doc, "content") |> LazyHTML.query("strong") |> LazyHTML.text() == "hover"
    end

    test "prefers the text attribute over the slot" do
      doc =
        render_component(&TestComponent.text_wins_example/1, %{})
        |> LazyHTML.from_fragment()

      assert part(doc, "content") |> LazyHTML.text() |> String.trim() == "From the attribute"
    end
  end

  describe "arrow" do
    test "renders a decorative arrow by default" do
      doc = render()

      assert part_attr(doc, "arrow", "aria-hidden") == ["true"]
    end

    test "omits the arrow when disabled" do
      doc = render(arrow: false)

      assert count_part(doc, "arrow") == 0
    end
  end

  describe "markup" do
    test "keeps the root phrasing when it sits inside a paragraph" do
      html = render_component(&TestComponent.paragraph_example/1, %{})

      assert html =~ "<p>"
      assert html =~ "<span"
      assert html =~ ~s(role="tooltip")
    end
  end

  defp part_attr(doc, name, attribute) do
    doc |> part(name) |> LazyHTML.attribute(attribute)
  end

  defp count_part(doc, name) do
    doc
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(~r/data-part="#{name}"/, &1)))
  end
end
