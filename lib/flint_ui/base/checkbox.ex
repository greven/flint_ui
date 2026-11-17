defmodule FlintUI.Base.Checkbox do
  @moduledoc """
  Renders a single checkbox with a label, an optional sublabel, a hint, and
  errors.

  A checkbox is the native control for a boolean choice: opting in to terms,
  enabling a setting, or marking an item.

      <.checkbox
        name="notifications"
        label="Enable notifications"
        sublabel="Recommended"
        hint="We'll send you important updates about your account status and security."
      />

  Pass a `Phoenix.HTML.FormField` to bind the checkbox to a form. The component
  derives `id`, `name`, and the current value, and shows the field's errors only
  after it has been used (`Phoenix.Component.used_input?/1`):

      <.checkbox field={@form[:terms]} label="I accept the terms" />

  ## Wire values

  A checked checkbox submits `checked_value` and an unchecked one submits
  `unchecked_value`. The defaults are `"true"` and `"false"`, and the component
  renders a hidden input with the unchecked value so an unchecked box still
  submits a field. Set `unchecked_value={nil}` to omit the hidden mirror, such
  as inside a [checkbox group](/components/checkbox_group).

  `value` is the current value the checkbox compares with `checked_value`. Pass
  `checked` to set the state directly; it wins over `value`.

  ## Indeterminate

  `indeterminate` paints the mixed/dash appearance and sets
  `data-indeterminate="true"` on the native input. When `flint.js` is loaded, it
  mirrors that hook onto the native `indeterminate` DOM property, so assistive
  technology announces the mixed state. The server-rendered dash also works
  without JavaScript.

  Indeterminate is not a third form value: it does not change whether the
  checkbox submits `checked_value`. Leave `checked` false for a select-all
  parent whose children are partly selected. The native `:indeterminate` state
  set by your own JavaScript is styled the same way.

  ## Groups

  Use `<.checkbox_group>` for a list of options that share one form field. A
  bare `<.checkbox>` belongs to one boolean field.

  ## Accessibility

  The label wraps the native input, so the association works even without an
  `id`; the generated `id` also sets `for`. `sublabel` is rendered inside the
  label and is announced with it. The hint and errors sit outside the label and
  are linked with `aria-describedby`; an invalid field also carries
  `aria-invalid`.

  The native `<input type="checkbox">` carries the semantics, focus, and
  keyboard behavior. The styled theme paints a decorative indicator over it, so
  forced-colors mode and assistive technology still see a real checkbox. Always
  give the checkbox a label, or pass `aria-label`/`aria-labelledby` when the
  surrounding markup supplies one.

  ## Keyboard

  - `Tab` - moves focus into and out of the checkbox.
  - `Space` - toggles the checkbox.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :checkbox,
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
          value: "checkbox",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the checkbox root."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the checkbox is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the checkbox has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the checkbox is required."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description:
            "The clickable label. It wraps the indicator and the label text, and names the native control."
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
            "The decorative box around the native input. The theme paints the box and check mark; the native input stays focusable above it."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The indicator is decorative; the native checkbox carries the semantics."
        }
      ],
      check: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "check",
          description:
            "The inline SVG check mark shown while checked. The theme swaps it for a dash while the native input is indeterminate."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The check mark is decorative; the native checkbox carries the state."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description: "The native checkbox input."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("checkbox"),
          description: "The native checkbox type."
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
          description: "The value submitted while checked, taken from `checked_value`."
        },
        %Meta.PartAttr{
          name: "checked",
          value: "boolean",
          description: "Present while the checkbox is checked."
        },
        %Meta.PartAttr{
          name: "[data-indeterminate]",
          value: "true",
          description:
            "Present when `indeterminate` is set. Shows the mixed/dash appearance and is mirrored onto the native DOM property by `flint.js`; it does not change the checked state or the submitted value."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the checkbox has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description: "The hint and error message ids, appended to a caller-supplied value."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label-text",
          description: "The label and sublabel wrapper next to the indicator."
        }
      ],
      sublabel: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "sublabel",
          description: "A short qualifier shown beside the label, such as `Recommended`."
        }
      ],
      hint: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "hint",
          description: "Hint text shown below the control and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The hint id, derived from the control id."
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
        description: "Moves focus into and out of the checkbox."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles the checkbox."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The checkbox is disabled.",
        selector: ~s([data-element="checkbox"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The checkbox has at least one error.",
        selector: ~s([data-element="checkbox"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The checkbox must be checked.",
        selector: ~s([data-element="checkbox"][data-required])
      },
      %Meta.State{
        name: "indeterminate",
        description:
          "The checkbox shows the mixed/dash appearance. `flint.js` also sets the native DOM property; it does not change the submitted value.",
        selector: ~s([data-element="checkbox"] [data-part="control"][data-indeterminate])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "checkbox",
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
        "data-part" => "indicator",
        "aria-hidden" => "true"
      },
      check: %{
        "data-part" => "check",
        "aria-hidden" => "true"
      },
      control: %{
        "data-part" => "control",
        "data-indeterminate" => Map.get(assigns, :indeterminate, false) && "true"
      },
      label_text: %{
        "data-part" => "label-text"
      },
      sublabel: %{
        "data-part" => "sublabel"
      },
      hint: %{
        "data-part" => "hint"
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
  # inputs, on the checkbox root while the caller's global attributes stay on
  # the native control. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  # The styled wrapper and `checkbox_group` pass already-rendered custom label
  # content here so an empty default slot cannot override `label`.
  attr :label_content, :any, default: nil, doc: false

  attr :id, :any, default: nil, doc: "The control id. Derived from `field` when omitted."

  attr :name, :any, doc: "The form parameter name. Derived from `field` when omitted."

  attr :label, :string, default: nil, doc: "The checkbox label."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Recommended`."

  attr :value, :any,
    doc:
      "The current value, compared with `checked_value` to derive the checked state. Derived from `field` when omitted."

  attr :checked, :boolean,
    doc: "The checked state. When set, it wins over `value` and `checked_value`."

  attr :indeterminate, :boolean,
    default: false,
    doc:
      "Shows the mixed/dash appearance and sets `data-indeterminate=\"true\"` on the native input. `flint.js` mirrors that hook onto the native `indeterminate` DOM property for assistive technology; the dash still renders without JavaScript. It does not change the checked state or the submitted value."

  attr :checked_value, :any,
    default: "true",
    doc: "The value submitted while the checkbox is checked."

  attr :unchecked_value, :any,
    default: "false",
    doc:
      "The value submitted by the hidden mirror while the checkbox is unchecked. Set it to `nil` to omit the mirror."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:terms]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :hint, :string,
    default: nil,
    doc: "Hint text shown below the checkbox and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the checkbox is disabled."

  attr :required, :boolean,
    default: false,
    doc: "Whether the checkbox must be checked."

  attr :class, :any, default: nil, doc: "Additional classes for the checkbox root."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc: "Additional HTML and LiveView attributes, rendered on the native checkbox."

  slot :inner_block,
    doc: "Custom label content. Takes precedence over `label`."

  @impl true
  def render(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id, errors: errors)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> render()
  end

  def render(assigns), do: checkbox(assigns)

  @doc false
  # Also renders a single option for `FlintUI.Base.CheckboxGroup`. The group
  # supplies the same public assigns and no `flint_parts`, so the shared markup
  # stays one implementation.
  def checkbox(assigns) do
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
          <svg
            {@flint_parts[:check]}
            viewBox="0 0 24 24"
            width="16"
            height="16"
            fill="none"
            focusable="false"
          >
            <path
              data-mark="check"
              d="M5 12.6 10 17.2 19 6.8"
              stroke="currentColor"
              stroke-width="2.8"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
            <path
              data-mark="dash"
              d="M7 12h10"
              stroke="currentColor"
              stroke-width="2.8"
              stroke-linecap="round"
            />
          </svg>
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
      <p :if={@hint} id={@hint_id} {@flint_parts[:hint]}>{@hint}</p>
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
  # whitespace-only block falls back to `label`.
  defp content_or_label(content, label) when is_binary(content) do
    if String.trim(content) == "", do: label, else: content
  end

  defp content_or_label(nil, label), do: label
  defp content_or_label(content, _label), do: content

  defp prepare(assigns) do
    errors = Field.translate_errors(Map.get(assigns, :errors) || [])
    invalid? = errors != []
    id = Map.get(assigns, :id)
    hint_id = Field.hint_id(id, Map.get(assigns, :hint))
    error_ids = Field.error_ids(id, errors)

    described_by =
      Field.described_by(Map.get(assigns, :rest, %{}), [hint_id, error_ids])

    control_rest =
      Map.get(assigns, :rest, %{})
      |> Map.drop([:"aria-invalid", "aria-invalid", :"aria-describedby", "aria-describedby"])
      |> Field.put_present(:"aria-describedby", described_by)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    assign(assigns,
      name: Map.get(assigns, :name),
      value: Map.get(assigns, :value),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      indeterminate: Map.get(assigns, :indeterminate, false),
      checked_value: Map.get(assigns, :checked_value, "true"),
      unchecked_value: Map.get(assigns, :unchecked_value, "false"),
      disabled: Map.get(assigns, :disabled, false),
      required: Map.get(assigns, :required, false),
      rest: Map.get(assigns, :rest, %{}),
      class: Map.get(assigns, :class),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      label_content: Map.get(assigns, :label_content),
      inner_block: Map.get(assigns, :inner_block, []),
      errors: errors,
      invalid: invalid?,
      hint_id: hint_id,
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
