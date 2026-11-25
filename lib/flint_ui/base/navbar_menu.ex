defmodule FlintUI.Base.NavbarMenu do
  @moduledoc """
  A navbar item that reveals a menu of links.

  The trigger is a native button marked with `aria-expanded` and
  `aria-controls`, and the menu is a nested list of ordinary links:

      <FlintUI.navbar label="Primary">
        <FlintUI.navbar_item navigate="/">Home</FlintUI.navbar_item>
        <FlintUI.navbar_menu label="Products" icon="lucide-box">
          <FlintUI.navbar_menu_item navigate="/products/overview">
            Overview
          </FlintUI.navbar_menu_item>
          <FlintUI.navbar_menu_item navigate="/products/pricing">
            Pricing
          </FlintUI.navbar_menu_item>
        </FlintUI.navbar_menu>
      </FlintUI.navbar>

  The disclosure pattern is deliberate. Site navigation is a list of links, not
  an application menu, so the links keep their native semantics and the keyboard
  model is `Tab`/`Enter`/`Escape` rather than roving focus.

  `open` is the server-rendered state. Bind it to an assign when you want the
  server to control the menu, or leave it unset and let the browser toggle it.

  The panel is a `popover="manual"` element, so the browser renders it in the
  top layer beneath the trigger. It is not clipped by an `overflow` ancestor and
  does not compete with the page's stacking contexts.

  ## Accessibility

  The trigger is a button with `aria-expanded` and `aria-controls`. The menu is
  a `ul` inside a top-layer panel; it is hidden while closed and revealed above
  the page without moving the layout. Links inside the menu keep link semantics.

  `active` marks the menu's own page or section without changing `aria-current`
  on the trigger. Set `active` on the specific `navbar_menu_item` for the current
  page.

  ## Keyboard

  - `Enter` / `Space` - toggles the menu.
  - `Tab` - moves into and through the open menu's links.
  - `Escape` - closes the menu and returns focus to the trigger.
  """

  use FlintUI.Component

  alias FlintUI.Base.Collapsible

  @impl true
  def meta do
    %Meta{
      name: :navbar_menu,
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
          description: "The collapsible hook that toggles the menu and updates ARIA."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "navbar_menu",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the menu root."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-active]",
          value: "boolean",
          description: "Present when the menu's own page or section is current."
        }
      ],
      trigger: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the root id; labels the menu."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the trigger from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description: "Identifies the menu trigger."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the menu is open."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the menu content."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description: "The default chevron, or a custom indicator wrapper."
        },
        %Meta.PartAttr{
          name: "[data-default]",
          value: "boolean",
          description: "Present on the default chevron, which rotates when the menu is open."
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
          description: "Derived from the root id; the menu the trigger controls."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: "boolean",
          description: "Present while the menu is closed."
        },
        %Meta.PartAttr{
          name: "popover",
          value: "manual",
          description:
            "Renders the menu in the top layer; the navbar hook shows, hides, and positions it."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the menu panel."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        }
      ],
      list: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "list",
          description: "Identifies the unordered list that holds the menu links."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{keys: "Enter", description: "Toggles the menu."},
      %Meta.Keyboard{keys: "Space", description: "Toggles the menu."},
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves into and through the open menu's links."
      },
      %Meta.Keyboard{
        keys: "Escape",
        description: "Closes the menu and returns focus to the trigger."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The menu is expanded.",
        selector: ~s([data-element="navbar_menu"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The menu is collapsed.",
        selector: ~s([data-element="navbar_menu"][data-state="closed"])
      },
      %Meta.State{
        name: "active",
        description: "The menu's own page or section is current.",
        selector: ~s([data-element="navbar_menu"][data-active])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-navbar-menu")

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
        "data-element" => "navbar_menu",
        "data-part" => "root",
        "data-active" => assigns.active
      })

    trigger = Map.put(collapsible.trigger, "data-part", "trigger")

    content =
      collapsible.content
      |> Map.put("data-part", "content")
      |> Map.put("popover", "manual")

    indicator =
      %{"data-part" => "indicator", "aria-hidden" => "true"}
      |> Map.merge(indicator_attrs(Map.get(assigns, :indicator, [])))

    %{
      root: root,
      trigger: trigger,
      indicator: indicator,
      content: content,
      list: %{"data-part" => "list"}
    }
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

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    default: nil,
    doc: "Unique component DOM id. Generated when omitted."

  attr :label, :string,
    default: nil,
    doc:
      "The text of the trigger. Provide a label, or use the leading/trailing slots with an accessible name on the root."

  attr :open, :boolean,
    default: false,
    doc:
      "The server-rendered open state. Bind it to an assign to make the server the source of truth."

  attr :active, :boolean,
    default: false,
    doc:
      "Whether the menu's own page or section is current. Marks the trigger without setting `aria-current`."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The menu links: `navbar_menu_item` components."

  slot :leading,
    validate_attrs: false,
    doc: "Optional content rendered before the trigger label."

  slot :trailing,
    validate_attrs: false,
    doc: "Optional content rendered after the trigger label."

  slot :indicator,
    validate_attrs: false,
    doc:
      "A custom indicator. Omit it for the default chevron; pass an empty slot to render no indicator. Attributes are applied to the indicator wrapper. The wrapper is decorative and carries `aria-hidden`."

  @impl true
  def render(assigns) do
    ~H"""
    <li {@rest} {@flint_parts[:root]}>
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
end
