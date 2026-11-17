defmodule FlintUI.Base.SwitchGroup do
  @moduledoc """
  Renders a group of independent switches under one legend.

  Use it to group related settings, such as notification channels. Each switch
  keeps its own form field, name, and checked state, so bind one field per
  option:

      <.switch_group label="Notifications" description="Choose how we reach you.">
        <:switch
          field={f[:email_alerts]}
          label="Email"
          description="Account updates."
        />
        <:switch field={f[:sms_alerts]} label="SMS" description="Urgent alerts only." />
      </.switch_group>

  The group does not submit a value itself. An option takes a `field`, or an
  explicit `name` with `value`/`checked`, plus `label`, `sublabel`,
  `description`, `disabled`, and `class`. A field supplies the switch id, name,
  and current value.

  For one field that collects several values into a list, use a
  [checkbox group](/components/checkbox_group); switches are independent on/off
  settings, not a multi-select.

  ## Accessibility

  The group renders a native `<fieldset>` with a `<legend>`, so assistive
  technology announces the group name with every switch. The group description
  and errors are linked with `aria-describedby`, and `required` is exposed with
  `aria-required`. Each switch keeps its own label, state, and keyboard
  behavior. A disabled group disables every option natively and through each
  switch's own disabled state.

  ## Keyboard

  - `Tab` - moves focus from switch to switch. A disabled group leaves the tab
    order.
  - `Space` - toggles the focused switch.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :switch_group,
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
          value: "switch_group",
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
          description: "The wrapper that lays out the switch options."
        }
      ],
      description: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "description",
          description:
            "Explanatory text shown below the label and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from the group id."
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
        description: "Moves focus from switch to switch. A disabled group leaves the tab order."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles the focused switch."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The whole group is disabled.",
        selector: ~s([data-element="switch_group"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The group has at least one error.",
        selector: ~s([data-element="switch_group"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The group is required.",
        selector: ~s([data-element="switch_group"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "switch_group",
        "data-part" => "root",
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => errors != [],
        "data-required" => Map.get(assigns, :required, false)
      },
      label: %{"data-part" => "label"},
      options: %{"data-part" => "options"},
      description: %{"data-part" => "description"},
      error: %{"data-part" => "error"},
      error_icon: %{"data-part" => "error_icon", "aria-hidden" => "true"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the group root and the
  # nested switch roots. These connectors are internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :item_attrs, :map, default: %{}, doc: false

  attr :id, :any, default: nil, doc: "The group id. Derives the description and error ids."

  attr :label, :string, default: nil, doc: "The group label, rendered as a `legend`."

  attr :description, :string,
    default: nil,
    doc: "Explanatory text shown below the group label and linked with `aria-describedby`."

  attr :errors, :list,
    default: [],
    doc: "Group error messages, as translated strings or raw `{message, options}` tuples."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the whole group is disabled."

  attr :required, :boolean,
    default: false,
    doc:
      "Whether the group is required. Exposed as `aria-required`; validate the rule on the server."

  attr :class, :any, default: nil, doc: "Additional classes for the group root."

  attr :rest, :global,
    include: ~w(form),
    doc:
      "Additional HTML and LiveView attributes, rendered on the group root. A `form` attribute is forwarded to the options."

  slot :switch,
    required: true,
    doc:
      "One switch in the group. The inner block, when present, replaces the default label content." do
    attr :field, :any,
      doc: "A `Phoenix.HTML.FormField` for this switch. Supplies its id, name, and current value."

    attr :name, :any, doc: "The form parameter name, used when `field` is not given."

    attr :id, :any,
      doc: "The switch id. Derived from `field`, or from the group id and option index."

    attr :value, :any,
      doc:
        "The current value, compared with the switch's checked value. Derived from `field` when omitted."

    attr :checked, :boolean, doc: "The checked state. When set, it wins over `value`."

    attr :label, :string, doc: "The switch label."

    attr :sublabel, :string,
      doc: "A short qualifier shown beside the label, such as `Recommended`."

    attr :description, :string, doc: "Explanatory text shown below the switch."

    attr :disabled, :boolean, doc: "Whether this switch alone is disabled."

    attr :class, :any, doc: "Additional classes for this switch root."
  end

  @impl true
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

      <p :if={@description} id={@description_id} {@flint_parts[:description]}>{@description}</p>

      <div {@flint_parts[:options]}>
        <FlintUI.Base.Switch.switch
          :for={{item, index} <- Enum.with_index(@switch)}
          {option_assigns(
            item,
            index,
            assigns,
            Map.get(item, :inner_block) && render_slot(item)
          )}
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
    description_id = Field.description_id(id, Map.get(assigns, :description))
    rest = Map.get(assigns, :rest, %{})

    described_by =
      Field.described_by(rest, [description_id, Field.error_ids(id, errors)])

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
      id: id,
      label: Map.get(assigns, :label),
      description: Map.get(assigns, :description),
      disabled: Map.get(assigns, :disabled, false),
      required: Map.get(assigns, :required, false),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      item_attrs: Map.get(assigns, :item_attrs, %{}),
      switch: Map.get(assigns, :switch, []),
      errors: errors,
      invalid: invalid?,
      description_id: description_id,
      described_by: if(described_by == "", do: nil, else: described_by),
      item_rest: item_rest,
      root_rest: root_rest
    )
  end

  @option_attrs [:field, :name, :id, :value, :checked, :label, :sublabel, :description, :class]

  # Each option is its own field, so only the given attributes are forwarded:
  # an explicit `nil` would override the switch's field-derived id, name, and
  # value.
  defp option_assigns(item, index, group, label_content) do
    attrs =
      item
      |> Map.take(@option_attrs)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()

    attrs =
      case option_id(item, group.id, index) do
        nil -> attrs
        id -> Map.put(attrs, :id, id)
      end

    attrs
    |> Map.put(:disabled, group.disabled || Map.get(item, :disabled, false))
    |> Map.put(:root_attrs, group.item_attrs)
    |> Map.put(:rest, group.item_rest)
    |> put_label_content(label_content)
  end

  defp put_label_content(attrs, label_content) do
    if label_content do
      Map.put(attrs, :label_content, label_content)
    else
      attrs
    end
  end

  # A field supplies its own id; otherwise a name-only option gets a stable id
  # from the group, so its description can be linked.
  defp option_id(item, group_id, index) do
    cond do
      Field.present?(Map.get(item, :id)) -> Map.get(item, :id)
      match?(%Phoenix.HTML.FormField{}, Map.get(item, :field)) -> nil
      true -> option_index_id(group_id, index)
    end
  end

  defp option_index_id(id, index) when is_binary(id), do: "#{id}-#{index}"
  defp option_index_id(_id, _index), do: nil

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
