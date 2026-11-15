defmodule FlintUI.Base.Popover do
  @moduledoc """
  An interactive surface anchored to a trigger. Unlike a tooltip, a popover can
  contain links, buttons, forms, and other focusable content, and it stays open
  until the user dismisses it or an application action closes it.

  Use a popover for menus, filters, account switchers, rich hints, and small
  forms. Use a tooltip for a short, non-interactive description, and a dialog for
  a task that needs the whole page.

  ## Examples

  Wrap the popover around the element that should trigger it. The first element
  in the default slot becomes the trigger:

      <FlintUI.popover>
        <FlintUI.button>Account</FlintUI.button>
        <:content>
          <FlintUI.button variant="ghost">Sign out</FlintUI.button>
        </:content>
      </FlintUI.popover>

  The hook needs a DOM id, so the component generates one when `id` is omitted.
  A generated id changes on every render while the `data-part` hooks do not, so
  pass `id` only when you need a stable handle — for example to target the
  popover with `open_popover/2` from a control inside its content. The content
  id is derived as `<id>-content`.

  Only the first element in the default slot becomes the trigger — wrap a group
  in one element when the popover should describe the group. The trigger keeps
  its own role and accessible name; the hook only adds the ARIA wiring described
  under `## Accessibility` below, so there are no attributes to spread.

  ## Positioning

  `placement` picks the preferred side (`bottom` by default, or `top`, `left`,
  and `right`) and `align` picks the alignment along that side (`start`,
  `center`, `end`). The content flips to the opposite side when the preferred one
  does not fit, and shifts along the trigger to stay inside the viewport.

  `offset` is the gap between the trigger and the content in pixels, and `arrow`
  toggles the pointing arrow.

  The content is rendered in the browser's top layer with the
  [Popover API](https://developer.mozilla.org/en-US/docs/Web/API/Popover_API),
  so an `overflow: hidden` ancestor, a transformed parent, or a sibling with a
  high `z-index` cannot clip or cover it.

  ## Portal

  Set `portal` to move the content into another part of the DOM with
  [`Phoenix.Component.portal/1`](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#portal/1).
  The target defaults to `body` and can be changed with `portal_target`, which is
  a CSS selector that identifies a unique target element.

  Portalling keeps the content next to the document root for consumers whose
  layout would otherwise affect it, but the trade-off is inheritance: CSS custom
  properties set on the popover root, including the public `--fl-popover-*`
  variables, do not reach portalled content. Set those variables on
  `[data-part="content"][data-popover-content]` instead. Keep the default when
  you can — the content stays a normal child of the root, so LiveView patches it
  like any other element.

  ## Delays

  A popover opens on click and on `Enter`/`Space` immediately. To also open it on
  hover, set `open_on_hover`; `open_delay` is then how long the pointer must rest
  on the trigger before it opens, and `close_delay` is how long it stays open
  after the pointer leaves. A click on a hover-opened popover pins it open and
  moves focus into the content.

  `dismissible` defaults to `true`. When it is `false`, clicking outside and
  pressing `Escape` do not close the popover. Use
  `close_popover/2` or set `opened` to `false` from the server to close it.

  ## Controlled state

  `opened` is the initial open state and remains a server-driven input: changing
  it after mount opens or closes the popover. User opens and closes are
  client-side until the server renders a different value, so set `open_event`,
  `close_event`, or `toggle_event` to push the new state to the server. The
  payload is a map with the popover's `id` and `open` state. Pass a stable `id`
  when you handle those events, since a generated id changes on every render.

  Use `open_popover/2`, `close_popover/2`, and `toggle_popover/2` to drive the
  component from a `Phoenix.LiveView.JS` command.

  ## Accessibility

  The content carries `role="dialog"`. For a modal popover, it also carries
  `aria-modal="true"`, every outside element on the content's ancestor path is
  made `inert`, and focus is trapped inside the content. Non-modal popovers leave
  the rest of the page interactive.

  The hook names the dialog after its trigger: it gives the trigger a DOM id when
  it has none and points the content's `aria-labelledby` at it. Pass `aria_label`
  (or `aria_labelledby` pointing at a heading inside the content) when the
  trigger's name is not a good dialog name. The trigger receives
  `aria-haspopup="dialog"`, `aria-expanded`, and `aria-controls` pointing at the
  content.

  Opening with a click, `Enter`, `Space`, or a JS command moves focus to the
  first focusable element in the content, or to the content itself when it has
  none. Closing with `Escape` or a JS command returns focus to the trigger;
  clicking outside does not steal focus from the element that was clicked.

  While closed, the content is `display: none` (a closed popover), so it is
  neither exposed nor focusable.

  The popover follows the
  [WAI-ARIA dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/).
  A toolbar or menu with roving focus inside a popover needs its own keyboard
  behaviour; this component provides the surface, not the collection.

  ## Keyboard

  - `Enter` - opens or closes the popover when the trigger is focused.
  - `Space` - opens or closes the popover when the trigger is focused.
  - `Escape` - closes the popover and returns focus to the trigger, unless
    `dismissible` is `false`.
  - `Tab` / `Shift+Tab` - moves focus through the content. In a modal popover,
    focus wraps inside the content.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :popover,
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
          value: "FlintUI.Popover",
          description: "The JS hook that positions, focuses, and dismisses the popover."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "popover",
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
          name: "[data-opened]",
          value: ~s("true" | "false"),
          description:
            "The server-driven open input. The hook applies it on mount and whenever the value changes."
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
          description: "Gap between the trigger and the content, in pixels."
        },
        %Meta.PartAttr{
          name: "[data-open-delay]",
          value: "number",
          description: "Hover delay before the popover opens, in milliseconds."
        },
        %Meta.PartAttr{
          name: "[data-close-delay]",
          value: "number",
          description: "Hover delay before the popover closes, in milliseconds."
        },
        %Meta.PartAttr{
          name: "[data-open-on-hover]",
          value: "boolean",
          description: "Present when the popover may open on hover."
        },
        %Meta.PartAttr{
          name: "[data-dismissible]",
          value: "boolean",
          description: "Present when outside clicks and `Escape` close the popover."
        },
        %Meta.PartAttr{
          name: "[data-modal]",
          value: "boolean",
          description: "Present when the popover isolates outside content."
        },
        %Meta.PartAttr{
          name: "[data-portal]",
          value: "boolean",
          description: "Present when the content is rendered through a Phoenix portal."
        },
        %Meta.PartAttr{
          name: "[data-open-event]",
          value: "string",
          description: "Server event pushed when the popover opens."
        },
        %Meta.PartAttr{
          name: "[data-close-event]",
          value: "string",
          description: "Server event pushed when the popover closes."
        },
        %Meta.PartAttr{
          name: "[data-toggle-event]",
          value: "string",
          description: "Server event pushed on every open or close."
        }
      ],
      trigger: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "Applied by the hook when the trigger has none. The content uses it as its accessible name."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description:
            "Applied by the hook to the first element in the default slot, identifying it as the trigger."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, applied by the hook."
        },
        %Meta.PartAttr{
          name: "aria-haspopup",
          value: "dialog",
          description: "Tells assistive technology that the trigger opens a dialog."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the popover content is open."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the content element, applied by the hook."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Content element ID (derived from the root id)."
        },
        %Meta.PartAttr{
          name: "role",
          value: "dialog",
          description: "The dialog role."
        },
        %Meta.PartAttr{
          name: "aria-modal",
          value: "true",
          description: "Present when `modal` is set."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "An explicit accessible name from the `aria_label` attribute."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description:
            "An explicit accessible name from `aria_labelledby`, or the trigger id published by the hook."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description: "Lets the content receive focus when it contains no focusable element."
        },
        %Meta.PartAttr{
          name: "popover",
          value: "manual",
          description:
            "Renders the content in the top layer; the hook shows and hides it explicitly."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the content element."
        },
        %Meta.PartAttr{
          name: "[data-popover-content]",
          value: "boolean",
          description:
            "Presence hook for the content element. It survives portalling, where a root-scoped selector would not."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description:
            "Current open/closed state, managed by the hook. The content only joins the open state after it has been positioned."
        },
        %Meta.PartAttr{
          name: "[data-side]",
          value: ~s("top" | "bottom" | "left" | "right"),
          description:
            "The resolved side after collision handling, published by the hook. It can differ from `placement` when the content flips."
        },
        %Meta.PartAttr{
          name: "[data-align]",
          value: ~s("start" | "center" | "end"),
          description: "The resolved alignment after collision handling, published by the hook."
        },
        %Meta.PartAttr{
          name: "[data-modal]",
          value: "boolean",
          description: "Present when `modal` is set."
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
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Enter",
        description: "Opens or closes the popover when the trigger is focused."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Opens or closes the popover when the trigger is focused."
      },
      %Meta.Keyboard{
        keys: "Escape",
        description:
          "Closes the popover and returns focus to the trigger, unless `dismissible` is `false`."
      },
      %Meta.Keyboard{
        keys: "Tab | Shift+Tab",
        description:
          "Moves focus through the content. In a modal popover, focus wraps inside the content."
      }
    ]
  end

  @impl true
  def css_vars do
    [
      %Meta.CSSVar{
        name: "--_fl-popover-arrow-x",
        description:
          "Runtime-only horizontal offset of the arrow along the content, in pixels, published by the hook."
      },
      %Meta.CSSVar{
        name: "--_fl-popover-arrow-y",
        description:
          "Runtime-only vertical offset of the arrow along the content, in pixels, published by the hook."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:popover:open",
        source: :client,
        doc:
          "Client command event that opens the popover. Dispatch it with `open_popover/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:popover:close",
        source: :client,
        doc:
          "Client command event that closes the popover. Dispatch it with `close_popover/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:popover:toggle",
        source: :client,
        doc:
          "Client command event that toggles the popover. Dispatch it with `toggle_popover/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:popover:change",
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
        description: "The popover is open.",
        selector: ~s([data-element="popover"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The popover is closed.",
        selector: ~s([data-element="popover"][data-state="closed"])
      },
      %Meta.State{
        name: "modal",
        description: "The popover isolates content outside the dialog.",
        selector: ~s([data-element="popover"][data-modal])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-popover")
    content_id = "#{id}-content"
    opened = if assigns.opened, do: "true", else: "false"
    state = if assigns.opened, do: "open", else: "closed"

    %{
      root: %{
        "id" => id,
        "phx-hook" => "FlintUI.Popover",
        "data-element" => "popover",
        "data-part" => "root",
        "data-state" => state,
        "data-opened" => opened,
        "data-placement" => assigns.placement,
        "data-align" => assigns.align,
        "data-offset" => to_string(assigns.offset),
        "data-open-delay" => to_string(assigns.open_delay),
        "data-close-delay" => to_string(assigns.close_delay),
        "data-open-on-hover" => assigns.open_on_hover,
        "data-dismissible" => assigns.dismissible,
        "data-modal" => assigns.modal,
        "data-portal" => assigns.portal,
        "data-open-event" => assigns.open_event,
        "data-close-event" => assigns.close_event,
        "data-toggle-event" => assigns.toggle_event
      },
      content: %{
        "id" => content_id,
        "role" => "dialog",
        "aria-modal" => if(assigns.modal, do: "true", else: nil),
        "aria-label" => assigns.aria_label,
        "aria-labelledby" => assigns.aria_labelledby,
        "tabindex" => "-1",
        "popover" => "manual",
        "data-part" => "content",
        "data-popover-content" => true,
        "data-state" => "closed",
        "data-side" => assigns.placement,
        "data-align" => assigns.align,
        "data-modal" => assigns.modal
      },
      arrow: %{
        "data-part" => "arrow",
        "aria-hidden" => "true"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    default: nil,
    doc:
      "The DOM id. Generated when omitted; pass one only when you need a stable handle from your own CSS or JS, such as targeting the popover with `open_popover/2`."

  attr :placement, :string,
    default: "bottom",
    values: ~w(top bottom left right),
    doc:
      "Preferred side of the trigger. The content flips to the opposite side when it does not fit."

  attr :align, :string,
    default: "center",
    values: ~w(start center end),
    doc: "Preferred alignment along the side. The content shifts to stay inside the viewport."

  attr :offset, :integer,
    default: 8,
    doc: "Gap between the trigger and the content, in pixels."

  attr :arrow, :boolean,
    default: false,
    doc: "Whether to render the arrow pointing at the trigger."

  attr :portal, :boolean,
    default: false,
    doc:
      "Whether to render the content through a Phoenix portal. The content leaves the root's DOM subtree, so its CSS variables no longer inherit from the root."

  attr :portal_target, :string,
    default: "body",
    doc:
      "The CSS selector of the portal target. It must identify a unique element. Used when `portal` is set."

  attr :opened, :boolean,
    default: false,
    doc:
      "The initial open state. Changing it after mount opens or closes the popover, so the server can drive it too."

  attr :dismissible, :boolean,
    default: true,
    doc:
      "Whether clicking outside or pressing `Escape` closes the popover. Set it to `false` to require an explicit close."

  attr :modal, :boolean,
    default: false,
    doc:
      "Whether the popover is modal. A modal popover makes outside content inert, hides it from assistive technology, and traps focus inside the content."

  attr :open_on_hover, :boolean,
    default: false,
    doc:
      "Whether the popover may open on hover. When `false`, it opens only on click, `Enter`, `Space`, or a JS command."

  attr :open_delay, :integer,
    default: 0,
    doc: "Hover delay before the popover opens, in milliseconds. Requires `open_on_hover`."

  attr :close_delay, :integer,
    default: 0,
    doc: "Hover delay before the popover closes, in milliseconds. Requires `open_on_hover`."

  attr :open_event, :string,
    default: nil,
    doc:
      "The server event pushed when the popover opens. The payload is a map with `id` and `open`."

  attr :close_event, :string,
    default: nil,
    doc:
      "The server event pushed when the popover closes. The payload is a map with `id` and `open`."

  attr :toggle_event, :string,
    default: nil,
    doc:
      "The server event pushed on every open or close. The payload is a map with `id` and `open`."

  attr :aria_label, :string,
    default: nil,
    doc:
      "An accessible name for the dialog content, applied as `aria-label`. Use it when the trigger's name is not a good dialog name. The hook otherwise labels the content with the trigger's name."

  attr :aria_labelledby, :string,
    default: nil,
    doc:
      "The DOM id of an element inside the content that names the dialog, applied as `aria-labelledby`. Takes precedence over the hook's trigger-based label."

  attr :as, :string,
    default: "div",
    doc: "The HTML element to render the root as."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block,
    required: true,
    doc:
      "The trigger. The first element in the slot becomes the trigger; the hook marks it and wires its ARIA state."

  slot :content, required: true, doc: "The popover content."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
      <%= if @portal do %>
        <.portal
          id={@flint_parts[:root]["id"] <> "-portal"}
          target={@portal_target}
        >
          <div {@flint_parts[:content]}>
            <span :if={@arrow} {@flint_parts[:arrow]}></span>
            {render_slot(@content)}
          </div>
        </.portal>
      <% else %>
        <div {@flint_parts[:content]}>
          <span :if={@arrow} {@flint_parts[:arrow]}></span>
          {render_slot(@content)}
        </div>
      <% end %>
    </.dynamic_tag>
    """
  end

  ## JS Helpers

  def open_popover(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:popover:open", to: "##{id}")
  end

  def close_popover(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:popover:close", to: "##{id}")
  end

  def toggle_popover(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:popover:toggle", to: "##{id}")
  end
end
