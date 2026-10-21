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
          doc: "The label color for text-carrying variants."
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
            "Whether solid and outline buttons show their highlight/inner line. Shadows are always on for solid, subtle, and outline; remove them with `--fl-control-shadow`."
        )
      ]
    }
  end
end
