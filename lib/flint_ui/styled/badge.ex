defmodule FlintUI.Styled.Badge do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Slot, Var}

  def entry do
    %Entry{
      name: :badge,
      base: FlintUI.Base.Badge,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add badge",
      css: "styled/badge.css",
      tokens: [:color, :radius, :font, :spacing, :control, :badge],
      dependencies: [:icon],
      slots: [
        Slot.new(
          name: :leading,
          doc:
            "Optional content rendered before the badge's content. A nested Button or Toggle is sized to the badge's row."
        ),
        Slot.new(
          name: :trailing,
          doc:
            "Optional content rendered after the badge's content. A nested Button or Toggle is sized to the badge's row and inset from the edge."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "surface", "outline", "ghost", "dot"],
          default: "subtle",
          doc: "The visual emphasis of the badge."
        ),
        Prop.new(
          name: :dashed,
          values: [true, false],
          default: false,
          doc:
            "Whether the badge's border is dashed. Composes with any variant; variants without a visible border are unaffected."
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
          doc: "The badge size."
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
            "Whether the badge renders as a full-radius pill. Pills also add inline padding so a short label clears the curve, and `pill` takes precedence over `radius`."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          doc: "Whether the badge fills the width of its container."
        ),
        Prop.new(
          name: :uppercase,
          values: [true, false],
          default: false,
          doc: "Whether the badge text is rendered in uppercase."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc: "An icon CSS class rendered before the badge's content. The icon is decorative."
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
          name: "--fl-badge-color",
          default: "var(--fl-color-inverted)",
          doc:
            "The solid fill, the outline border, and the source for tinted surfaces and borders."
        ),
        Var.new(
          name: "--fl-badge-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on the solid fill."
        ),
        Var.new(
          name: "--fl-badge-text",
          default: "var(--fl-badge-color)",
          doc:
            "The label color on tinted, bordered, and ghost variants; it maps to the role's `-text` token."
        ),
        Var.new(
          name: "--fl-badge-soft",
          default: "color-mix(in oklab, var(--fl-badge-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind soft and subtle badges; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-badge-soft-border",
          default:
            "color-mix(in oklab, var(--fl-badge-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The matching border for subtle and surface badges; roles map it to the role's `-soft-border` token. A raw color falls back to the soft border-strength mix."
        ),
        Var.new(
          name: "--fl-badge-border-width",
          default: "1px",
          doc:
            "The badge border width. Set it to `0` to remove the border without changing the variant."
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
