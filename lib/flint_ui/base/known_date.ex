defmodule FlintUI.Base.KnownDate do
  @moduledoc """
  Renders a known date as separate day, month, and year fields.

  A known date is a date the user already knows, such as a birthday, an issue
  date, or an expiration. It follows the UK Government Design System date input
  pattern: a labeled `<fieldset>` wraps three plain text inputs, so the user
  types each part themselves. There is no popup calendar, no auto-advance, and
  no clever parsing.

      <.known_date
        id="date-of-birth"
        name="date_of_birth"
        label="Date of birth"
        hint="For example, 27 3 2007"
      />

  The host submits one canonical ISO 8601 date (`YYYY-MM-DD`) through a hidden
  input named `name`, regardless of the order the fields are rendered in. A
  partial or invalid date submits nothing. `flint.js` composes the hidden value
  as the user types. Without the bundle, the server-rendered value is what
  submits; editing the visible fields does not update it.

  ## Value and form fields

  `value` accepts an ISO date string or a `Date`. Pass a
  `Phoenix.HTML.FormField` to derive `id`, `name`, the current value, and the
  errors. Errors only show once the field has been used
  (`Phoenix.Component.used_input?/1`):

      <.known_date field={@form[:date_of_birth]} label="Date of birth" />

  The visible inputs do not submit their own form parameters. They have no
  `name`; only the hidden input carries `name`. The component id names the
  group, and each part derives its id from it (`<id>-day`, `<id>-month`, and
  `<id>-year`).

  ## Locale-aware field order

  `locale` accepts a BCP-47 locale and changes the order of the three fields:
  most of the world reads day, month, year; `en-US` reads month, day, year; and
  locales such as `ja-JP`, `zh-CN`, `ko-KR`, `hu-HU`, `lt-LT`, and `sv-SE` read
  year, month, day. The labels stay the same; only their position changes.

  When `locale` is omitted, a `lang` attribute passed through the global
  attributes is used. With neither, the default is the European order: day,
  month, year.

  ## Range, required, and validation

  `min` and `max` accept an ISO 8601 string or a `Date` and are checked by the
  hook alongside the validity of the composed date. `required` puts the native
  `required` attribute on each part, so an incomplete date blocks submission in
  the browser. The field also carries `data-invalid` and links its errors to
  every part with `aria-describedby`.

  ## Accessibility

  The root is a native `<fieldset>`, and `label` renders as its `<legend>`, so
  assistive technology announces the group name as the user moves between the
  parts. Each part has its own `<label>` (`Day`, `Month`, `Year`), and the
  description, hint, and errors are linked from every part.

  `sublabel` renders inside the legend and is announced with the group name.
  The description and hint sit outside the legend, so they do not join the
  accessible name; they are read from the links instead.

  A disabled group renders the native `disabled` attribute on the fieldset.
  Read-only parts keep their values focusable and selectable while preventing
  edits, and the hidden canonical value still submits.

  ## Keyboard

  - `Tab` - moves between the day, month, and year fields, then out of the
    group.
  - `Enter` - submits the form from any part.
  - `Arrow keys` - move the caret within the focused field. The control does
    not auto-advance.
  """

  use FlintUI.Component

  alias FlintUI.{API, Field}

  @field_orders %{
    "dmy" => ~w(day month year),
    "mdy" => ~w(month day year),
    "ymd" => ~w(year month day)
  }

  @field_labels %{"day" => "Day", "month" => "Month", "year" => "Year"}
  @field_max_lengths %{"day" => 2, "month" => 2, "year" => 4}
  @field_sizes %{"day" => 2, "month" => 2, "year" => 4}

  @year_first_languages ~w(ja zh ko hu lt fa sv)
  @month_first_english_regions ~w(us ph bz pr as gu mh mp um vi)

  @impl true
  def meta do
    %Meta{
      name: :known_date,
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
          value: "known_date",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the group root, rendered as a native `fieldset`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "The group id. Derived from `field` when omitted, and generated when neither is given. The parts derive their ids from it."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: ~s("FlintUI.KnownDate"),
          description: "Attaches the hook that composes the canonical ISO value."
        },
        %Meta.PartAttr{
          name: "[data-order]",
          value: ~s("dmy" | "mdy" | "ymd"),
          description: "The order the three fields are rendered in."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the group is disabled."
        },
        %Meta.PartAttr{
          name: "[data-invalid]",
          value: "boolean",
          description: "Present when the field has at least one error."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set when the field has at least one error."
        },
        %Meta.PartAttr{
          name: "[data-readonly]",
          value: "boolean",
          description: "Present when the parts are read-only."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the date is required."
        },
        %Meta.PartAttr{
          name: "[data-min]",
          value: "string",
          description: "The earliest accepted date as `YYYY-MM-DD`, when `min` is set."
        },
        %Meta.PartAttr{
          name: "[data-max]",
          value: "string",
          description: "The latest accepted date as `YYYY-MM-DD`, when `max` is set."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description: "The group label, rendered as a native `legend`."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label_text",
          description: "The label and sublabel row inside the legend."
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
            "Explanatory text shown between the legend and the fields and exposed through `aria-describedby`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from the group id."
        }
      ],
      fields: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "fields",
          description: "The row that lays out the day, month, and year blocks."
        }
      ],
      field: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "field",
          description: "One field block, holding a part label and its native input."
        },
        %Meta.PartAttr{
          name: "[data-field]",
          value: ~s("day" | "month" | "year"),
          description: "Identifies which part of the date the block holds."
        }
      ],
      field_label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "field_label",
          description: "The visible `Day`, `Month`, or `Year` label for one part."
        },
        %Meta.PartAttr{
          name: "for",
          value: "string",
          description: "The part input id."
        }
      ],
      control: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "control",
          description:
            "A native text input for one date part. Three inputs render, marked with `data-field`."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("text"),
          description: "The native text type, with a numeric input mode."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "`<group id>-day`, `<group id>-month`, or `<group id>-year`."
        },
        %Meta.PartAttr{
          name: "inputmode",
          value: ~s("numeric"),
          description: "Asks touch keyboards for digits."
        },
        %Meta.PartAttr{
          name: "pattern",
          value: ~s("[0-9]*"),
          description: "Restricts form submission to digits."
        },
        %Meta.PartAttr{
          name: "maxlength",
          value: "number",
          description: "Two characters for day and month, four for the year."
        },
        %Meta.PartAttr{
          name: "autocomplete",
          value: "string",
          description:
            "Derived from `autocomplete`: `bday` expands to `bday-day`, `bday-month`, and `bday-year`."
        },
        %Meta.PartAttr{
          name: "aria-invalid",
          value: ~s("true"),
          description: "Set on every part when the field has errors."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "The description, hint, and error message ids, appended to a caller-supplied value."
        }
      ],
      value: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "value",
          description:
            "The hidden input that submits the canonical ISO date. It is disabled while the date is incomplete or invalid."
        },
        %Meta.PartAttr{
          name: "name",
          value: "string",
          description: "The form parameter name."
        },
        %Meta.PartAttr{
          name: "value",
          value: "string",
          description: "The canonical ISO date, or absent when it is incomplete or invalid."
        }
      ],
      hint: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "hint",
          description:
            "Supporting text shown below the fields and exposed through `aria-describedby`."
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
            "One error message. Each message carries its own id and is exposed through `aria-describedby`."
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
        description: "Moves between the day, month, and year fields, then out of the group."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Submits the form from any part."
      },
      %Meta.Keyboard{
        keys: "Arrow keys",
        description: "Move the caret within the focused field. The control does not auto-advance."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "invalid",
        description: "The field has at least one error.",
        selector: ~s([data-element="known_date"][data-invalid])
      },
      %Meta.State{
        name: "disabled",
        description: "The group is disabled.",
        selector: ~s([data-element="known_date"][data-disabled])
      },
      %Meta.State{
        name: "readonly",
        description: "The parts are read-only.",
        selector: ~s([data-element="known_date"][data-readonly])
      },
      %Meta.State{
        name: "required",
        description: "The date is required.",
        selector: ~s([data-element="known_date"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    derived = derive(assigns)

    root =
      %{
        "id" => derived.id,
        "phx-hook" => "FlintUI.KnownDate",
        "data-element" => "known_date",
        "data-part" => "root",
        "data-order" => derived.order_key,
        "data-disabled" => Map.get(assigns, :disabled, false),
        "data-invalid" => derived.errors != [],
        "data-readonly" => Map.get(assigns, :readonly, false),
        "data-required" => Map.get(assigns, :required, false)
      }
      |> Field.put_present("data-min", derived.min)
      |> Field.put_present("data-max", derived.max)

    %{
      root: root,
      label: %{"data-part" => "label"},
      label_text: %{"data-part" => "label_text"},
      sublabel: %{"data-part" => "sublabel"},
      description: %{"data-part" => "description"},
      fields: %{"data-part" => "fields"},
      field: %{"data-part" => "field"},
      field_label: %{"data-part" => "field_label"},
      control: %{"data-part" => "control", "type" => "text", "inputmode" => "numeric"},
      value: %{"data-part" => "value"},
      hint: %{"data-part" => "hint"},
      error: %{"data-part" => "error"},
      error_icon: %{"data-part" => "error_icon", "aria-hidden" => "true"}
    }
  end

  # The public attrs are also the docs API, so keep `doc: false` on internal
  # connectors only.
  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the group root while the
  # caller's global attributes stay on the native part inputs. This connector is
  # internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :id, :any,
    default: nil,
    doc:
      "The group id. Derived from `field` when omitted, and generated when neither is given. The part inputs derive their ids from it."

  attr :name, :any,
    doc:
      "The form parameter name. Derived from `field` when omitted. Only the hidden canonical input submits it."

  attr :label, :string, default: nil, doc: "The group label, rendered as a `legend`."

  attr :sublabel, :string,
    default: nil,
    doc: "A short qualifier shown beside the label, such as `Optional`."

  attr :value, :any,
    doc: "The date as an ISO 8601 string or a `Date`. Derived from `field` when omitted."

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct retrieved from the form, for example `@form[:date_of_birth]`."

  attr :errors, :list,
    default: [],
    doc:
      "Error messages, as translated strings or raw `{message, options}` tuples. A field's own errors are used when `field` is given."

  attr :locale, :string,
    default: nil,
    doc:
      "A BCP-47 locale that selects the field order. `en-US` is month-first; `ja-JP`, `zh-CN`, `ko-KR`, `hu-HU`, `lt-LT`, and `sv-SE` are year-first; everything else is day-first. Defaults to a `lang` attribute from the global attributes, then day-first."

  attr :min, :any,
    default: nil,
    doc: "The earliest accepted date as an ISO 8601 string or a `Date`."

  attr :max, :any,
    default: nil,
    doc: "The latest accepted date as an ISO 8601 string or a `Date`."

  attr :autocomplete, :string,
    default: nil,
    doc:
      "Browser autofill family. `bday` expands to `bday-day`, `bday-month`, and `bday-year`; `on` and `off` apply to every part; any other value is forwarded only to the year part."

  attr :description, :string,
    default: nil,
    doc:
      "Explanatory text shown between the legend and the fields and linked with `aria-describedby`."

  attr :hint, :string,
    default: nil,
    doc: "Supporting text shown below the fields and linked with `aria-describedby`."

  attr :disabled, :boolean, default: false, doc: "Whether the group is disabled."

  attr :readonly, :boolean,
    default: false,
    doc:
      "Whether the parts are read-only. The values stay focusable and selectable, and the hidden canonical value still submits."

  attr :required, :boolean, default: false, doc: "Whether the date must be complete."

  attr :class, :any, default: nil, doc: "Additional classes for the group root."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc:
      "Additional HTML and LiveView attributes, rendered on every part input. A `lang` attribute also selects the field order."

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
      lang={@locale}
      aria-invalid={@invalid && "true"}
      class={@class}
    >
      <legend :if={@label || @sublabel} {@flint_parts[:label]}>
        <span {@flint_parts[:label_text]}>
          <span :if={@label}>{@label}</span>
          <span :if={@sublabel} {@flint_parts[:sublabel]}>{@sublabel}</span>
        </span>
      </legend>

      <p :if={@description} id={@description_id} {@flint_parts[:description]}>{@description}</p>

      <div {@flint_parts[:fields]}>
        <div :for={part <- @parts} {@flint_parts[:field]} data-field={part.key}>
          <label {@flint_parts[:field_label]} for={part.id}>{part.label}</label>
          <input
            type="text"
            id={part.id}
            value={part.value}
            size={part.size}
            maxlength={part.maxlength}
            inputmode="numeric"
            pattern="[0-9]*"
            autocomplete={part.autocomplete}
            autofocus={part.first? && Field.rest_attr(@rest, :autofocus)}
            disabled={@disabled}
            readonly={@readonly}
            required={@required}
            aria-invalid={@invalid && "true"}
            aria-describedby={@describedby}
            {@control_rest}
            data-field={part.key}
            {@flint_parts[:control]}
          />
        </div>
      </div>

      <input
        type="hidden"
        name={@name}
        value={@canonical_iso}
        disabled={@disabled or is_nil(@canonical_iso)}
        form={Field.rest_attr(@rest, :form)}
        {@flint_parts[:value]}
      />

      <p :if={@hint} id={@hint_id} {@flint_parts[:hint]}>{@hint}</p>

      <p
        :for={{message, index} <- Enum.with_index(@errors, 1)}
        id={Field.error_id(@root_id, index)}
        {@flint_parts[:error]}
      >
        <Field.error_icon attrs={@flint_parts[:error_icon]} />
        {message}
      </p>
    </fieldset>
    """
  end

  defp prepare(assigns) do
    derived = derive(assigns)
    errors = derived.errors
    invalid? = errors != []
    rest = Map.get(assigns, :rest, %{})
    description_id = Field.description_id(derived.id, Map.get(assigns, :description))
    hint_id = Field.hint_id(derived.id, Map.get(assigns, :hint))

    describedby =
      Field.described_by(rest, [description_id, hint_id, Field.error_ids(derived.id, errors)])

    control_rest =
      rest
      |> Map.drop([
        :autofocus,
        "autofocus",
        :"aria-invalid",
        "aria-invalid",
        :"aria-describedby",
        "aria-describedby"
      ])
      |> Field.put_present(:"aria-describedby", describedby)
      |> Field.put_present(:"aria-invalid", invalid? && "true")

    parts =
      derived.order
      |> Enum.with_index()
      |> Enum.map(fn {key, index} ->
        %{
          key: key,
          label: Map.fetch!(@field_labels, key),
          id: part_id(derived.id, key),
          value: Map.get(derived.parts, key, ""),
          size: Map.fetch!(@field_sizes, key),
          maxlength: Map.fetch!(@field_max_lengths, key),
          autocomplete: field_autocomplete(Map.get(assigns, :autocomplete), key),
          first?: index == 0
        }
      end)

    assign(assigns,
      name: Map.get(assigns, :name),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      description: Map.get(assigns, :description),
      hint: Map.get(assigns, :hint),
      locale: Map.get(assigns, :locale),
      disabled: Map.get(assigns, :disabled, false),
      readonly: Map.get(assigns, :readonly, false),
      required: Map.get(assigns, :required, false),
      errors: errors,
      invalid: invalid?,
      root_id: derived.id,
      canonical_iso: derived.canonical_iso,
      description_id: description_id,
      hint_id: hint_id,
      describedby: if(describedby == "", do: nil, else: describedby),
      control_rest: control_rest,
      parts: parts,
      rest: rest,
      root_attrs: Map.get(assigns, :root_attrs, %{})
    )
  end

  defp derive(assigns) do
    rest = Map.get(assigns, :rest, %{})
    id = root_id(assigns)
    errors = field_errors(assigns)
    min = normalize_date(Map.get(assigns, :min))
    max = normalize_date(Map.get(assigns, :max))
    iso = normalize_date(value(assigns))
    in_range? = in_range?(iso, min, max)
    order_key = order_key(Map.get(assigns, :locale) || Field.rest_attr(rest, :lang))

    %{
      id: id,
      errors: errors,
      min: min,
      max: max,
      canonical_iso: if(in_range?, do: iso, else: nil),
      parts: if(iso, do: date_parts(iso), else: %{}),
      order: Map.fetch!(@field_orders, order_key),
      order_key: order_key
    }
  end

  defp value(assigns) do
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

  defp normalize_date(%Date{} = date), do: Date.to_iso8601(date)
  defp normalize_date(nil), do: nil

  defp normalize_date(value) when is_binary(value) do
    case Date.from_iso8601(String.trim(value)) do
      {:ok, date} -> Date.to_iso8601(date)
      _ -> nil
    end
  end

  defp normalize_date(_value), do: nil

  defp date_parts(iso) do
    [year, month, day] = String.split(iso, "-")
    %{"day" => day, "month" => month, "year" => year}
  end

  defp in_range?(nil, _min, _max), do: false
  defp in_range?(iso, min, max), do: at_or_after?(iso, min) and at_or_before?(iso, max)
  defp at_or_after?(_iso, nil), do: true
  defp at_or_after?(iso, min), do: iso >= min
  defp at_or_before?(_iso, nil), do: true
  defp at_or_before?(iso, max), do: iso <= max

  defp order_key(nil), do: "dmy"
  defp order_key(""), do: "dmy"

  defp order_key(locale) when is_binary(locale) do
    parts = locale |> String.replace("_", "-") |> String.downcase() |> String.split("-")
    [language | rest] = parts
    region = Enum.find(rest, &Regex.match?(~r/^[a-z]{2}$/, &1))

    cond do
      language in @year_first_languages -> "ymd"
      language == "en" and region in @month_first_english_regions -> "mdy"
      language == "es" and region == "us" -> "mdy"
      language == "en" and region == "ca" -> "ymd"
      true -> "dmy"
    end
  end

  defp field_autocomplete("bday", key), do: "bday-" <> key
  defp field_autocomplete(value, _key) when value in ["on", "off"], do: value
  defp field_autocomplete(value, "year") when is_binary(value) and value != "", do: value
  defp field_autocomplete(_value, _key), do: nil

  defp root_id(assigns) do
    case Map.get(assigns, :id) do
      id when is_binary(id) and id != "" ->
        id

      _ ->
        case Map.get(assigns, :field) do
          %Phoenix.HTML.FormField{id: id} when is_binary(id) and id != "" -> id
          _ -> API.use_id("fl-known-date")
        end
    end
  end

  defp part_id(id, key) when is_binary(id), do: "#{id}-#{key}"
  defp part_id(_id, _key), do: nil

  defp field_errors(%{field: %Phoenix.HTML.FormField{} = field}) do
    if Phoenix.Component.used_input?(field), do: Field.translate_errors(field.errors), else: []
  end

  defp field_errors(assigns), do: Field.translate_errors(Map.get(assigns, :errors) || [])
end
