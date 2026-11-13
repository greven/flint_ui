defmodule FlintUI.Base.Indicator do
  @moduledoc """
  Positions a badge relative to another element.

  The default slot is the anchor: the element the indicator annotates. The badge
  is rendered by the component itself, so the generated styled component exposes
  `label`, `variant`, `color`, `size`, and `radius` directly on the indicator.

      <FlintUI.indicator label="3">
        <FlintUI.button aria-label="Inbox, 3 unread">Inbox</FlintUI.button>
      </FlintUI.indicator>

  The indicator is structural: the anchor keeps its own behavior and accessible
  name, and the badge is a sibling positioned over a corner. The styled theme
  owns the corner placement and the optional surface ring. The root is
  `inline-flex` so it hugs an inline anchor; pass `class="flex"` when the anchor
  is block-level.

  With no `label`, the badge is a dot. A dot drops the label height scale and
  uses the theme's smaller marker scale, so it stays a compact status mark
  instead of a full badge.

  ## Accessibility

  The badge is decorative by default: it is `aria-hidden`, so the count must be
  part of the anchor's accessible name.

      <FlintUI.indicator label="3">
        <FlintUI.button aria-label="Inbox, 3 unread">Inbox</FlintUI.button>
      </FlintUI.indicator>

  Give `badge_label` to expose the badge with its own accessible name, or use
  `status` for a count that changes and should be announced as a live region.
  A bare dot is decorative unless it is named.

  The indicator adds no role and no keyboard interaction. The badge ignores
  pointer events, so clicks reach the anchor.

  ## Keyboard

  The indicator adds no keyboard interaction. Keyboard behavior comes from the
  anchor.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :indicator,
      type: :feedback,
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
          value: "indicator",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the indicator root and its containing block."
        }
      ],
      badge: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "badge",
          description:
            "The positioning wrapper around the nested badge. The nested badge keeps `data-element=\"badge\"` and `data-part=\"root\"`."
        },
        %Meta.PartAttr{
          name: "[data-dot]",
          value: "boolean",
          description:
            "Present on the nested badge when `label` is empty. The theme renders it as a compact dot instead of a full badge."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "indicator",
        "data-part" => "root"
      },
      badge: %{
        "data-part" => "badge"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper supplies the badge's visual hooks. It is an internal
  # connector, like `flint_parts`, so it stays out of the public API.
  attr :badge_attrs, :map, default: %{}, doc: false

  attr :as, :string, default: "span", doc: "The HTML element to render the indicator root as."

  attr :label, :string,
    default: nil,
    doc:
      "The visible badge content. Omit it to render a dot, which uses the smaller marker size scale."

  attr :badge_label, :string,
    default: nil,
    doc:
      "An accessible name for the badge. When set, the badge is exposed to assistive technology; otherwise it is decorative."

  attr :status, :boolean,
    default: false,
    doc:
      "Expose the badge as a `status` live region. Use it when the count changes and should be announced."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. The root is a passive container, so pass any accessible name to the anchor instead."

  slot :inner_block, required: true, doc: "The anchor the badge is positioned against."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
      <span {@flint_parts[:badge]}>
        <span
          data-element="badge"
          data-part="root"
          data-dot={dot?(assigns)}
          {@badge_attrs}
          role={badge_role(assigns)}
          aria-label={@badge_label}
          aria-hidden={badge_hidden(assigns)}
        >
          {@label}
        </span>
      </span>
    </.dynamic_tag>
    """
  end

  # A dot is a badge with no visible content; whitespace-only labels count as
  # empty so a formatted template does not accidentally render a full badge.
  defp dot?(%{label: label}), do: is_nil(label) or String.trim(label) == ""

  defp badge_role(%{status: true}), do: "status"

  defp badge_role(%{badge_label: label}) when is_binary(label) and label != "",
    do: "img"

  defp badge_role(_assigns), do: nil

  defp badge_hidden(%{status: true}), do: nil

  defp badge_hidden(%{badge_label: label}) when is_binary(label) and label != "",
    do: nil

  defp badge_hidden(_assigns), do: "true"
end
