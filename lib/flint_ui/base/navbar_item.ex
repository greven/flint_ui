defmodule FlintUI.Base.NavbarItem do
  @moduledoc """
  A single link in a `FlintUI.navbar`.

  The item renders a native link when it has a destination, and plain text
  otherwise:

      <FlintUI.navbar_item navigate="/">Home</FlintUI.navbar_item>
      <FlintUI.navbar_item href="https://example.com">Example</FlintUI.navbar_item>
      <FlintUI.navbar_item active>Current</FlintUI.navbar_item>

  Set `active` on the item for the page being viewed. It sets
  `aria-current="page"` on the item content and exposes the `data-active` hook
  the styled layer uses.

  Use `navbar_item` for a direct link. Use `navbar_menu` when the item reveals a
  menu of links.

  ## Accessibility

  A destination renders a native link, so it keeps link semantics and its
  content is its accessible name. An item without a destination renders plain
  text in a non-focusable element and does not pretend to be a link.

  Mark exactly one item per navigation with `active`. The item is a list item
  inside the navbar's `ul`, so the position and count come from the native list.

  When an icon is the only visible content, pass `aria-label` so the item keeps
  an accessible name. The icon itself is decorative.

  ## Keyboard

  A linked item behaves like any link: `Tab` moves focus to it and `Enter`
  follows it. A plain-text item adds no tab stop and no keyboard behavior.
  """

  use FlintUI.Component

  @content_attrs ~w(
    href navigate patch replace method csrf_token target rel download
    hreflang referrerpolicy title aria-label aria-labelledby aria-describedby
  )a

  @impl true
  def meta do
    %Meta{
      name: :navbar_item,
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
          value: "navbar_item",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "Identifies the list item that holds one nav link."
        },
        %Meta.PartAttr{
          name: "[data-active]",
          value: "boolean",
          description: "Present on the item for the current page."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description:
            "Identifies the element that holds the item content: a link when the item has a destination, otherwise plain text."
        },
        %Meta.PartAttr{
          name: "aria-current",
          value: "page",
          description: "Present on the item content when `active` is set."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves focus to the next link in the navbar."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Follows the focused link. Plain-text items are not focusable."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "active",
        description: "The item links to the page currently being viewed.",
        selector: ~s([data-element="navbar_item"][data-active])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "navbar_item",
        "data-part" => "item",
        "data-active" => assigns.active
      },
      content: %{
        "data-part" => "content",
        "aria-current" => assigns.active && "page"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :active, :boolean,
    default: false,
    doc:
      "Whether the item links to the page currently being viewed. Sets `aria-current=\"page\"` on the item content."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy title aria-label aria-labelledby aria-describedby),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of plain text."

  slot :inner_block, required: true, doc: "The content of the item."

  @impl true
  def render(assigns) do
    {content_rest, root_rest} = split_rest(Map.get(assigns, :rest, %{}))
    link? = link?(assigns)

    assigns =
      assigns
      |> assign(:content_rest, content_rest)
      |> assign(:root_rest, root_rest)
      |> assign(:link?, link?)

    ~H"""
    <li {@root_rest} {@flint_parts[:root]}>
      <.link :if={@link?} {@content_rest} {@flint_parts[:content]}>
        {render_slot(@inner_block)}
      </.link>
      <span :if={!@link?} {@content_rest} {@flint_parts[:content]}>
        {render_slot(@inner_block)}
      </span>
    </li>
    """
  end

  defp link?(assigns) do
    rest = Map.get(assigns, :rest, %{})
    Enum.any?([:href, :navigate, :patch], &present?(rest[&1]))
  end

  defp present?(value), do: value not in [nil, false, ""]

  # The root is the list item, so structural and event attributes stay on it.
  # Navigation and naming attributes belong on the link, where they describe the
  # destination and the accessible name.
  defp split_rest(rest), do: Map.split(rest, @content_attrs)
end
