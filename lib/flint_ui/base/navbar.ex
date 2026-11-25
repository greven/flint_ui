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

  ## Accessibility

  The root is a native `nav` element. Give it a unique accessible name with
  `label`; the default `"Primary"` is appropriate for the site's main
  navigation, but a page with more than one navbar needs distinct labels.

  The list is a native `ul`, so assistive technology announces the number of
  navigation links. Items keep their native link semantics. Icons are
  decorative; give an icon-only item an `aria-label`.

  ## Keyboard

  - `Tab` / `Shift+Tab` - move between nav items and into an open menu.
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
        }
      ]
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
