defmodule FlintUI.Styled.Card do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :card,
      base: FlintUI.Base.Card,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add card",
      css: "styled/card.css",
      tokens: [:color, :radius, :font, :shadow, :spacing],
      slots: [],
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
          name: "--fl-card-shadow",
          default: "var(--fl-shadow-base)",
          doc:
            "The outer elevation; set it to `0 0 #0000` to remove the shadow. The ghost variant already clears it."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "accented", "ghost"],
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
          doc: "Draws the card's outer elevation."
        ),
        Prop.new(
          name: :inverted,
          values: [true, false],
          default: false,
          doc: "Inverts the card's surface, text, border and divider colors."
        )
      ]
    }
  end
end
