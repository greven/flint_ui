defmodule FlintUI.Base.SliderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.TestDOM

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.slider
        id={@id}
        name={@name}
        label={@label}
        sublabel={@sublabel}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        description={@description}
        hint={@hint}
        errors={@errors}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        orientation={@orientation}
        show_tooltip={@show_tooltip}
        class={@class}
      />
      """
    end

    def range(assigns) do
      ~H"""
      <.slider
        id={@id}
        name={@name}
        label={@label}
        range
        min={@min}
        max={@max}
        min_value={@min_value}
        max_value={@max_value}
        show_markers={@show_markers}
        show_tooltip={@show_tooltip}
      />
      """
    end

    def field(assigns) do
      ~H"""
      <.slider field={@field} label="Volume" />
      """
    end

    def field_range(assigns) do
      ~H"""
      <.slider field={@field} label="Price range" range min="0" max="100" />
      """
    end

    def range_aria_label(assigns) do
      ~H"""
      <.slider id="budget" name="budget" label="Budget" range aria-label="Budget" />
      """
    end

    def range_aria_labelledby(assigns) do
      ~H"""
      <.slider
        id="budget"
        name="budget"
        label="Budget"
        range
        aria-labelledby="budget-label"
      />
      """
    end
  end

  @defaults %{
    id: "volume",
    name: "volume",
    label: "Volume",
    sublabel: nil,
    value: nil,
    min: 0,
    max: 100,
    step: 1,
    description: nil,
    hint: nil,
    errors: [],
    disabled: false,
    readonly: false,
    required: false,
    orientation: "horizontal",
    show_tooltip: false,
    class: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp render_range(overrides \\ %{}) do
    assigns =
      Map.merge(
        %{
          id: "price",
          name: "price",
          label: "Price range",
          min: 0,
          max: 100,
          min_value: 20,
          max_value: 80,
          show_markers: false,
          show_tooltip: false
        },
        Map.new(overrides)
      )

    render_component(&TestComponent.range/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp control(html), do: LazyHTML.query(html, ~s([data-part="control"]))
  defp control_attr(html, name), do: LazyHTML.attribute(control(html), name)
  defp inputs(html), do: LazyHTML.query(html, ~s([data-part="input"]))
  defp label(html), do: LazyHTML.query(html, ~s([data-part="label"]))
  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp assert_control_vars(html, start, finish) do
    styles = TestDOM.style_vars(control(html))

    assert styles["--_fl-slider-start"] == start
    assert styles["--_fl-slider-end"] == finish
  end

  describe "single slider" do
    test "renders the field, label, track, and one native range input" do
      html = render()

      assert root_attr(html, "data-element") == ["slider"]
      assert root_attr(html, "id") == ["volume"]
      assert root_attr(html, "phx-hook") == ["FlintUI.Slider"]
      assert root_attr(html, "data-range") == []
      assert root_attr(html, "data-orientation") == ["horizontal"]
      assert root_attr(html, "data-disabled") == []
      assert root_attr(html, "data-readonly") == []
      assert root_attr(html, "data-required") == []
      assert root_attr(html, "data-invalid") == []

      assert LazyHTML.attribute(label(html), "for") == ["volume-input"]
      assert LazyHTML.text(label(html)) =~ "Volume"

      input = inputs(html)
      assert LazyHTML.attribute(input, "type") == ["range"]
      assert LazyHTML.attribute(input, "id") == ["volume-input"]
      assert LazyHTML.attribute(input, "name") == ["volume"]
      assert LazyHTML.attribute(input, "value") == ["50"]
      assert LazyHTML.attribute(input, "min") == ["0"]
      assert LazyHTML.attribute(input, "max") == ["100"]
      assert LazyHTML.attribute(input, "step") == ["1"]
      assert LazyHTML.attribute(input, "aria-readonly") == []

      refute Enum.empty?(part(html, "track"))
      refute Enum.empty?(part(html, "indicator"))
      assert Enum.empty?(part(html, "markers"))
      assert Enum.empty?(part(html, "tooltip"))
    end

    test "publishes the server-rendered thumb fraction" do
      html = render(value: 40)

      assert_control_vars(html, "0.0", "0.4")
    end

    test "renders a midpoint default value" do
      html = render(min: 0, max: 10, step: 1)

      assert LazyHTML.attribute(inputs(html), "value") == ["5"]
      assert_control_vars(html, "0.0", "0.5")
    end

    test "renders the tooltip for the current value" do
      html = render(value: 40, show_tooltip: true)

      tooltip = part(html, "tooltip")
      assert Enum.count(tooltip) == 1
      assert LazyHTML.text(tooltip) |> String.trim() == "40"
      assert LazyHTML.attribute(tooltip, "aria-hidden") == ["true"]
      assert TestDOM.style_vars(tooltip)["--_fl-slider-offset"] == "0.4"
    end

    test "renders a fractional step and value" do
      html = render(min: 0, max: 1, step: 0.1, value: 0.5, show_tooltip: true)

      assert LazyHTML.attribute(inputs(html), "step") == ["0.1"]
      assert LazyHTML.attribute(inputs(html), "value") == ["0.5"]
      assert_control_vars(html, "0.0", "0.5")
      assert LazyHTML.text(part(html, "tooltip")) |> String.trim() == "0.5"
    end

    test "clamps a value outside the range" do
      html = render(value: 140)

      assert LazyHTML.attribute(inputs(html), "value") == ["100"]
      assert_control_vars(html, "0.0", "1.0")
    end

    test "renders the description, hint, and errors" do
      html =
        render(
          description: "Controls the output.",
          hint: "Applies immediately.",
          errors: ["must be louder"]
        )

      assert root_attr(html, "data-invalid") == [""]
      assert LazyHTML.attribute(part(html, "description"), "id") == ["volume-description"]
      assert LazyHTML.attribute(part(html, "hint"), "id") == ["volume-hint"]
      assert LazyHTML.attribute(part(html, "error"), "id") == ["volume-error-1"]

      input = inputs(html)
      assert LazyHTML.attribute(input, "aria-invalid") == ["true"]

      assert LazyHTML.attribute(input, "aria-describedby") == [
               "volume-description volume-hint volume-error-1"
             ]
    end

    test "renders disabled, read-only, and required state" do
      html = render(disabled: true, readonly: true, required: true)

      assert root_attr(html, "data-disabled") == [""]
      assert root_attr(html, "data-readonly") == [""]
      assert root_attr(html, "data-required") == [""]

      input = inputs(html)
      assert LazyHTML.attribute(input, "disabled") == [""]
      assert LazyHTML.attribute(input, "required") == [""]
      assert LazyHTML.attribute(input, "aria-readonly") == ["true"]
    end

    test "renders a vertical orientation" do
      html = render(orientation: "vertical")

      assert root_attr(html, "data-orientation") == ["vertical"]
    end
  end

  describe "range slider" do
    test "renders two named thumbs and one list param" do
      html = render_range()

      assert root_attr(html, "data-range") == [""]
      assert LazyHTML.attribute(label(html), "for") == []

      min_input = LazyHTML.query(html, ~s([data-part="input"][data-thumb="min"]))
      max_input = LazyHTML.query(html, ~s([data-part="input"][data-thumb="max"]))
      assert LazyHTML.attribute(min_input, "id") == ["price-min"]
      assert LazyHTML.attribute(max_input, "id") == ["price-max"]
      assert LazyHTML.attribute(min_input, "name") == ["price[]"]
      assert LazyHTML.attribute(max_input, "name") == ["price[]"]
      assert LazyHTML.attribute(min_input, "value") == ["20"]
      assert LazyHTML.attribute(max_input, "value") == ["80"]
      assert LazyHTML.attribute(min_input, "data-thumb") == ["min"]
      assert LazyHTML.attribute(max_input, "data-thumb") == ["max"]
      assert LazyHTML.attribute(min_input, "aria-label") == ["Price range minimum"]
      assert LazyHTML.attribute(max_input, "aria-label") == ["Price range maximum"]

      assert control_attr(html, "data-range") == [""]
      assert_control_vars(html, "0.2", "0.8")
    end

    test "keeps an existing list suffix" do
      html = render_range(name: "price[]")

      assert LazyHTML.attribute(inputs(html), "name") == ["price[]", "price[]"]
    end

    test "renders one tooltip per thumb" do
      html = render_range(show_tooltip: true)

      min_tooltip = LazyHTML.query(html, ~s([data-part="tooltip"][data-thumb="min"]))
      max_tooltip = LazyHTML.query(html, ~s([data-part="tooltip"][data-thumb="max"]))
      assert LazyHTML.attribute(min_tooltip, "data-thumb") == ["min"]
      assert LazyHTML.attribute(max_tooltip, "data-thumb") == ["max"]
      assert LazyHTML.text(min_tooltip) |> String.trim() == "20"
      assert LazyHTML.text(max_tooltip) |> String.trim() == "80"
      assert LazyHTML.attribute(min_tooltip, "aria-hidden") == ["true"]
    end

    test "renders a marker for every step" do
      html = render_range(min: 0, max: 8, min_value: 2, max_value: 6, show_markers: true)

      markers = part(html, "marker")
      assert Enum.count(markers) == 9

      assert markers
             |> LazyHTML.attribute("style")
             |> Enum.map(&TestDOM.style_vars/1)
             |> Enum.map(& &1["--_fl-slider-offset"]) == [
               "0.0",
               "0.125",
               "0.25",
               "0.375",
               "0.5",
               "0.625",
               "0.75",
               "0.875",
               "1.0"
             ]
    end

    test "skips markers past the cap" do
      html = render_range(min: 0, max: 1000, min_value: 200, max_value: 800, show_markers: true)

      assert Enum.empty?(part(html, "marker"))
    end

    test "defaults each thumb to its bound" do
      html = render_range(min_value: nil, max_value: nil)

      assert LazyHTML.attribute(inputs(html), "value") == ["0", "100"]
      assert_control_vars(html, "0.0", "1.0")
    end

    test "clamps crossed or out-of-range thumbs" do
      html = render_range(min_value: 90, max_value: 110)

      assert LazyHTML.attribute(inputs(html), "value") == ["90", "100"]
      assert_control_vars(html, "0.9", "1.0")
    end
  end

  describe "form fields" do
    test "derives the id, name, value, and errors from a field" do
      form = Phoenix.Component.to_form(%{"volume" => 30}, as: :user)

      html =
        render_component(&TestComponent.field/1, %{field: form[:volume]})
        |> LazyHTML.from_fragment()

      assert root_attr(html, "id") == ["user_volume"]

      input = inputs(html)
      assert LazyHTML.attribute(input, "id") == ["user_volume-input"]
      assert LazyHTML.attribute(input, "name") == ["user[volume]"]
      assert LazyHTML.attribute(input, "value") == ["30"]
    end

    test "derives the two thumbs from a bound list" do
      form = Phoenix.Component.to_form(%{"price" => [10, 90]}, as: :user)

      html =
        render_component(&TestComponent.field_range/1, %{field: form[:price]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(inputs(html), "value") == ["10", "90"]
      assert LazyHTML.attribute(inputs(html), "name") == ["user[price][]", "user[price][]"]
    end
  end

  describe "accessibility and forwarding" do
    test "uses a caller aria-label as the range thumb prefix" do
      html =
        render_component(&TestComponent.range_aria_label/1, %{}) |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(inputs(html), "aria-label") == [
               "Budget minimum",
               "Budget maximum"
             ]
    end

    test "leaves aria-labelledby in charge when supplied" do
      html =
        render_component(&TestComponent.range_aria_labelledby/1, %{})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(inputs(html), "aria-label") == []

      assert LazyHTML.attribute(inputs(html), "aria-labelledby") == [
               "budget-label",
               "budget-label"
             ]
    end
  end
end
