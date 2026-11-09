defmodule FlintUI.Styled.Button do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Slot, Var}

  def entry do
    %Entry{
      name: :button,
      base: FlintUI.Base.Button,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add button",
      css: "styled/button.css",
      tokens: [:color, :radius, :font, :spacing, :shadow, :control, :duration, :ease],
      related: [:group],
      dependencies: [:icon],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the button's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the button's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"],
          default: "surface",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :dashed,
          values: [true, false],
          default: false,
          doc:
            "Whether the button's border is dashed. Composes with any variant; variants without a visible border are unaffected."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the variant is built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius, from `none` for square corners to `xl`, following the shared radius scale. Use `pill` for a full-radius pill."
        ),
        Prop.new(
          name: :pill,
          values: [true, false],
          default: false,
          doc:
            "Whether the button renders as a full-radius pill. The control keeps its height and padding; combine it with `square` for a circular icon-only button."
        ),
        Prop.new(
          name: :square,
          values: [true, false],
          default: false,
          doc:
            "Whether the button is square. Use it for icon-only buttons; the width follows the selected size."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          doc: "Whether the button fills the width of its container."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between"],
          default: "center",
          doc:
            "Where the content sits when the button is wider than its content. `between` pushes the leading and trailing content to the edges."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and surface buttons show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
        ),
        Prop.new(
          name: :inset,
          values: ["top", "bottom", "left", "right", "all"],
          default: false,
          multi: true,
          doc:
            "Negates the control's padding on the selected sides so its content aligns with surrounding content. Pass `inset` for every side, or a space-separated combination of `top`, `bottom`, `left`, `right`, and `all` (for example, `inset=\"top bottom\"`). Left and right follow the writing direction. The hit area is unchanged. Most useful on ghost and link variants."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc:
            "An icon CSS class rendered before the button's content. The icon is decorative; use `aria-label` when the button has no text."
        ),
        Attr.new(
          name: :text,
          type: :string,
          fills_content: true,
          doc:
            "A text label rendered when the default slot is not given. The default slot wins when both are set."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-button-color",
          default: "var(--fl-color-inverted)",
          doc: "The solid fill, the outline border, and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-button-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-button-text",
          default: "var(--fl-button-color)",
          doc:
            "The label color on tinted, bordered, ghost, and link variants; it maps to the role's `-text` token."
        ),
        Var.new(
          name: "--fl-button-soft",
          default: "color-mix(in oklab, var(--fl-button-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind soft and subtle buttons; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-button-soft-border",
          default:
            "color-mix(in oklab, var(--fl-button-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The matching border for subtle and surface buttons; roles map it to the role's `-soft-border` token. A raw color falls back to the soft border-strength mix."
        )
      ],
      color_vars: [
        fill: "--fl-button-color",
        on_fill: "--fl-button-color-content",
        on_text: "--fl-button-text"
      ]
    }
  end
end
