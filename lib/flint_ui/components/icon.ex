defmodule FlintUI.Icon do
  @moduledoc """
  Renders a decorative or labeled icon.

  The `name` is applied verbatim as a CSS class. FlintUI does not ship icon
  assets; the host application provides the classes, for example a Tailwind
  plugin that exposes `lucide-*` utilities (the docs site does exactly this).
  Size and color are controlled through `class`:

      <.icon name="lucide-house" />
      <.icon name="lucide-x" class="size-5" />
      <.icon name="lucide-circle-alert" label="Error" class="size-5 text-red-500" />

  ## Accessibility

  Icons are decorative by default and hidden from assistive technology. When an
  icon conveys meaning on its own, pass `label` to expose it as an image with an
  accessible name:

      <.icon name="lucide-circle-alert" label="Error" />
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :icon,
      type: :element,
      since: "0.1.0",
      status: :stable
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "icon",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        }
      ]
    }
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "icon",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr(:flint_parts, :map, default: nil)

  attr(:name, :string,
    required: true,
    doc: "The icon CSS class (e.g. `\"lucide-house\"`), applied verbatim as a class."
  )

  attr(:class, :any, default: "size-4", doc: "Additional classes for sizing and color.")

  attr(:label, :string,
    default: nil,
    doc: "An accessible name. When set, the icon is exposed as a labeled image."
  )

  attr(:rest, :global, doc: "Additional HTML attributes.")

  @impl true
  def render(assigns) do
    ~H"""
    <span
      class={[@name, @class]}
      aria-hidden={is_nil(@label) && "true"}
      role={@label && "img"}
      aria-label={@label}
      {@flint_parts[:root]}
      {@rest}
    />
    """
  end
end
