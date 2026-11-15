defmodule FlintUI.Base.DropdownHeading do
  @moduledoc """
  A muted label that introduces a section of dropdown items.

  Headings are presentational: they help sighted users scan the menu, while the
  menu itself and its groups carry the accessible structure.

      <FlintUI.dropdown_heading>Account</FlintUI.dropdown_heading>
      <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>

  The default color is muted. `color` tints the label with a semantic role when
  the section itself needs emphasis.

  ## Accessibility

  The heading carries `role="presentation"`, so its text stays exposed as static
  content without adding a heading level to the page outline. It is not
  focusable and does not appear in the menu's roving focus sequence.

  Use the heading for a short label, not for a sentence or an instruction that
  belongs in the items.

  ## Keyboard

  The heading is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @colors ~w(neutral info success warning error primary secondary)

  @impl true
  def meta do
    %Meta{
      name: :dropdown_heading,
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
          value: "dropdown_heading",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "heading",
          description: "Identifies the heading element."
        },
        %Meta.PartAttr{
          name: "role",
          value: "presentation",
          description: "Keeps the label out of the page outline."
        },
        %Meta.PartAttr{
          name: "[data-color]",
          value: "string",
          description: "The semantic color of the heading."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "dropdown_heading",
        "data-part" => "heading",
        "role" => "presentation",
        "data-color" => assigns.color
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :color, :string,
    default: "neutral",
    values: @colors,
    doc: "The semantic color of the heading. The default is muted."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The heading label."

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
