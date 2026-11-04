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
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the badge's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the badge's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "outline", "dashed", "ghost", "link", "dot"],
          default: "subtle",
          doc: "The visual emphasis of the badge."
        ),
        Prop.new(
          name: :color,
          values: ["primary", "secondary", "success", "info", "warning", "error", "neutral"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the variant is built from, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The badge size."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl", "full"],
          default: "md",
          doc:
            "The corner radius. Use `none` for square corners and `full` for a pill shape; `xs` through `xl` follow the shared radius scale."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          doc: "Whether the badge fills the width of its container."
        ),
        Prop.new(
          name: :inset,
          values: [true, false],
          default: false,
          doc:
            "Whether to negate the badge's padding so its content aligns with surrounding content. The hit area is unchanged."
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
          doc: "An icon CSS class rendered before the badge's content. The icon is decorative."
        ),
        Attr.new(
          name: :text,
          type: :string,
          doc:
            "A text label rendered when the default slot is not given. The default slot wins when both are set."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-badge-color",
          default: "var(--fl-color-inverted)",
          doc: "The solid fill and the source for tinted surfaces and borders."
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
            "The label color on tinted, bordered, ghost, and link variants; it maps to the role's `-text` token."
        ),
        Var.new(
          name: "--fl-badge-soft",
          default: "color-mix(in oklab, var(--fl-badge-color) 10%, var(--fl-color-control))",
          doc:
            "The tinted surface behind soft and subtle badges; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-badge-soft-border",
          default:
            "color-mix(in oklab, var(--fl-badge-color) var(--fl-border-strength), var(--fl-color-control))",
          doc:
            "The matching border for subtle, outline, and dashed badges; roles map it to the role's `-soft-border` token."
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
