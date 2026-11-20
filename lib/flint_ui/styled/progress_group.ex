defmodule FlintUI.Styled.ProgressGroup do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :progress_group,
      base: FlintUI.Base.ProgressGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add progress_group",
      css: "styled/progress_group.css",
      tokens: [:color, :radius, :font, :spacing, :duration, :ease],
      related: [:progress],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The track thickness, legend text size, and dot size. `xs` is 2px, `sm` 4px, `md` 8px, `lg` 12px, and `xl` 16px."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The fallback color for segments that do not set their own, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE`. The track stays neutral."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl", "full"],
          default: "full",
          doc:
            "The corner radius of the track, from `none` for square corners to `xl`, or `full` for rounded ends."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-progress-group-color",
          default: "var(--fl-color-primary)",
          doc: "The fallback segment color."
        ),
        Var.new(
          name: "--fl-progress-group-track",
          default: "var(--fl-color-surface-strong)",
          doc: "The unfilled part of the track."
        ),
        Var.new(
          name: "--fl-progress-group-height",
          default: "0.5rem",
          doc:
            "The thickness of the track, which the `size` prop sets. A vertical group uses it as its width."
        ),
        Var.new(
          name: "--fl-progress-group-dot-size",
          default: "0.5rem",
          doc: "The diameter of the legend dot. The `size` prop sets it."
        )
      ],
      color_vars: [
        fill: "--fl-progress-group-color"
      ]
    }
  end
end
