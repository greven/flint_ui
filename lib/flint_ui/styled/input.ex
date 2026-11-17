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
      tokens: [:color, :radius, :font, :spacing, :control, :field, :duration, :ease],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          allow_custom: true,
          type: :any,
          doc:
            "The control size, from `xs` to `xl`, or a number for the native `size` attribute (a character width on text inputs, a row count on a listbox select)."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius of the control, from `none` for square corners to `xl`, following the shared radius scale."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-input-fill",
          default: "var(--fl-color-surface)",
          doc: "The control background."
        ),
        Var.new(
          name: "--fl-input-border",
          default: "var(--fl-color-border)",
          doc: "The control border color at rest."
        ),
        Var.new(
          name: "--fl-input-placeholder",
          default: "var(--fl-color-text-dimmed)",
          doc: "The placeholder text color."
        ),
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
