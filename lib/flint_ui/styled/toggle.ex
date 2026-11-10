defmodule FlintUI.Styled.Toggle do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Slot, Var}

  def entry do
    %Entry{
      name: :toggle,
      base: FlintUI.Base.Toggle,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add toggle",
      css: "styled/toggle.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [:group],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the toggle's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the toggle's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "subtle", "surface", "outline", "ghost"],
          default: "solid",
          doc: "How the pressed state is emphasized."
        ),
        Prop.new(
          name: :dashed,
          values: [true, false],
          default: false,
          doc:
            "Whether the toggle's border is dashed. Composes with any variant; variants without a visible border are unaffected."
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
            "Whether the toggle renders as a full-radius pill. The control keeps its height and padding."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and surface toggles show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-toggle-color",
          default: "var(--fl-color-inverted)",
          doc:
            "The pressed fill, the pressed outline border, and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-toggle-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on the pressed solid fill."
        ),
        Var.new(
          name: "--fl-toggle-text",
          default: "var(--fl-toggle-color)",
          doc: "The label color for text-carrying variants."
        ),
        Var.new(
          name: "--fl-toggle-soft",
          default: "color-mix(in oklab, var(--fl-toggle-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind pressed subtle toggles; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-toggle-soft-border",
          default:
            "color-mix(in oklab, var(--fl-toggle-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The matching border for pressed subtle and surface toggles; colored roles map it to the role's `-soft-border` token. Neutral strengthens the shared mix so the pressed state stays legible. A raw color falls back to the soft border-strength mix."
        )
      ],
      color_vars: [
        fill: "--fl-toggle-color",
        on_fill: "--fl-toggle-color-content",
        on_text: "--fl-toggle-text"
      ]
    }
  end
end
