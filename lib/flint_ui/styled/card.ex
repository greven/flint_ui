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
      tokens: [:color, :radius, :font],
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
          name: "--fl-card-surface-foreground",
          default: "var(--fl-color-surface-foreground)",
          doc: "The text color on the card surface."
        ),
        Var.new(
          name: "--fl-card-border",
          default: "var(--fl-color-border)",
          doc: "The outline color when `outline` is set."
        ),
        Var.new(
          name: "--fl-card-shadow",
          default: "var(--fl-shadow-base)",
          doc: "The outer elevation; set it to `0 0 #0000` to remove the shadow."
        ),
        Var.new(
          name: "--fl-card-divider",
          default: "var(--fl-color-border)",
          doc: "The hairline color used by divided body lines."
        ),
        Var.new(
          name: "--fl-card-band-surface",
          default:
            "light-dark(color-mix(in oklab, black 1.5%, var(--fl-card-surface)), color-mix(in oklab, black 10%, var(--fl-card-surface)))",
          doc:
            "The darker band used by separated headers and footers: 1.5% black in light, 10% in dark; inverted cards swap the strengths."
        ),
        Var.new(
          name: "--fl-card-body-surface",
          default: "var(--fl-card-surface)",
          doc: "The content surface used by separated bodies; defaults to the card surface."
        ),
        Var.new(
          name: "--fl-card-body-foreground",
          default: "var(--fl-card-surface-foreground)",
          doc: "The text color on the separated body surface."
        ),
        Var.new(
          name: "--fl-card-panel-surface",
          default:
            "light-dark(color-mix(in oklab, var(--fl-color-foreground) 2.5%, transparent), color-mix(in oklab, var(--fl-card-surface-foreground) 2.5%, var(--fl-card-surface)))",
          doc:
            "The inset/flush panel fill: a well on light solid and inverted cards, and a raised surface in dark or on tinted cards."
        ),
        Var.new(
          name: "--fl-card-panel-shadow",
          default: "light-dark(inset 0 1px 2px rgb(0 0 0 / 0.05), var(--fl-shadow-xs))",
          doc: "The inset/flush panel depth: inset for wells and raised for elevated panels."
        ),
        Var.new(
          name: "--fl-card-panel-inset",
          default: "var(--fl-spacing)",
          doc: "The small gap between an inset body panel and the card shell."
        ),
        Var.new(
          name: "--fl-card-body-border",
          default: "var(--fl-card-border)",
          doc: "The border color of inset and flush body panels."
        ),
        Var.new(
          name: "--fl-card-body-radius",
          default: "var(--fl-radius-lg)",
          doc: "The corner radius of inset and flush body panels."
        ),
        Var.new(
          name: "--fl-card-radius",
          default: "var(--fl-radius-xl)",
          doc: "The card corner radius."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "muted"],
          default: "solid",
          doc: "The neutral surface treatment of the card."
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
