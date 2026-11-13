defmodule FlintUI.Base.AccordionItem do
  @moduledoc """
  A single collapsible section inside an accordion.

  Use it inside `FlintUI.accordion/1`; the accordion coordinates single mode,
  keyboard focus, and the "at least one open" guard. The item reuses the
  collapsible behavior, so its open state, animation, and ARIA wiring match
  `FlintUI.collapsible/1`.

      <FlintUI.accordion id="faq">
        <FlintUI.accordion_item id="faq-shipping" label="Shipping" expanded>
          <:panel>Orders leave the warehouse in one business day.</:panel>
        </FlintUI.accordion_item>
      </FlintUI.accordion>

  Set `heading` to the surrounding heading level, or to `"none"` to omit the
  heading wrapper. The heading has no visual effect; it only supplies the
  semantic level. Give every item a stable `id`: it is the DOM id, the JS
  command target, and the base for the header and panel ids.

  ## Accessibility

  The header is a native `<button>` inside an `h2`–`h6` unless `heading` is
  `"none"`. The button carries `aria-expanded` and `aria-controls`; the panel is
  a `region` labelled by the header. A disabled item renders a native disabled
  button and its content stays in the DOM.

  The `:header` slot accepts arbitrary attributes and forwards them to the
  header button, so `phx-click`, `phx-value-*`, and custom `data-*` hooks work
  there. Its `class` is merged onto the button. Keep the header content
  non-interactive; the button itself is the control.

  The `:indicator` slot replaces the default chevron. An empty indicator slot
  renders no indicator. A custom indicator is not rotated automatically; target
  the item's `data-state` to drive its visuals.

  ## Keyboard

  - `Enter` / `Space` - toggles the focused header.
  - `ArrowDown` / `ArrowUp`, `Home` / `End` - provided by the parent accordion.
  """

  use FlintUI.Component

  alias FlintUI.Base.Collapsible

  @impl true
  def meta do
    %Meta{
      name: :accordion_item,
      type: :action,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Unique item DOM id."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: "FlintUI.Collapsible",
          description: "The collapsible hook that animates the panel and updates ARIA."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "accordion_item",
          description: "Identifies the item."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the item root."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-animate]",
          value: "boolean",
          description: "Present while the panel is animating."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the item is disabled."
        }
      ],
      heading: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "heading",
          description: "The heading wrapper around the trigger, omitted when `heading=\"none\"`."
        }
      ],
      header: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the item id; labels the panel."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the header from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description: "Identifies the header button."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the header is disabled."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the controlled panel."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the panel is expanded."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: "true | false",
          description: "Whether the header is disabled."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Native disabled state for a disabled item."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description: "The default chevron or a custom indicator wrapper."
        },
        %Meta.PartAttr{
          name: "[data-default]",
          value: "boolean",
          description: "Present on the default chevron, which rotates when open."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the item id; the panel the header controls."
        },
        %Meta.PartAttr{
          name: "role",
          value: "region",
          description: "Exposes the panel as a labelled region."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description: "The ID of the header button."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: "boolean",
          description: "Present while the panel is collapsed."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the animating panel wrapper."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the item is disabled."
        }
      ],
      panel: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "panel",
          description: "The padded panel body; the `:panel` slot class applies here."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{keys: "Enter", description: "Toggles the focused header."},
      %Meta.Keyboard{keys: "Space", description: "Toggles the focused header."}
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The item is expanded.",
        selector: ~s([data-element="accordion_item"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The item is collapsed.",
        selector: ~s([data-element="accordion_item"][data-state="closed"])
      },
      %Meta.State{
        name: "animating",
        description: "Applied while the panel is animating.",
        selector: ~s([data-element="accordion_item"][data-animate])
      },
      %Meta.State{
        name: "disabled",
        description: "The item is disabled.",
        selector: ~s([data-element="accordion_item"][data-disabled])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id

    collapsible =
      Collapsible.build_attrs(%{
        id: id,
        open: assigns.expanded,
        disabled: assigns.disabled,
        hidden_until_found: false,
        open_event: nil,
        close_event: nil,
        toggle_event: nil
      })

    {header_class, header_attrs} = pop_attrs(List.first(assigns.header))
    {indicator_class, indicator_attrs} = pop_attrs(List.first(assigns.indicator))
    {panel_class, _panel_attrs} = pop_attrs(List.first(assigns.panel))

    root =
      collapsible.root
      |> Map.merge(%{"data-element" => "accordion_item", "data-part" => "root"})

    header =
      header_attrs
      |> Map.merge(collapsible.trigger)
      |> Map.put("id", "#{id}-header")
      |> put_class(header_class)

    content =
      Map.merge(collapsible.content, %{
        "role" => "region",
        "aria-labelledby" => "#{id}-header"
      })

    indicator =
      indicator_attrs
      |> Map.merge(%{"data-part" => "indicator", "aria-hidden" => "true"})
      |> put_class(indicator_class)

    panel =
      %{"data-part" => "panel"}
      |> put_class(panel_class)

    %{
      root: root,
      heading: %{"data-part" => "heading"},
      header: header,
      indicator: indicator,
      content: content,
      panel: panel
    }
  end

  defp pop_attrs(nil), do: {nil, %{}}

  defp pop_attrs(slot) when is_map(slot) do
    class = Map.get(slot, :class) || Map.get(slot, "class")
    attrs = Map.drop(slot, [:inner_block, :__slot__, :class, "class"])
    {class, attrs}
  end

  defp put_class(attrs, nil), do: attrs
  defp put_class(attrs, class), do: Map.put(attrs, "class", class)

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string, required: true, doc: "Unique item DOM id."

  attr :label, :string,
    default: nil,
    doc: "Header text used when no `:header` slot is given."

  attr :expanded, :boolean,
    default: false,
    doc:
      "The server-rendered open state. Bind it to an assign to make the server the source of truth."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the item is disabled and skipped by keyboard navigation."

  attr :heading, :string,
    default: "h3",
    values: ~w(h2 h3 h4 h5 h6 none),
    doc:
      "The heading level wrapped around the trigger, or `none` to omit the heading wrapper. Has no visual effect."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :header,
    validate_attrs: false,
    doc:
      "Custom header content. Overrides `label` when set. Attributes other than `class` are forwarded to the header button, so `phx-click` and `phx-value-*` work there; `class` is merged onto the button. The button's `id` and ARIA attributes are managed by the item."

  slot :indicator,
    validate_attrs: false,
    doc:
      "A custom indicator. Omit it for the default chevron; pass an empty slot to render no indicator. Attributes are applied to the indicator wrapper. The wrapper is decorative and carries `aria-hidden`."

  slot :panel, required: true, doc: "The collapsible panel content." do
    attr :class, :any, doc: "Additional classes merged onto the padded panel body."
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      <%= if @heading == "none" do %>
        {header_button(assigns)}
      <% else %>
        <.dynamic_tag tag_name={@heading} {@flint_parts[:heading]}>
          {header_button(assigns)}
        </.dynamic_tag>
      <% end %>
      <div {@flint_parts[:content]}>
        <div {@flint_parts[:panel]}>{render_slot(@panel)}</div>
      </div>
    </div>
    """
  end

  defp header_button(assigns) do
    ~H"""
    <button {@flint_parts[:header]}>
      <span data-part="header">
        <%= if @header != [] do %>
          {render_slot(@header)}
        <% else %>
          {@label}
        <% end %>
      </span>
      <%= if @indicator == [] do %>
        <svg
          data-part="indicator"
          data-default
          viewBox="0 0 24 24"
          fill="none"
          aria-hidden="true"
          focusable="false"
        >
          <path
            d="m6 9 6 6 6-6"
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
          />
        </svg>
      <% else %>
        <% indicator = render_slot(@indicator) %>
        <%= if present?(indicator) do %>
          <span {@flint_parts[:indicator]}>{indicator}</span>
        <% end %>
      <% end %>
    </button>
    """
  end

  defp present?(nil), do: false

  defp present?(rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.trim() != ""
  end
end
