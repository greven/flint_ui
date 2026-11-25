defmodule FlintUI.Base.Dropdown do
  @moduledoc """
  A menu of actions or links anchored to a trigger.

  Use a dropdown for a compact list of commands, links, and grouped actions. The
  trigger stays in place and the menu is rendered in the browser's top layer, so
  an `overflow: hidden` ancestor cannot clip it and a sibling's `z-index` cannot
  cover it.

  ## Examples

  `label` renders the default trigger. The default slot is the menu content:

      <FlintUI.dropdown label="Actions">
        <FlintUI.dropdown_header>Account</FlintUI.dropdown_header>
        <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        <FlintUI.dropdown_item navigate="/account">Account</FlintUI.dropdown_item>
        <FlintUI.dropdown_separator />
        <FlintUI.dropdown_group aria-label="Session">
          <FlintUI.dropdown_item intent="danger">Log out</FlintUI.dropdown_item>
        </FlintUI.dropdown_group>
      </FlintUI.dropdown>

  Pass a `:trigger` slot for a custom trigger. The slot receives the attributes
  to spread onto the element, like `FlintUI.collapsible/1`:

      <FlintUI.dropdown>
        <:trigger :let={attrs}>
          <FlintUI.button {attrs}>Actions</FlintUI.button>
        </:trigger>
        <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
      </FlintUI.dropdown>

  The default trigger is a native `<button>`. A custom trigger should also be a
  button; the hook marks it as the trigger and mirrors the open state onto it.

  ## Positioning

  `placement` picks the preferred side (`bottom` by default) and `align` picks
  the alignment along that side (`start` by default). The menu flips to the
  opposite side when it does not fit and shifts to stay inside the viewport.
  `offset` is the gap between the trigger and the menu in pixels, and `arrow`
  adds a pointing arrow.

  `max_height` caps the menu height in pixels and makes the content scroll when
  it is taller than the cap. Leave it unset to let the menu grow with its
  content.

  ## Submenus

  Declare submenu content in a `:submenu` slot with an `id`, then point a
  `dropdown_sub` at it with `menu`:

      <FlintUI.dropdown label="Actions">
        <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        <:submenu id="more">
          <FlintUI.dropdown_item>Documentation</FlintUI.dropdown_item>
          <FlintUI.dropdown_item>Changelog</FlintUI.dropdown_item>
        </:submenu>
        <FlintUI.dropdown_sub menu="more">More</FlintUI.dropdown_sub>
      </FlintUI.dropdown>

  A submenu opens to the right of its trigger and flips left when it does not
  fit. The root menu closes its open submenu when focus or the pointer leaves,
  and `Escape` closes one level at a time. Set `open_on_hover` on a
  `dropdown_sub` to open that submenu when the pointer rests on it.

  ## Hover

  Menus open on click, `Enter`, `Space`, and `ArrowDown`. Set `open_on_hover` to
  also open on hover; `open_delay` is how long the pointer must rest on the
  trigger, and `close_delay` is how long the menu stays open after the pointer
  leaves. Hover opening never moves focus. A click pins the menu open and moves
  focus into it.

  Submenus take their own `open_on_hover`; a hovered submenu shares the
  dropdown's `open_delay`.

  ## Accessibility

  The trigger carries `aria-haspopup="menu"`, `aria-expanded`, and
  `aria-controls`. The content is a `role="menu"` labelled by the trigger.
  Items are `role="menuitem"`, groups are `role="group"`, headers are
  presentational, and separators keep the `separator` role.

  Only one item is in the tab sequence at a time; the arrow keys move focus
  between enabled items. Disabled items are skipped. `custom` items are
  non-interactive content blocks: they carry no menu role and no menu item
  layout, so they can hold a footer or other arbitrary content.

  A pointer click focuses the menu surface, so no item looks selected until you
  move with the arrow keys. Opening from the keyboard focuses the first item
  (or the last, with `ArrowUp`) and keeps the trigger's focus ring while the
  menu is open, so the control that owns the menu stays visible. The active
  item is marked with a fill, not a focus ring.

  Selecting an item closes the menu and returns focus to the trigger. Links keep
  their link behavior: `Enter` follows the link, and `Space` does not.

  The dropdown follows the
  [WAI-ARIA menu button pattern](https://www.w3.org/WAI/ARIA/apg/patterns/menubar/).
  It is a menu, not a navigation bar or a toolbar; put long-lived site
  navigation in a navigation landmark instead.

  ## Keyboard

  - `Enter` / `Space` - opens the menu and focuses the first item, or closes the
    open menu when the trigger is focused.
  - `ArrowDown` / `ArrowUp` - opens the menu and focuses the first or last item
    when the trigger is focused; moves through enabled items when the menu is
    open.
  - `Home` / `End` - moves focus to the first or last enabled item.
  - `ArrowRight` - opens the submenu of a focused submenu trigger.
  - `ArrowLeft` - closes an open submenu and returns focus to its trigger.
  - `Escape` - closes the open submenu, or the menu, and returns focus to the
    trigger that opened it.
  - `Tab` - closes the menu and lets focus leave.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :dropdown,
      type: :overlay,
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
          value: "FlintUI.Dropdown",
          description: "The JS hook that positions the menu, manages focus, and dismisses it."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "dropdown",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, managed by the hook."
        },
        %Meta.PartAttr{
          name: "[data-placement]",
          value: ~s("top" | "bottom" | "left" | "right"),
          description: "Preferred side of the trigger, from the `placement` attribute."
        },
        %Meta.PartAttr{
          name: "[data-align]",
          value: ~s("start" | "center" | "end"),
          description: "Preferred alignment along the side, from the `align` attribute."
        },
        %Meta.PartAttr{
          name: "[data-offset]",
          value: "number",
          description: "Gap between the trigger and the menu, in pixels."
        },
        %Meta.PartAttr{
          name: "[data-open-on-hover]",
          value: "boolean",
          description: "Present when the menu may open on hover."
        },
        %Meta.PartAttr{
          name: "[data-open-delay]",
          value: "number",
          description: "Hover delay before the menu opens, in milliseconds."
        },
        %Meta.PartAttr{
          name: "[data-close-delay]",
          value: "number",
          description: "Hover delay before the menu closes, in milliseconds."
        }
      ],
      trigger: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "Derived from the root id. The hook points the menu's `aria-labelledby` at it."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the default trigger from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description: "Identifies the trigger element."
        },
        %Meta.PartAttr{
          name: "[data-dropdown-trigger]",
          value: "boolean",
          description:
            "Present on the default trigger. Use it to style the built-in trigger without touching a custom one."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, applied by the hook."
        },
        %Meta.PartAttr{
          name: "[data-focus-ring]",
          value: "boolean",
          description:
            "Present while the menu is open after a keyboard open. The trigger keeps its focus ring after focus moves into the menu."
        },
        %Meta.PartAttr{
          name: "aria-haspopup",
          value: "menu",
          description: "Tells assistive technology that the trigger opens a menu."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the menu is open."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the menu content, applied by the hook."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "indicator",
          description: "The default trigger's trailing chevron. Hidden from assistive technology."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The chevron is decorative."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Menu element ID, derived from the root id."
        },
        %Meta.PartAttr{
          name: "role",
          value: "menu",
          description: "Exposes the menu collection role."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description: "The trigger ID, so the menu borrows the trigger's accessible name."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description: "Lets the menu receive focus when it has no enabled item."
        },
        %Meta.PartAttr{
          name: "popover",
          value: "manual",
          description:
            "Renders the menu in the top layer; the hook shows and hides it explicitly."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the menu element."
        },
        %Meta.PartAttr{
          name: "[data-dropdown-content]",
          value: "boolean",
          description: "Presence hook for the menu element, used by the styled layer."
        },
        %Meta.PartAttr{
          name: "[data-elevation]",
          value: "boolean",
          description: "Presence hook that applies the shared raised-surface trim and elevation."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description:
            "Current open/closed state, managed by the hook. The menu joins the open state only after it has been positioned."
        },
        %Meta.PartAttr{
          name: "[data-side]",
          value: ~s("top" | "bottom" | "left" | "right"),
          description:
            "The resolved side after collision handling, published by the hook. It can differ from `placement` when the menu flips."
        },
        %Meta.PartAttr{
          name: "[data-align]",
          value: ~s("start" | "center" | "end"),
          description: "The resolved alignment after collision handling, published by the hook."
        }
      ],
      arrow: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "arrow",
          description: "Identifies the arrow element. Rendered only when `arrow` is set."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The arrow is decorative."
        }
      ],
      list: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "list",
          description:
            "The scrollable list inside the menu surface. `max_height` caps its height, so the arrow stays outside the scroll area."
        }
      ],
      submenu: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The submenu DOM id, from the `:submenu` slot."
        },
        %Meta.PartAttr{
          name: "role",
          value: "menu",
          description: "Exposes the nested menu collection role."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description: "The ID of the `dropdown_sub` trigger that opened the submenu."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description: "Lets the submenu receive focus when it has no enabled item."
        },
        %Meta.PartAttr{
          name: "popover",
          value: "manual",
          description: "Renders the submenu in the top layer."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "submenu",
          description: "Identifies a nested menu element."
        },
        %Meta.PartAttr{
          name: "[data-dropdown-submenu]",
          value: "boolean",
          description: "Presence hook for a nested menu, used by the styled layer."
        },
        %Meta.PartAttr{
          name: "[data-elevation]",
          value: "boolean",
          description: "Presence hook that applies the shared raised-surface trim and elevation."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state of the submenu, managed by the hook."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Enter / Space",
        description:
          "Opens the menu and focuses the first item, or closes the open menu when the trigger is focused."
      },
      %Meta.Keyboard{
        keys: "ArrowDown / ArrowUp",
        description:
          "Opens the menu and focuses the first or last item when the trigger is focused; moves through enabled items when the menu is open."
      },
      %Meta.Keyboard{
        keys: "Home / End",
        description: "Moves focus to the first or last enabled item."
      },
      %Meta.Keyboard{
        keys: "ArrowRight",
        description: "Opens the submenu of a focused submenu trigger."
      },
      %Meta.Keyboard{
        keys: "ArrowLeft",
        description: "Closes an open submenu and returns focus to its trigger."
      },
      %Meta.Keyboard{
        keys: "Escape",
        description:
          "Closes the open submenu, or the menu, and returns focus to the trigger that opened it."
      },
      %Meta.Keyboard{
        keys: "Tab",
        description: "Closes the menu and lets focus leave."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:dropdown:open",
        source: :client,
        doc:
          "Client command event that opens the dropdown. Dispatch it with `open_dropdown/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:dropdown:close",
        source: :client,
        doc:
          "Client command event that closes the dropdown. Dispatch it with `close_dropdown/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:dropdown:toggle",
        source: :client,
        doc:
          "Client command event that toggles the dropdown. Dispatch it with `toggle_dropdown/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:dropdown:change",
        source: :client,
        doc:
          "Dispatched on the root whenever the open state changes. Bubbles up the DOM. The event `detail` is a map with a `state` key (`\"open\"` or `\"closed\"`)."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The dropdown is open.",
        selector: ~s([data-element="dropdown"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The dropdown is closed.",
        selector: ~s([data-element="dropdown"][data-state="closed"])
      },
      %Meta.State{
        name: "submenu-open",
        description: "A submenu is open.",
        selector: ~s([data-element="dropdown"] [data-part="submenu"][data-state="open"])
      },
      %Meta.State{
        name: "keyboard",
        description:
          "The trigger keeps its focus ring because the open menu was activated from the keyboard.",
        selector: ~s([data-element="dropdown"] > [data-part="trigger"][data-focus-ring])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-dropdown")
    trigger_id = "#{id}-trigger"
    content_id = "#{id}-content"

    %{
      root: %{
        "id" => id,
        "phx-hook" => "FlintUI.Dropdown",
        "data-element" => "dropdown",
        "data-part" => "root",
        "data-state" => "closed",
        "data-placement" => assigns.placement,
        "data-align" => assigns.align,
        "data-offset" => to_string(assigns.offset),
        "data-open-on-hover" => assigns.open_on_hover,
        "data-open-delay" => to_string(assigns.open_delay),
        "data-close-delay" => to_string(assigns.close_delay)
      },
      trigger: %{
        "id" => trigger_id,
        "type" => "button",
        "data-part" => "trigger",
        "data-state" => "closed",
        "aria-haspopup" => "menu",
        "aria-expanded" => "false",
        "aria-controls" => content_id
      },
      content: %{
        "id" => content_id,
        "role" => "menu",
        "aria-labelledby" => trigger_id,
        "tabindex" => "-1",
        "popover" => "manual",
        "data-part" => "content",
        "data-dropdown-content" => true,
        "data-elevation" => true,
        "data-state" => "closed",
        "data-side" => assigns.placement,
        "data-align" => assigns.align
      },
      list: %{
        "data-part" => "list",
        "style" => max_height_style(assigns.max_height)
      },
      submenu: %{
        "role" => "menu",
        "tabindex" => "-1",
        "popover" => "manual",
        "data-part" => "submenu",
        "data-dropdown-submenu" => true,
        "data-elevation" => true,
        "data-state" => "closed"
      },
      arrow: %{
        "data-part" => "arrow",
        "aria-hidden" => "true"
      }
    }
  end

  defp max_height_style(nil), do: nil
  defp max_height_style(height), do: "--fl-dropdown-max-height: #{height}px"

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    default: nil,
    doc:
      "The DOM id. Generated when omitted; pass one only when you need a stable handle from your own CSS or JS, such as targeting the dropdown with `open_dropdown/2`."

  attr :label, :string,
    default: nil,
    doc:
      "The text of the default trigger. Ignored when the `:trigger` slot is given. Provide one of the two so the trigger has an accessible name."

  attr :placement, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc:
      "Preferred side of the trigger. The menu flips to the opposite side when it does not fit."

  attr :align, :string,
    default: "start",
    values: ~w(start center end),
    doc:
      "Preferred alignment along the side. The menu shifts to stay inside the viewport. Menus default to `start` so items line up with the trigger."

  attr :offset, :integer,
    default: 4,
    doc: "Gap between the trigger and the menu, in pixels."

  attr :arrow, :boolean,
    default: false,
    doc: "Whether to render the arrow pointing at the trigger."

  attr :max_height, :integer,
    default: nil,
    doc:
      "Maximum height of the menu in pixels. The menu scrolls when its content is taller. Leave it unset to let the menu grow with its content."

  attr :open_on_hover, :boolean,
    default: false,
    doc:
      "Whether the menu may open on hover. When `false`, it opens only on click, `Enter`, `Space`, `ArrowDown`, `ArrowUp`, or a JS command."

  attr :open_delay, :integer,
    default: 0,
    doc: "Hover delay before the menu opens, in milliseconds. Requires `open_on_hover`."

  attr :close_delay, :integer,
    default: 0,
    doc: "Hover delay before the menu closes, in milliseconds. Requires `open_on_hover`."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block,
    required: true,
    doc: "The menu content: items, groups, headers, and separators."

  slot :trigger,
    doc:
      "A custom trigger. Render a button and spread the provided attributes onto it. Overrides `label`."

  slot :submenu,
    doc:
      "A submenu linked by id. Point a `DropdownSub` at it with `menu`, and render its items in this slot." do
    attr :id, :string,
      required: true,
      doc: "The DOM id the matching `DropdownSub` references with `menu`."
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      <%= if @trigger == [] do %>
        <button data-dropdown-trigger {@flint_parts[:trigger]}>
          {@label}
          <span data-part="indicator" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" focusable="false">
              <path
                d="m6 9 6 6 6-6"
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
              />
            </svg>
          </span>
        </button>
      <% else %>
        {render_slot(@trigger, @flint_parts[:trigger])}
      <% end %>

      <div {@flint_parts[:content]}>
        <span :if={@arrow} {@flint_parts[:arrow]}></span>
        <div {@flint_parts[:list]}>{render_slot(@inner_block)}</div>
      </div>

      <div
        :for={submenu <- @submenu}
        id={submenu.id}
        aria-labelledby={"#{submenu.id}-trigger"}
        {@flint_parts[:submenu]}
      >
        <div {@flint_parts[:list]}>{render_slot(submenu)}</div>
      </div>
    </div>
    """
  end

  ## JS Helpers

  @doc """
  Opens the dropdown from a `Phoenix.LiveView.JS` command.

  The command targets the dropdown root:

      <button phx-click={FlintUI.open_dropdown("account-menu")}>Open</button>
  """
  def open_dropdown(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:dropdown:open", to: "##{id}")
  end

  @doc """
  Closes the dropdown from a `Phoenix.LiveView.JS` command.
  """
  def close_dropdown(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:dropdown:close", to: "##{id}")
  end

  @doc """
  Toggles the dropdown from a `Phoenix.LiveView.JS` command.
  """
  def toggle_dropdown(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:dropdown:toggle", to: "##{id}")
  end
end
