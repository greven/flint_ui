defmodule FlintUI.Styled.Radio do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :radio,
      base: FlintUI.Base.Radio,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add radio",
      css: "styled/radio.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [{:radio_group, nav: true}],
      props: [
        Prop.new(
          name: :variant,
          values: ["simple", "card"],
          default: "simple",
          doc:
            "The visual treatment. `simple` is an inline radio; `card` makes the whole field a selectable surface."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The radio size, from the shared control scale."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "sm",
          doc:
            "The corner radius of the card, following the shared radius scale; the card rounds to twice the value so it keeps the theme's card curve. The radio indicator stays circular."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The selected fill and border, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE` for a one-off accent. The dot is a neutral ink that only flips on a light fill."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-radio-fill",
          default: "var(--fl-color-surface)",
          doc: "The circle background while unselected."
        ),
        Var.new(
          name: "--fl-radio-border",
          default: "var(--fl-color-border-strong)",
          doc: "The circle border while unselected."
        ),
        Var.new(
          name: "--fl-radio-color",
          default: "var(--fl-color-primary)",
          doc: "The selected fill and border, and the card's selected accent."
        ),
        Var.new(
          name: "--fl-radio-color-content",
          default: "var(--fl-tone-content, var(--fl-color-text-inverted))",
          doc: "The dot color on the selected circle."
        )
      ],
      color_vars: [
        fill: "--fl-radio-color",
        on_fill: "--fl-radio-color-content"
      ]
    }
  end
end
