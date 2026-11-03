defmodule FlintUI.Base.Badge do
  @moduledoc """
  A short label that conveys status, category, or a count.

  ## Examples

      <.badge>New</.badge>
      <.badge href={~p"/releases"} variant="link">v1.2.0</.badge>

  Pass `as` to choose the root element. It defaults to `span`, so a badge can sit
  inside a paragraph, heading, or table cell; use `as="div"` when you need a
  block container. Pass `href`, `navigate`, or `patch` to render a link instead.
  The badge is presentational: it adds no role and no interaction of its own.

  ## Accessibility

  A badge is a plain text label, so keep its content meaningful on its own. When
  it conveys a state that changes, put it in a live region or pair it with text
  that announces the change. Icons are decorative unless the badge has no text,
  in that case give the surrounding element an accessible name.

  A link badge renders a native `<a>`, so it keeps the link role and browser
  activation behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :badge,
      type: :element,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "badge",
          description: "Identifies the component type. Shared by the element and link forms."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the badge root element."
        }
      ]
    }
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "badge",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string, default: "span", doc: "The HTML element to render the badge as."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of the badge element."

  slot :inner_block, doc: "The content of the badge."

  @impl true
  def render(assigns) do
    if link?(assigns) do
      ~H"""
      <.link {@rest} {@flint_parts[:root]}>{render_slot(@inner_block)}</.link>
      """
    else
      ~H"""
      <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
        {render_slot(@inner_block)}
      </.dynamic_tag>
      """
    end
  end

  defp link?(assigns) do
    rest = Map.get(assigns, :rest, %{})
    rest[:href] || rest[:navigate] || rest[:patch]
  end
end
