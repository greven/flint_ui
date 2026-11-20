defmodule FlintUI.Styled.Progress do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :progress,
      base: FlintUI.Base.Progress,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add progress",
      css: "styled/progress.css",
      tokens: [:color, :radius, :font, :spacing, :duration, :ease],
      related: [
        {:loading, nav: false},
        {:progress_group, nav: true},
        {:progress_ring, nav: true}
      ],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The track thickness and status text size. `xs` is 2px, `sm` 4px, `md` 8px, `lg` 12px, and `xl` 16px."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The fill color, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE` for a one-off accent. The track stays neutral."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl", "full"],
          default: "full",
          doc:
            "The corner radius of the track, from `none` for square corners to `xl`, or `full` for rounded ends."
        ),
        Prop.new(
          name: :striped,
          values: [true, false],
          default: false,
          doc:
            "Whether the fill carries a static diagonal stripe overlay. Use `animated` for moving stripes."
        ),
        Prop.new(
          name: :animated,
          values: [true, false],
          default: false,
          doc:
            "Whether the stripe pattern scrolls. Implies the stripe pattern, so `striped` is not required."
        ),
        Prop.new(
          name: :indeterminate,
          values: ["carousel", "swing", "elastic"],
          default: "carousel",
          doc:
            "The motion used while the bar is indeterminate: a bar that travels forward, swings between the ends, or stretches and shrinks. Ignored when `value` is set; whether the bar is indeterminate is decided by omitting `value`."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-progress-color",
          default: "var(--fl-color-primary)",
          doc: "The filled part of the track."
        ),
        Var.new(
          name: "--fl-progress-track",
          default: "var(--fl-color-surface-strong)",
          doc: "The unfilled part of the track."
        ),
        Var.new(
          name: "--fl-progress-height",
          default: "0.5rem",
          doc:
            "The thickness of the track, which the `size` prop sets. A vertical bar uses it as its width."
        )
      ],
      color_vars: [
        fill: "--fl-progress-color"
      ]
    }
  end
end
