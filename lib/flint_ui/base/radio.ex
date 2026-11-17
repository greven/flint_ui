defmodule FlintUI.Base.Radio do
  @moduledoc """
  Renders a single radio with a label, an optional sublabel, a description, and errors.

  A radio is a native control for one choice among mutually exclusive options.
  Options that share a `name` form one group: checking one unchecks the others,
  and the group submits exactly one value while a choice is selected.

      <.radio
        name="plan"
        value="pro"
        label="Pro"
        sublabel="$19 per month"
        description="Unlimited projects and priority support."
        checked
      />

  A standalone radio can bind to a form field. The field supplies the current
  selection, and this radio checks itself when its `value` matches. The control
  id appends the option value to the field id, so radios that share a field keep
  distinct label and description ids:

      <.radio field={@form[:plan]} value="free" label="Free" />
      <.radio field={@form[:plan]} value="pro" label="Pro" />

  ## Selection

  `value` is the value this radio submits and the value it compares against the
  field's current selection. `checked` sets the state directly and wins over the
  comparison. Because a radio cannot be unchecked by clicking it, there is no
  hidden mirror: the server receives no parameter for the group while nothing is
  selected.

  ## Groups

  Use `<.radio_group>` to render a related set of radios from one form field,
  including the fieldset, legend, description, and errors. A bare `<.radio>` is
  one option, usually rendered by the group.

  ## Accessibility

  The label wraps the native input, so the association works even without an
  `id`; the generated `id` also sets `for`. `sublabel` is rendered inside the
  label and is announced with it. The description and errors sit outside the label and
  are linked with `aria-describedby`; an invalid field also carries
  `aria-invalid`.

  The native `<input type="radio">` carries the semantics, focus, and keyboard
  behavior. The styled theme paints a decorative indicator over it, so
  forced-colors mode and assistive technology still see a real radio. Always
  give the radio a label, or pass `aria-label`/`aria-labelledby` when the
  surrounding markup supplies one.

  ## Keyboard

  - `Tab` - moves focus into and out of a radio group.
  - `Space` - selects the focused radio.
  - `Arrow keys` - move focus within a group of radios that share a `name`, and
    select the newly focused radio.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :radio,
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
          value: "radio",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the radio root."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the radio is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the radio has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the radio is required."
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
            "The decorative circle around the native input. The theme paints the circle and dot; the native input stays focusable above it."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The indicator is decorative; the native radio carries the semantics."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description: "The native radio input."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("radio"),
          description: "The native radio type."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The control id, derived from the field when one is not passed."
        },
        %Meta.PartAttr{
          name: "name",
          value: "string",
          description: "The form parameter name shared by the group."
        },
        %Meta.PartAttr{
          name: "value",
          value: "string",
          description: "The value submitted while this radio is selected."
        },
        %Meta.PartAttr{
          name: "checked",
          value: "boolean",
          description: "Present while this radio is selected."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the radio has errors."
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
        description: "Moves focus into and out of a radio group."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Selects the focused radio."
      },
      %Meta.Keyboard{
        keys: "Arrow keys",
        description:
          "Move focus within a group of radios that share a name, and select the newly focused radio."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The radio is disabled.",
        selector: ~s([data-element="radio"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The radio has at least one error.",
        selector: ~s([data-element="radio"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The radio is required.",
        selector: ~s([data-element="radio"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "radio",
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
      control: %{
        "data-part" => "control"
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
  # inputs, on the radio root while the caller's global attributes stay on the
  # native control. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  # The styled wrapper and `radio_group` pass already-rendered custom label
  # content here so an empty default slot cannot override `label`.
  attr :label_content, :any, default: nil, doc: false

  attr :id, :any, default: nil, doc: "The control id. Derived from `field` when omitted."

  attr :name, :any,
    doc: "The form parameter name shared by the group. Derived from `field` when omitted."

  attr :label, :string, default: nil, doc: "The radio label."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Recommended`."

  attr :value, :any,
    required: true,
    doc:
      "The value this radio submits, and the value compared with the field's current selection."

  attr :checked, :boolean,
    doc: "The selected state. When set, it wins over the field's current selection."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:plan]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :description, :string,
    default: nil,
    doc: "Explanatory text shown below the radio and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the radio is disabled."

  attr :required, :boolean,
    default: false,
    doc: "Whether the radio is required."

  attr :class, :any, default: nil, doc: "Additional classes for the radio root."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc: "Additional HTML and LiveView attributes, rendered on the native radio."

  slot :inner_block,
    doc: "Custom label content. Takes precedence over `label`."

  @impl true
  def render(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(
      field: nil,
      id: assigns[:id] || option_id(field, assigns[:value]),
      errors: errors,
      current_value: field.value
    )
    |> assign_new(:name, fn -> field.name end)
    |> radio()
  end

  def render(assigns), do: radio(assigns)

  @doc false
  # Also renders a single option for `FlintUI.Base.RadioGroup`. The group
  # supplies the same public assigns and no `flint_parts`, so the shared markup
  # stays one implementation.
  def radio(assigns) do
    assigns = prepare(assigns)
    assigns = assign(assigns, :checked, checked?(assigns))

    parts = Map.get(assigns, :flint_parts) || build_attrs(assigns)
    assigns = assign(assigns, :flint_parts, parts)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs} class={@class}>
      <label {@flint_parts[:label]}>
        <span {@flint_parts[:indicator]}>
          <input
            type="radio"
            id={@id}
            name={@name}
            value={@value}
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

  # Options that share a field still need distinct ids so each label and
  # description targets its own radio.
  defp option_id(%{id: id}, value) when is_binary(id) and value not in [nil, ""] do
    "#{id}-#{value}"
  end

  defp option_id(%{id: id}, _value), do: id

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
      name: Map.get(assigns, :name),
      value: Map.get(assigns, :value),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      disabled: Map.get(assigns, :disabled, false),
      required: Map.get(assigns, :required, false),
      rest: Map.get(assigns, :rest, %{}),
      class: Map.get(assigns, :class),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      label_content: Map.get(assigns, :label_content),
      inner_block: Map.get(assigns, :inner_block, []),
      errors: errors,
      invalid: invalid?,
      description_id: description_id,
      control_rest: control_rest,
      current_value: Map.get(assigns, :current_value)
    )
  end

  defp checked?(assigns) do
    case Map.fetch(assigns, :checked) do
      {:ok, checked} when is_boolean(checked) -> checked
      _ -> selected?(Map.get(assigns, :current_value), Map.get(assigns, :value))
    end
  end

  defp selected?(nil, _value), do: false
  defp selected?(_selected, nil), do: false
  defp selected?(selected, value), do: Field.matches?(selected, value)

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
