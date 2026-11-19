defmodule FlintUI.Base.Text do
  @moduledoc """
  Renders a block of text, or a link when link attributes are given.

  The default element is a paragraph:

      <.text>Body copy that belongs in the page flow.</.text>
      <.text as="span" color="muted">Inline meta text.</.text>

  Pass `href`, `navigate`, or `patch` to render a native link instead. The link
  form keeps the same text styling, adds an underline, and uses the primary ink
  when no color overrides it:

      <.text href={~p"/pricing"}>View pricing</.text>
      <.text navigate={~p"/settings"}>Settings</.text>

  `as` chooses the element for the non-link form. Use `p` for paragraphs,
  `span` for inline text, and `div` only when the text is a block container of
  its own. The styled wrapper adds `size`, `color`, `weight`, `align`,
  `truncate`, and `line_clamp`.

  The base renders the semantic element only and ships no styling. The styled
  wrapper applies the type scale and ink tiers through the shared typography
  primitive.

  ## Accessibility

  Use the element that matches the content. A paragraph is a block of prose; a
  `span` is a run of text inside a larger block. Do not use `as` only to make
  text smaller or larger, and do not render a heading with `Text`; use
  `FlintUI.Base.Heading` for the document outline.

  A link is a native `<a>`, so it is focusable and activated with the keyboard.
  Write descriptive link text; avoid names such as "click here" that do not
  make sense out of context. The styled wrapper underlines links by default, so
  color is not the only way to identify them. When a link opens in a new
  window, say so in the text or with an accessible name rather than relying on
  an icon alone.

  `color="dimmed"` is below the AA contrast floor on purpose. Use it for
  placeholders and decorative text only, never for readable content or
  interactive labels.

  ## Keyboard

  Plain text is not interactive and adds no keyboard behavior. A link keeps the
  browser's native `Tab` focus and `Enter` activation.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :text,
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
          value: "text",
          description: "Identifies the component type for both the text and link forms."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "The text element, or the native anchor when link attributes are given."
        },
        %Meta.PartAttr{
          name: "href",
          value: "string",
          description: "Present on the link form, alongside the other forwarded link attributes."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "text",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "p",
    doc:
      "The HTML element to render the text as. Use `span` for inline text. Ignored when `href`, `navigate`, or `patch` renders a link."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download hreflang
         referrerpolicy),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of the text element."

  slot :inner_block, required: true, doc: "The text content."

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
