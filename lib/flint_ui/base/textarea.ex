defmodule FlintUI.Base.Textarea do
  @moduledoc """
  Renders a native textarea with a label, an optional sublabel, a description,
  an optional hint, and errors.

  A textarea collects multi-line free text, such as a bio, a note, or a message.
  It stays a native `<textarea>`, so the browser keeps line breaks, the resize
  handle, and the keyboard behavior.

      <.textarea
        id="bio"
        name="bio"
        label="Bio"
        sublabel="Optional"
        description="A short introduction for your profile."
        rows="4"
        value="I write accessible interfaces."
      />

  Native attributes such as `rows`, `placeholder`, `maxlength`, and `wrap` pass
  through `rest` to the control. The styled layer adds the `size`, `radius`,
  `resize`, and `autogrow` props.

  Pass a `Phoenix.HTML.FormField` to bind the textarea to a form. The component
  derives `id`, `name`, and the current value, and shows the field's errors only
  after it has been used (`Phoenix.Component.used_input?/1`):

      <.textarea field={@form[:bio]} label="Bio" rows="6" />

  This is the standalone field that shares the label, sublabel, description, and
  error contract of `checkbox`, `radio`, and `switch`. `<.input type="textarea">`
  stays available for `CoreComponents` parity, including the prefix and suffix
  slots.

  ## Description, hint, and errors

  `description` renders explanatory text between the label and the control.
  `hint` renders supporting text below the control, after it. Both are linked
  from the control with `aria-describedby`, and errors do the same with one
  paragraph per message. An invalid field also carries `aria-invalid="true"`; a
  caller-supplied `aria-describedby` is preserved and the generated ids are
  appended.

  ## Accessibility

  The label points at the control with `for`, so pass an `id` or bind a `field`
  (which supplies one). `name` is only the form parameter: it does not create an
  id or a label association, matching the `CoreComponents` input contract.
  `sublabel` sits inside the label and is announced with it. The description,
  hint, and errors sit outside the label, so they do not join the control's
  accessible name.

  The native `<textarea>` carries the semantics, focus, and keyboard behavior.
  A disabled or read-only control keeps the native attribute, so assistive
  technology announces the state. Always give the control a name with `label`,
  or pass `aria-label`/`aria-labelledby` through `rest`.

  ## Keyboard

  - `Tab` - moves focus into and out of the textarea.
  - `Enter` - inserts a newline; it does not submit the form.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :textarea,
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
          value: "textarea",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the field root."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the textarea is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the field has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-readonly]",
          value: "boolean",
          description: "Present when the textarea is read-only."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the textarea is required."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description:
            "The label and control wrapper. It names the native textarea and holds the control box."
        },
        %Meta.PartAttr{
          name: "for",
          value: "string",
          description: "The control id, when one is present."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label_text",
          description: "The label text and sublabel row above the control."
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
            "Explanatory text shown between the label and the control and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from the control id."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description:
            "The native `textarea`, which carries the field's HTML and LiveView attributes."
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
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the field has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "The description, hint, and error message ids, appended to a caller-supplied value."
        }
      ],
      hint: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "hint",
          description:
            "Supporting text shown below the control and exposed through `aria-describedby`."
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
      %Meta.Keyboard{keys: "Tab", description: "Moves focus into and out of the textarea."},
      %Meta.Keyboard{
        keys: "Enter",
        description: "Inserts a newline; it does not submit the form."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "invalid",
        description: "The field has at least one error.",
        selector: ~s([data-element="textarea"][data-invalid])
      },
      %Meta.State{
        name: "disabled",
        description: "The textarea is disabled.",
        selector: ~s([data-element="textarea"][data-disabled])
      },
      %Meta.State{
        name: "readonly",
        description: "The textarea is read-only.",
        selector: ~s([data-element="textarea"][data-readonly])
      },
      %Meta.State{
        name: "required",
        description: "The textarea is required.",
        selector: ~s([data-element="textarea"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    errors = field_errors(assigns)

    %{
      root: %{
        "data-element" => "textarea",
        "data-part" => "root",
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => errors != [],
        "data-readonly" => Map.get(assigns, :readonly, false),
        "data-required" => Map.get(assigns, :required, false)
      },
      label: %{
        "data-part" => "label",
        "for" => derived_id(assigns)
      },
      label_text: %{
        "data-part" => "label_text"
      },
      sublabel: %{
        "data-part" => "sublabel"
      },
      control: %{
        "data-part" => "control"
      },
      hint: %{
        "data-part" => "hint"
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

  # The public attrs are also the docs API, so keep `doc: false` on internal
  # connectors only.
  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the field root while the
  # caller's global attributes stay on the native control. This connector is
  # internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :id, :any,
    default: nil,
    doc: "The control id. Derived from `field` when omitted."

  attr :name, :any,
    doc: "The form parameter name. It does not create an id; pass `id` for a label association."

  attr :label, :string, default: nil, doc: "The field label."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Optional`."

  attr :value, :any, doc: "The control value. Derived from `field` when omitted."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:bio]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :description, :string,
    default: nil,
    doc:
      "Explanatory text shown between the label and the control and linked with `aria-describedby`."

  attr :hint, :string,
    default: nil,
    doc: "Supporting text shown below the control and linked with `aria-describedby`."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the textarea is disabled."

  attr :readonly, :boolean,
    default: false,
    doc: "Whether the textarea is read-only. The value stays selectable but not editable."

  attr :required, :boolean,
    default: false,
    doc: "Whether the textarea must be filled in."

  attr :class, :any, default: nil, doc: "Additional classes for the native control."

  attr :rest, :global,
    include: ~w(autocomplete autocapitalize autofocus cols dirname enterkeyhint form
         inputmode maxlength minlength placeholder rows spellcheck wrap),
    doc: "Additional HTML and LiveView attributes, rendered on the native control."

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
    <div {@flint_parts[:root]} {@root_attrs}>
      <label :if={@label || @sublabel} {@flint_parts[:label]} for={@id}>
        <span {@flint_parts[:label_text]}>
          <span :if={@label}>{@label}</span>
          <span :if={@sublabel} {@flint_parts[:sublabel]}>{@sublabel}</span>
        </span>
      </label>
      <p :if={@description} id={@description_id} {@flint_parts[:description]}>{@description}</p>
      <textarea
        id={@id}
        name={@name}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        {@control_rest}
        {@flint_parts[:control]}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
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

  defp prepare(assigns) do
    errors = Field.translate_errors(Map.get(assigns, :errors) || [])
    invalid? = errors != []
    id = derived_id(assigns)
    description_id = Field.description_id(id, Map.get(assigns, :description))
    hint_id = Field.hint_id(id, Map.get(assigns, :hint))

    described_by =
      Field.described_by(Map.get(assigns, :rest, %{}), [
        description_id,
        hint_id,
        Field.error_ids(id, errors)
      ])

    control_rest =
      Map.get(assigns, :rest, %{})
      |> Map.drop([:"aria-invalid", "aria-invalid", :"aria-describedby", "aria-describedby"])
      |> Field.put_present(:class, Map.get(assigns, :class))
      |> Field.put_present(:"aria-describedby", described_by)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    assign(assigns,
      id: id,
      name: Map.get(assigns, :name),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      value: Map.get(assigns, :value),
      description: Map.get(assigns, :description),
      hint: Map.get(assigns, :hint),
      disabled: Map.get(assigns, :disabled, false),
      readonly: Map.get(assigns, :readonly, false),
      required: Map.get(assigns, :required, false),
      errors: errors,
      invalid: invalid?,
      description_id: description_id,
      hint_id: hint_id,
      control_rest: control_rest,
      root_attrs: Map.get(assigns, :root_attrs, %{})
    )
  end

  defp derived_id(assigns) do
    case Map.get(assigns, :id) do
      id when is_binary(id) ->
        id

      _ ->
        case Map.get(assigns, :field) do
          %Phoenix.HTML.FormField{id: id} -> id
          _ -> nil
        end
    end
  end

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
