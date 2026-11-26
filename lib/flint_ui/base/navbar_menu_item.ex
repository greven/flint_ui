defmodule FlintUI.Base.NavbarMenuItem do
  @moduledoc """
  A single link inside a `FlintUI.navbar_menu`.

  The item renders a native link when it has a destination, and plain text
  otherwise:

      <FlintUI.navbar_menu label="Products">
        <FlintUI.navbar_menu_item navigate="/products/overview">
          Overview
        </FlintUI.navbar_menu_item>
        <FlintUI.navbar_menu_item active>Pricing</FlintUI.navbar_menu_item>
      </FlintUI.navbar_menu>

  Set `active` on the item for the page being viewed. It sets
  `aria-current="page"` on the item content.

  Set `disabled` to render the item as non-focusable text, even when it has a
  destination. The destination attributes are dropped, so the item cannot be
  followed.

  ## Accessibility

  The item is a list item in the menu's `ul`. A destination renders a native
  link, while an item without a destination renders plain text and does not
  pretend to be a link. A disabled item is plain text with
  `aria-disabled="true"`.

  Mark exactly one item per menu with `active` when the menu links to the current
  page. When an icon is the only visible content, pass `aria-label`.

  ## Keyboard

  Links use the native link behavior: `Tab` moves through the open menu and
  `Enter` follows the focused link. Plain-text and disabled items are not
  focusable. `Escape` is handled by the parent `navbar_menu`.
  """

  use FlintUI.Component

  @content_attrs ~w(
    href navigate patch replace method csrf_token target rel download
    hreflang referrerpolicy title aria-label aria-labelledby aria-describedby
  )a

  @impl true
  def meta do
    %Meta{
      name: :navbar_menu_item,
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
          value: "navbar_menu_item",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "Identifies the list item that holds one menu link."
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
        description: "Moves focus to the next link in the open menu."
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
        selector: ~s([data-element="navbar_menu_item"][data-active])
      },
      %Meta.State{
        name: "disabled",
        description: "The item is disabled and renders as non-focusable text.",
        selector: ~s([data-element="navbar_menu_item"][data-disabled])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "navbar_menu_item",
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
