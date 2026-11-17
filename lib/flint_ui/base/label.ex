defmodule FlintUI.Base.Label do
  @moduledoc """
  Renders a native label for a control with an optional sublabel and description.

  A label names the control it points at. Put the control's id in `for`, and the
  browser associates the two without wrapping the control:

      <.label for="email">Email</.label>
      <.input id="email" name="email" type="email" />

  `sublabel` adds a short qualifier after the label text, in the muted text
  tier. Use it for a hint such as `Optional` or `Recommended`, not for a second
  sentence of instructions:

      <.label for="email" sublabel="Optional">Email</.label>

  `description` adds explanatory text beneath the label row. The description is
  a sibling of the native `<label>`, not part of it, so it does not join the
  control's accessible name. When `for` is set, the description gets the id
  `<for>-description`; link it from the control with `aria-describedby`:

      <.label for="email" description="We only use this for receipts.">
        Email
      </.label>

      <.input
        id="email"
        name="email"
        type="email"
        aria-describedby="email-description"
      />

  When `for` is absent, the description id follows the root `id` instead. With
  neither, the description is visual only.

  The default slot supplies the label text and wins over `label`. Pass
  `required` to show a decorative asterisk after the label text. The marker does
  not make the control required, so the control itself must still carry
  `required` or `aria-required`:

      <.label for="email" required>Email</.label>
      <.input id="email" name="email" type="email" required />

  The styled wrapper adds the `size` prop.

  ## Accessibility

  The root is a native `<label>` associated through `for`, so clicking the text
  activates the control. Keep the text short and unique; an empty label names
  nothing. When no `for` is available, give the label an `id` and point the
  control's `aria-labelledby` at it.

  The sublabel is inside the label, so it is announced with the label text.
  The required asterisk is decorative and hidden from assistive technology; the
  control's native `required` or `aria-required` state carries the requirement.
  The description is outside the label and does not change the accessible name.
  Link it from the control with `aria-describedby` when the hint matters to
  assistive technology.

  ## Keyboard

  A label is not interactive and adds no keyboard behavior. It forwards the
  browser's native label activation, and `Tab` stays on the control.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :label,
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
          value: "label",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the label root."
        },
        %Meta.PartAttr{
          name: "[data-required]",
          value: "boolean",
          description: "Present when the label shows the required marker."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description: "The native label that names the control."
        },
        %Meta.PartAttr{
          name: "for",
          value: "string",
          description: "The id of the control this label describes."
        }
      ],
      label_text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label_text",
          description: "The label text, required marker, and sublabel row."
        }
      ],
      required: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "required",
          description: "The decorative required asterisk shown after the label text."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The marker is decorative; the control carries the required state."
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
            "Explanatory text shown beneath the label row and kept outside the native label."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, derived from `for` or the root id."
        }
      ]
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "required",
        description: "The label shows the required marker.",
        selector: ~s([data-element="label"][data-required])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "label",
        "data-part" => "root",
        "data-required" => Map.get(assigns, :required, false)
      },
      label: %{
        "data-part" => "label"
      },
      label_text: %{
        "data-part" => "label_text"
      },
      required: %{
        "data-part" => "required",
        "aria-hidden" => "true"
      },
      sublabel: %{
        "data-part" => "sublabel"
      },
      description: %{
        "data-part" => "description"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks on the label root while the
  # caller's global attributes stay on the native label. This connector is
  # internal.
  attr :root_attrs, :map, default: %{}, doc: false

  # The styled wrapper passes already-rendered custom label content here so an
  # empty default slot cannot override `label`.
  attr :label_content, :any, default: nil, doc: false

  attr :for, :any,
    default: nil,
    doc: "The id of the control the label names. Also derives the description id."

  attr :label, :string, default: nil, doc: "The label text."

  attr :sublabel, :string,
    default: nil,
    doc: "A short muted qualifier shown after the label text, such as `Optional`."

  attr :required, :boolean,
    default: false,
    doc:
      "Whether to render the decorative required marker. The control must still carry `required` or `aria-required`."

  attr :description, :string,
    default: nil,
    doc: "Explanatory text shown beneath the label and given the `<for>-description` id."

  attr :class, :any, default: nil, doc: "Additional classes for the label root."

  attr :rest, :global, doc: "Additional HTML attributes, rendered on the native label."

  slot :inner_block, doc: "Custom label content. Takes precedence over `label`."

  @impl true
  def render(assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs} class={@class}>
      <label {@flint_parts[:label]} for={@for} {@rest}>
        <span {@flint_parts[:label_text]}>
          {@label_content || content_or_label(render_slot(@inner_block), @label)}
          <span :if={@required} {@flint_parts[:required]}>*</span>
          <span :if={@sublabel} {@flint_parts[:sublabel]}>{@sublabel}</span>
        </span>
      </label>
      <p :if={@description} id={@description_id} {@flint_parts[:description]}>{@description}</p>
    </div>
    """
  end

  defp prepare(assigns) do
    assign(assigns,
      for: Map.get(assigns, :for),
      label: Map.get(assigns, :label),
      sublabel: Map.get(assigns, :sublabel),
      required: Map.get(assigns, :required, false),
      description: Map.get(assigns, :description),
      class: Map.get(assigns, :class),
      rest: Map.get(assigns, :rest, %{}),
      root_attrs: Map.get(assigns, :root_attrs, %{}),
      label_content: Map.get(assigns, :label_content),
      inner_block: Map.get(assigns, :inner_block, []),
      description_id: description_id(assigns)
    )
  end

  defp description_id(assigns) do
    with true <- Field.present?(Map.get(assigns, :description)),
         id when is_binary(id) <- label_id(assigns) do
      "#{id}-description"
    else
      _ -> nil
    end
  end

  defp label_id(assigns) do
    case Map.get(assigns, :for) do
      value when is_binary(value) and value != "" ->
        value

      _ ->
        case Field.rest_attr(Map.get(assigns, :rest, %{}), :id) do
          value when is_binary(value) and value != "" -> value
          _ -> nil
        end
    end
  end

  # Custom label content wins only when it renders something. An empty or
  # whitespace-only block falls back to `label`.
  defp content_or_label(content, label) when is_binary(content) do
    if String.trim(content) == "", do: label, else: content
  end

  defp content_or_label(nil, label), do: label
  defp content_or_label(content, _label), do: content
end
