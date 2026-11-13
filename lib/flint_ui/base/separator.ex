defmodule FlintUI.Base.Separator do
  @moduledoc """
  Separates sections of content or groups of controls with a horizontal or
  vertical line.

  The root carries `role="separator"` and is announced as a structural divider.
  It is not focusable and adds no behavior of its own; the styled theme draws
  the line and the optional content.

      <.separator />
      <.separator orientation="vertical" />
      <.separator>or</.separator>
      <.separator as="hr" />

  `as` chooses the root element and defaults to `div`. Use `as="hr"` when the
  separation is a thematic break in the document structure. An `hr` is a void
  element, so it cannot carry the default slot, a label, or an icon; keep the
  default `div` when the separator has content.

  Pass `decorative` when the line is purely visual. The root then renders
  `role="none"` and drops `aria-orientation`, so assistive technology treats it
  as ordinary layout. The visible text from the default slot stays exposed;
  only the separator role is removed. The default is `false`: a separator is
  structural unless the design says otherwise.

  ## Accessibility

  A separator is a static structure, not a control. It is not in the tab
  sequence, has no keyboard behavior, and must not be used as a generic
  spacing spacer when a margin would do.

  Prefer real document structure first. A heading marks a new section more
  reliably than a line, and a separator should not replace one. Use a
  separator when the visual boundary itself communicates the grouping, such as
  between groups in a toolbar or around an "or" label in a form.

  The horizontal orientation is implicit in the `separator` role, so only a
  vertical separator renders `aria-orientation="vertical"`. When
  `decorative` is true, neither the role nor `aria-orientation` is exposed.

  A separator does not label the content around it. When the content on each
  side needs a name, give each region its own heading or `aria-label`; do not
  rely on the separator to carry that meaning. A separator with a visible label
  keeps that text exposed, so write the label as meaningful copy.

  ## Keyboard

  The separator is not interactive and adds no keyboard behavior. It is never
  focusable.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :separator,
      type: :element,
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
          value: "separator",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the separator root element."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The line direction, for styling."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("separator" | "none"),
          description: "Exposes the static separator role, or `none` when `decorative` is true."
        },
        %Meta.PartAttr{
          name: "aria-orientation",
          value: "vertical",
          description:
            "Present only on a non-decorative vertical separator; horizontal is the role default."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description:
            "Identifies the content wrapper rendered only when the default slot has content."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "separator",
        "data-part" => "root",
        "data-orientation" => assigns.orientation,
        "role" => if(assigns.decorative, do: "none", else: "separator"),
        "aria-orientation" =>
          if(not assigns.decorative and assigns.orientation == "vertical", do: "vertical")
      },
      content: %{"data-part" => "content"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "div",
    doc:
      "The HTML element to render the separator as. Use `hr` for a thematic break; a void element cannot carry content."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "The direction of the line."

  attr :decorative, :boolean,
    default: false,
    doc:
      "Whether the separator is purely visual. When true, the root renders `role=\"none\"` and drops `aria-orientation`."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block,
    doc:
      "Optional content rendered between the lines, such as a label. The styled wrapper supplies it from its default slot, `label`, or `icon`."

  @impl true
  def render(assigns) do
    ~H"""
    <% content = render_slot(@inner_block) %>
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      <span :if={present?(content)} {@flint_parts[:content]}>{content}</span>
    </.dynamic_tag>
    """
  end

  # A generated wrapper can forward an empty inner block, so treat blank output
  # as absent and keep the separator a single line. HEEx debug annotations are
  # HTML comments in development, so strip them before deciding whether the
  # content is empty.
  defp present?(nil), do: false

  defp present?(rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.replace(~r/<!--.*?-->/s, "")
    |> String.trim() != ""
  end
end
