defmodule FlintUI.Base.Switch do
  @moduledoc """
  Renders a switch with a label, an optional sublabel, a description, and errors.

  A switch is a binary control for turning a setting on or off, such as
  notifications, two-factor authentication, or a feature flag. It uses the
  native `<input type="checkbox">` with `role="switch"`, so assistive
  technology announces an on/off switch instead of a checkbox.

      <.switch
        name="notifications"
        label="Enable notifications"
        sublabel="Recommended"
        description="We'll send you important updates about your account status and security."
      />

  Pass a `Phoenix.HTML.FormField` to bind the switch to a form. The component
  derives `id`, `name`, and the current value, and shows the field's errors only
  after it has been used (`Phoenix.Component.used_input?/1`):

      <.switch field={@form[:notifications]} label="Enable notifications" />

  ## Wire values

  A checked switch submits its `checked_value` and an unchecked one submits
  `unchecked_value`. The defaults are `"true"` and `"false"`, and the component
  renders a hidden input with the unchecked value so an unchecked switch still
  submits a field. Set `unchecked_value={nil}` to omit the hidden mirror.

  `value` is the current value the switch compares with `checked_value`. Pass
  `checked` to set the state directly; it wins over `value`.

  ## State labels

  The `:on` and `:off` slots render short decorative text inside the track,
  opposite the thumb. Both render in the DOM; the theme hides the one that does
  not match the checked state, so a headless consumer hides it from
  `:checked` themselves:

      <.switch name="wifi" label="Wi-Fi">
        <:on>ON</:on>
        <:off>OFF</:off>
      </.switch>

  Keep the labels short and leave the accessible name to `label`. They are
  `aria-hidden`, because `role="switch"` already announces the on/off state.

  ## Accessibility

  The label wraps the native input, so the association works even without an
  `id`; the generated `id` also sets `for`. `sublabel` is rendered inside the
  label and is announced with it. The description and errors sit outside the label and
  are linked with `aria-describedby`; an invalid field also carries
  `aria-invalid`.

  The native input carries the semantics, focus, and keyboard behavior.
  `role="switch"` maps the native checked state to the switch's on/off state,
  so do not set `aria-checked` yourself. The styled theme paints a decorative
  track and thumb around the input; the thumb is hidden from assistive
  technology, and the input stays available to forced-colors mode and
  assistive technology. Always give the switch a label, or pass
  `aria-label`/`aria-labelledby` when the surrounding markup supplies one.

  Prefer a switch for a setting that applies immediately, and a
  [checkbox](/components/checkbox) for consent or for selecting items from a
  set. A switch is not a group control; use a checkbox group when one field
  collects several choices.

  ## Keyboard

  - `Tab` - moves focus into and out of the switch.
  - `Space` - toggles the switch.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :switch,
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
          value: "switch",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the switch root."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the switch is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the switch has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the switch is required."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description:
            "The clickable label. It wraps the track and the label text, and names the native control."
        },
        %Meta.PartAttr{
          name: "for",
          value: "string",
          description: "The control id, when one is present."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description:
            "The decorative track around the native input. The theme paints the track and moves the thumb; the native input stays focusable above it."
        }
      ],
      thumb: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "thumb",
          description:
            "The decorative thumb inside the track. The theme moves and recolors it as the native input is checked."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The thumb is decorative; the native switch carries the state."
        }
      ],
      on_state: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "on-state",
          description:
            "The decorative `:on` label inside the track, shown beside the thumb while the switch is on."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description:
            "The label is decorative; `role=\"switch\"` already announces the on/off state."
        }
      ],
      off_state: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "off-state",
          description:
            "The decorative `:off` label inside the track, shown beside the thumb while the switch is off."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description:
            "The label is decorative; `role=\"switch\"` already announces the on/off state."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description: "The native switch input."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("checkbox"),
          description: "The native checkbox type."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("switch"),
          description:
            "Exposes the native checked state as a switch's on/off state instead of a checkbox."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The control id, derived from the field when one is not passed."
        },
        %Meta.PartAttr{
          name: "name",
          value: "string",
          description: "The form parameter name."
        },
        %Meta.PartAttr{
          name: "value",
          value: "string",
          description: "The value submitted while the switch is on, taken from `checked_value`."
        },
        %Meta.PartAttr{
          name: "checked",
          value: "boolean",
          description: "Present while the switch is on."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the switch has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "The description and error message ids, appended to a caller-supplied value."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label-text",
          description: "The label and sublabel wrapper next to the track."
        }
      ],
      sublabel: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "sublabel",
          description: "A short qualifier shown beside the label, such as `Recommended`."
        }
      ],
      description: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "description",
          description:
            "Explanatory text shown below the control and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from the control id."
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
          description: "The error id, derived from the control id and the message index."
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
        description: "Moves focus into and out of the switch."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles the switch."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The switch is disabled.",
        selector: ~s([data-element="switch"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The switch has at least one error.",
        selector: ~s([data-element="switch"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The switch is required.",
        selector: ~s([data-element="switch"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "switch",
        "data-part" => "root",
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => errors != [],
        "data-required" => Map.get(assigns, :required, false)
      },
      label: %{
        "data-part" => "label",
        "for" => Map.get(assigns, :id)
      },
      indicator: %{
        "data-part" => "indicator"
      },
      thumb: %{
        "data-part" => "thumb",
        "aria-hidden" => "true"
      },
      on_state: %{
        "data-part" => "on-state",
        "aria-hidden" => "true"
      },
      off_state: %{
        "data-part" => "off-state",
        "aria-hidden" => "true"
      },
      control: %{
        "data-part" => "control",
        "role" => "switch"
      },
      label_text: %{
        "data-part" => "label-text"
      },
      sublabel: %{
        "data-part" => "sublabel"
      },
      description: %{
        "data-part" => "description"
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

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks, and the raw color's inline
  # inputs, on the switch root while the caller's global attributes stay on the
  # native control. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  # The styled wrapper passes already-rendered custom label content here so an
  # empty default slot cannot override `label`.
  attr :label_content, :any, default: nil, doc: false

  attr :id, :any, default: nil, doc: "The control id. Derived from `field` when omitted."

  attr :name, :any, doc: "The form parameter name. Derived from `field` when omitted."

  attr :label, :string, default: nil, doc: "The switch label."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Recommended`."

  attr :value, :any,
    doc:
      "The current value, compared with `checked_value` to derive the on state. Derived from `field` when omitted."

  attr :checked, :boolean,
    doc: "The on state. When set, it wins over `value` and `checked_value`."

  attr :checked_value, :any,
    default: "true",
    doc: "The value submitted while the switch is on."

  attr :unchecked_value, :any,
    default: "false",
    doc:
      "The value submitted by the hidden mirror while the switch is off. Set it to `nil` to omit the mirror."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:notifications]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :description, :string,
    default: nil,
    doc: "Explanatory text shown below the switch and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the switch is disabled."

  attr :required, :boolean,
    default: false,
    doc: "Whether the switch must be on."

  attr :class, :any, default: nil, doc: "Additional classes for the switch root."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc: "Additional HTML and LiveView attributes, rendered on the native control."

  slot :inner_block,
    doc: "Custom label content. Takes precedence over `label`."

  slot :on,
    doc:
      "Decorative text inside the track shown while the switch is on, opposite the thumb. Hidden from assistive technology; the switch already announces its state."

  slot :off,
    doc:
      "Decorative text inside the track shown while the switch is off, opposite the thumb. Hidden from assistive technology; the switch already announces its state."

  @impl true
  def render(assigns), do: switch(assigns)

  @doc false
  # Also renders a single option for `FlintUI.Base.SwitchGroup`. The group
  # supplies the same public assigns and no `flint_parts`, so the shared markup
  # stays one implementation.
  def switch(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id, errors: errors)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> switch()
  end

  def switch(assigns) do
    assigns = prepare(assigns)
    assigns = assign(assigns, :checked, checked?(assigns))

    parts = Map.get(assigns, :flint_parts) || build_attrs(assigns)
    assigns = assign(assigns, :flint_parts, parts)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs} class={@class}>
      <input
        :if={hidden_input?(@name, @unchecked_value)}
        type="hidden"
        name={@name}
        value={@unchecked_value}
        disabled={@disabled}
        form={Field.rest_attr(@rest, :form)}
      />
      <label {@flint_parts[:label]}>
        <span {@flint_parts[:indicator]}>
          <span {@flint_parts[:thumb]}></span>
          <span :if={@on != []} {@flint_parts[:on_state]}>{render_slot(@on)}</span>
          <span :if={@off != []} {@flint_parts[:off_state]}>{render_slot(@off)}</span>
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value={@checked_value}
            checked={@checked}
            disabled={@disabled}
            required={@required}
            {@control_rest}
            {@flint_parts[:control]}
          />
        </span>
        <span {@flint_parts[:label_text]}>
          {@label_content || content_or_label(render_slot(@inner_block), @label)}
          <span :if={@sublabel} {@flint_parts[:sublabel]}>{@sublabel}</span>
        </span>
      </label>
      <p :if={@description} id={@description_id} {@flint_parts[:description]}>{@description}</p>
      <p
        :for={{message, index} <- Enum.with_index(@errors, 1)}
        id={Field.error_id(@id, index)}
        {@flint_parts[:error]}
      >
        <Field.error_icon attrs={@flint_parts[:error_icon]} />
        {message}
      </p>
    </div>
    """
  end

  defp hidden_input?(name, unchecked_value) do
    Field.present?(name) and not is_nil(unchecked_value)
  end

  # Custom label content wins only when it renders something. An empty or
  # whitespace-only block falls back to `label`; a call that only passes named
  # slots still sends the whitespace around them as the default block.
  defp content_or_label(content, label) do
    if blank?(content), do: label, else: content
  end

  defp blank?(nil), do: true
  defp blank?(content) when is_binary(content), do: String.trim(content) == ""

  defp blank?(content) do
    content
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.trim() == ""
  end

  defp prepare(assigns) do
    errors = Field.translate_errors(Map.get(assigns, :errors) || [])
    invalid? = errors != []
    id = Map.get(assigns, :id)
    description_id = Field.description_id(id, Map.get(assigns, :description))
    error_ids = Field.error_ids(id, errors)

    described_by =
      Field.described_by(Map.get(assigns, :rest, %{}), [description_id, error_ids])

    control_rest =
      Map.get(assigns, :rest, %{})
      |> Map.drop([:"aria-invalid", "aria-invalid", :"aria-describedby", "aria-describedby"])
      |> Field.put_present(:"aria-describedby", described_by)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    assign(assigns,
      id: id,
      name: Map.get(assigns, :name),
      value: Map.get(assigns, :value),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      description: Map.get(assigns, :description),
      checked_value: Map.get(assigns, :checked_value, "true"),
      unchecked_value: Map.get(assigns, :unchecked_value, "false"),
      disabled: Map.get(assigns, :disabled, false),
      required: Map.get(assigns, :required, false),
      rest: Map.get(assigns, :rest, %{}),
      class: Map.get(assigns, :class),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      label_content: Map.get(assigns, :label_content),
      inner_block: Map.get(assigns, :inner_block, []),
      on: Map.get(assigns, :on, []),
      off: Map.get(assigns, :off, []),
      errors: errors,
      invalid: invalid?,
      description_id: description_id,
      control_rest: control_rest
    )
  end

  defp checked?(assigns) do
    case Map.fetch(assigns, :checked) do
      {:ok, checked} when is_boolean(checked) -> checked
      _ -> Field.matches?(Map.get(assigns, :value), Map.get(assigns, :checked_value, "true"))
    end
  end

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
