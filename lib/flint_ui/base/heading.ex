defmodule FlintUI.Base.Heading do
  @moduledoc """
  Renders a semantic heading with an optional kicker above and subtitle below.

  The component keeps the document outline and the visual treatment separate.
  `as` chooses the real heading level, from `h1` to `h6`, while the styled
  wrapper's `size` controls how large it looks:

      <.heading as="h1">Release notes</.heading>

      <.heading as="h2" size="sm">
        <:kicker>API</:kicker>
        Authentication
        <:subtitle>Tokens, scopes, and request signing.</:subtitle>
      </.heading>

  The kicker and subtitle sit outside the heading element, so neither becomes
  part of the heading's accessible name. The root is a plain wrapper; the
  native `h1`–`h6` carries the heading role and the caller's `id`, `aria-*`,
  and event attributes.

  The base renders semantic structure only and ships no styling. The styled
  wrapper adds the visual `size`, `color`, `weight`, `align`, `truncate`, and
  `line_clamp` props. There, the caller `class` and `style` apply to the
  wrapper, not to the heading, so the whole block can be spaced and aligned as
  a unit. In the base, `class` and the rest attributes apply directly to the
  native heading.

  ## Accessibility

  A heading marks a section of the document. Keep one `h1` per page and do not
  skip levels: an `h2` follows the `h1`, an `h3` follows an `h2`, and so on.
  Use `as` for that structure and `size` when the design needs a different
  visual scale. Do not choose a heading level for its size.

  The kicker and subtitle are read as ordinary text before and after the
  heading. They describe or qualify the heading, but they do not change its
  accessible name. When the heading needs a name beyond its content, point
  `aria-labelledby` at the heading's `id`, not at the outer wrapper.

  A heading is not interactive. Do not attach click handlers that make it act
  like a button or link; use a real control instead.

  ## Keyboard

  The heading is not interactive and adds no keyboard behavior. It is not in
  the tab sequence.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :heading,
      type: :typography,
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
          value: "heading",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "The wrapper that stacks the kicker, heading, and subtitle."
        }
      ],
      kicker: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "kicker",
          description: "The small label rendered above the heading."
        }
      ],
      heading: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "heading",
          description: "The semantic `h1`–`h6` element selected by `as`."
        },
        %Meta.PartAttr{
          name: "[data-level]",
          value: ~s("h1" | "h2" | "h3" | "h4" | "h5" | "h6"),
          description: "The heading level, kept in sync with `as`."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Caller attributes such as `id`, `aria-*`, and events land on the heading."
        }
      ],
      subtitle: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "subtitle",
          description: "The supporting copy rendered below the heading."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "heading",
        "data-part" => "root"
      },
      kicker: %{"data-part" => "kicker"},
      heading: %{
        "data-part" => "heading",
        "data-level" => assigns.as
      },
      subtitle: %{"data-part" => "subtitle"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks, class, and style on the
  # root while the caller's global attributes stay on the native heading.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :as, :string,
    default: "h2",
    values: ~w(h1 h2 h3 h4 h5 h6),
    doc:
      "The semantic heading level. It controls the document outline; the styled `size` prop controls the visual scale."

  attr :rest, :global, doc: "Additional HTML attributes, rendered on the native heading."

  slot :inner_block, required: true, doc: "The heading text. Use inline content."

  slot :kicker,
    doc:
      "A short label rendered above the heading, such as a category or eyebrow. It stays outside the heading element."

  slot :subtitle,
    doc: "Supporting copy rendered below the heading. It stays outside the heading element."

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        kicker: Map.get(assigns, :kicker, []),
        subtitle: Map.get(assigns, :subtitle, []),
        root_attrs: Map.get(assigns, :root_attrs, %{})
      )

    ~H"""
    <div {@flint_parts[:root]} {@root_attrs}>
      <div :if={@kicker != []} {@flint_parts[:kicker]}>{render_slot(@kicker)}</div>
      <.dynamic_tag tag_name={@as} {@flint_parts[:heading]} {@rest}>
        {render_slot(@inner_block)}
      </.dynamic_tag>
      <p :if={@subtitle != []} {@flint_parts[:subtitle]}>{render_slot(@subtitle)}</p>
    </div>
    """
  end
end
