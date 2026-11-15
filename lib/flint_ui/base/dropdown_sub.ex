defmodule FlintUI.Base.DropdownSub do
  @moduledoc """
  A menu item that opens a submenu.

  Point `menu` at the `id` of a `:submenu` slot declared on the surrounding
  `FlintUI.dropdown/1`:

      <FlintUI.dropdown label="Actions">
        <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
        <:submenu id="more">
          <FlintUI.dropdown_item>Documentation</FlintUI.dropdown_item>
          <FlintUI.dropdown_item>Changelog</FlintUI.dropdown_item>
        </:submenu>
        <FlintUI.dropdown_sub menu="more">More</FlintUI.dropdown_sub>
      </FlintUI.dropdown>

  The submenu opens to the right of the item, flips when it does not fit, and is
  managed by the dropdown's hook. A submenu can contain items, groups, headings,
  and separators.

  ## Accessibility

  The trigger is a `role="menuitem"` with `aria-haspopup="menu"`,
  `aria-expanded`, and `aria-controls` pointing at the submenu. The submenu is a
  `role="menu"` labelled by the trigger. A disabled submenu trigger is skipped
  by the dropdown's arrow keys.

  ## Keyboard

  - `Enter` / `Space` - opens the submenu and focuses its first item.
  - `ArrowRight` - opens the submenu.
  - `ArrowLeft` - closes the submenu and returns focus to this trigger.
  - `Escape` - closes the submenu, or the whole menu when it is already closed.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :dropdown_sub,
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
          description: "Derived from the referenced menu id; labels the submenu."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the trigger from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "dropdown_sub",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "submenu-trigger",
          description: "Identifies the submenu trigger."
        },
        %Meta.PartAttr{
          name: "[data-menu]",
          value: "string",
          description: "The submenu DOM id the trigger opens."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the trigger is disabled."
        },
        %Meta.PartAttr{
          name: "role",
          value: "menuitem",
          description: "Exposes the trigger as a menu item."
        },
        %Meta.PartAttr{
          name: "aria-haspopup",
          value: "menu",
          description: "Tells assistive technology that the item opens a menu."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the submenu is open."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The submenu DOM id."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: "true",
          description: "Present when the trigger is disabled."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "The native disabled state for a disabled trigger."
        }
      ],
      indicator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "submenu-indicator",
          description: "The trailing chevron that marks a submenu."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The chevron is decorative."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "id" => "#{assigns.menu}-trigger",
        "type" => "button",
        "data-element" => "dropdown_sub",
        "data-part" => "submenu-trigger",
        "data-menu" => assigns.menu,
        "data-disabled" => assigns.disabled,
        "role" => "menuitem",
        "tabindex" => "-1",
        "aria-haspopup" => "menu",
        "aria-expanded" => "false",
        "aria-controls" => assigns.menu,
        "aria-disabled" => assigns.disabled && "true"
      },
      indicator: %{
        "data-part" => "submenu-indicator",
        "aria-hidden" => "true"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :menu, :string,
    required: true,
    doc: "The DOM id of the `:submenu` slot this item opens."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the trigger is disabled and skipped by menu navigation."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The submenu trigger label."

  @impl true
  def render(assigns) do
    ~H"""
    <button {@rest} disabled={@disabled} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
      <span {@flint_parts[:indicator]}>
        <svg viewBox="0 0 24 24" fill="none" focusable="false">
          <path
            d="m9 6 6 6-6 6"
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
          />
        </svg>
      </span>
    </button>
    """
  end
end
