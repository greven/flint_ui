defmodule FlintUI.Styled.Button do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Slot, Var}

  def entry do
    %Entry{
      name: :button,
      base: FlintUI.Base.Button,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add button",
      css: "styled/button.css",
      tokens: [:color, :radius, :font, :spacing, :shadow, :control, :duration, :ease],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the button's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the button's content.")
      ],
      vars: [
        Var.new(
          name: "--fl-button-color",
          default: "var(--fl-color-inverted)",
          doc: "The solid fill and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-button-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-button-text",
          default: "var(--fl-button-color)",
          doc:
            "The label color on tinted, bordered, ghost, and link variants; it maps to the role's `-text` token."
        )
      ],
      color_vars: [
        fill: "--fl-button-color",
        on_fill: "--fl-button-color-content",
        on_text: "--fl-button-text"
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "outline", "dashed", "ghost", "link"],
          default: "outline",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :color,
          values: ["primary", "secondary", "success", "info", "warning", "error", "neutral"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the variant is built from, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size."
        ),
        Prop.new(
          name: :square,
          values: [true, false],
          default: false,
          doc:
            "Whether the button is square. Use it for icon-only buttons; the width follows the selected size."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          doc: "Whether the button fills the width of its container."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and outline buttons show their highlight/inner line. Shadows are always on for solid, subtle, and outline; remove them with `--fl-control-shadow`."
        ),
        Prop.new(
          name: :inset,
          values: [true, false],
          default: false,
          doc:
            "Whether to negate the button's invisible padding so its content aligns with surrounding content. Most useful on ghost and link variants; the hit area is unchanged."
        )
      ]
    }
  end
end
