defmodule FlintUIDocsWeb.Docs.Slider do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :slider

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        controls: [
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :color, type: :select, default: "primary", label: "Color"}
        ]
      },
      %{tab: :styled, section: :usage, id: :range, title: "Range Selection"},
      %{tab: :styled, section: :usage, id: :tooltip, title: "Tooltips and Markers"},
      %{
        tab: :styled,
        section: :usage,
        id: :orientation,
        title: "Vertical",
        controls: [
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"}
        ]
      },
      %{tab: :styled, section: :usage, id: :validation, title: "Description and Validation"},
      %{tab: :styled, section: :usage, id: :readonly, title: "Disabled and Read-only"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :settings,
        title: "Settings Panel",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={~S|A slider chooses a number from a range. It keeps the native
      `input[type=range]`, so dragging, the arrow keys, and form submission belong to the
      browser. `label` names the control through `for`; pass an `id` or bind a `field`, which
      supplies one. `sublabel` adds a short qualifier, and `description` renders linked helper
      text between the label and the track.|} />

    <.prose content="`size` follows the shared control scale, so the track, thumb, and text grow
      together. `color` sets the filled track and the thumb ring; the thumb body stays a neutral
      surface." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.slider
          id="slider-basic-volume"
          name="volume"
          label="Volume"
          sublabel="Optional"
          description="Controls the output level."
          value="40"
          size={props.size}
          color={props.color}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :range} = assigns) do
    ~H"""
    <.prose content={~S|Set `range` to select a span with two thumbs. `min_value` is the lower
      thumb and `max_value` is the upper thumb; either defaults to the matching bound. The hook
      keeps the lower thumb at or below the upper thumb.|} />

    <.prose content={~S|A range slider submits both values under one list: the component appends
      `[]` to `name`, so the server receives `%{"price" => ["200", "800"]}`. A bound field value
      may be a two-item list, or a map with `min` and `max` keys. In range mode the visible label
      cannot point at both inputs, so each thumb is named after the label plus “minimum” or
      “maximum”.|} />

    <.preview {assigns} code={~S|<.slider
      id="price"
      name="price"
      label="Price range"
      range
      min="0"
      max="1000"
      min_value="200"
      max_value="800"
      show_tooltip
    />|}>
      <div class="w-full max-w-sm">
        <Components.slider
          id="slider-range-price"
          name="price"
          label="Price range"
          range
          min="0"
          max="1000"
          min_value="200"
          max_value="800"
          show_tooltip
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :tooltip} = assigns) do
    ~H"""
    <.prose content="`show_tooltip` (off by default) shows the current value above the thumb
      while the control has focus or is being dragged. A range slider shows one tooltip per thumb.
      The tooltip repeats the value the native input already announces, so it is hidden from
      assistive technology." />

    <.prose content="`show_markers` draws a dot at every step. Steps are counted from `min`; a
      range that would need more than 100 markers renders none, because the dots stop being readable.
      Markers are server-rendered and work without JavaScript. The tooltip text and the fill
      track the value through the `FlintUI.Slider` hook; without the bundle they keep their
      server-rendered value." />

    <.preview {assigns} code={~S|<.slider
      id="quality"
      name="quality"
      label="Quality"
      min="0"
      max="10"
      value="6"
      show_markers
      show_tooltip
    />|}>
      <div class="w-full max-w-sm">
        <Components.slider
          id="slider-tooltip-quality"
          name="quality"
          label="Quality"
          min="0"
          max="10"
          value="6"
          show_markers
          show_tooltip
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :orientation} = assigns) do
    ~H"""
    <.prose content={~S|Set `orientation` to `vertical` to put the track on its side. The minimum
      sits at the bottom, the label stays above the track, and the tooltip moves beside the thumb.
      The control keeps the same `size` scale and a default height of ten rems.|} />

    <.preview :let={props} {assigns} code={&code_orientation/1}>
      <div class="flex items-end gap-8">
        <Components.slider
          id="slider-vertical-volume"
          name="volume"
          label="Volume"
          value="65"
          orientation={props.orientation}
          show_tooltip
        />
        <Components.slider
          id="slider-vertical-bass"
          name="bass"
          label="Bass"
          value="40"
          orientation={props.orientation}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`description` renders explanatory text between the label and the track.
      `hint` renders supporting text below the track. Both link from the inputs with
      `aria-describedby`, and `errors` adds one paragraph per message and marks the inputs
      invalid. Errors only show for a form field once it has been used." />

    <.preview {assigns} code={~S|<.slider
      id="server-load"
      name="server_load"
      label="Server load"
      description="The alarm fires above 80%."
      hint="Updates every minute."
      value="72"
      errors={["is above the alarm threshold"]}
      show_tooltip
    />|}>
      <div class="w-full max-w-sm">
        <Components.slider
          id="slider-validation-load"
          name="server_load"
          label="Server load"
          description="The alarm fires above 80%."
          hint="Updates every minute."
          value="72"
          errors={["is above the alarm threshold"]}
          show_tooltip
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :readonly} = assigns) do
    ~H"""
    <.prose content={~S|`disabled` renders the native attribute, removes the slider from the tab
      order, and drops it from the form payload. Native range inputs have no read-only
      attribute, so `readonly` keeps the value visible, focusable, and submitted while the hook
      blocks changes and restores the value. Without the bundle, the theme still blocks pointer
      changes, but the keyboard can still change the value.|} />

    <.preview {assigns} code={~S|<.slider
      id="budget"
      name="budget"
      label="Monthly budget"
      value="40"
      readonly
      show_tooltip
    />
    <.slider id="quota" name="quota" label="Storage quota" value="75" disabled />|}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.slider
          id="slider-readonly-budget"
          name="budget"
          label="Monthly budget"
          value="40"
          readonly
          show_tooltip
        />
        <Components.slider
          id="slider-disabled-quota"
          name="quota"
          label="Storage quota"
          value="75"
          disabled
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive the root id, name, value, and
      errors. The field drives the value, so the slider stays in step with the form after a
      validation round trip. A range field takes a two-item list." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:settings} id="audio-form">
      <.slider field={f[:volume]} label="Volume" show_tooltip />
    </.form>|}>
      <.form :let={f} for={%{}} as={:settings} id="slider-field-form">
        <div class="w-full max-w-sm">
          <Components.slider field={f[:volume]} label="Volume" show_tooltip />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :settings} = assigns) do
    ~H"""
    <.prose content="A settings panel can mix a single slider with a range that shares the same
      field contract. Both stay in one form and submit their own parameters." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:audio} id="audio-settings">
      <.slider field={f[:volume]} label="Volume" show_tooltip />
      <.slider
        field={f[:balance]}
        label="Balance"
        min="-5"
        max="5"
        value="0"
        show_tooltip
      />
      <.slider
        field={f[:frequency]}
        label="Frequency range"
        range
        min="20"
        max="20000"
        step="100"
        min_value="200"
        max_value="8000"
        show_tooltip
      />
    </.form>|}>
      <.form :let={f} for={%{}} as={:audio} id="slider-example-form">
        <div class="grid w-full max-w-sm gap-6">
          <Components.slider field={f[:volume]} label="Volume" value="65" show_tooltip />
          <Components.slider
            field={f[:balance]}
            label="Balance"
            min="-5"
            max="5"
            value="0"
            show_tooltip
          />
          <Components.slider
            field={f[:frequency]}
            label="Frequency range"
            range
            min="20"
            max="20000"
            step="100"
            min_value="200"
            max_value="8000"
            show_tooltip
          />
        </div>
      </.form>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-sm">
      <Components.slider
        id={"#{@parts_id}-price"}
        name={"#{@parts_id}-price"}
        label="Price range"
        sublabel="Required"
        description="Choose the lowest and highest price."
        hint="Both thumbs are included in the form payload."
        range
        min="0"
        max="100"
        min_value="20"
        max_value="80"
        show_markers
        show_tooltip
        errors={["must span at least 20"]}
      />
    </div>
    """
  end

  defp code_basic(props) do
    attrs = [
      ~s(id="volume"),
      ~s(name="volume"),
      ~s(label="Volume"),
      ~s(sublabel="Optional"),
      ~s(description="Controls the output level."),
      ~s(value="40"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("color", props.color, "primary")
    ]

    Snippet.component(".slider", attrs)
  end

  defp code_orientation(props) do
    Snippet.component(".slider", [
      ~s(id="volume"),
      ~s(name="volume"),
      ~s(label="Volume"),
      ~s(value="65"),
      Snippet.attr("orientation", props.orientation, "horizontal"),
      "show_tooltip"
    ])
  end
end
