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
          name: "--fl-button-color-foreground",
          default: "var(--fl-color-inverted-foreground)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-button-text",
          default: "var(--fl-button-color)",
          doc:
            "The label color for ghost and link variants; it maps to the role's regular `-text` token."
        ),
        Var.new(
          name: "--fl-button-soft-text",
          default: "var(--fl-button-color)",
          doc:
            "The label color for tinted and bordered variants (soft, subtle, outline, dashed); it maps to the role's `-soft-foreground` token."
        )
      ],
      color_vars: [
        fill: "--fl-button-color",
        on_fill: "--fl-button-color-foreground",
        on_page: "--fl-button-text",
        on_tint: "--fl-button-soft-text"
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
