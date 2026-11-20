defmodule FlintUI.Base.Breadcrumbs do
  @moduledoc """
  Shows where the current page sits in the site hierarchy as a trail of links.

  The root is a `nav` landmark labelled with `label`, and the trail is an
  ordered list:

      <FlintUI.breadcrumbs label="Breadcrumb">
        <FlintUI.breadcrumbs_item navigate="/">Home</FlintUI.breadcrumbs_item>
        <FlintUI.breadcrumbs_item navigate="/blog">Blog</FlintUI.breadcrumbs_item>
        <FlintUI.breadcrumbs_item current>Post</FlintUI.breadcrumbs_item>
      </FlintUI.breadcrumbs>

  Give every crumb that leads somewhere a destination with `href`, `navigate`,
  or `patch`, and mark the page being viewed with `current` on the last item.
  An item without a destination renders plain text, which is the right form for
  the current page and for a trail that ends on a section rather than a page.

  Breadcrumbs supplement the main navigation; they are not a replacement for
  it. Keep the trail short, start from a predictable root, and do not repeat
  the main navigation's labels verbatim unless that matches the hierarchy.

  ## Accessibility

  The root is a `nav` element, so assistive technology exposes it as a
  navigation landmark. Every breadcrumb trail needs an accessible name; `label`
  defaults to `"Breadcrumb"` and should be kept unless a page carries more than
  one trail.

  The current page carries `aria-current="page"` on its item content, whether
  that content is a link or plain text. Do not mark any other crumb as current.
  The ordered list keeps the trail's reading order, so a screen reader announces
  the position and the number of crumbs.

  The separators drawn by the styled layer are decorative and hidden from
  assistive technology. They must never carry information that the crumbs
  themselves do not.

  ## Keyboard

  The trail adds no keyboard behavior of its own. Each link is a native link:
  `Tab` moves through them and `Enter` follows the focused one. A plain-text
  crumb is not focusable.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :breadcrumbs,
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
          value: "breadcrumbs",
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
          description: "Identifies the ordered list that holds the crumbs."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "breadcrumbs",
        "data-part" => "root",
        "aria-label" => assigns.label
      },
      list: %{"data-part" => "list"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :label, :string,
    default: "Breadcrumb",
    doc:
      "The accessible name of the navigation landmark. Keep the default unless the page carries more than one breadcrumb trail."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The breadcrumb items."

  @impl true
  def render(assigns) do
    ~H"""
    <nav {@rest} {@flint_parts[:root]}>
      <ol {@flint_parts[:list]}>
        {render_slot(@inner_block)}
      </ol>
    </nav>
    """
  end
end
