defmodule FlintUI.Styled.Input do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :input,
      base: FlintUI.Base.Input,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add input",
      css: "styled/input.css",
      primitives: [:field],
      tokens: [:color, :radius, :font, :spacing, :control, :field, :duration, :ease],
      related: [:textarea],
      props: [
        Prop.new(
          name: :size,
          primitive: :field,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          allow_custom: true,
          type: :any,
          doc:
            "The control size, from `xs` to `xl`, or a number for the native `size` attribute (a character width on text inputs, a row count on a listbox select)."
        ),
        Prop.new(
          name: :radius,
          primitive: :field,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius of the control, from `none` for square corners to `xl`, following the shared radius scale."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-input-check",
          default: "var(--fl-color-primary)",
          doc: "The checked checkbox fill and border."
        ),
        Var.new(
          name: "--fl-input-check-content",
          default: "var(--fl-color-neutral-50)",
          doc: "The check mark color on the checked checkbox."
        )
      ]
    }
  end
end
