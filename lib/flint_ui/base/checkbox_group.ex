defmodule FlintUI.Base.CheckboxGroup do
  @moduledoc """
  Renders a group of checkboxes that collect multiple selections into one form
  field.

      <.checkbox_group
        field={f[:languages]}
        label="Programming languages"
        hint="Pick the languages you reach for first."
      >
        <:checkbox value="elixir" label="Elixir" />
        <:checkbox value="rust" label="Rust" />
        <:checkbox value="typescript" label="TypeScript" />
      </.checkbox_group>

  The group appends `[]` to `name`, so the server receives a list, and renders
  one hidden input with an empty value so the field is present even when
  nothing is selected. Filter the empty string in your handler:

      selected = Enum.reject(params["languages"] || [], &(&1 == ""))

  With a `Phoenix.HTML.FormField`, `id`, `name`, the selected values, and the
  errors are derived from the field. Errors only show once the field has been
  used (`Phoenix.Component.used_input?/1`). Group-level `disabled` disables the
  whole fieldset; an option can also be disabled on its own.

  Each `:checkbox` slot takes `value`, `label`, `sublabel`, `hint`,
  `disabled`, `checked`, and `class`, plus an optional inner block that replaces
  the default label content. An option is checked when its `value` is in the
  group's selected values, or when its own `checked` attribute is set.

  ## Accessibility

  The group renders a native `<fieldset>` with a `<legend>`, so assistive
  technology announces the group's name with every option. The hint and errors
  are linked to the group with `aria-describedby`, and `required` is
  exposed with `aria-required`.

  Each option keeps its own native checkbox semantics and accessible name. Give
  the group a `label`, or an `aria-label` through the global attributes when the
  surrounding markup already provides one.

  ## Keyboard

  - `Tab` - moves focus from option to option. A disabled group leaves the tab
    order.
  - `Space` - toggles the focused option.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :checkbox_group,
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
          value: "checkbox_group",
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
          description: "The wrapper that lays out the checkbox options."
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
        description: "Moves focus from option to option. A disabled group leaves the tab order."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles the focused option."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The whole group is disabled.",
        selector: ~s([data-element="checkbox_group"][data-disabled])
      },
      %Meta.State{
        name: "invalid",
        description: "The group has at least one error.",
        selector: ~s([data-element="checkbox_group"][data-invalid])
      },
      %Meta.State{
        name: "required",
        description: "The group requires at least one selection.",
        selector: ~s([data-element="checkbox_group"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "checkbox_group",
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
  # nested checkbox roots. These connectors are internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :item_attrs, :map, default: %{}, doc: false

  attr :id, :any, default: nil, doc: "The group id. Derived from `field` when omitted."

  attr :name, :any,
    doc:
      "The form parameter name. A `[]` suffix is added so the server receives a list. Derived from `field` when omitted."

  attr :label, :string, default: nil, doc: "The group label, rendered as a `legend`."

  attr :value, :any,
    doc: "The selected values. Derived from `field` when omitted; a selected option is checked."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:languages]`."

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
    doc: "Whether at least one option must be selected."

  attr :class, :any, default: nil, doc: "Additional classes for the group root."

  attr :rest, :global,
    include: ~w(form),
    doc:
      "Additional HTML and LiveView attributes, rendered on the group root. A `form` attribute is forwarded to the options."

  slot :checkbox,
    required: true,
    doc:
      "One option in the group. The inner block, when present, replaces the default label content." do
    attr :value, :any,
      required: true,
      doc: "The value submitted while this option is checked."

    attr :label, :string, doc: "The option label."

    attr :sublabel, :string,
      doc: "A short qualifier shown beside the option label, such as `Recommended`."

    attr :hint, :string, doc: "Hint text shown below the option."

    attr :disabled, :boolean, doc: "Whether this option alone is disabled."

    attr :checked, :boolean,
      doc:
        "Forces this option's checked state. When omitted, membership in the group's `value` list decides."

    attr :class, :any, doc: "Additional classes for this option's native checkbox."
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

      <input
        :if={@group_name}
        type="hidden"
        name={@group_name}
        value=""
        disabled={@disabled}
        form={@form}
      />

      <div {@flint_parts[:options]}>
        <FlintUI.Base.Checkbox.checkbox
          :for={{item, index} <- Enum.with_index(@checkbox)}
          id={option_id(@id, index)}
          name={@group_name}
          checked_value={Map.get(item, :value)}
          unchecked_value={nil}
          checked={option_checked?(item, @values)}
          label={Map.get(item, :label)}
          sublabel={Map.get(item, :sublabel)}
          hint={Map.get(item, :hint)}
          disabled={Map.get(item, :disabled, false)}
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
      group_name: group_name(Map.get(assigns, :name)),
      values: List.wrap(Map.get(assigns, :value)),
      form: form,
      item_rest: item_rest,
      root_rest: root_rest
    )
  end

  defp group_name(nil), do: nil

  defp group_name(name) do
    name = to_string(name)

    if String.ends_with?(name, "[]"), do: name, else: name <> "[]"
  end

  defp option_id(id, index) when is_binary(id), do: "#{id}-#{index}"
  defp option_id(_id, _index), do: nil

  defp option_checked?(item, values) do
    case Map.get(item, :checked) do
      checked when is_boolean(checked) -> checked
      _ -> Field.matches?(values, Map.get(item, :value))
    end
  end

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
