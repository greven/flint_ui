defmodule FlintUI.Styled.DropdownItem do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Var}

  def entry do
    %Entry{
      name: :dropdown_item,
      base: FlintUI.Base.DropdownItem,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_item",
      css: "styled/dropdown_item.css",
      tokens: [:color, :radius, :spacing, :font, :duration, :ease],
      related: [:dropdown],
      dependencies: [:icon],
      slots: [],
      props: [],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc:
            "An icon CSS class rendered before the item's content. The icon is decorative; keep the item's text so it keeps its accessible name."
        ),
        Attr.new(
          name: :text,
          type: :string,
          fills_content: true,
          doc:
            "A text label rendered when the default slot is not given. The default slot wins when both are set."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-dropdown-item-text",
          default: "var(--fl-color-text-toned)",
          doc:
            "The item label color at rest. Hover, focus, and the active row fall back to the default text ink unless this is set."
        ),
        Var.new(
          name: "--fl-dropdown-item-highlight",
          default: "var(--fl-color-surface-subtle)",
          doc:
            "The hover and active background behind the item, shared by every intent so a row's intent color never spreads into its fill."
        ),
        Var.new(
          name: "--fl-dropdown-item-accent",
          default: "color-mix(in oklab, currentcolor 70%, transparent)",
          doc:
            "The color of the item's icon and other secondary marks. It is a muted step of the row's label ink, so `intent` and hover retint it with the text."
        )
      ]
    }
  end
end
