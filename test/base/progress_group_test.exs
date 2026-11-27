defmodule FlintUI.Base.ProgressGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.TestDOM

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.progress_group
        max={@max}
        label={@label}
        orientation={@orientation}
        show_status={@show_status}
        class={@class}
        data-test={@data_test}
      >
        <:segment
          :for={segment <- @segments}
          value={segment.value}
          label={Map.get(segment, :label)}
          icon={Map.get(segment, :icon)}
          color={Map.get(segment, :color)}
        />
      </.progress_group>
      """
    end

    def custom_label(assigns) do
      ~H"""
      <.progress_group label="Build">
        <:segment value={1} label="Fallback">Custom <strong>label</strong></:segment>
        <:segment value={1} />
      </.progress_group>
      """
    end

    def custom_status(assigns) do
      ~H"""
      <.progress_group max="100" label="Storage" show_status={@show_status}>
        <:status>69 GB of 100 GB used</:status>
        <:segment value="42" label="Compute" />
        <:segment value="18" label="Storage" />
      </.progress_group>
      """
    end
  end

  @segments [
    %{value: 42, label: "Compute", icon: nil, color: nil},
    %{value: 18, label: "Storage", icon: nil, color: nil},
    %{value: 9, label: "Bandwidth", icon: nil, color: nil}
  ]

  @defaults %{
    segments: @segments,
    max: 128,
    label: "Storage",
    orientation: "horizontal",
    show_status: false,
    class: nil,
    data_test: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp segment_sizes(html) do
    html
    |> part("segment")
    |> LazyHTML.attribute("style")
    |> Enum.map(fn style ->
      vars = TestDOM.style_vars(style)
      vars["inline-size"] || vars["block-size"]
    end)
  end

  defp legend_text(html) do
    html
    |> part("legend")
    |> LazyHTML.text()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp count_part(html, name) do
    html
    |> part(name)
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(~r/data-part="#{Regex.escape(name)}"/, &1)))
  end

  describe "group value" do
    test "reports the summed value and the ratio" do
      html = render()

      assert root_attr(html, "data-element") == ["progress_group"]
      assert root_attr(html, "role") == ["progressbar"]
      assert root_attr(html, "aria-valuemin") == ["0"]
      assert root_attr(html, "aria-valuemax") == ["128"]
      assert root_attr(html, "aria-valuenow") == ["69"]
      assert root_attr(html, "aria-valuetext") == ["54%"]
      assert root_attr(html, "aria-label") == ["Storage"]
      assert root_attr(html, "data-orientation") == ["horizontal"]
      assert root_attr(html, "aria-orientation") == []
    end

    test "sizes each segment by its share of max" do
      assert segment_sizes(render()) == [
               "32.8125%",
               "14.0625%",
               "7.03125%"
             ]
    end

    test "normalizes widths when the segments add up past max" do
      html =
        render(
          max: 100,
          segments: [
            %{value: 60, label: "Read"},
            %{value: 60, label: "Write"}
          ]
        )

      assert root_attr(html, "aria-valuenow") == ["100"]
      assert root_attr(html, "aria-valuetext") == ["100%"]
      assert segment_sizes(html) == ["50%", "50%"]
      assert length(String.split(legend_text(html), "50%")) == 3
    end

    test "clamps negative and non-numeric values at zero" do
      html =
        render(
          max: 5,
          segments: [%{value: -10}, %{value: "nope"}, %{value: "5"}]
        )

      assert root_attr(html, "aria-valuenow") == ["5"]
      assert root_attr(html, "aria-valuetext") == ["100%"]
      assert segment_sizes(html) == ["0%", "0%", "100%"]
    end

    test "falls back to 100 for a non-positive maximum" do
      html = render(max: 0, segments: [%{value: 40, label: "Used"}])

      assert root_attr(html, "aria-valuemax") == ["100"]
      assert root_attr(html, "aria-valuenow") == ["40"]
      assert segment_sizes(html) == ["40%"]
    end

    test "shows the summed status above the bar" do
      html = render(show_status: true)

      assert LazyHTML.text(part(html, "status")) |> String.trim() == "54%"
      assert LazyHTML.attribute(part(html, "status"), "aria-hidden") == ["true"]
      assert TestDOM.style_var(html, ~s([data-part="status"]), "inline-size") == "53.90625%"
    end

    test "omits the status width on a vertical group" do
      html = render(orientation: "vertical", show_status: true)

      assert LazyHTML.text(part(html, "status")) |> String.trim() == "54%"
      assert LazyHTML.attribute(part(html, "status"), "style") == []
    end

    test "renders a custom status slot without show_status" do
      html =
        render_component(&TestComponent.custom_status/1, %{show_status: false})
        |> LazyHTML.from_fragment()

      status = part(html, "status")

      assert LazyHTML.text(status) |> String.trim() == "69 GB of 100 GB used"
      assert LazyHTML.attribute(status, "aria-hidden") == []
      assert TestDOM.style_var(html, ~s([data-part="status"]), "inline-size") == "60%"
    end

    test "the custom status wins over show_status" do
      html =
        render_component(&TestComponent.custom_status/1, %{show_status: true})
        |> LazyHTML.from_fragment()

      status = part(html, "status")

      assert LazyHTML.text(status) |> String.trim() == "69 GB of 100 GB used"
      assert LazyHTML.attribute(status, "aria-hidden") == []
    end

    test "forwards caller globals to the root" do
      html = render(class: "my-group", data_test: "storage")

      assert root_attr(html, "class") == ["my-group"]
      assert root_attr(html, "data-test") == ["storage"]
    end
  end

  describe "legend" do
    test "renders one row per segment with its label and percentage" do
      html = render()

      assert count_part(html, "item") == 3
      assert count_part(html, "dot") == 3

      text = legend_text(html)

      assert text =~ "Compute"
      assert text =~ "Storage"
      assert text =~ "Bandwidth"
      assert text =~ "33%"
      assert text =~ "14%"
      assert text =~ "7%"
    end

    test "carries each segment's color on the bar and the row" do
      segments = [
        %{value: 42, label: "Compute", color: "primary"},
        %{value: 18, label: "Storage", color: "info"},
        %{value: 9, label: "Bandwidth", color: "warning"}
      ]

      html = render(segments: segments)

      assert LazyHTML.attribute(part(html, "segment"), "data-color") ==
               ["primary", "info", "warning"]

      assert LazyHTML.attribute(part(html, "item"), "data-color") ==
               ["primary", "info", "warning"]
    end

    test "replaces the dot with an icon" do
      segments = [
        %{value: 42, label: "Compute", icon: "lucide-cpu"},
        %{value: 18, label: "Storage"}
      ]

      html = render(segments: segments)

      assert count_part(html, "dot") == 1
      assert count_part(html, "icon") == 1
      assert LazyHTML.attribute(part(html, "icon"), "class") == ["lucide-cpu"]
      assert LazyHTML.attribute(part(html, "icon"), "aria-hidden") == ["true"]
    end

    test "renders a legend for an icon without a label" do
      html = render(segments: [%{value: 42, icon: "lucide-cpu"}])

      assert count_part(html, "item") == 1
      assert count_part(html, "label") == 0
      assert legend_text(html) == "33%"
    end

    test "omits the legend when no segment has content" do
      html = render(segments: [%{value: 42}, %{value: 18}])

      assert count_part(html, "legend") == 0
      assert count_part(html, "segment") == 2
    end

    test "replaces the label text with a custom inner block" do
      html = render_component(&TestComponent.custom_label/1, %{}) |> LazyHTML.from_fragment()

      text = legend_text(html)

      assert text =~ "Custom"
      assert text =~ "label"
      refute text =~ "Fallback"
    end
  end

  describe "orientation" do
    test "fills the block axis on a vertical group" do
      html = render(orientation: "vertical")

      assert root_attr(html, "data-orientation") == ["vertical"]
      assert root_attr(html, "aria-orientation") == ["vertical"]

      assert segment_sizes(html) == [
               "32.8125%",
               "14.0625%",
               "7.03125%"
             ]
    end
  end
end
