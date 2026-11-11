defmodule FlintUI.Styled.Alert do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :alert,
      base: FlintUI.Base.Alert,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add alert",
      css: "styled/alert.css",
      tokens: [:color, :radius, :font, :shadow, :spacing, :duration, :ease],
      dependencies: [:icon],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ~w(solid soft outline),
          default: "outline",
          doc:
            "The visual emphasis of the alert. `outline` is the default tinted surface with the role's full-strength edge, `soft` keeps the tint with the faint matching edge, and `solid` fills the alert with the role color."
        ),
        Prop.new(
          name: :color,
          values: ~w(neutral info success warning error primary secondary),
          default: nil,
          allow_custom: true,
          doc:
            "The theme color the variant is built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. Defaults to the `intent` when set, otherwise `neutral`."
        ),
        Prop.new(
          name: :spacing,
          values: ~w(xs sm md lg xl),
          default: "md",
          doc: "The internal spacing of the alert."
        ),
        Prop.new(
          name: :shadow,
          values: [true, false],
          default: true,
          doc: "Draws the alert's outer elevation."
        ),
        Prop.new(
          name: :border,
          values: ~w(solid dashed none),
          default: "solid",
          doc:
            "The edge treatment. `solid` is the default, `dashed` keeps the variant's color with a dashed stroke, and `none` removes the edge while keeping the variant's surface."
        ),
        Prop.new(
          name: :background,
          values: [true, false],
          default: true,
          doc:
            "Whether the alert paints its surface. Set false to keep the border and elevation over a transparent background; the label falls back to the role text."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :show_icon,
          type: :boolean,
          default: true,
          doc:
            "Whether to render the default icon selected by `intent`. An explicit `:icon` slot always renders."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-alert-color",
          default: "var(--fl-color-inverted)",
          doc:
            "The solid fill, the outline border, and the source for tinted surfaces and borders."
        ),
        Var.new(
          name: "--fl-alert-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-alert-text",
          default: "var(--fl-alert-color)",
          doc:
            "The label color on tinted variants and alerts without a background; it maps to the role's `-text` token. The body derives a slightly muted mix from it."
        ),
        Var.new(
          name: "--fl-alert-soft",
          default: "color-mix(in oklab, var(--fl-alert-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind soft and outline alerts; roles map it to the role's `-soft` token. Matching-color controls nested in the alert read one elevated step of the same token."
        ),
        Var.new(
          name: "--fl-alert-soft-border",
          default:
            "color-mix(in oklab, var(--fl-alert-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The faint matching border for soft alerts; roles map it to the role's `-soft-border` token. Outline uses the full role edge instead. A raw color falls back to the soft border-strength mix."
        )
      ],
      color_vars: [
        fill: "--fl-alert-color",
        on_fill: "--fl-alert-color-content",
        on_text: "--fl-alert-text"
      ]
    }
  end
end
