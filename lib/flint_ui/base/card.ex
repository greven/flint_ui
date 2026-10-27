defmodule FlintUI.Base.Card do
  @moduledoc """
  A container that groups related content into an optional header, sections and
  an optional footer.

  ## Examples

      <FlintUI.card>
        <:title>Starred repositories</:title>
        <:description>Updated 2 minutes ago</:description>
        <:header_actions>
          <FlintUI.button>Edit</FlintUI.button>
        </:header_actions>
        <ul>
          <li>flint_ui</li>
        </ul>
        <:section>
          <p>More detail</p>
        </:section>
        <:footer>3 repositories</:footer>
        <:footer_actions>
          <FlintUI.button variant="outline">View logs</FlintUI.button>
        </:footer_actions>
      </FlintUI.card>

  The default slot is shorthand for the first body section. Additional sections
  use the repeatable `:section` slot. All body sections share the card's
  `padded` setting; set `padded={false}` on the card for full-bleed content.

  The card is structural: it renders a root element with `data-part` hooks for
  each region (`root`, `header`, `title`, `description`, `header-actions`,
  `header-content`, `body`, `section`, `footer`, `footer-content`,
  `footer-actions`). The default slot and the repeatable `:section` slots live
  inside the body region; the header and footer sit outside it. The generated
  styled component adds the surface treatment and body treatments.

  Header and footer actions use separate slots because Phoenix slot entries must
  be direct children of the component; slots cannot be nested. Each actions slot
  can be repeated or contain multiple controls.

  ## Accessibility

  The card is a plain container with no implicit role. Choose the root element
  with `as` (for example `"section"`, `"article"` or `"li"`) when a landmark or
  list semantics are appropriate, and give it an accessible name with
  `aria-labelledby` pointing at `title_id`.

  `orientation` is a layout hook for the styled theme. It does not add
  `aria-orientation`; set that yourself only if you give the card a role that
  expects it.
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
          name: "[data-orientation]",
          value: ~s("vertical" | "horizontal"),
          description: "The layout direction, for styling."
        }
      ],
      header: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header",
          description: "Identifies the header region wrapping the title, description and actions."
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
      header_actions: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header-actions",
          description: "Identifies the header actions element."
        }
      ],
      header_content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header-content",
          description:
            "Identifies additional header content rendered after the title, description and actions."
        }
      ],
      body: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "body",
          description:
            "Identifies the body region wrapping the default slot and any additional sections."
        }
      ],
      section: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "section",
          description: "Identifies a content section, including the implicit first section."
        },
        %Meta.PartAttr{
          name: "[data-padded]",
          value: "boolean",
          description:
            "Whether the section carries the card inset, from the root `padded` attribute."
        }
      ],
      footer: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "footer",
          description: "Identifies the footer region."
        }
      ],
      footer_content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "footer-content",
          description: "Identifies the content at the start of the footer."
        }
      ],
      footer_actions: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "footer-actions",
          description: "Identifies the actions at the end of the footer."
        }
      ]
    }
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "card",
        "data-part" => "root",
        "data-orientation" => assigns.orientation
      },
      header: %{"data-part" => "header"},
      title: %{"data-part" => "title", "id" => assigns.title_id},
      description: %{"data-part" => "description"},
      header_actions: %{"data-part" => "header-actions"},
      header_content: %{"data-part" => "header-content"},
      body: %{"data-part" => "body"},
      footer: %{"data-part" => "footer"},
      footer_content: %{"data-part" => "footer-content"},
      footer_actions: %{"data-part" => "footer-actions"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string, default: "div", doc: "The HTML element to render the card root as."

  attr :title_id, :string,
    default: nil,
    doc: "The DOM id for the title element, for use with `aria-labelledby`."

  attr :orientation, :string,
    default: "vertical",
    values: ~w(vertical horizontal),
    doc: "The layout direction of the card's direct regions."

  attr :padded, :boolean,
    default: true,
    doc: "Adds the card inset to every body section. Set false for full-bleed content."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :title, doc: "The card title. Rendered in the header."

  slot :description, doc: "Supporting text rendered under the title."

  slot :header_actions,
    doc: "Actions rendered at the end of the header, such as buttons. May be repeated."

  slot :header,
    doc: "Additional content rendered full-width below the title, description and actions."

  slot :inner_block,
    doc: "Shorthand for the first body section. Additional sections use `:section`."

  slot :section,
    doc: "An additional body section rendered after the implicit first section."

  slot :footer, doc: "Content rendered at the start of the footer."

  slot :footer_actions,
    doc: "Actions rendered at the end of the footer, such as buttons. May be repeated."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      <% title = render_slot(@title) %>
      <% description = render_slot(@description) %>
      <% header_actions = render_slot(@header_actions) %>
      <% header_content = render_slot(@header) %>
      <% body_content = render_slot(@inner_block) %>
      <% footer_content = render_slot(@footer) %>
      <% footer_actions = render_slot(@footer_actions) %>
      <% title? = present?(title) %>
      <% description? = present?(description) %>
      <% header_actions? = present?(header_actions) %>
      <% header_content? = present?(header_content) %>
      <% body? = present?(body_content) or @section != [] %>
      <% footer_content? = present?(footer_content) %>
      <% footer_actions? = present?(footer_actions) %>
      <% footer? = footer_content? || footer_actions? %>
      <div
        :if={title? || description? || header_actions? || header_content?}
        {@flint_parts[:header]}
      >
        <div :if={title?} {@flint_parts[:title]}>{title}</div>
        <div :if={description?} {@flint_parts[:description]}>{description}</div>
        <div :if={header_actions?} {@flint_parts[:header_actions]}>{header_actions}</div>
        <div :if={header_content?} {@flint_parts[:header_content]}>{header_content}</div>
      </div>
      <div :if={body?} {@flint_parts[:body]}>
        <div
          :if={present?(body_content)}
          data-part="section"
          data-padded={to_string(@padded)}
        >
          {body_content}
        </div>
        <div
          :for={section <- @section}
          data-part="section"
          data-padded={to_string(@padded)}
        >
          {render_slot(section)}
        </div>
      </div>
      <div :if={footer?} {@flint_parts[:footer]}>
        <div :if={footer_content?} {@flint_parts[:footer_content]}>{footer_content}</div>
        <div :if={footer_actions?} {@flint_parts[:footer_actions]}>{footer_actions}</div>
      </div>
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
