defmodule FlintUI.Styled.ProgressRing do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :progress_ring,
      base: FlintUI.Base.ProgressRing,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add progress_ring",
      css: "styled/progress_ring.css",
      tokens: [:color, :font, :spacing, :duration, :ease],
      related: [{:progress, nav: false}],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The outer diameter of the ring and the size of the status text. `xs` is 2.5rem, `sm` 3rem, `md` 4rem, `lg` 6rem, and `xl` 8rem."
        ),
        Prop.new(
          name: :thickness,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The stroke width as a share of the diameter, so the ring stays proportional at every `size`. `xs` is 3%, `sm` 4%, `md` 6%, `lg` 8%, and `xl` 10%."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The arc color, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. The track stays neutral."
        ),
        Prop.new(
          name: :indeterminate,
          values: ["spin", "sweep"],
          default: "spin",
          doc:
            "The motion used while the ring is indeterminate: a fixed arc that rotates, or an arc that grows and shrinks while it rotates. Ignored when `value` is set; whether the ring is indeterminate is decided by omitting `value`."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-progress-ring-color",
          default: "var(--fl-color-primary)",
          doc: "The filled arc."
        ),
        Var.new(
          name: "--fl-progress-ring-track",
          default: "var(--fl-color-surface-strong)",
          doc: "The unfilled circle behind the arc."
        ),
        Var.new(
          name: "--fl-progress-ring-size",
          default: "4rem",
          doc:
            "The outer diameter of the ring, which the `size` prop sets. Override it for a one-off diameter."
        ),
        Var.new(
          name: "--fl-progress-ring-thickness",
          default: "6",
          doc:
            "The stroke width in the ring's 100-unit drawing space, which the `thickness` prop sets. The value is unitless and scales with the diameter."
        )
      ],
      color_vars: [
        fill: "--fl-progress-ring-color"
      ]
    }
  end
end
