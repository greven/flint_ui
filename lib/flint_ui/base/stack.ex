defmodule FlintUI.Base.Stack do
  @moduledoc """
  Lays out children in a vertical stack with a consistent gap and alignment.

  A stack is structural: it renders a plain container and arranges its
  children, but it never changes their behavior and it does not care what they
  are, so any content can sit inside. The generated styled component supplies
  the layout through `align`, `gap`, and `justify`; the headless component is
  the unstyled element underneath. `as` chooses that element, so a stack can be
  a `section`, `article`, or `nav` when the grouping is meaningful.

      <FlintUI.stack>
        <FlintUI.card>...</FlintUI.card>
        <FlintUI.card>...</FlintUI.card>
      </FlintUI.stack>

  The generated wrapper defaults to `align="stretch"`, `gap="md"`, and
  `justify="start"`. Use `justify` when the stack itself is taller than its
  content, such as a centered empty state or a card body that fills its row.

  With `pile`, the children overlap along the depth axis instead of flowing:
  the last child is the front layer and earlier children recede along
  `direction`, narrowing by `shrink`. `gap` sets the base distance between
  layers, `limit` caps how many are visible, and `align` and `justify` no
  longer apply. Append the newest item last, because the last child is the one
  in front. In the generated component the layers are also shaded and the front
  layer casts a shadow onto them, so the pile reads as depth; `depth` sets how
  strongly.

  The stack is a generic container and carries no implicit role. Pass a `role`
  and an accessible name through `rest` when the grouping itself is meaningful.

  ## Accessibility

  A stack is a generic container, so it has no implicit role and is not in the
  tab sequence. Its children keep their own semantics and keyboard behavior.

  Prefer real document structure first. A stack can visually group a heading, a
  description, and an action, but the heading and the button still carry the
  meaning; the stack is only the layout around them. When the grouping is a
  named region, pass `role="group"` or a landmark role with an `aria-label`
  through `rest`, and keep the visual order the same as the reading order.

  A pile is a preview, not a notification system. Layers past `limit` are
  hidden with `display: none`, so they leave the accessibility tree and the tab
  sequence: render a count or a link to the full list for whatever the limit
  hides, and keep interactive content on the visible layers. The layers behind
  the front one are still read in full, so their text should stand on its own
  even though only a strip of each is visible. The pile shading is decorative:
  it dims the back layers and casts the front layer's shadow, but it moves no
  focus, changes no reading order, and sets no role.

  ## Keyboard

  The stack adds no keyboard interaction. Keyboard behavior comes from the
  content inside it.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :stack,
      type: :layout,
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
          value: "stack",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the stack root element."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{root: %{"data-element" => "stack", "data-part" => "root"}}
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "div",
    doc:
      "The HTML element to render the stack as. Choose a block-level element that carries the grouping's meaning, such as `section` or `article`."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. Pass a `role` and an accessible name when the grouping is meaningful."

  slot :inner_block, required: true, doc: "The stacked children."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end
end
