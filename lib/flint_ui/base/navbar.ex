defmodule FlintUI.Base.Navbar do
  @moduledoc """
  A left-to-right navigation landmark for the primary links in an app or site.

  The root is a `nav` landmark wrapped around an unordered list:

      <FlintUI.navbar label="Primary">
        <FlintUI.navbar_item navigate="/">Home</FlintUI.navbar_item>
        <FlintUI.navbar_item navigate="/projects" active>Projects</FlintUI.navbar_item>
        <FlintUI.navbar_item navigate="/team">Team</FlintUI.navbar_item>
      </FlintUI.navbar>

  Use `navbar_item` for a link and `navbar_menu` when an item opens a menu of
  links. A navbar is the horizontal counterpart to `FlintUI.navlist`, which
  stacks links vertically and supports groups.

  Mark the page being viewed with `active` on exactly one item. Active items
  carry `aria-current="page"` in addition to the visual state.

  ## Overflow

  Set `scrollable` when the items can be wider than the container. The list
  scrolls horizontally instead of overflowing, and the hook scrolls the active
  item into view. Set `fadable` to add a fade at the edge that still has hidden
  items; it also makes the list scrollable.

  ## Disabled

  Set `disabled` on an item to render it as non-focusable text with
  `aria-disabled="true"`, even when it has a destination. Set `disabled` on the
  navbar to make the whole landmark inert: its links and menus cannot be
  focused, clicked, or reached by assistive technology.

  ## Accessibility

  The root is a native `nav` element. Give it a unique accessible name with
  `label`; the default `"Primary"` is appropriate for the site's main
  navigation, but a page with more than one navbar needs distinct labels.

  The list is a native `ul`, so assistive technology announces the number of
  navigation links. Items keep their native link semantics. A disabled item is
  plain text, not a link, so it cannot be followed by keyboard or pointer.
  Icons are decorative; give an icon-only item an `aria-label`.

  ## Keyboard

  - `Tab` / `Shift+Tab` - move between nav items and into an open menu.
  - `ArrowRight` / `ArrowLeft` - move focus between the top-level items and
    menu triggers. The active item is not selected; navigation stays a link
    list. `loop` controls whether focus wraps at the ends.
  - `Home` / `End` - move focus to the first or last enabled top-level item.
  - `Enter` - follows a focused link or toggles a focused menu trigger.
  - `Space` - toggles a focused menu trigger. Does not follow a link.
  - `Escape` - closes an open menu and returns focus to its trigger.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :navbar,
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
          value: "FlintUI.Navbar",
          description: "The navbar hook that dismisses open menus and keeps one menu open."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "navbar",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the navigation landmark."
        },
        %Meta.PartAttr{
          name: "[data-loop]",
          value: ~s("true" | "false"),
          description: "Whether arrow-key navigation wraps at the ends."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the whole navbar is disabled."
        },
        %Meta.PartAttr{
          name: "[data-scrollable]",
          value: "boolean",
          description: "Present when the list scrolls horizontally on overflow."
        },
        %Meta.PartAttr{
          name: "[data-fadable]",
          value: "boolean",
          description: "Present when the list fades at the edge with hidden items."
        },
        %Meta.PartAttr{
          name: "inert",
          value: "boolean",
          description:
            "Present when the navbar is disabled, removing its links and menus from interaction and the accessibility tree."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name of the navigation landmark."
        }
      ],
      list: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "list",
          description: "Identifies the unordered list that holds the nav items."
        },
        %Meta.PartAttr{
          name: "[data-fade-start]",
          value: "boolean",
          description:
            "Set by the hook when `fadable` is set and the list can scroll toward the start."
        },
        %Meta.PartAttr{
          name: "[data-fade-end]",
          value: "boolean",
          description:
            "Set by the hook when `fadable` is set and the list can scroll toward the end."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab / Shift+Tab",
        description: "Moves between nav items and into an open menu."
      },
      %Meta.Keyboard{
        keys: "ArrowRight / ArrowLeft",
        description:
          "Moves focus between the top-level items and menu triggers. Wraps at the ends when `loop` is set."
      },
      %Meta.Keyboard{
        keys: "Home / End",
        description: "Moves focus to the first or last enabled top-level item."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Follows a focused link or toggles a focused menu trigger."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Toggles a focused menu trigger. Does not follow a link."
      },
      %Meta.Keyboard{
        keys: "Escape",
        description: "Closes an open menu and returns focus to its trigger."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The whole navbar is disabled and inert.",
        selector: ~s([data-element="navbar"][data-disabled])
      },
      %Meta.State{
        name: "fade-start",
        description: "The list can scroll toward its start edge.",
        selector: ~s([data-element="navbar"] [data-part="list"][data-fade-start])
      },
      %Meta.State{
        name: "fade-end",
        description: "The list can scroll toward its end edge.",
        selector: ~s([data-element="navbar"] [data-part="list"][data-fade-end])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "id" => assigns.id || FlintUI.API.use_id("fl-navbar"),
        "phx-hook" => "FlintUI.Navbar",
        "data-element" => "navbar",
        "data-part" => "root",
        "data-loop" => to_string(assigns.loop),
        "data-disabled" => assigns.disabled,
        "data-scrollable" => assigns.scrollable,
        "data-fadable" => assigns.fadable,
        "inert" => assigns.disabled,
        "aria-label" => assigns.label
      },
      list: %{"data-part" => "list"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    default: nil,
    doc: "Unique component DOM id. Generated when omitted."

  attr :label, :string,
    default: "Primary",
    doc:
      "The accessible name of the navigation landmark. Keep the default unless the page carries more than one navbar."

  attr :disabled, :boolean,
    default: false,
    doc:
      "Whether the whole navbar is disabled. A disabled navbar is inert: its links and menus cannot be focused, clicked, or reached by assistive technology."

  attr :fadable, :boolean,
    default: false,
    doc:
      "Whether the list fades at the edge that still has hidden items. It also makes the list scrollable, so use it with a bounded width."

  attr :loop, :boolean,
    default: true,
    doc: "Whether arrow-key navigation wraps from the last top-level item to the first and back."

  attr :scrollable, :boolean,
    default: false,
    doc:
      "Whether the list scrolls horizontally when its items overflow. The hook keeps the active item in view."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The navbar items and menus."

  @impl true
  def render(assigns) do
    ~H"""
    <nav {@rest} {@flint_parts[:root]}>
      <ul {@flint_parts[:list]}>
        {render_slot(@inner_block)}
      </ul>
    </nav>
    """
  end
end
