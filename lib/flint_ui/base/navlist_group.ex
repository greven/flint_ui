defmodule FlintUI.Base.NavlistGroup do
  @moduledoc """
  A labelled section of a `FlintUI.navlist`, with optional collapsible children.

  A group has a header and a nested list of `navlist_item` components:

      <FlintUI.navlist label="Documentation">
        <FlintUI.navlist_group label="Overview" icon="lucide-book-open">
          <FlintUI.navlist_item navigate="/docs">Introduction</FlintUI.navlist_item>
          <FlintUI.navlist_item navigate="/docs/install">Installation</FlintUI.navlist_item>
        </FlintUI.navlist_group>
      </FlintUI.navlist>

  Set `collapsible` (the default) for a group that opens and closes. Set
  `collapsible={false}` for a static section label whose items are always
  visible. That covers both the plain section headings and the expandable
  branches in a documentation sidebar.

  The styled layer draws a rail beside the nested list. It does not add a
  per-item arrow; the header keeps a default disclosure chevron, which the
  `:indicator` slot can replace or remove.

  ## Accessibility

  A collapsible header is a native button with `aria-expanded` and
  `aria-controls`; the nested list is the controlled region. A static header is
  a non-interactive element, so it adds no tab stop and no ARIA state.

  The group is a list item inside the navlist's `ul`, and its children form a
  nested `ul`, so the list structure and count stay available to assistive
  technology.

  ## Keyboard

  - `Enter` / `Space` - toggles a collapsible header.
  - `Tab` - moves through the header and the visible links.
  - A static header is not focusable.
  """

  use FlintUI.Component

  alias FlintUI.Base.Collapsible

  @impl true
  def meta do
    %Meta{
      name: :navlist_group,
      type: :navigation,
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
          description: "Unique component DOM id. Generated when `id` is omitted."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: "FlintUI.Collapsible",
          description: "The collapsible hook, present only when the group is collapsible."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "navlist_group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "group",
          description: "Identifies the group root."
        },
        %Meta.PartAttr{
          name: "[data-collapsible]",
          value: "boolean",
          description: "Present when the group can be opened and closed."
        },
        %Meta.PartAttr{
          name: "[data-static]",
          value: "boolean",
          description: "Present when the group is a static header that cannot be collapsed."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, present only on a collapsible group."
        }
      ],
      header: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header",
          description: "Identifies the non-interactive header of a static group."
        }
      ],
      trigger: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the root id; labels the nested list."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the header from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description: "Identifies the collapsible group header button."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the group is open."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the nested list's content wrapper."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description:
            "The default chevron, or a custom indicator wrapper. Rendered only on a collapsible group."
        },
        %Meta.PartAttr{
          name: "[data-default]",
          value: "boolean",
          description: "Present on the default chevron, which rotates when the group is open."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The indicator is decorative."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "Derived from the root id on a collapsible group; the element the header controls."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: "boolean",
          description: "Present while a collapsible group is closed."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the wrapper around the nested list."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, present only on a collapsible group."
        }
      ],
      list: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "list",
          description: "Identifies the nested unordered list of navlist items."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{keys: "Enter", description: "Toggles a collapsible group header."},
      %Meta.Keyboard{keys: "Space", description: "Toggles a collapsible group header."},
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves through the header and the visible links."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The collapsible group is expanded.",
        selector: ~s([data-element="navlist_group"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The collapsible group is collapsed.",
        selector: ~s([data-element="navlist_group"][data-state="closed"])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-navlist-group")

    if assigns.collapsible do
      collapsible =
        Collapsible.build_attrs(%{
          id: id,
          open: assigns.open,
          disabled: false,
          hidden_until_found: false,
          open_event: nil,
          close_event: nil,
          toggle_event: nil
        })

      root =
        collapsible.root
        |> Map.merge(%{
          "data-element" => "navlist_group",
          "data-part" => "group",
          "data-collapsible" => true
        })

      indicator =
        %{"data-part" => "indicator", "aria-hidden" => "true"}
        |> Map.merge(indicator_attrs(Map.get(assigns, :indicator, [])))

      %{
        root: root,
        trigger: Map.put(collapsible.trigger, "data-part", "trigger"),
        indicator: indicator,
        content: Map.put(collapsible.content, "data-part", "content"),
        list: %{"data-part" => "list"}
      }
    else
      %{
        root: %{
          "id" => id,
          "data-element" => "navlist_group",
          "data-part" => "group",
          "data-static" => true
        },
        header: %{"data-part" => "header"},
        content: %{"data-part" => "content"},
        list: %{"data-part" => "list"}
      }
    end
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    default: nil,
    doc: "Unique component DOM id. Generated when omitted."

  attr :label, :string,
    default: nil,
    doc:
      "The header text. Provide a label, or use the leading/trailing slots with an accessible name on the root."

  attr :collapsible, :boolean,
    default: true,
    doc:
      "Whether the group can be opened and closed. Set it to false for a static section header whose items are always visible."

  attr :open, :boolean,
    default: false,
    doc:
      "The server-rendered open state of a collapsible group. Ignored when `collapsible` is false."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The group links: `navlist_item` components."

  slot :leading,
    validate_attrs: false,
    doc: "Optional content rendered before the header label."

  slot :trailing,
    validate_attrs: false,
    doc: "Optional content rendered after the header label."

  slot :indicator,
    validate_attrs: false,
    doc:
      "A custom indicator. Omit it for the default chevron; pass an empty slot to render no indicator. Only rendered on a collapsible group. Attributes are applied to the indicator wrapper. The wrapper is decorative and carries `aria-hidden`."

  @impl true
  def render(assigns) do
    ~H"""
    <li {@rest} {@flint_parts[:root]}>
      <%= if @collapsible do %>
        <button {@flint_parts[:trigger]}>
          {render_slot(@leading)}
          {@label}
          {render_slot(@trailing)}
          <%= if @indicator == [] do %>
            <svg
              {@flint_parts[:indicator]}
              data-default
              viewBox="0 0 24 24"
              fill="none"
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
      <% else %>
        <div {@flint_parts[:header]}>
          {render_slot(@leading)}
          {@label}
          {render_slot(@trailing)}
        </div>
      <% end %>

      <div {@flint_parts[:content]}>
        <ul {@flint_parts[:list]}>{render_slot(@inner_block)}</ul>
      </div>
    </li>
    """
  end

  defp present?(nil), do: false

  defp present?(rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.trim() != ""
  end

  defp indicator_attrs(slots) do
    case List.first(slots) do
      nil ->
        %{}

      slot ->
        class = Map.get(slot, :class) || Map.get(slot, "class")

        slot
        |> Map.drop([:inner_block, :__slot__, :class, "class"])
        |> Map.new(fn {key, value} -> {to_string(key), value} end)
        |> then(fn attrs -> if class, do: Map.put(attrs, "class", class), else: attrs end)
    end
  end
end
