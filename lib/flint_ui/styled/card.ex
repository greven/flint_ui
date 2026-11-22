defmodule FlintUI.Styled.Card do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :card,
      base: FlintUI.Base.Card,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add card",
      css: "styled/card.css",
      tokens: [:color, :radius, :font, :shadow, :elevation, :spacing],
      primitives: [:elevation],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "strong", "ghost"],
          default: "solid",
          doc:
            "The neutral surface treatment of the card. `ghost` drops the card's own surface and elevation, composing with `outline` for an outline-only card or a bare container."
        ),
        Prop.new(
          name: :body,
          values: [
            "seamless",
            "inset",
            "flush",
            "divided",
            "separated",
            "separated-header",
            "separated-footer"
          ],
          default: "seamless",
          doc: "How the header, body and footer are set apart."
        ),
        Prop.new(
          name: :spacing,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The internal spacing of the card."
        ),
        Prop.new(
          name: :outline,
          values: [true, false],
          default: true,
          doc: "Draws the card outline."
        ),
        Prop.new(
          name: :shadow,
          values: [true, false],
          default: true,
          doc:
            "Draws the card's outer elevation. The shadow is the shared raised-surface recipe; tune it with `--fl-elevation-level` or replace it with `--fl-card-shadow`. A replacement also drops the linked-card hover lift."
        ),
        Prop.new(
          name: :inverted,
          values: [true, false],
          default: false,
          doc: "Inverts the card's surface, text, border and divider colors."
        ),
        Prop.new(
          name: :indicator,
          values: [true, false],
          default: false,
          doc:
            "Marks a linked card as clickable with a dimmed arrow in the top-right corner and the `data-indicator` hook. Use it to show that the card is a link, that it leaves the site, or another purpose. It only applies to a linked card and does not change where the link opens; set `target` and `rel` when it should open in a new tab."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :indicator_icon,
          type: :string,
          default: "lucide-arrow-up-right",
          doc:
            "The icon class for the corner arrow. Set it to a class from your icon set, or to an empty string to keep the `data-indicator` hook without an arrow."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-card-spacing",
          default: "calc(var(--fl-spacing) * 5)",
          doc: "The inline inset and gap between regions; the `spacing` prop sets it."
        ),
        Var.new(
          name: "--fl-card-surface",
          default: "var(--fl-color-surface)",
          doc: "The card's background surface; `variant` selects it."
        ),
        Var.new(
          name: "--fl-card-text",
          default: "var(--fl-color-text)",
          doc: "The text color on the card surface."
        ),
        Var.new(
          name: "--fl-card-border",
          default: "var(--fl-color-border)",
          doc: "The outline color and the source for dividers and panel borders."
        ),
        Var.new(
          name: "--fl-card-border-hover",
          default: "color-mix(in oklab, var(--fl-card-border), var(--fl-card-text) 20%)",
          doc:
            "The outline color while a linked card is hovered or focused. It defaults to the resting border plus a share of the card ink; set it per instance with `style` for a colored edge."
        ),
        Var.new(
          name: "--fl-card-shadow",
          default: "var(--fl-elevation-surface)",
          doc:
            "The outer elevation; it defaults to the shared raised-surface recipe and follows `--fl-elevation-level`. Set it to `0 0 #0000` to remove the shadow. The ghost variant already clears it."
        )
      ]
    }
  end
end
