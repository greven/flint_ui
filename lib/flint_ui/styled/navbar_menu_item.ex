defmodule FlintUI.Styled.NavbarMenuItem do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Slot}

  def entry do
    %Entry{
      name: :navbar_menu_item,
      base: FlintUI.Base.NavbarMenuItem,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navbar_menu_item",
      css: "styled/navbar_menu_item.css",
      tokens: [:color, :font, :spacing, :radius, :duration, :ease, :control],
      related: [:navbar_menu],
      dependencies: [:icon],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the item's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the item's content.")
      ],
      props: [],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc:
            "An icon CSS class rendered before the item's content. The icon is decorative; pass `aria-label` when it is the only visible content."
        ),
        Attr.new(
          name: :trailing_icon,
          type: :string,
          doc:
            "An icon CSS class rendered after the item's content, such as an external-link mark. The icon is decorative."
        ),
        Attr.new(
          name: :text,
          type: :string,
          fills_content: true,
          doc:
            "A text label rendered when the default slot is not given. The default slot wins when both are set."
        )
      ]
    }
  end
end
