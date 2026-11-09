defmodule FlintUI.Base.Flag do
  @moduledoc """
  Renders a flag from a host-provided CSS class.

  The `name` is applied verbatim as a CSS class. FlintUI does not ship flag
  assets; `mix flint.icons flags` installs Flag Icons as either a Tailwind
  plugin or plain CSS. The generated classes are `flag-<country>` for the 4:3
  flag and `flag-<country>-square` for the 1:1 flag:

      <.flag name="flag-pt" />
      <.flag name="flag-pt-square" label="Portugal" />

  The styled wrapper adds the flag box, size scale, radius, overlay, border, and
  shadow. The headless component only owns the class, the accessible name, and
  the `data-*` contract.

  ## Accessibility

  A flag is decorative by default and hidden from assistive technology. When it
  conveys meaning on its own, pass `label` to expose it as an image with an
  accessible name:

      <.flag name="flag-pt" label="Portugal" />

  A flag is not a language. Use a text label for a language and only use a flag
  when it represents the country or region itself.

  ## Keyboard

  The flag is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :flag,
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
          value: "flag",
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
        "data-element" => "flag",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :name, :string,
    required: true,
    doc: "The flag CSS class (e.g. `\"flag-pt\"` or `\"flag-pt-square\"`), applied verbatim."

  attr :class, :any,
    default: nil,
    doc: "Additional classes for the flag root."

  attr :label, :string,
    default: nil,
    doc: "An accessible name. When set, the flag is exposed as a labeled image."

  attr :rest, :global, doc: "Additional HTML attributes."

  @impl true
  def render(assigns) do
    ~H"""
    <span
      {@rest}
      class={[@name, @class]}
      aria-hidden={is_nil(@label) && "true"}
      role={@label && "img"}
      aria-label={@label}
      {@flint_parts[:root]}
    />
    """
  end
end
