defmodule FlintUI.Base.ProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.progress
        value={@value}
        max={@max}
        label={@label}
        orientation={@orientation}
        show_status={@show_status}
        class={@class}
        data-test={@data_test}
      />
      """
    end

    def rest_attrs(assigns) do
      ~H"""
      <.progress
        value="40"
        label="Upload progress"
        class="my-progress"
        data-test="progress"
      />
      """
    end

    def labelled(assigns) do
      ~H"""
      <.progress value="40" label="Upload progress" aria-labelledby="upload-label" />
      """
    end

    def caller_named(assigns) do
      ~H"""
      <.progress value="40" label="Upload progress" aria-label="Custom name" />
      """
    end
  end

  @defaults %{
    value: 40,
    max: 100,
    label: nil,
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
  defp segment_style(html), do: LazyHTML.attribute(part(html, "segment"), "style")

  defp count_part(html, name) do
    html
    |> part(name)
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(~r/data-part="#{Regex.escape(name)}"/, &1)))
  end

  describe "determinate progress" do
    test "renders the progressbar role and the current percentage" do
      html = render()

      assert root_attr(html, "data-element") == ["progress"]
      assert root_attr(html, "role") == ["progressbar"]
      assert root_attr(html, "aria-valuemin") == ["0"]
      assert root_attr(html, "aria-valuemax") == ["100"]
      assert root_attr(html, "aria-valuenow") == ["40"]
      assert root_attr(html, "aria-valuetext") == ["40%"]
      assert root_attr(html, "data-orientation") == ["horizontal"]
      assert root_attr(html, "data-state") == []
      assert root_attr(html, "aria-orientation") == []

      assert segment_style(html) == ["inline-size: 40%"]
      assert part(html, "status") |> Enum.empty?()
      assert part(html, "header") |> Enum.empty?()
      assert part(html, "label") |> Enum.empty?()
      assert LazyHTML.attribute(part(html, "track"), "aria-hidden") == ["true"]
      assert LazyHTML.attribute(part(html, "segment"), "aria-hidden") == ["true"]
    end

    test "uses the maximum as the scale and reports the ratio" do
      html = render(value: 3, max: 4)

      assert root_attr(html, "aria-valuemax") == ["4"]
      assert root_attr(html, "aria-valuenow") == ["3"]
      assert root_attr(html, "aria-valuetext") == ["75%"]
      assert segment_style(html) == ["inline-size: 75%"]
    end

    test "accepts numbers and numeric strings" do
      assert render(value: 42) |> root_attr("aria-valuenow") == ["42"]
      assert render(value: "42") |> root_attr("aria-valuenow") == ["42"]
      assert render(max: "4", value: "3") |> root_attr("aria-valuemax") == ["4"]
    end

    test "renders a fractional value" do
      html = render(value: 0.5, max: 1)

      assert root_attr(html, "aria-valuenow") == ["0.5"]
      assert root_attr(html, "aria-valuemax") == ["1"]
      assert root_attr(html, "aria-valuetext") == ["50%"]
      assert segment_style(html) == ["inline-size: 50%"]
    end

    test "clamps values outside the scale" do
      high = render(value: 150)
      assert root_attr(high, "aria-valuenow") == ["100"]
      assert root_attr(high, "aria-valuetext") == ["100%"]
      assert segment_style(high) == ["inline-size: 100%"]

      low = render(value: -10)
      assert root_attr(low, "aria-valuenow") == ["0"]
      assert root_attr(low, "aria-valuetext") == ["0%"]
      assert segment_style(low) == ["inline-size: 0%"]
    end

    test "falls back to 100 for a non-positive maximum" do
      html = render(max: 0, value: 40)

      assert root_attr(html, "aria-valuemax") == ["100"]
      assert root_attr(html, "aria-valuenow") == ["40"]
    end

    test "rounds the status and value text" do
      html = render(value: 1, max: 3, show_status: true)

      assert root_attr(html, "aria-valuetext") == ["33%"]
      assert LazyHTML.text(part(html, "status")) |> String.trim() == "33%"
    end

    test "renders the status in the header above the bar" do
      html = render(show_status: true)
      status = part(html, "status")

      assert Enum.count(status) == 1
      assert LazyHTML.text(status) |> String.trim() == "40%"
      assert LazyHTML.attribute(status, "aria-hidden") == ["true"]

      assert LazyHTML.query(html, ~s([data-part="header"] > [data-part="status"])) |> Enum.count() ==
               1
    end

    test "renders the label visibly and names the bar from it" do
      html = render(label: "Upload progress")
      label = part(html, "label")
      label_id = LazyHTML.attribute(label, "id") |> List.first()

      assert LazyHTML.text(label) |> String.trim() == "Upload progress"
      assert label_id

      assert LazyHTML.query(html, ~s([data-part="header"] > [data-part="label"])) |> Enum.count() ==
               1

      assert root_attr(html, "aria-labelledby") == [label_id]
      assert root_attr(html, "aria-label") == []
    end

    test "renders only the status when the label is omitted" do
      html = render(show_status: true)

      assert part(html, "label") |> Enum.empty?()

      assert LazyHTML.query(html, ~s([data-part="header"] > [data-part="status"])) |> Enum.count() ==
               1
    end

    test "lets a caller aria-label replace the generated label reference" do
      html = render_component(&TestComponent.caller_named/1, %{}) |> LazyHTML.from_fragment()

      assert root_attr(html, "aria-label") == ["Custom name"]
      assert root_attr(html, "aria-labelledby") == []
    end

    test "forwards caller globals to the root" do
      html = render_component(&TestComponent.rest_attrs/1, %{}) |> LazyHTML.from_fragment()

      assert root_attr(html, "class") == ["my-progress"]
      assert root_attr(html, "data-test") == ["progress"]
    end

    test "forwards aria-labelledby unchanged" do
      html = render_component(&TestComponent.labelled/1, %{}) |> LazyHTML.from_fragment()

      assert root_attr(html, "aria-labelledby") == ["upload-label"]
      assert root_attr(html, "aria-label") == []
    end
  end

  describe "indeterminate progress" do
    test "omits the value attributes and renders no status" do
      html = render(value: nil, show_status: true)

      assert root_attr(html, "data-state") == ["indeterminate"]
      assert root_attr(html, "aria-valuenow") == []
      assert root_attr(html, "aria-valuetext") == []
      assert part(html, "status") |> Enum.empty?()
      assert segment_style(html) == []
    end

    test "treats a blank value as indeterminate" do
      html = render(value: "")

      assert root_attr(html, "data-state") == ["indeterminate"]
      assert root_attr(html, "aria-valuenow") == []
    end
  end

  describe "step labels" do
    @steps ["Waiting", "Cloning", "Migrating", "Deploying", "Done"]

    test "uses the last label index as the maximum" do
      html = render(value: 3, max: @steps)

      assert root_attr(html, "aria-valuemax") == ["4"]
      assert root_attr(html, "aria-valuenow") == ["3"]
      assert root_attr(html, "aria-valuetext") == ["Deploying"]
      assert segment_style(html) == ["inline-size: 75%"]
    end

    test "renders the labels below the bar and marks the active step" do
      html = render(value: 2, max: @steps)
      steps = part(html, "steps")
      active = LazyHTML.query(html, ~s([data-part="step"][data-active]))

      assert LazyHTML.attribute(steps, "aria-hidden") == ["true"]
      assert count_part(html, "step") == 5
      assert LazyHTML.text(active) |> String.trim() == "Migrating"
      assert LazyHTML.text(steps) =~ "Waiting"
      assert LazyHTML.text(steps) =~ "Done"
    end

    test "keeps fractional values in the step they reached" do
      reached = render(value: 3.9, max: @steps)

      assert root_attr(reached, "aria-valuetext") == ["Deploying"]

      idle = render(value: 0.4, max: @steps)

      assert root_attr(idle, "aria-valuetext") == ["Waiting"]
    end

    test "clamps the step to the ends" do
      high = render(value: 99, max: @steps)

      assert root_attr(high, "aria-valuetext") == ["Done"]

      low = render(value: -4, max: @steps)

      assert root_attr(low, "aria-valuetext") == ["Waiting"]
    end

    test "renders no steps while the bar is indeterminate" do
      html = render(value: nil, max: @steps)

      assert part(html, "steps") |> Enum.empty?()
      assert root_attr(html, "aria-valuetext") == []
    end

    test "accepts a single label" do
      html = render(value: 1, max: ["Done"])

      assert root_attr(html, "aria-valuemax") == ["1"]
      assert root_attr(html, "aria-valuetext") == ["Done"]
      assert segment_style(html) == ["inline-size: 100%"]
    end

    test "keeps the percentage when a step label is blank" do
      html = render(value: 0, max: ["", "Done!"])

      assert root_attr(html, "aria-valuetext") == ["0%"]
    end
  end

  describe "orientation" do
    test "marks a vertical bar and fills it on the block axis" do
      html = render(orientation: "vertical")

      assert root_attr(html, "data-orientation") == ["vertical"]
      assert root_attr(html, "aria-orientation") == ["vertical"]
      assert segment_style(html) == ["block-size: 40%"]
    end

    test "keeps horizontal as the default" do
      html = render()

      assert root_attr(html, "data-orientation") == ["horizontal"]
      assert root_attr(html, "aria-orientation") == []
    end
  end
end
