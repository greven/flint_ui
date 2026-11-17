defmodule FlintUI.Styled.Slider do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :slider,
      base: FlintUI.Base.Slider,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add slider",
      css: "styled/slider.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [{:switch, nav: false}],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The track, thumb, and text size, from the shared control scale. A vertical slider keeps the same scale."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "primary",
          allow_custom: true,
          doc:
            "The filled track and the thumb ring, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. The thumb body stays a neutral surface."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-slider-color",
          default: "var(--fl-color-primary)",
          doc: "The filled part of the track and the thumb ring."
        ),
        Var.new(
          name: "--fl-slider-track",
          default: "var(--fl-color-surface-strong)",
          doc: "The unfilled part of the track."
        ),
        Var.new(
          name: "--fl-slider-thumb",
          default: "var(--fl-color-surface)",
          doc: "The thumb body."
        ),
        Var.new(
          name: "--fl-slider-thumb-border",
          default: "var(--fl-slider-color)",
          doc: "The thumb border. It follows `--fl-slider-color` unless set directly."
        ),
        Var.new(
          name: "--fl-slider-marker",
          default: "var(--fl-color-surface)",
          doc: "The step marker fill. A muted outline keeps it visible over the track."
        )
      ],
      color_vars: [
        fill: "--fl-slider-color"
      ]
    }
  end
end
