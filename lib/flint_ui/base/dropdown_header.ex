defmodule FlintUI.Base.DropdownHeader do
  @moduledoc """
  A muted label that introduces a section of dropdown items.

  A header is presentational: it helps sighted users scan the menu, while the
  menu itself and its groups carry the accessible structure.

      <FlintUI.dropdown_header>Account</FlintUI.dropdown_header>
      <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>

  The default color is muted. `color` tints the label with a semantic role when
  the section itself needs emphasis.

  ## Accessibility

  The header is a native `<header>` with `role="presentation"`. The role drops
  the implicit `banner` landmark, so a menu cannot inject a page landmark, while
  the text stays exposed as static content. It is not focusable and does not
  appear in the menu's roving focus sequence.

  Use the header for a short label, not for a sentence or an instruction that
  belongs in the items. It adds no heading level to the page outline; a dropdown
  is a menu, not a document section.

  ## Keyboard

  The header is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @colors ~w(neutral info success warning danger primary secondary)

  @impl true
  def meta do
    %Meta{
      name: :dropdown_header,
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
          name: "[data-element]",
          value: "dropdown_header",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header",
          description: "Identifies the header element."
        },
        %Meta.PartAttr{
          name: "role",
          value: "presentation",
          description:
            "Drops the implicit `banner` landmark and keeps the label out of the page outline."
        },
        %Meta.PartAttr{
          name: "[data-color]",
          value: "string",
          description: "The semantic color of the header. Absent when no color is set."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "dropdown_header",
        "data-part" => "header",
        "role" => "presentation",
        "data-color" => assigns[:color]
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :color, :string,
    values: @colors,
    doc: "The semantic color of the header. When omitted, the label uses the muted ink tier."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The header label."

  @impl true
  def render(assigns) do
    ~H"""
    <header {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </header>
    """
  end
end
