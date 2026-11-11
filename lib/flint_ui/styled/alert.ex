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
          values: ~w(solid soft subtle outline ghost),
          default: "subtle",
          doc: "The visual emphasis of the alert."
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
          default: "xs",
          doc: "The internal spacing of the alert."
        ),
        Prop.new(
          name: :shadow,
          values: [true, false],
          default: false,
          doc: "Draws the alert's outer elevation."
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
            "The label color on tinted, bordered, and ghost variants; it maps to the role's `-text` token."
        ),
        Var.new(
          name: "--fl-alert-soft",
          default: "color-mix(in oklab, var(--fl-alert-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind soft and subtle alerts; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-alert-soft-border",
          default:
            "color-mix(in oklab, var(--fl-alert-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The matching border for subtle alerts; roles map it to the role's `-soft-border` token. A raw color falls back to the soft border-strength mix."
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
