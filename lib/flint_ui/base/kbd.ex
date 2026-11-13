defmodule FlintUI.Base.Kbd do
  @moduledoc """
  Displays a keyboard key or one key of a shortcut.

  The component renders the native `<kbd>` element, which identifies text the
  user should enter from a keyboard. Use it for key names, not as a generic
  label or for code:

      <.kbd>K</.kbd>
      <.kbd>Shift</.kbd>
      <.kbd>⌘</.kbd>

  Render one key per element and keep the separators outside them, so a shortcut
  reads as text while each key keeps its own cap:

      <span><.kbd>⌘</.kbd> + <.kbd>K</.kbd></span>

  The styled wrapper adds the key's `variant` (`raised`, `subtle`, or
  `outline`) and `size`. The base renders the semantic element only and ships
  no styling.

  ## Accessibility

  `<kbd>` is a plain text element, so assistive technology announces its content
  as written. Keep the label short and literal.

  A symbol-only key, such as `⌘`, may not be announced by name consistently, so
  pair it with visible text when the symbol matters, or give the surrounding
  shortcut an accessible label.

  A key is not interactive: the component adds no role, no focus behavior, and
  no click handling. Never use it as a button. When a shortcut is only a hint,
  keep the same action available through a visible button or menu item.

  ## Keyboard

  The component is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :kbd,
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
          value: "kbd",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "kbd",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block,
    required: true,
    doc: "The key label, for example `K`, `Shift`, `Esc`, or `⌘`."

  @impl true
  def render(assigns) do
    ~H"""
    <kbd {@rest} {@flint_parts[:root]}>{render_slot(@inner_block)}</kbd>
    """
  end
end
