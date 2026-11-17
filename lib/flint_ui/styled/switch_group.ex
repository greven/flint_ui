defmodule FlintUI.Styled.SwitchGroup do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :switch_group,
      base: FlintUI.Base.SwitchGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add switch_group",
      css: "styled/switch_group.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [:switch],
      props: [
        Prop.new(
          name: :orientation,
          values: ["vertical", "horizontal"],
          default: "vertical",
          doc: "The option layout. `vertical` stacks them; `horizontal` wraps them in a row."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          forwarded_to: :switch,
          doc: "The switch size, forwarded to every option."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          forwarded_to: :switch,
          doc:
            "The on track fill and border, forwarded to every option. Accepts a semantic role, a Tailwind palette color such as `tw:rose` (500), or a raw CSS color. The thumb is a neutral ink that only flips on a light fill."
        )
      ],
      color_vars: [
        fill: "--fl-switch-color",
        on_fill: "--fl-switch-color-content"
      ]
    }
  end
end
