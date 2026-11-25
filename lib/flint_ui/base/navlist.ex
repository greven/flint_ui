defmodule FlintUI.Base.Navlist do
  @moduledoc """
  A vertical navigation landmark for sidebars, settings, and documentation.

  The root is a `nav` landmark wrapped around an unordered list:

      <FlintUI.navlist label="Documentation" rail>
        <FlintUI.navlist_item navigate="/docs">Overview</FlintUI.navlist_item>
        <FlintUI.navlist_item navigate="/docs/install">Installation</FlintUI.navlist_item>
      </FlintUI.navlist>

  A navlist is the vertical counterpart to `FlintUI.navbar`. Use
  `navlist_group` to label a section or group related links, and
  `navlist_item` for each link.

  The styled layer optionally draws a rail along the inline start of the list
  and along nested group lists. It is purely visual; the base component only
  renders the landmark and the list.

  ## Accessibility

  The root is a native `nav` element. Give it a unique accessible name with
  `label`; the default `"Navigation"` is appropriate for a single sidebar, but a
  page with several navlists needs distinct labels.

  Items keep native link semantics, and groups are nested lists with a button
  header. Icons are decorative; give an icon-only item an `aria-label`.

  ## Keyboard

  - `Tab` - moves through the visible links and group headers.
  - `Enter` - follows a focused link or toggles a focused group header.
  - `Space` - toggles a focused group header. Does not follow a link.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :navlist,
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
          name: "[data-element]",
          value: "navlist",
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
          description: "Identifies the unordered list that holds the navlist items."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "navlist",
        "data-part" => "root",
        "aria-label" => assigns.label
      },
      list: %{"data-part" => "list"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :label, :string,
    default: "Navigation",
    doc:
      "The accessible name of the navigation landmark. Keep the default unless the page carries more than one navlist."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The navlist items and groups."

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
