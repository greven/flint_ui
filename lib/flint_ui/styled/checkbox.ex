defmodule FlintUI.Styled.Checkbox do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :checkbox,
      base: FlintUI.Base.Checkbox,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add checkbox",
      css: "styled/checkbox.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [{:checkbox_group, nav: true}],
      props: [
        Prop.new(
          name: :variant,
          values: ["simple", "card"],
          default: "simple",
          doc:
            "The visual treatment. `simple` is an inline checkbox; `card` makes the whole field a selectable surface."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The checkbox size, from the shared control scale."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "sm",
          doc:
            "The corner radius of the box, following the shared radius scale. A card surface rounds to twice the box radius so it keeps the theme's card curve."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The checked fill and border, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE` for a one-off accent. The check mark is a neutral ink that only flips on a light fill."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-checkbox-fill",
          default: "var(--fl-color-surface)",
          doc: "The box background while unchecked."
        ),
        Var.new(
          name: "--fl-checkbox-border",
          default: "var(--fl-color-border-strong)",
          doc: "The box border while unchecked."
        ),
        Var.new(
          name: "--fl-checkbox-color",
          default: "var(--fl-color-primary)",
          doc: "The checked fill and border, and the card's checked accent."
        ),
        Var.new(
          name: "--fl-checkbox-color-content",
          default: "var(--fl-tone-on, var(--fl-color-text-inverted))",
          doc: "The check mark color on the checked box."
        )
      ],
      color_vars: [
        fill: "--fl-checkbox-color",
        on_fill: "--fl-checkbox-color-content"
      ]
    }
  end
end
