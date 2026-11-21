defmodule FlintUI.Styled.Switch do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :switch,
      base: FlintUI.Base.Switch,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add switch",
      css: "styled/switch.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [{:checkbox, nav: false}, {:switch_group, nav: true}],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The switch size, from the shared control scale."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The on track fill and border, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE` for a one-off accent. The thumb is a neutral ink that only flips on a light fill."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-switch-fill",
          default: "var(--fl-color-border-strong)",
          doc: "The track background while the switch is off."
        ),
        Var.new(
          name: "--fl-switch-border",
          default: "var(--fl-color-border-strong)",
          doc: "The track border while the switch is off."
        ),
        Var.new(
          name: "--fl-switch-thumb",
          default: "var(--fl-color-surface)",
          doc: "The thumb color while the switch is off."
        ),
        Var.new(
          name: "--fl-switch-color",
          default: "var(--fl-color-primary)",
          doc: "The track fill and border while the switch is on."
        ),
        Var.new(
          name: "--fl-switch-color-content",
          default: "var(--fl-tone-on, var(--fl-color-text-inverted))",
          doc: "The thumb color on the on track."
        )
      ],
      color_vars: [
        fill: "--fl-switch-color",
        on_fill: "--fl-switch-color-content"
      ]
    }
  end
end
