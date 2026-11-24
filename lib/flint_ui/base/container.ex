defmodule FlintUI.Base.Container do
  @moduledoc """
  Centers content and caps its inline size.

  A container is a structural wrapper for the main content of a page or region.
  It adds a maximum inline size, centers itself with auto inline margins, and
  adds inline padding, so content keeps a readable measure on wide screens. The
  generated styled component sets the cap through `size`: a container token
  from `xs` to `7xl`, `fluid` for no cap, a number of pixels converted to rem,
  an arbitrary CSS length, or a map of breakpoint overrides.

      <FlintUI.container>
        ...
      </FlintUI.container>

  `as` chooses the element, so a page shell can render a `main`, a `section`, or
  an `article`. The headless component is the chosen element with the caller's
  attributes; it adds no role and no behavior.

  The generated wrapper defaults to `size="6xl"`. Use `as="main"` for the page's
  main region and `as="section"` with a heading for one region of a larger page.

  ## Accessibility

  A container is a generic wrapper, so it has no implicit role and is not in the
  tab sequence. Its children keep their own semantics and keyboard behavior.

  Prefer the element that already carries the right semantics. `main` marks the
  page's primary content; use it once per document. A `section` needs an
  accessible name, either from a heading referenced by `aria-labelledby` or from
  `aria-label`. A container does not label the content inside it.

  Do not use a container only to add spacing or a visual boundary; use `Stack`
  for rhythm or a surface component when the grouping is meaningful. Keep the
  visual order the same as the reading order.

  ## Keyboard

  The container adds no keyboard interaction. Keyboard behavior comes from the
  content inside it.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :container,
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
          value: "container",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "The centered, size-capped content region."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{root: %{"data-element" => "container", "data-part" => "root"}}
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "div",
    doc:
      "The HTML element to render the container as. Choose a block-level element that carries the grouping's meaning, such as `section`, `main`, or `article`."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. Pass `role`, `aria-labelledby`, or `aria-label` when the region needs an accessible name."

  slot :inner_block, required: true, doc: "The container's content."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end
end
