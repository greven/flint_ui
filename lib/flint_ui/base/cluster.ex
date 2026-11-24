defmodule FlintUI.Base.Cluster do
  @moduledoc """
  Lays out children in a wrapping row with a consistent gap and alignment.

  A cluster is structural: it renders a plain container and arranges its
  children, but it never changes their behavior and it does not care what they
  are, so any content can sit inside. The generated styled component supplies
  the layout through `align`, `gap`, and `justify`; the headless component is
  the unstyled element underneath. `as` chooses that element, so a cluster can
  be a `section`, a `nav`, or a list when the grouping is meaningful.

      <FlintUI.cluster>
        <FlintUI.badge>Design</FlintUI.badge>
        <FlintUI.badge>Shipped</FlintUI.badge>
        <FlintUI.badge>Review</FlintUI.badge>
      </FlintUI.cluster>

  The generated wrapper defaults to `align="center"`, `gap="md"`, and
  `justify="start"`. Children wrap onto the next line when the row runs out of
  space, and the same gap separates the lines, so a cluster adapts to the
  available inline size without breakpoints. `justify="split"` keeps the last
  child at the inline end on every line, so a trailing action group stays right
  aligned after it wraps.

  A cluster is a generic container and carries no implicit role. Pass a `role`
  and an accessible name through `rest` when the grouping itself is meaningful,
  or choose `as="ul"` or `as="ol"` and render `li` children when the items form
  a list; the styled layer resets the browser's list chrome for you.

  ## Accessibility

  A cluster is a generic container, so it has no implicit role and is not in the
  tab sequence. Its children keep their own semantics and keyboard behavior.

  Wrapping and the `justify` alignment change only the visual position, not the
  reading order, so keep the source order meaningful and do not rely on
  horizontal position alone to convey meaning. When the items form a list, use
  `as="ul"` or `as="ol"` with `li` children so assistive technology announces
  the structure; the styled layer removes the markers and spacing, while the
  native list semantics stay.

  ## Keyboard

  The cluster adds no keyboard interaction. Keyboard behavior comes from the
  content inside it.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :cluster,
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
          value: "cluster",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the cluster root element."
        },
        %Meta.PartAttr{
          name: "[data-list]",
          value: "boolean",
          description:
            "Present when `as` is `ul` or `ol`. The styled layer resets the list chrome while the native list semantics stay."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    root =
      %{"data-element" => "cluster", "data-part" => "root"}
      |> put_list(assigns)

    %{root: root}
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "div",
    doc:
      "The HTML element to render the cluster as. Choose a block-level element that carries the grouping's meaning, such as `section` or `nav`, or `ul`/`ol` with `li` children when the items form a list; the styled layer resets the list chrome."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. Pass a `role` and an accessible name when the grouping is meaningful."

  slot :inner_block, required: true, doc: "The clustered children."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  defp put_list(attrs, assigns) do
    if Map.get(assigns, :as) in ["ul", "ol"] do
      Map.put(attrs, "data-list", "")
    else
      attrs
    end
  end
end
