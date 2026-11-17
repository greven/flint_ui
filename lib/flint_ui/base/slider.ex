defmodule FlintUI.Base.Slider do
  @moduledoc """
  Renders a slider with a label, an optional sublabel, a description, a hint,
  and errors.

  A slider chooses a number from a range by dragging a thumb. It uses native
  range inputs, so the browser keeps the keyboard behavior, the form submission,
  and the slider semantics.

      <.slider
        id="volume"
        name="volume"
        label="Volume"
        min="0"
        max="100"
        value="40"
      />

  Pass a `Phoenix.HTML.FormField` to bind the slider to a form. The component
  derives `id`, `name`, the current value, and the errors, and shows the field's
  errors only after it has been used (`Phoenix.Component.used_input?/1`):

      <.slider field={@form[:volume]} label="Volume" />

  ## Range sliders

  Set `range` to select a span with two thumbs. `min_value` is the lower thumb
  and `max_value` the upper thumb; either defaults to the matching bound:

      <.slider
        field={@form[:price]}
        label="Price range"
        range
        min="0"
        max="1000"
        min_value="200"
        max_value="800"
      />

  A range slider submits both values under one list. The component appends `[]`
  to `name`, so the server receives `%{"price" => ["200", "800"]}`. A bound
  field value may be a two-item list, or a map with `min` and `max` keys. The
  hook keeps the lower thumb at or below the upper thumb.

  ## Markers and tooltips

  `show_markers` draws a dot at every step between `min` and `max`. Steps are
  counted from `min`. A range that would need more than 100 markers renders
  none, since the dots stop being readable and the markup grows without bound.

  `show_tooltip` (off by default) shows the current value above the thumb while
  the control has focus or is being dragged. A range slider shows one tooltip
  per thumb. The tooltip is decorative and hidden from assistive technology,
  because the native input already announces its value.

      <.slider label="Quality" min="0" max="100" value="50" show_tooltip show_markers />

  Markers are server-rendered and work without JavaScript. The tooltip text and
  thumb position track the value through the `FlintUI.Slider` hook; without the
  bundle they keep their server-rendered value. A range slider still drags and
  submits without the hook, but the fill between the thumbs keeps its
  server-rendered span.

  ## Sizes and orientation

  `size` and `color` live on the generated styled component. `orientation` is a
  headless attribute: `horizontal` is the default and `vertical` puts the track
  on its side, with the minimum at the bottom.

      <.slider label="Volume" orientation="vertical" value="60" />

  ## Read-only, disabled, and required

  `disabled` renders the native attribute on both inputs and removes the slider
  from the tab order. `readonly` keeps the value visible and focusable and keeps
  it in the form submission; native range inputs have no read-only attribute, so
  the hook blocks changes and restores the value. Without the bundle, the theme
  still blocks pointer changes, but the keyboard can still change the value.

  `required` renders the native attribute. A range input always has a value, so
  required validation never fails; use a server-side check when a slider must
  differ from its default.

  ## Accessibility

  A single slider is a native `input[type=range]`, exposed as a `slider` with
  its value, minimum, and maximum. The visible label points at it with `for`;
  the description, hint, and errors are linked from the input with
  `aria-describedby`, and errors also set `aria-invalid`.

  In range mode the two inputs are separate sliders. The visible label cannot
  point at both, so each input is named after the label plus “minimum” or
  “maximum”, such as “Price range maximum”. A caller-supplied `aria-label` is
  used as that prefix, and `aria-labelledby` passes through unchanged. Each
  thumb is its own tab stop, so a keyboard user reaches both.

  The field `id` names the component root, because the root owns the hook.
  The native inputs derive their ids from it: `<id>-input` for a single slider,
  and `<id>-min` and `<id>-max` for a range. When neither `id` nor `field` is
  given, a root id is generated.

  Never rely on color alone to show the value: keep the label and the tooltip
  or surrounding text meaningful. The styled theme paints the track and thumb
  around the native inputs, so forced-colors mode and assistive technology still
  see real sliders.

  ## Keyboard

  - `Tab` - moves focus into and out of a single slider, or between the two
    thumbs of a range slider.
  - `Arrow keys` - increase or decrease the value by one step.
  - `Home` / `End` - jump to the minimum or maximum.
  - `Page Up` / `Page Down` - move by a larger increment. The exact increment
    is the browser's.
  """

  use FlintUI.Component

  alias FlintUI.{API, Field}

  @max_markers 100

  @impl true
  def meta do
    %Meta{
      name: :slider,
      type: :form,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "slider",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the field root."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "The field root id, derived from the field or generated. The native inputs derive their own ids from it."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: ~s("FlintUI.Slider"),
          description: "Attaches the hook that tracks the fill and the tooltips."
        },
        %Meta.PartAttr{
          name: "[data-range]",
          value: "boolean",
          description: "Present when the slider selects a range with two thumbs."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The orientation the theme lays the track out in."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the slider is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the field has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-readonly]",
          value: "boolean",
          description:
            "Present when the slider is read-only. The hook blocks changes and restores the value."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the slider is required."
        },
        %Meta.PartAttr{
          name: "[data-show-markers]",
          value: "boolean",
          description: "Present when step markers are drawn on the track."
        },
        %Meta.PartAttr{
          name: "[data-show-tooltip]",
          value: "boolean",
          description: "Present when the value tooltip is shown on focus or while dragging."
        },
        %Meta.PartAttr{
          name: "[data-dragging]",
          value: "boolean",
          description: "Present while a thumb is being dragged. Managed by the hook."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description:
            "The field label and sublabel row. It points at the single input with `for`; in range mode it names both thumbs through their `aria-label`s."
        },
        %Meta.PartAttr{
          name: "for",
          value: "string",
          description: "The single input id. Omitted in range mode."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label_text",
          description: "The label text and sublabel row above the track."
        }
      ],
      sublabel: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "sublabel",
          description: "A short muted qualifier shown after the label text, such as `Optional`."
        }
      ],
      description: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "description",
          description:
            "Explanatory text shown between the label and the track and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from the field root id."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description:
            "The interactive area that stacks the track, the native inputs, and the tooltips. The hook publishes the thumb positions on it."
        },
        %Meta.PartAttr{
          name: "[data-range]",
          value: "boolean",
          description: "Present when the control holds two thumbs."
        },
        %Meta.PartAttr{
          name: "style",
          value: "string",
          description:
            "The server-rendered thumb fractions, as the runtime `--_fl-slider-start` and `--_fl-slider-end` properties."
        }
      ],
      track: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "track",
          description:
            "The visual rail. It is stretched between the centres of the end thumbs and is hidden from assistive technology."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The rail is decorative; the native inputs carry the value and semantics."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description:
            "The filled part of the rail, from the minimum to the value, or between the two thumbs in range mode."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The fill is decorative; the native inputs carry the value."
        }
      ],
      markers: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "markers",
          description: "The container for the step markers when `show_markers` is set."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The markers are decorative."
        }
      ],
      marker: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "marker",
          description: "One step marker. Its position is published as `--_fl-slider-offset`."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The marker is decorative."
        }
      ],
      input: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "input",
          description:
            "A native range input. A single slider renders one; a range renders two, marked with `data-thumb`."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("range"),
          description: "The native range type."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "`<root id>-input` for a single slider, or `<root id>-min` and `<root id>-max` for a range."
        },
        %Meta.PartAttr{
          name: "name",
          value: "string",
          description:
            "The form parameter name. In range mode the component appends `[]`, so both values arrive as a list."
        },
        %Meta.PartAttr{
          name: "[data-thumb]",
          value: ~s("min" | "max"),
          description: "Marks the lower and upper thumb in range mode."
        },
        %Meta.PartAttr{
          name: "min",
          value: "number",
          description: "The lowest selectable value. Defaults to `0`."
        },
        %Meta.PartAttr{
          name: "max",
          value: "number",
          description: "The highest selectable value. Defaults to `100`."
        },
        %Meta.PartAttr{
          name: "step",
          value: "number",
          description: "The increment between values, counted from `min`."
        },
        %Meta.PartAttr{
          name: "value",
          value: "number",
          description:
            "The current position. A range slider renders one per thumb, from `min_value` and `max_value`."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Present when the slider is disabled."
        },
        %Meta.PartAttr{
          name: "required",
          value: "boolean",
          description: "Present when the slider is required."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the field has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "The description, hint, and error message ids, appended to a caller-supplied value."
        },
        %Meta.PartAttr{
          name: "aria-readonly",
          value: ~s("true"),
          description: "Set when the slider is read-only; the hook blocks changes."
        }
      ],
      tooltip: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "tooltip",
          description:
            "The current value shown above or beside a thumb when `show_tooltip` is set. One per thumb."
        },
        %Meta.PartAttr{
          name: "[data-thumb]",
          value: ~s("min" | "max"),
          description: "Identifies which thumb the tooltip follows in range mode."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The tooltip repeats the value the native input already announces."
        }
      ],
      hint: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "hint",
          description:
            "Supporting text shown below the track and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The hint id, derived from the field root id."
        }
      ],
      error: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "error",
          description:
            "One error message. Each message carries its own id and is exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The error id, derived from the field root id and the message index."
        }
      ],
      error_icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "error_icon",
          description: "The decorative warning icon that precedes each error message."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The icon is decorative; the error text carries the message."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description:
          "Moves focus into and out of a single slider, or between the two thumbs of a range slider."
      },
      %Meta.Keyboard{
        keys: "Arrow keys",
        description: "Increase or decrease the value by one step."
      },
      %Meta.Keyboard{
        keys: "Home / End",
        description: "Jump to the minimum or maximum."
      },
      %Meta.Keyboard{
        keys: "Page Up / Page Down",
        description: "Move by a larger increment. The exact increment is the browser's."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The slider is disabled.",
        selector: ~s([data-element="slider"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The field has at least one error.",
        selector: ~s([data-element="slider"][data-invalid])
      },
      %Meta.State{
        name: "readonly",
        description: "The slider is read-only; the hook blocks changes.",
        selector: ~s([data-element="slider"][data-readonly])
      },
      %Meta.State{
        name: "required",
        description: "The slider is required.",
        selector: ~s([data-element="slider"][data-required])
      },
      %Meta.State{
        name: "dragging",
        description: "A thumb is being dragged. Managed by the hook.",
        selector: ~s([data-element="slider"][data-dragging])
      }
    ]
  end

  @impl true
  def css_vars do
    [
      %Meta.CSSVar{
        name: "--_fl-slider-start",
        description:
          "Runtime-only start of the fill and lower tooltip position, from `0` to `1`. Rendered on the server and kept current by the hook."
      },
      %Meta.CSSVar{
        name: "--_fl-slider-end",
        description:
          "Runtime-only end of the fill and upper tooltip position, from `0` to `1`. Rendered on the server and kept current by the hook."
      },
      %Meta.CSSVar{
        name: "--_fl-slider-offset",
        description:
          "Runtime-only position of a marker or tooltip along the track, from `0` to `1`."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    derived = resolve(assigns)
    errors = field_errors(assigns)

    %{
      root: %{
        "id" => derived.id,
        "phx-hook" => "FlintUI.Slider",
        "data-element" => "slider",
        "data-part" => "root",
        "data-range" => derived.range,
        "data-orientation" => Map.get(assigns, :orientation, "horizontal"),
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => errors != [],
        "data-readonly" => Map.get(assigns, :readonly, false),
        "data-required" => Map.get(assigns, :required, false),
        "data-show-markers" => Map.get(assigns, :show_markers, false),
        "data-show-tooltip" => Map.get(assigns, :show_tooltip, false)
      },
      label: %{
        "data-part" => "label",
        "for" => if(derived.range, do: nil, else: derived.id <> "-input")
      },
      label_text: %{
        "data-part" => "label_text"
      },
      sublabel: %{
        "data-part" => "sublabel"
      },
      description: %{
        "data-part" => "description",
        "id" => Field.description_id(derived.id, Map.get(assigns, :description))
      },
      control: %{
        "data-part" => "control",
        "data-range" => derived.range,
        "style" =>
          "--_fl-slider-start: #{fraction_string(derived.start)}; " <>
            "--_fl-slider-end: #{fraction_string(derived.stop)}"
      },
      track: %{
        "data-part" => "track",
        "aria-hidden" => "true"
      },
      indicator: %{
        "data-part" => "indicator",
        "aria-hidden" => "true"
      },
      markers: %{
        "data-part" => "markers",
        "aria-hidden" => "true"
      },
      marker: %{
        "data-part" => "marker",
        "aria-hidden" => "true"
      },
      input: %{
        "data-part" => "input",
        "type" => "range"
      },
      tooltip: %{
        "data-part" => "tooltip",
        "aria-hidden" => "true"
      },
      hint: %{
        "data-part" => "hint",
        "id" => Field.hint_id(derived.id, Map.get(assigns, :hint))
      },
      error: %{
        "data-part" => "error"
      },
      error_icon: %{
        "data-part" => "error_icon",
        "aria-hidden" => "true"
      }
    }
  end

  # The public attrs are also the docs API, so keep `doc: false` on internal
  # connectors only.
  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks, and the raw color's inline
  # inputs, on the field root while the caller's global attributes stay on the
  # native inputs. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :id, :any,
    default: nil,
    doc:
      "The field root id. Derived from `field` when omitted, and generated when neither is given. The native inputs derive their ids from it."

  attr :name, :any,
    doc:
      "The form parameter name. Derived from `field` when omitted. In range mode the component appends `[]`, so both values arrive as a list."

  attr :label, :string, default: nil, doc: "The field label."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Optional`."

  attr :value, :any,
    doc:
      "The current value for a single slider, or a two-item list for a range slider. Derived from `field` when omitted. A single slider defaults to the midpoint of `min` and `max`."

  attr :min, :any,
    default: 0,
    doc: "The lowest selectable value. Accepts a number or a numeric string."

  attr :max, :any,
    default: 100,
    doc: "The highest selectable value. Accepts a number or a numeric string."

  attr :step, :any,
    default: 1,
    doc:
      "The increment between values, counted from `min`. Accepts a positive number or numeric string."

  attr :min_value, :any,
    doc:
      "The lower thumb of a range slider. Defaults to `min`, or to the first item of a bound field value."

  attr :max_value, :any,
    doc:
      "The upper thumb of a range slider. Defaults to `max`, or to the second item of a bound field value."

  attr :range, :boolean,
    default: false,
    doc: "Whether the slider selects a span with two thumbs."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc:
      "The slider orientation. A vertical slider puts the minimum at the bottom and centres the track."

  attr :show_markers, :boolean,
    default: false,
    doc:
      "Whether to draw a marker at every step. A range that would need more than 100 markers renders none."

  attr :show_tooltip, :boolean,
    default: false,
    doc:
      "Whether to show the current value in a tooltip on focus or while dragging. The hook keeps the text current."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:volume]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :description, :string,
    default: nil,
    doc:
      "Explanatory text shown between the label and the track and linked with `aria-describedby`."

  attr :hint, :string,
    default: nil,
    doc: "Supporting text shown below the track and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the slider is disabled."

  attr :readonly, :boolean,
    default: false,
    doc:
      "Whether the slider is read-only. The value stays focusable and is still submitted; the hook blocks changes and restores it."

  attr :required, :boolean,
    default: false,
    doc:
      "Whether the slider is required. A range input always has a value, so required validation never fails."

  attr :class, :any, default: nil, doc: "Additional classes for the field root."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc: "Additional HTML and LiveView attributes, rendered on the native inputs."

  @impl true
  def render(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id, errors: errors)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> render()
  end

  def render(assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div {@parts[:root]} {@root_attrs} class={@class}>
      <label :if={@label || @sublabel} {@parts[:label]}>
        <span {@parts[:label_text]}>
          <span :if={@label}>{@label}</span>
          <span :if={@sublabel} {@parts[:sublabel]}>{@sublabel}</span>
        </span>
      </label>
      <p :if={@description} {@parts[:description]}>{@description}</p>
      <div {@parts[:control]}>
        <div {@parts[:track]}>
          <div {@parts[:indicator]}></div>
          <div :if={@show_markers} {@parts[:markers]}>
            <span
              :for={{_value, offset} <- @markers}
              {@parts[:marker]}
              style={"--_fl-slider-offset: #{offset}"}
            ></span>
          </div>
        </div>
        <%= if @range do %>
          <input
            {@input_attrs}
            id={@root_id <> "-min"}
            name={@range_name}
            value={@range_min}
            data-thumb="min"
            aria-label={@min_label}
            disabled={@disabled}
            required={@required}
            aria-readonly={@readonly && "true"}
            {@control_rest}
            {@parts[:input]}
          />
          <input
            {@input_attrs}
            id={@root_id <> "-max"}
            name={@range_name}
            value={@range_max}
            data-thumb="max"
            aria-label={@max_label}
            disabled={@disabled}
            required={@required}
            aria-readonly={@readonly && "true"}
            {@max_control_rest}
            {@parts[:input]}
          />
          <span
            :if={@show_tooltip}
            {@parts[:tooltip]}
            data-thumb="min"
            style={"--_fl-slider-offset: #{@start_offset}"}
          >{@min_tooltip}</span>
          <span
            :if={@show_tooltip}
            {@parts[:tooltip]}
            data-thumb="max"
            style={"--_fl-slider-offset: #{@stop_offset}"}
          >{@max_tooltip}</span>
        <% else %>
          <input
            {@input_attrs}
            id={@root_id <> "-input"}
            name={@name}
            value={@single_value}
            disabled={@disabled}
            required={@required}
            aria-readonly={@readonly && "true"}
            {@control_rest}
            {@parts[:input]}
          />
          <span
            :if={@show_tooltip}
            {@parts[:tooltip]}
            style={"--_fl-slider-offset: #{@stop_offset}"}
          >{@single_tooltip}</span>
        <% end %>
      </div>
      <p :if={@hint} {@parts[:hint]}>{@hint}</p>
      <p
        :for={{message, index} <- Enum.with_index(@errors, 1)}
        id={Field.error_id(@root_id, index)}
        {@parts[:error]}
      >
        <Field.error_icon attrs={@parts[:error_icon]} />
        {message}
      </p>
    </div>
    """
  end

  defp prepare(assigns) do
    parts = assigns.flint_parts
    root_id = parts[:root]["id"]
    errors = Field.translate_errors(Map.get(assigns, :errors) || [])
    invalid? = errors != []
    range = Map.get(assigns, :range, false)
    derived = resolve(assigns)

    described_by =
      Field.described_by(Map.get(assigns, :rest, %{}), [
        parts[:description]["id"],
        parts[:hint]["id"],
        Field.error_ids(root_id, errors)
      ])

    control_rest =
      Map.get(assigns, :rest, %{})
      |> Map.drop([:"aria-invalid", "aria-invalid", :"aria-describedby", "aria-describedby"])
      |> Field.put_present(:"aria-describedby", described_by)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    {min_label, max_label, control_rest, max_control_rest} =
      if range do
        rest = Map.get(assigns, :rest, %{})
        labelled_by = Field.rest_attr(rest, :"aria-labelledby")
        labels = range_labels(Field.rest_attr(rest, :"aria-label"), labelled_by, assigns)

        control_rest =
          Map.drop(control_rest, [
            :"aria-label",
            "aria-label"
          ])

        max_control_rest = Map.drop(control_rest, [:autofocus, "autofocus"])

        {labels.min, labels.max, control_rest, max_control_rest}
      else
        {nil, nil, control_rest, control_rest}
      end

    assign(assigns,
      parts: parts,
      root_id: root_id,
      errors: errors,
      range: range,
      range_name: if(range, do: range_name(Map.get(assigns, :name)), else: nil),
      min_label: min_label,
      max_label: max_label,
      control_rest: control_rest,
      max_control_rest: max_control_rest,
      markers: marker_list(assigns),
      input_attrs: derived.input_attrs,
      single_value: derived.value,
      range_min: derived.min_value,
      range_max: derived.max_value,
      start_offset: fraction_string(derived.start),
      stop_offset: fraction_string(derived.stop),
      single_tooltip: derived.value && format_number(derived.value),
      min_tooltip: derived.min_value && format_number(derived.min_value),
      max_tooltip: derived.max_value && format_number(derived.max_value)
    )
  end

  defp range_labels(_aria_label, labelled_by, _assigns) when is_binary(labelled_by) do
    %{min: nil, max: nil}
  end

  defp range_labels(aria_label, _labelled_by, assigns) do
    prefix =
      cond do
        Field.present?(aria_label) -> to_string(aria_label)
        Field.present?(Map.get(assigns, :label)) -> Map.get(assigns, :label)
        true -> nil
      end

    case prefix do
      nil -> %{min: nil, max: nil}
      prefix -> %{min: prefix <> " minimum", max: prefix <> " maximum"}
    end
  end

  defp range_name(nil), do: nil
  defp range_name(""), do: nil

  defp range_name(name) do
    name = to_string(name)

    if String.ends_with?(name, "[]") do
      name
    else
      name <> "[]"
    end
  end

  defp marker_list(assigns) do
    if Map.get(assigns, :show_markers, false) do
      derived = resolve(assigns)

      Enum.map(derived.markers, fn value ->
        {value, fraction_string(fraction(value, derived.min, derived.max))}
      end)
    else
      []
    end
  end

  # Everything the markup and the geometry need, resolved once from assigns.
  # `build_attrs/1` runs before `render/1`, so both paths must derive the same
  # values, including the field value when one is bound.
  defp resolve(assigns) do
    min = number(Map.get(assigns, :min), 0)
    max = number(Map.get(assigns, :max), 100)
    step = step_number(Map.get(assigns, :step))
    range = Map.get(assigns, :range, false)
    root_id = root_id(assigns)

    {value, min_value, max_value} = thumbs(assigns, min, max, step, range)

    start = if range, do: fraction(min_value, min, max), else: 0.0
    stop = if range, do: fraction(max_value, min, max), else: fraction(value, min, max)

    %{
      id: root_id,
      min: min,
      max: max,
      step: step,
      range: range,
      value: value,
      min_value: min_value,
      max_value: max_value,
      start: start,
      stop: stop,
      input_attrs: %{
        "min" => format_number(min),
        "max" => format_number(max),
        "step" => format_number(step)
      },
      markers: marker_values(min, max, step)
    }
  end

  defp thumbs(assigns, min, max, _step, true) do
    {list_min, list_max} = value_pair(raw_value(assigns))

    min_value =
      min
      |> bound(Map.get(assigns, :min_value), list_min)
      |> clamp(min, max)

    max_value =
      max
      |> bound(Map.get(assigns, :max_value), list_max)
      |> clamp(min_value, max)

    {nil, min_value, max_value}
  end

  defp thumbs(assigns, min, max, step, false) do
    value =
      case raw_value(assigns) do
        nil ->
          snap(min + (max - min) / 2, min, step) |> clamp(min, max)

        value ->
          number(value, min) |> clamp(min, max)
      end

    {value, nil, nil}
  end

  defp bound(default, nil, nil), do: default
  defp bound(default, nil, list_value), do: number(list_value, default)
  defp bound(default, value, _list_value), do: number(value, default)

  defp value_pair([min, max]), do: {min, max}
  defp value_pair(%{} = map), do: {map_value(map, :min), map_value(map, :max)}
  defp value_pair(_value), do: {nil, nil}

  defp map_value(map, key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp raw_value(assigns) do
    case Map.get(assigns, :value) do
      nil ->
        case Map.get(assigns, :field) do
          %Phoenix.HTML.FormField{value: value} -> value
          _ -> nil
        end

      value ->
        value
    end
  end

  defp root_id(assigns) do
    case Map.get(assigns, :id) do
      id when is_binary(id) and id != "" ->
        id

      _ ->
        case Map.get(assigns, :field) do
          %Phoenix.HTML.FormField{id: id} when is_binary(id) and id != "" -> id
          _ -> API.use_id("fl-slider")
        end
    end
  end

  defp marker_values(min, max, step) do
    span = max - min

    if span <= 0 do
      [min]
    else
      count = floor(span / step + 1.0e-9)

      if count + 1 > @max_markers do
        []
      else
        Enum.map(0..count, fn index ->
          min
          |> Kernel.+(index * step)
          |> normalize_number()
          |> min(max)
        end)
      end
    end
  end

  defp fraction(_value, min, max) when max <= min, do: 0.0

  defp fraction(value, min, max) do
    clamped = clamp(value, min, max)
    (clamped - min) / (max - min)
  end

  defp fraction_string(value) do
    value
    |> Float.round(6)
    |> to_string()
  end

  defp clamp(_value, min, max) when max <= min, do: min
  defp clamp(value, min, max), do: value |> Kernel.max(min) |> Kernel.min(max)

  defp snap(value, min, step) do
    min
    |> Kernel.+(round((value - min) / step) * step)
    |> normalize_number()
  end

  defp step_number(value) do
    case number(value, 1) do
      step when step > 0 -> step
      _ -> 1
    end
  end

  defp number(nil, default), do: default
  defp number(value, _default) when is_integer(value), do: value

  defp number(value, _default) when is_float(value) do
    normalize_number(value)
  end

  defp number(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> normalize_number(number)
      _ -> default
    end
  end

  defp number(_value, default), do: default

  defp normalize_number(value) when is_float(value) do
    if value == trunc(value), do: trunc(value), else: value
  end

  defp normalize_number(value), do: value

  defp format_number(value) when is_integer(value), do: Integer.to_string(value)

  defp format_number(value) when is_float(value) do
    value = Float.round(value, 6)

    if value == trunc(value) do
      Integer.to_string(trunc(value))
    else
      Float.to_string(value)
    end
  end

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
