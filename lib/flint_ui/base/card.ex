defmodule FlintUI.Base.Card do
  @moduledoc """
  A container that groups related content into a header, body and footer.

  ## Examples

      <FlintUI.card>
        <:title>Starred repositories</:title>
        <:description>Updated 2 minutes ago</:description>
        <:action>
          <FlintUI.button variant="ghost">Edit</FlintUI.button>
        </:action>
        <ul>
          <li>flint_ui</li>
        </ul>
        <:footer>3 repositories</:footer>
      </FlintUI.card>

  The card is structural: it renders a root element with `data-part` hooks for
  each region (`root`, `header`, `title`, `description`, `action`, `header-content`,
  `body`, `footer`). The generated styled component adds the surface treatment.

  Every region is optional except the body (`:inner_block`), so a card can be a
  bare panel with content, a titled panel, or a fully sectioned card.

  ## Accessibility

  The card is a plain container with no implicit role. Choose the root element
  with `as` (for example `"section"`, `"article"` or `"li"`) when a landmark or
  list semantics are appropriate, and give it an accessible name with
  `aria-labelledby` pointing at the title.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :card,
      type: :element,
      since: "0.1.0",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "card",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the card root element."
        },
        %Meta.PartAttr{
          name: "[data-flush]",
          value: "boolean",
          description:
            "Present when `flush` is set. The theme removes the card's internal spacing."
        }
      ],
      header: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header",
          description: "Identifies the header region wrapping the title, description and action."
        }
      ],
      title: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "title",
          description: "Identifies the title element."
        }
      ],
      description: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "description",
          description: "Identifies the description element."
        }
      ],
      action: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "action",
          description: "Identifies the action element."
        }
      ],
      header_content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header-content",
          description:
            "Identifies arbitrary header content rendered after the title, description and action."
        }
      ],
      body: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "body",
          description: "Identifies the body element."
        }
      ],
      footer: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "footer",
          description: "Identifies the footer element."
        }
      ]
    }
  end

  @impl true
  def css_vars do
    [
      %Meta.CSSVar{
        name: "--fl-card-spacing",
        description:
          "Internal spacing of the card, derived from the `size` attribute. Override it in CSS to customize the padding and gap."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{"data-element" => "card", "data-part" => "root", "data-flush" => assigns.flush},
      header: %{"data-part" => "header"},
      title: %{"data-part" => "title"},
      description: %{"data-part" => "description"},
      action: %{"data-part" => "action"},
      header_content: %{"data-part" => "header-content"},
      body: %{"data-part" => "body"},
      footer: %{"data-part" => "footer"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil

  attr :as, :string, default: "div", doc: "The HTML element to render the card root as."

  attr :flush, :boolean,
    default: false,
    doc:
      "Removes the card's internal spacing so its content can manage its own inset, e.g. a full-bleed collapsible. Overrides `size`."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :title, doc: "The card title. Rendered in the header."

  slot :description, doc: "Supporting text rendered under the title."

  slot :action, doc: "Content rendered in the top-right of the header, such as a button."

  slot :header,
    doc: "Arbitrary content rendered full-width at the bottom of the header."

  slot :inner_block, required: true, doc: "The card body."

  slot :footer, doc: "Content rendered in the footer."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      <% title = render_slot(@title) %>
      <% description = render_slot(@description) %>
      <% action = render_slot(@action) %>
      <% header = render_slot(@header) %>
      <% footer = render_slot(@footer) %>
      <% title? = present?(title) %>
      <% description? = present?(description) %>
      <% action? = present?(action) %>
      <% header? = present?(header) %>
      <% footer? = present?(footer) %>
      <div :if={title? || description? || action? || header?} {@flint_parts[:header]}>
        <div :if={title?} {@flint_parts[:title]}>{title}</div>
        <div :if={description?} {@flint_parts[:description]}>{description}</div>
        <div :if={action?} {@flint_parts[:action]}>{action}</div>
        <div :if={header?} {@flint_parts[:header_content]}>{header}</div>
      </div>
      <div {@flint_parts[:body]}>{render_slot(@inner_block)}</div>
      <div :if={footer?} {@flint_parts[:footer]}>{footer}</div>
    </.dynamic_tag>
    """
  end

  # A generated wrapper forwards every optional slot, so an unfilled one still
  # arrives as a one-entry list whose `render_slot/1` is a blank `%Rendered{}`
  # (truthy). Treat blank output as absent so the header/footer are skipped.
  defp present?(nil), do: false

  defp present?(rendered) do
    rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary() |> String.trim() != ""
  end
end
