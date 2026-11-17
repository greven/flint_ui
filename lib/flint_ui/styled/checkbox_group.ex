defmodule FlintUI.Styled.CheckboxGroup do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :checkbox_group,
      base: FlintUI.Base.CheckboxGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add checkbox_group",
      css: "styled/checkbox_group.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [:checkbox],
      props: [
        Prop.new(
          name: :orientation,
          values: ["vertical", "horizontal"],
          default: "vertical",
          doc: "The option layout. `vertical` stacks them; `horizontal` wraps them in a row."
        ),
        Prop.new(
          name: :variant,
          values: ["simple", "card"],
          default: "simple",
          doc:
            "The visual treatment forwarded to every option. `simple` is an inline checkbox; `card` makes each option a selectable surface."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          forwarded_to: :checkbox,
          doc: "The checkbox size, forwarded to every option."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "sm",
          forwarded_to: :checkbox,
          doc: "The box and card radius, forwarded to every option."
        )
      ]
    }
  end
end
