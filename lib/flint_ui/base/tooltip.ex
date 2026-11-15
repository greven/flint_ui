defmodule FlintUI.Base.Tooltip do
  @moduledoc """
  A short, non-interactive label that appears next to its trigger on hover or
  keyboard focus.

  Use a tooltip to name an icon-only control, clarify a truncated value, or add
  a one-line hint. A tooltip is a description, not a surface: it must not contain
  links, buttons, or anything else that takes focus. When the content needs to be
  interacted with, reached on touch devices, or kept open, use a popover instead.

  ## Examples

  Wrap the tooltip around the element that should trigger it. The first element
  in the default slot becomes the trigger:

      <FlintUI.tooltip text="Save changes">
        <button type="button">Save</button>
      </FlintUI.tooltip>

  The hook needs a DOM id, so the component generates one when `id` is omitted.
  A generated id changes on every render while the `data-part` hooks do not, so
  pass `id` only when you need a stable handle from your own CSS or JS.

  The trigger keeps its own role and accessible name; the hook only adds the
  wiring described under `## Accessibility` below, so there are no attributes to
  spread. Only the first element becomes the trigger — wrap a group in one
  element when the tooltip should describe the group.

  Rich content, such as a formatted hint or a keyboard shortcut, goes in the
  `:content` slot:

      <FlintUI.tooltip>
        <button type="button">Help</button>
        <:content>
          Hints are shown on hover and on <kbd>Tab</kbd> focus.
        </:content>
      </FlintUI.tooltip>

  When both are given, `text` wins over the `:content` slot.

  ## Positioning

  `placement` picks the preferred side (`top`, `right`, `bottom`, `left`) and
  `align` picks the alignment along that side (`start`, `center`, `end`). The
  content flips to the opposite side when the preferred one does not fit and
  shifts along the trigger to stay inside the viewport, so a tooltip at the edge
  of the page is still readable without extra configuration.

  `offset` is the gap between the trigger and the content in pixels, `delay` is
  how long the pointer must rest on the trigger before the tooltip appears
  (`0` opens immediately), and `arrow` adds the pointing arrow (off by
  default).

  The content is rendered in the browser's top layer with the
  [Popover API](https://developer.mozilla.org/en-US/docs/Web/API/Popover_API),
  so an `overflow: hidden` ancestor, a transformed parent, or a sibling with a
  high `z-index` cannot clip or cover it. It stays a normal child in the DOM, so
  LiveView patches it like any other element; if a patch replaces the content
  element, the tooltip resets to closed.

  ## Accessibility

  The content carries `role="tooltip"` and the trigger carries `aria-describedby`
  pointing at it, so a screen reader announces the hint as the trigger's
  description, not as part of its name. The hook owns that wiring: it marks the
  first element in the default slot with `data-part="trigger"`, appends the
  content id to any `aria-describedby` the trigger already has (a form hint
  pointing at a help text is kept), and mirrors the open and disabled states
  onto it. Because the wiring happens on mount, the markup ships without those
  attributes; the tooltip does not work without JS in the first place.

  While closed, the content is `display: none` (a closed popover), so it is
  neither exposed nor focusable.

  The tooltip follows the [WAI-ARIA tooltip pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/):
  it opens on hover and on keyboard focus, it never takes focus, and `Escape`
  dismisses it while focus stays on the trigger. Focus that follows a pointer
  press (for example clicking a button) does not open the tooltip, because a
  click is not a request for help.

  Tooltips are a pointer-device convenience and are unreliable on touch screens,
  where there is no hover and a tap should perform the action. Never rely on a
  tooltip for information that is required to use the page: put it in the UI, in
  a visible label, or in a popover that can be opened by tap. The hint is still
  available to touch screen readers through `aria-describedby`.

  ## Keyboard

  The trigger keeps its own keyboard behaviour; the tooltip adds no shortcut.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :tooltip,
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
          value: "FlintUI.Tooltip",
          description: "The JS hook that positions and reveals the tooltip."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "tooltip",
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
          description: "Gap between the trigger and the content, in pixels."
        },
        %Meta.PartAttr{
          name: "[data-delay]",
          value: "number",
          description: "Hover delay before the tooltip opens, in milliseconds."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when interactions are suppressed."
        }
      ],
      trigger: [
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
          name: "[data-disabled]",
          value: "boolean",
          description: "Applied by the hook while interactions are suppressed."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "The content ID, appended by the hook to any description the trigger already has. The hook removes only its own ID when `disabled` is set."
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
          value: "tooltip",
          description: "The tooltip role."
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
        keys: "Escape",
        description: "Closes the tooltip. Focus stays on the trigger."
      },
      %Meta.Keyboard{
        keys: "Tab | Shift+Tab",
        description: "Focusing the trigger opens the tooltip; leaving it closes the tooltip."
      }
    ]
  end

  @impl true
  def css_vars do
    [
      %Meta.CSSVar{
        name: "--_fl-tooltip-arrow-x",
        description:
          "Runtime-only horizontal offset of the arrow along the content, in pixels, published by the hook."
      },
      %Meta.CSSVar{
        name: "--_fl-tooltip-arrow-y",
        description:
          "Runtime-only vertical offset of the arrow along the content, in pixels, published by the hook."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:tooltip:open",
        source: :client,
        doc:
          "Dispatched on the root when the tooltip becomes visible. Bubbles up the DOM. Carries no payload."
      },
      %Meta.Event{
        name: "fl:tooltip:close",
        source: :client,
        doc:
          "Dispatched on the root when the tooltip is hidden. Bubbles up the DOM. Carries no payload."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The tooltip is visible.",
        selector: ~s([data-element="tooltip"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The tooltip is hidden.",
        selector: ~s([data-element="tooltip"][data-state="closed"])
      },
      %Meta.State{
        name: "disabled",
        description: "The tooltip is disabled.",
        selector: ~s([data-element="tooltip"][data-disabled])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-tooltip")
    content_id = "#{id}-content"

    %{
      root: %{
        "id" => id,
        "phx-hook" => "FlintUI.Tooltip",
        "data-element" => "tooltip",
        "data-part" => "root",
        "data-state" => "closed",
        "data-placement" => assigns.placement,
        "data-align" => assigns.align,
        "data-offset" => to_string(assigns.offset),
        "data-delay" => to_string(assigns.delay),
        "data-disabled" => assigns.disabled
      },
      content: %{
        "id" => content_id,
        "role" => "tooltip",
        "popover" => "manual",
        "data-part" => "content",
        "data-state" => "closed",
        "data-side" => assigns.placement,
        "data-align" => assigns.align
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
      "The DOM id. Generated when omitted; pass one only when you need a stable handle from your own CSS or JS."

  attr :text, :string,
    default: nil,
    doc:
      "Plain-text content for the tooltip. The short path for a one-line label; when set together with the `:content` slot, `text` wins."

  attr :placement, :string,
    default: "top",
    values: ~w(top bottom left right),
    doc:
      "Preferred side of the trigger. The content flips to the opposite side when it does not fit."

  attr :align, :string,
    default: "center",
    values: ~w(start center end),
    doc: "Preferred alignment along the side. The content shifts to stay inside the viewport."

  attr :offset, :integer,
    default: 6,
    doc: "Gap between the trigger and the content, in pixels."

  attr :delay, :integer,
    default: 200,
    doc: "Delay in milliseconds before the tooltip opens on hover. `0` opens immediately."

  attr :arrow, :boolean,
    default: false,
    doc: "Whether to render the arrow pointing at the trigger. Off by default."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the tooltip is disabled. A disabled tooltip does not open."

  attr :as, :string,
    default: "span",
    doc:
      "The HTML element to render the root as. Keep a phrasing element when the tooltip sits inside a paragraph."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block,
    required: true,
    doc:
      "The trigger. The first element in the slot becomes the trigger; the hook marks it and wires its description."

  slot :content, doc: "Rich tooltip content. Ignored when `text` is set."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
      <span {@flint_parts[:content]}>
        <span :if={@arrow} {@flint_parts[:arrow]}></span>
        {if @text, do: @text, else: render_slot(@content)}
      </span>
    </.dynamic_tag>
    """
  end
end
