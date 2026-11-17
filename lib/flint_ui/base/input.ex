defmodule FlintUI.Base.Input do
  @moduledoc """
  Renders a form control with its label, hint, and error messages.

  `input` follows the same contract as the `input/1` function that `phx.new`
  generates in `MyAppWeb.CoreComponents`: the same attributes, the same input
  types, the same `Phoenix.HTML.FormField` handling, and the same
  `options_for_select/2` and `normalize_value/2` behavior. Replacing the core
  function with the generated FlintUI wrapper keeps existing forms working:

      <.input field={@form[:email]} type="email" label="Email" />

      <.input name="search" type="search" placeholder="Search" />

  It also renders a label, a hint, and every error so the field is one
  accessible unit instead of a bare control. The headless layer is unstyled; the
  generated styled component maps `size` and `radius` onto `data-*` hooks.

  ## Field structs

  Pass a `Phoenix.HTML.FormField` from a form built with `to_form/2` and the
  component derives the `id`, `name`, `value`, and errors. Errors only show once
  the field has been used (`Phoenix.Component.used_input?/1`), so a form does not
  display errors before the first submit.

      <.form for={@form} id="user-form">
        <.input field={@form[:email]} type="email" label="Email" />
      </.form>

  `multiple` selects derive a `name` with a `[]` suffix.

  ## Types

  `type` accepts the same values as the core component: `checkbox`, `color`,
  `date`, `datetime-local`, `email`, `file`, `month`, `number`, `password`,
  `search`, `select`, `tel`, `text`, `textarea`, `time`, `url`, `week`, and
  `hidden`.

  `checkbox` renders a hidden `"false"` input before the checkbox when a `name`
  is set, so an unchecked box still submits a value. `select` takes `options` in
  the shape `options_for_select/2` accepts, an optional `prompt`, and supports
  `multiple`. `hidden` renders only the input; it has no label or errors.

  For a standalone textarea with `sublabel`, `description`, and `hint`, use
  `FlintUI.textarea`. The `textarea` type stays for `CoreComponents` parity and
  for the prefix and suffix slots.

  FlintUI keeps the native `<select>` appearance. A separate, richer Select
  component will cover custom option lists; this one stays progressive and
  usable without JavaScript.

  ## Prefix and suffix slots

  Four slots frame the control. `:inner_prefix` and `:inner_suffix` render inside
  the control's border; `:outer_prefix` and `:outer_suffix` render outside it, on
  either side of the control box.

      <.input name="price" label="Price">
        <:inner_prefix>$</:inner_prefix>
        <:inner_suffix>USD</:inner_suffix>
      </.input>

      <.input name="domain" label="Domain" value="acme">
        <:outer_prefix>https://</:outer_prefix>
        <:outer_suffix>.example.com</:outer_suffix>
      </.input>

  The inner slots sit inside the `<label>`, so keep their content decorative or
  textual. Put interactive content, such as a reveal or clear button, in an outer
  slot.

  The styled theme renders the outer slots as addons: they share the control's
  fill and height, join its border so the group has a single seam, and keep only
  the free end rounded. A styled button placed directly in an outer slot becomes
  the segment itself; give it the same `size` as the input.

  The slots apply to text inputs, `select`, and `textarea`; the `checkbox` and
  `hidden` branches do not render them.

  ## Errors

  `errors` accepts translated strings and raw `{message, options}` tuples.
  Tuples are interpolated like the `translate_error/1` that `phx.new` generates
  without Gettext. Applications that use Gettext can keep their translations by
  configuring the function:

      config :flint_ui, :translate_error, {MyAppWeb.CoreComponents, :translate_error}

  The configuration accepts `{module, function}`, `{module, function, extra_args}`
  (the error tuple is passed first), or a one-arity function.

  An invalid control carries `aria-invalid="true"` and an `aria-describedby`
  pointing at its hint and error messages, so assistive technology reads
  the error with the field. A caller-supplied `aria-describedby` is preserved and
  the generated ids are appended.

  Every error is preceded by a decorative warning icon. The icon is inline SVG,
  so it does not depend on an icon set, and it is hidden from assistive
  technology because the message text carries the meaning.

  ## Accessibility

  Always give the control an accessible name. `label` renders a `<label>` that
  wraps the control, so the association works even without an `id`; an explicit
  `id` also sets `for`. When you omit `label`, supply `aria-label` or
  `aria-labelledby`.

  Each native control keeps its semantics and keyboard behavior: inputs expose a
  `textbox` role (or the type-specific role), `select` exposes `combobox` or
  `listbox` depending on `multiple`, `textarea` exposes `textbox` with multiline
  behavior, and a checkbox exposes `checkbox`. Errors are text, not color alone,
  and the control is marked invalid for assistive technology.

  The checkbox keeps a real, focusable native input. The styled theme paints the
  visible box on a decorative indicator around it, so forced-colors mode and
  screen readers still see the native control. The label is the checkbox's
  accessible name when `label` is set.

  Disabled controls render the native `disabled` attribute. Read-only controls
  keep their value selectable but not editable.

  Inner prefix and suffix content sits inside the label, so its text contributes
  to the control's accessible name; hide decorative icons with `aria-hidden`.
  Outer slots sit outside the label and are read in DOM order. Give an
  interactive outer control its own accessible name.

  ## Keyboard

  Keyboard behavior comes from the native control:

  - `Tab` - moves focus into and out of the control.
  - `Enter` - submits the form from a single-line input. Ignored by a textarea,
    where it inserts a newline.
  - `Space` - toggles a checkbox; opens or selects in a native select.
  - `Arrow keys` - move through native radio/select options and date segments.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @types ~w(checkbox color date datetime-local email file month number password
            search select tel text textarea time url week hidden)

  @impl true
  def meta do
    %Meta{
      name: :input,
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
          value: "input",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the field root."
        },
        %Meta.PartAttr{
          name: "[data-type]",
          value: "string",
          description:
            "The input type, such as `text`, `select`, `textarea`, or `checkbox`. Drives the per-type theme rules."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the field has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the control is disabled."
        },
        %Meta.PartAttr{
          name: "[data-readonly]",
          value: "boolean",
          description: "Present when the control is read-only."
        }
      ],
      row: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "row",
          description:
            "The control row for text inputs, `select`, and `textarea`. It places the outer slots on either side of the control box."
        }
      ],
      outer_prefix: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "outer_prefix",
          description:
            "Content outside the control border, before the label. It sits outside the `<label>`, so it may contain an interactive control."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description:
            "The field label and control box. It wraps the native control, so it names the control even without an `id`; a checkbox's label also wraps its indicator."
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
          description:
            "The label text for text inputs, `select`, and `textarea`. It spans the control row above the box, so a field with an outer prefix keeps its label aligned with the rest of the form."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description:
            "The decorative box around a checkbox's native input. The theme paints the box and check mark; the native input stays focusable above it."
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
            "The inline SVG check mark shown while a checkbox is checked. The theme swaps it for a dash while the native input is indeterminate."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The check mark is decorative; the native checkbox carries the state."
        }
      ],
      box: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "box",
          description:
            "The bordered control surface for text inputs, `select`, and `textarea`. It holds the inner slots and the native control."
        }
      ],
      inner_prefix: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "inner_prefix",
          description:
            "Content inside the control border, before the native control. It sits inside the `<label>`, so keep it decorative or textual."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description:
            "The native `input`, `select`, or `textarea`, which carries the field's HTML and LiveView attributes."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The control id, derived from the field when one is not passed."
        },
        %Meta.PartAttr{
          name: "name",
          value: "string",
          description: "The form parameter name, with a `[]` suffix for multiple selects."
        },
        %Meta.PartAttr{
          name: "type",
          value: "string",
          description: "The input type. Omitted on `select` and `textarea`."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the field has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description: "The hint and error message ids, appended to a caller-supplied value."
        }
      ],
      inner_suffix: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "inner_suffix",
          description:
            "Content inside the control border, after the native control. It sits inside the `<label>`, so keep it decorative or textual."
        }
      ],
      outer_suffix: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "outer_suffix",
          description:
            "Content outside the control border, after the label. It sits outside the `<label>`, so it may contain an interactive control."
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
      %Meta.Keyboard{keys: "Tab", description: "Moves focus into and out of the control."},
      %Meta.Keyboard{
        keys: "Enter",
        description:
          "Submits the form from a single-line input. A textarea inserts a newline instead."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles a checkbox, or opens a native select."
      },
      %Meta.Keyboard{
        keys: "Arrow keys",
        description: "Move through native select options and date segments."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "invalid",
        description: "The field has at least one error.",
        selector: ~s([data-element="input"][data-invalid])
      },
      %Meta.State{
        name: "disabled",
        description: "The control is disabled.",
        selector: ~s([data-element="input"][data-disabled])
      },
      %Meta.State{
        name: "readonly",
        description: "The control is read-only.",
        selector: ~s([data-element="input"][data-readonly])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    derived = derive(assigns)
    rest = Map.get(assigns, :rest, %{})

    %{
      root: %{
        "data-element" => "input",
        "data-part" => "root",
        "data-type" => derived.type,
        "data-invalid" => derived.errors != [],
        "data-disabled" => Field.present?(Field.rest_attr(rest, :disabled)),
        "data-readonly" => Field.present?(Field.rest_attr(rest, :readonly))
      },
      row: %{
        "data-part" => "row"
      },
      outer_prefix: %{
        "data-part" => "outer_prefix"
      },
      label: %{
        "data-part" => "label",
        "for" => derived.id
      },
      label_text: %{
        "data-part" => "label_text"
      },
      box: %{
        "data-part" => "box"
      },
      inner_prefix: %{
        "data-part" => "inner_prefix"
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
        "data-part" => "control"
      },
      inner_suffix: %{
        "data-part" => "inner_suffix"
      },
      outer_suffix: %{
        "data-part" => "outer_suffix"
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

  # The public attrs are also the docs API, so keep `doc: false` on internal
  # connectors only.
  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the field root while the
  # caller's global attributes stay on the native control. This connector is
  # internal, like `FlintUI.Base.Indicator`'s `badge_attrs`.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :id, :any, default: nil, doc: "The control id. Derived from `field` when omitted."

  attr :name, :any,
    doc:
      "The form parameter name. Derived from `field` when omitted, with a `[]` suffix for multiple selects."

  attr :label, :string, default: nil, doc: "The field label."

  attr :value, :any, doc: "The control value. Derived from `field` when omitted."

  attr :type, :string,
    default: "text",
    values: @types,
    doc: "The input type. `select`, `textarea`, `checkbox`, and `hidden` have dedicated markup."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:email]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :checked, :boolean,
    doc:
      "The checked flag for checkbox inputs. When omitted, the value is normalized like `Phoenix.HTML.Form.normalize_value/2`."

  attr :prompt, :string, default: nil, doc: "The prompt option for select inputs."

  attr :options, :list, doc: "The options to pass to `Phoenix.HTML.Form.options_for_select/2`."

  attr :multiple, :boolean,
    default: false,
    doc: "The multiple flag for select and file inputs."

  attr :hint, :string,
    default: nil,
    doc: "Hint text shown below the control and linked with `aria-describedby`."

  attr :class, :any, default: nil, doc: "Additional classes for the native control."

  attr :error_class, :any,
    default: nil,
    doc: "Additional classes for the native control while the field has errors."

  attr :rest, :global,
    include: ~w(accept autocomplete autocapitalize capture cols dirname disabled enterkeyhint form
         inputmode list max maxlength min minlength multiple pattern placeholder readonly
         required rows size spellcheck step),
    doc: "Additional HTML and LiveView attributes, rendered on the native control."

  slot :inner_prefix,
    doc:
      "Content inside the control border, before the native control. Keep it decorative or textual; use `:outer_prefix` for interactive content."

  slot :inner_suffix,
    doc:
      "Content inside the control border, after the native control. Keep it decorative or textual; use `:outer_suffix` for interactive content."

  slot :outer_prefix,
    doc:
      "Content outside the control border, before the label. It may contain interactive content."

  slot :outer_suffix,
    doc:
      "Content outside the control border, after the label. It may contain interactive content."

  @impl true
  def render(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id, errors: errors)
    |> assign_new(:name, fn ->
      if assigns[:multiple], do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> render()
  end

  def render(%{type: "hidden"} = assigns) do
    assigns = prepare(assigns)

    ~H"""
    <input
      type="hidden"
      id={@id}
      name={@name}
      value={@value}
      {@rest}
      {@flint_parts[:root]}
      {@root_attrs}
    />
    """
  end

  def render(%{type: "checkbox"} = assigns) do
    assigns =
      assigns
      |> prepare()
      |> assign(:checked, checked?(assigns))

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs}>
      <input
        type="hidden"
        name={@name}
        value="false"
        disabled={Field.rest_attr(@rest, :disabled)}
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
            value="true"
            checked={@checked}
            {@control_rest}
            {@flint_parts[:control]}
          />
        </span>
        {@label}
      </label>
      <.chrome
        hint={@hint}
        hint_id={@hint_id}
        errors={@errors}
        id={@id}
        flint_parts={@flint_parts}
      />
    </div>
    """
  end

  def render(%{type: "select"} = assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs}>
      <.frame
        label={@label}
        outer_prefix={render_slot(@outer_prefix)}
        inner_prefix={render_slot(@inner_prefix)}
        inner_suffix={render_slot(@inner_suffix)}
        outer_suffix={render_slot(@outer_suffix)}
        flint_parts={@flint_parts}
      >
        <select
          id={@id}
          name={@name}
          multiple={@multiple}
          {@control_rest}
          {@flint_parts[:control]}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options || [], @value)}
        </select>
      </.frame>
      <.chrome
        hint={@hint}
        hint_id={@hint_id}
        errors={@errors}
        id={@id}
        flint_parts={@flint_parts}
      />
    </div>
    """
  end

  def render(%{type: "textarea"} = assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs}>
      <.frame
        label={@label}
        outer_prefix={render_slot(@outer_prefix)}
        inner_prefix={render_slot(@inner_prefix)}
        inner_suffix={render_slot(@inner_suffix)}
        outer_suffix={render_slot(@outer_suffix)}
        flint_parts={@flint_parts}
      >
        <textarea
          id={@id}
          name={@name}
          {@control_rest}
          {@flint_parts[:control]}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </.frame>
      <.chrome
        hint={@hint}
        hint_id={@hint_id}
        errors={@errors}
        id={@id}
        flint_parts={@flint_parts}
      />
    </div>
    """
  end

  def render(assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs}>
      <.frame
        label={@label}
        outer_prefix={render_slot(@outer_prefix)}
        inner_prefix={render_slot(@inner_prefix)}
        inner_suffix={render_slot(@inner_suffix)}
        outer_suffix={render_slot(@outer_suffix)}
        flint_parts={@flint_parts}
      >
        <input
          type={@type}
          id={@id}
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          multiple={@type == "file" && @multiple}
          {@control_rest}
          {@flint_parts[:control]}
        />
      </.frame>
      <.chrome
        hint={@hint}
        hint_id={@hint_id}
        errors={@errors}
        id={@id}
        flint_parts={@flint_parts}
      />
    </div>
    """
  end

  defp frame(assigns) do
    ~H"""
    <div {@flint_parts[:row]}>
      <span :if={present?(@outer_prefix)} {@flint_parts[:outer_prefix]}>{@outer_prefix}</span>
      <label {@flint_parts[:label]}>
        <span :if={Field.present?(@label)} {@flint_parts[:label_text]}>{@label}</span>
        <span {@flint_parts[:box]}>
          <span :if={present?(@inner_prefix)} {@flint_parts[:inner_prefix]}>{@inner_prefix}</span>
          {render_slot(@inner_block)}
          <span :if={present?(@inner_suffix)} {@flint_parts[:inner_suffix]}>{@inner_suffix}</span>
        </span>
      </label>
      <span :if={present?(@outer_suffix)} {@flint_parts[:outer_suffix]}>{@outer_suffix}</span>
    </div>
    """
  end

  defp chrome(assigns) do
    ~H"""
    <p :if={@hint} id={@hint_id} {@flint_parts[:hint]}>{@hint}</p>
    <p
      :for={{message, index} <- Enum.with_index(@errors, 1)}
      id={Field.error_id(@id, index)}
      {@flint_parts[:error]}
    >
      <Field.error_icon attrs={@flint_parts[:error_icon]} />
      {message}
    </p>
    """
  end

  # The root state hooks are computed before the field is unwrapped, so they
  # share the same derivation as `render/1`.
  defp derive(assigns) do
    case Map.get(assigns, :field) do
      %Phoenix.HTML.FormField{} = field ->
        errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

        %{
          type: Map.get(assigns, :type) || "text",
          id: Map.get(assigns, :id) || field.id,
          errors: Field.translate_errors(errors)
        }

      _ ->
        %{
          type: Map.get(assigns, :type) || "text",
          id: Map.get(assigns, :id),
          errors: Field.translate_errors(Map.get(assigns, :errors) || [])
        }
    end
  end

  defp prepare(assigns) do
    errors = Field.translate_errors(assigns[:errors] || [])
    invalid? = errors != []
    id = assigns[:id]

    hint_id =
      if Field.present?(id) and Field.present?(assigns[:hint]), do: "#{id}-hint"

    error_ids =
      if Field.present?(id) do
        errors
        |> Enum.with_index(1)
        |> Enum.map(fn {_message, index} -> Field.error_id(id, index) end)
      else
        []
      end

    described_by =
      [Field.rest_attr(assigns.rest, :"aria-describedby"), hint_id, error_ids]
      |> List.flatten()
      |> Enum.reject(&Field.blank?/1)
      |> Enum.join(" ")

    control_class =
      Field.class_list([
        assigns[:class],
        invalid? && assigns[:error_class]
      ])

    control_rest =
      assigns.rest
      |> Map.drop([
        :"aria-invalid",
        "aria-invalid",
        :"aria-describedby",
        "aria-describedby"
      ])
      |> Field.put_present(:class, control_class)
      |> Field.put_present(:"aria-describedby", described_by)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    # Attributes declared without a default are absent when the caller omits
    # them, so give the templates a stable value.
    assign(assigns,
      name: assigns[:name],
      value: assigns[:value],
      options: assigns[:options],
      errors: errors,
      hint_id: hint_id,
      control_rest: control_rest
    )
  end

  # A generated wrapper forwards every optional slot, so an unfilled one still
  # arrives as a one-entry list whose rendered output is blank. Treat blank
  # output as absent so the wrappers around the slots are skipped.
  defp present?(nil), do: false

  defp present?(rendered) do
    rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary() |> String.trim() != ""
  end

  # An explicit boolean wins; otherwise derive the check from the value, like
  # `Phoenix.HTML.Form.normalize_value/2` does for a checkbox input.
  defp checked?(assigns) do
    case Map.fetch(assigns, :checked) do
      {:ok, checked} when not is_nil(checked) -> checked
      _ -> Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
    end
  end
end
