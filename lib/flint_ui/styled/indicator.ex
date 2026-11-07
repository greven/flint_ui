defmodule FlintUI.Styled.Indicator do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :indicator,
      base: FlintUI.Base.Indicator,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add indicator",
      css: "styled/indicator.css",
      tokens: [:color],
      props: [
        Prop.new(
          name: :variant,
          values: ~w(solid soft subtle outline dashed ghost),
          default: "solid",
          forwarded_to: :badge,
          doc: "The visual emphasis of the nested badge."
        ),
        Prop.new(
          name: :color,
          values: ~w(neutral info success warning error primary secondary),
          default: "error",
          allow_custom: true,
          forwarded_to: :badge,
          doc:
            "The theme color the nested badge is built from, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ~w(xs sm md lg xl),
          default: "xs",
          forwarded_to: :badge,
          doc: "The nested badge size."
        ),
        Prop.new(
          name: :radius,
          values: ~w(none xs sm md lg xl full),
          default: "full",
          forwarded_to: :badge,
          doc:
            "The nested badge corner radius. Use `full` for a pill; a full badge narrower than its height, such as a single digit, renders as a circle."
        ),
        Prop.new(
          name: :position,
          values: ~w(top-right top-left bottom-right bottom-left),
          default: "top-right",
          doc:
            "The anchor corner the badge is placed on. `left` and `right` follow the writing direction."
        ),
        Prop.new(
          name: :inset,
          values: [true, false],
          default: false,
          doc: "Whether the badge sits fully inside the anchor's corner instead of straddling it."
        ),
        Prop.new(
          name: :ring,
          values: [true, false],
          default: false,
          doc: "Adds a ring in the surrounding surface color so the badge reads as a cutout."
        )
      ],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-indicator-offset",
          default: "0px",
          doc:
            "Extra distance between the badge and the corner. Positive values push the badge outward."
        ),
        Var.new(
          name: "--fl-indicator-ring-width",
          default: "2px",
          doc: "The width of the surface ring."
        ),
        Var.new(
          name: "--fl-indicator-ring-color",
          default: "var(--fl-color-surface)",
          doc: "The ring color. Match it to the surrounding surface on a tinted card or image."
        )
      ],
      color_vars: [
        fill: "--fl-badge-color",
        on_fill: "--fl-badge-color-content",
        on_text: "--fl-badge-text"
      ]
    }
  end
end
