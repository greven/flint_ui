defmodule FlintUI.Base.BreadcrumbsItem do
  @moduledoc """
  A single crumb in a `FlintUI.breadcrumbs` trail.

  The item renders a link when it has a destination, and plain text otherwise:

      <FlintUI.breadcrumbs_item navigate="/">Home</FlintUI.breadcrumbs_item>
      <FlintUI.breadcrumbs_item href="https://example.com">Example</FlintUI.breadcrumbs_item>
      <FlintUI.breadcrumbs_item current>Post</FlintUI.breadcrumbs_item>

  Mark the page being viewed with `current`, which sets `aria-current="page"`
  on the item's content. Use the no-destination form for that page rather than a
  link to itself.

  An item can hold arbitrary content, such as a dropdown trigger that reveals
  sibling pages on a narrow screen. Keep an item's content small and
  breadcrumb-like; the trail is a shortcut, not a second menu.

  ## Accessibility

  A link item is a native link, so it keeps link semantics and its content is
  its accessible name. A no-destination item renders plain text in a non-focusable
  element and does not pretend to be a link.

  `current` sets `aria-current="page"` on the item's content. Set it on exactly
  one item per trail. The surrounding ordered list supplies the position and
  count, so no extra labeling is needed.

  When an icon is the item's only visible content, pass an accessible name with
  `aria-label` or `aria-labelledby`. The icon itself is decorative.

  ## Keyboard

  A link item behaves like any link: `Tab` moves focus to it and `Enter`
  follows it. A no-destination item adds no tab stop and no keyboard behavior.
  """

  use FlintUI.Component

  @content_attrs ~w(
    href navigate patch replace method csrf_token target rel download
    hreflang referrerpolicy title aria-label aria-labelledby aria-describedby
  )a

  @impl true
  def meta do
    %Meta{
      name: :breadcrumbs_item,
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
          value: "breadcrumbs_item",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "Identifies the list item that holds one crumb."
        },
        %Meta.PartAttr{
          name: "[data-current]",
          value: "boolean",
          description: "Present on the crumb for the current page."
        }
      ],
      separator: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "separator",
          description:
            "Identifies the decorative separator before the crumb. The styled layer supplies its glyph; the element is always hidden from assistive technology."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "Hides the decorative separator from assistive technology."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description:
            "Identifies the element that holds the crumb content: a link when the item has a destination, otherwise a plain container."
        },
        %Meta.PartAttr{
          name: "aria-current",
          value: "page",
          description: "Present on the current crumb's content when `current` is set."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves focus to the next link in the trail."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Follows the focused link. Plain-text crumbs are not focusable."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "current",
        description: "The crumb represents the page currently being viewed.",
        selector: ~s([data-element="breadcrumbs_item"][data-current])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "breadcrumbs_item",
        "data-part" => "item",
        "data-current" => assigns.current
      },
      separator: %{
        "data-part" => "separator",
        "aria-hidden" => "true"
      },
      content: %{
        "data-part" => "content",
        "aria-current" => assigns.current && "page"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :current, :boolean,
    default: false,
    doc:
      "Whether the crumb is the page currently being viewed. Sets `aria-current=\"page\"` on the item content."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy title aria-label aria-labelledby aria-describedby),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of plain text."

  slot :inner_block, required: true, doc: "The content of the crumb."

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
      <span {@flint_parts[:separator]}></span>
      <.link :if={@link?} {@content_rest} {@flint_parts[:content]}>
        {render_slot(@inner_block)}
      </.link>
      <span :if={!@link? and @current} {@content_rest} {@flint_parts[:content]}>
        {render_slot(@inner_block)}
      </span>
      <div :if={!@link? and !@current} {@content_rest} {@flint_parts[:content]}>
        {render_slot(@inner_block)}
      </div>
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
