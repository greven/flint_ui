defmodule FlintUI.Base.NavlistItem do
  @moduledoc """
  A single link in a `FlintUI.navlist`.

  The item renders a native link when it has a destination, and plain text
  otherwise:

      <FlintUI.navlist_item navigate="/docs">Overview</FlintUI.navlist_item>
      <FlintUI.navlist_item href="https://example.com">Example</FlintUI.navlist_item>
      <FlintUI.navlist_item active>Current</FlintUI.navlist_item>

  Set `active` on the item for the page being viewed. It sets
  `aria-current="page"` on the item content and exposes the `data-active` hook
  the styled layer uses. With a rail, the active item colors the rail segment;
  without one, it uses a background fill.

  Set `disabled` to render the item as non-focusable text, even when it has a
  destination. The destination attributes are dropped, so the item cannot be
  followed.

  ## Accessibility

  A destination renders a native link, so it keeps link semantics and its
  content is its accessible name. An item without a destination renders plain
  text in a non-focusable element and does not pretend to be a link. A disabled
  item renders the same plain text with `aria-disabled="true"`.

  Mark exactly one item per navlist with `active`. The item is a list item inside
  the navlist's `ul`, so the position and count come from the native list.

  When an icon is the only visible content, pass `aria-label`. The icon itself
  is decorative.

  ## Keyboard

  A linked item behaves like any link: `Tab` moves focus to it and `Enter`
  follows it. A plain-text or disabled item adds no tab stop and no keyboard
  behavior.
  """

  use FlintUI.Component

  @content_attrs ~w(
    href navigate patch replace method csrf_token target rel download
    hreflang referrerpolicy title aria-label aria-labelledby aria-describedby
  )a

  @impl true
  def meta do
    %Meta{
      name: :navlist_item,
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
          value: "navlist_item",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "Identifies the list item that holds one navlist link."
        },
        %Meta.PartAttr{
          name: "[data-active]",
          value: "boolean",
          description: "Present on the item for the current page."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the item is disabled."
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
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: "true",
          description: "Present on the item content when `disabled` is set."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description:
          "Moves focus to the next link in the navlist. Plain-text and disabled items are not focusable."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Follows the focused link. Plain-text and disabled items are not focusable."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "active",
        description: "The item links to the page currently being viewed.",
        selector: ~s([data-element="navlist_item"][data-active])
      },
      %Meta.State{
        name: "disabled",
        description: "The item is disabled and renders as non-focusable text.",
        selector: ~s([data-element="navlist_item"][data-disabled])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "navlist_item",
        "data-part" => "item",
        "data-active" => assigns.active,
        "data-disabled" => assigns.disabled
      },
      content: %{
        "data-part" => "content",
        "aria-current" => assigns.active && "page",
        "aria-disabled" => assigns.disabled && "true"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :active, :boolean,
    default: false,
    doc:
      "Whether the item links to the page currently being viewed. Sets `aria-current=\"page\"` on the item content."

  attr :disabled, :boolean,
    default: false,
    doc:
      "Whether the item is disabled. It renders as non-focusable text with `aria-disabled=\"true\"`, and any destination is dropped."

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

    content_rest =
      if assigns.disabled, do: drop_navigation(content_rest), else: content_rest

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
    not assigns.disabled and Enum.any?([:href, :navigate, :patch], &present?(rest[&1]))
  end

  defp present?(value), do: value not in [nil, false, ""]

  defp split_rest(rest), do: Map.split(rest, @content_attrs)

  defp drop_navigation(rest) do
    Map.drop(rest, [
      :href,
      :navigate,
      :patch,
      :replace,
      :method,
      :csrf_token,
      :target,
      :rel,
      :download,
      :hreflang,
      :referrerpolicy
    ])
  end
end
