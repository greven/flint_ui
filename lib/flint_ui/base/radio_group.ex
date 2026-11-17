defmodule FlintUI.Base.RadioGroup do
  @moduledoc """
  Renders a group of radios that collect one choice into one form field.

      <.radio_group
        field={f[:plan]}
        label="Plan"
        hint="Choose the plan that fits your team."
      >
        <:radio value="free" label="Free" sublabel="$0" />
        <:radio value="pro" label="Pro" sublabel="$19 per month" />
        <:radio value="team" label="Team" sublabel="$49 per month" />
      </.radio_group>

  Every option shares the group's `name`, so the browser treats them as one
  radio group: selecting one clears the others and the group submits a single
  value under that name. There is no hidden empty input; while no option is
  selected, the server receives no parameter for the field.

  With a `Phoenix.HTML.FormField`, `id`, `name`, the selected value, and the
  errors are derived from the field. Errors only show once the field has been
  used (`Phoenix.Component.used_input?/1`). Group-level `disabled` disables the
  whole fieldset; an option can also be disabled on its own.

  Each `:radio` slot takes `value`, `label`, `sublabel`, `hint`,
  `disabled`, `checked`, and `class`, plus an optional inner block that replaces
  the default label content. An option is selected when its `value` matches the
  group's `value`, or when its own `checked` attribute is set.

  ## Accessibility

  The group renders a native `<fieldset>` with a `<legend>`, so assistive
  technology announces the group's name with every option. The hint and errors
  are linked to the group with `aria-describedby`, and `required` is
  exposed with `aria-required` and on the native radios.

  Each option keeps its own native radio semantics and accessible name. Give
  the group a `label`, or an `aria-label` through the global attributes when the
  surrounding markup already provides one.

  ## Keyboard

  - `Tab` - moves focus into and out of the group.
  - `Space` - selects the focused option.
  - `Arrow keys` - move focus and selection between the options in the group.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :radio_group,
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
          value: "radio_group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the group root, rendered as a native `fieldset`."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the whole group is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the group has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the group is required."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description: "The group label, rendered as a native `legend`."
        }
      ],
      options: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "options",
          description: "The wrapper that lays out the radio options."
        }
      ],
      hint: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "hint",
          description: "Hint text shown below the label and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The hint id, derived from the group id."
        }
      ],
      error: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "error",
          description:
            "One group error message. Each message carries its own id and is exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The error id, derived from the group id and the message index."
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
        description: "Moves focus into and out of the group."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Selects the focused option."
      },
      %Meta.Keyboard{
        keys: "Arrow keys",
        description: "Move focus and selection between the options in the group."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The whole group is disabled.",
        selector: ~s([data-element="radio_group"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The group has at least one error.",
        selector: ~s([data-element="radio_group"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The group requires a selection.",
        selector: ~s([data-element="radio_group"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "radio_group",
        "data-part" => "root",
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => errors != [],
        "data-required" => Map.get(assigns, :required, false)
      },
      label: %{"data-part" => "label"},
      options: %{"data-part" => "options"},
      hint: %{"data-part" => "hint"},
      error: %{"data-part" => "error"},
      error_icon: %{"data-part" => "error_icon", "aria-hidden" => "true"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the group root and the
  # nested radio roots. These connectors are internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :item_attrs, :map, default: %{}, doc: false

  attr :id, :any, default: nil, doc: "The group id. Derived from `field` when omitted."

  attr :name, :any,
    doc:
      "The form parameter name. Every option shares it and the group submits one value. Derived from `field` when omitted."

  attr :label, :string, default: nil, doc: "The group label, rendered as a `legend`."

  attr :value, :any,
    doc: "The selected value. Derived from `field` when omitted; the matching option is checked."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:plan]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :hint, :string,
    default: nil,
    doc: "Hint text shown below the group label and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the whole group is disabled."

  attr :required, :boolean,
    default: false,
    doc: "Whether one option must be selected."

  attr :class, :any, default: nil, doc: "Additional classes for the group root."

  attr :rest, :global,
    include: ~w(form),
    doc:
      "Additional HTML and LiveView attributes, rendered on the group root. A `form` attribute is forwarded to the options."

  slot :radio,
    required: true,
    doc:
      "One option in the group. The inner block, when present, replaces the default label content." do
    attr :value, :any,
      required: true,
      doc: "The value submitted while this option is selected."

    attr :label, :string, doc: "The option label."

    attr :sublabel, :string,
      doc: "A short qualifier shown beside the option label, such as `Recommended`."

    attr :hint, :string, doc: "Hint text shown below the option."

    attr :disabled, :boolean, doc: "Whether this option alone is disabled."

    attr :checked, :boolean,
      doc:
        "Forces this option's selected state. When omitted, a match with the group's `value` decides."

    attr :class, :any, doc: "Additional classes for this option's native radio."
  end

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
    <fieldset
      {@flint_parts[:root]}
      {@root_attrs}
      disabled={@disabled}
      aria-required={@required && "true"}
      aria-invalid={@invalid && "true"}
      aria-describedby={@described_by}
      class={@class}
      {@root_rest}
    >
      <legend :if={@label} {@flint_parts[:label]}>{@label}</legend>

      <p :if={@hint} id={@hint_id} {@flint_parts[:hint]}>{@hint}</p>

      <div {@flint_parts[:options]}>
        <FlintUI.Base.Radio.radio
          :for={{item, index} <- Enum.with_index(@radio)}
          id={option_id(@id, index)}
          name={@group_name}
          value={Map.get(item, :value)}
          checked={option_checked?(item, @selected_value)}
          label={Map.get(item, :label)}
          sublabel={Map.get(item, :sublabel)}
          hint={Map.get(item, :hint)}
          disabled={Map.get(item, :disabled, false)}
          required={@required}
          class={Map.get(item, :class)}
          label_content={Map.get(item, :inner_block) && render_slot(item)}
          root_attrs={@item_attrs}
          rest={@item_rest}
        />
      </div>

      <p
        :for={{message, index} <- Enum.with_index(@errors, 1)}
        id={Field.error_id(@id, index)}
        {@flint_parts[:error]}
      >
        <Field.error_icon attrs={@flint_parts[:error_icon]} />
        {message}
      </p>
    </fieldset>
    """
  end

  defp prepare(assigns) do
    errors = Field.translate_errors(Map.get(assigns, :errors) || [])
    invalid? = errors != []
    id = Map.get(assigns, :id)
    hint_id = Field.hint_id(id, Map.get(assigns, :hint))
    rest = Map.get(assigns, :rest, %{})

    described_by =
      Field.described_by(rest, [hint_id, Field.error_ids(id, errors)])

    root_rest =
      rest
      |> Map.drop([
        :form,
        "form",
        :"aria-invalid",
        "aria-invalid",
        :"aria-describedby",
        "aria-describedby",
        :"aria-required",
        "aria-required"
      ])

    form = Field.rest_attr(rest, :form)
    item_rest = if Field.present?(form), do: %{form: form}, else: %{}

    assign(assigns,
      name: Map.get(assigns, :name),
      value: Map.get(assigns, :value),
      label: Map.get(assigns, :label),
      hint: Map.get(assigns, :hint),
      disabled: Map.get(assigns, :disabled, false),
      required: Map.get(assigns, :required, false),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      item_attrs: Map.get(assigns, :item_attrs, %{}),
      errors: errors,
      invalid: invalid?,
      hint_id: hint_id,
      described_by: if(described_by == "", do: nil, else: described_by),
      group_name: Map.get(assigns, :name),
      selected_value: selected_value(Map.get(assigns, :value)),
      item_rest: item_rest,
      root_rest: root_rest
    )
  end

  defp selected_value(values) when is_list(values), do: List.first(values)
  defp selected_value(value), do: value

  defp option_id(id, index) when is_binary(id), do: "#{id}-#{index}"
  defp option_id(_id, _index), do: nil

  defp option_checked?(item, selected_value) do
    case Map.get(item, :checked) do
      checked when is_boolean(checked) ->
        checked

      _ ->
        selected_value not in [nil, ""] and
          Field.matches?(selected_value, Map.get(item, :value))
    end
  end

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
