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
          doc: "The solid fill and focus ring color."
        ),
        Var.new(
          name: "--fl-button-color-foreground",
          default: "var(--fl-color-inverted-foreground)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-button-text",
          default: "var(--fl-button-color)",
          doc: "The label color for text-carrying variants."
        ),
        Var.new(
          name: "--fl-button-surface",
          default: "color-mix(in oklab, var(--fl-button-color) 10%, transparent)",
          doc: "The tinted background for soft and subtle variants."
        ),
        Var.new(
          name: "--fl-button-surface-hover",
          default: "color-mix(in oklab, var(--fl-button-color) 15%, transparent)",
          doc: "The tinted background on hover."
        ),
        Var.new(
          name: "--fl-button-border",
          default: "var(--fl-color-neutral-border)",
          doc: "The border color for outline and dashed variants."
        ),
        Var.new(
          name: "--fl-button-border-soft",
          default: "var(--fl-color-neutral-border-soft)",
          doc: "The border color for subtle buttons."
        ),
        Var.new(
          name: "--fl-button-radius",
          default: "var(--fl-radius-md)",
          doc: "The button corner radius."
        ),
        Var.new(
          name: "--fl-button-depth",
          default: "1",
          doc:
            "Scales the solid rim light and outline inner line; set to `0` to flatten. Does not affect shadows."
        ),
        Var.new(
          name: "--fl-button-highlight",
          default: "rgb(255 255 255 / calc(12% * var(--fl-button-depth, 1)))",
          doc: "The solid button's rim-light color."
        ),
        Var.new(
          name: "--fl-button-sheen-stop",
          default: "100%",
          doc: "Where the solid button's rim light fades out."
        ),
        Var.new(
          name: "--fl-button-inner-line",
          default: "inset 0 -1px 0 rgb(0 0 0 / calc(5% * var(--fl-button-depth, 1)))",
          doc: "The outline button's bottom inner line."
        ),
        Var.new(
          name: "--fl-button-shadow",
          default: "var(--fl-shadow-base)",
          doc:
            "The outer elevation used by solid, subtle, and outline buttons; set to `0 0 #0000` to remove it."
        ),
        Var.new(
          name: "--fl-button-press",
          default: "translateY(1px)",
          doc: "The press nudge; set to `none` to disable movement."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "outline", "dashed", "ghost", "link"],
          default: "subtle",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :color,
          values: ["primary", "secondary", "success", "info", "warning", "error", "neutral"],
          default: "neutral",
          doc: "The theme color the variant is built from."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and outline buttons show their highlight/inner line. Shadows are always on for solid, subtle, and outline; remove them with `--fl-button-shadow`."
        )
      ]
    }
  end
end
