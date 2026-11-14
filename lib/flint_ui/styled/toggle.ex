defmodule FlintUI.Styled.Toggle do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Slot, Var}

  @colors ["neutral", "info", "success", "warning", "error", "primary", "secondary"]
  @variants ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"]

  def entry do
    %Entry{
      name: :toggle,
      base: FlintUI.Base.Toggle,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add toggle",
      css: "styled/toggle.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      related: [:group],
      dependencies: [:icon],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the toggle's content."),
        Slot.new(
          name: :on,
          doc:
            "Content shown only while the toggle is on. Both state slots render in the DOM; the theme hides the inactive one, so a headless consumer hides them from `data-state`."
        ),
        Slot.new(
          name: :off,
          doc:
            "Content shown only while the toggle is off. Both state slots render in the DOM; the theme hides the inactive one, so a headless consumer hides them from `data-state`."
        ),
        Slot.new(name: :trailing, doc: "Optional content rendered after the toggle's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: @variants,
          default: "ghost",
          doc: "The visual treatment of the untoggled control."
        ),
        Prop.new(
          name: :active_variant,
          values: ["inherit"] ++ @variants,
          default: "soft",
          resolved: ["inherit"],
          doc: "The visual treatment of the toggled control. `inherit` follows `variant` instead."
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
          values: @colors,
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the untoggled control and its variants are built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :active_color,
          values: ["inherit"] ++ @colors,
          default: "inherit",
          allow_custom: true,
          resolved: ["inherit"],
          doc:
            "The theme color of the toggled control. `inherit` follows `color`. Accepts the same roles, Tailwind palette colors, and raw colors as `color`."
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
            "Whether the toggle renders as a full-radius pill. The control keeps its height and padding; combine it with `square` for a circular icon-only toggle."
        ),
        Prop.new(
          name: :square,
          values: [true, false],
          default: false,
          doc:
            "Whether the toggle is square. Use it for icon-only toggles; the width follows the selected size."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          doc: "Whether the toggle fills the width of its container."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between"],
          default: "center",
          doc:
            "Where the content sits when the toggle is wider than its content. `between` pushes the leading and trailing content to the edges."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether the solid and surface treatments show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
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
            "An icon CSS class rendered before the toggle's content. The icon is decorative; use `aria-label` when the toggle has no text."
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
          name: "--fl-toggle-color",
          default: "var(--fl-color-inverted)",
          doc:
            "The untoggled fill, the untoggled outline border, and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-toggle-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on an untoggled solid fill."
        ),
        Var.new(
          name: "--fl-toggle-text",
          default: "var(--fl-toggle-color)",
          doc: "The untoggled label color for text-carrying variants."
        ),
        Var.new(
          name: "--fl-toggle-soft",
          default: "color-mix(in oklab, var(--fl-toggle-color) 10%, var(--fl-color-surface))",
          doc:
            "The tinted surface behind an untoggled soft or subtle toggle; roles map it to the role's `-soft` token."
        ),
        Var.new(
          name: "--fl-toggle-soft-border",
          default:
            "color-mix(in oklab, var(--fl-toggle-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc:
            "The matching border for an untoggled subtle or surface toggle; roles map it to the role's `-soft-border` token. Neutral strengthens the shared mix so the untoggled state stays legible. A raw color falls back to the soft border-strength mix. The toggled state reads the matching `--fl-toggle-active-*` variable, which follows this one unless `active-color` is set."
        )
      ],
      color_vars: [
        fill: "--fl-toggle-color",
        on_fill: "--fl-toggle-color-content",
        on_text: "--fl-toggle-text"
      ],
      active_color: %{
        prop: :active_color,
        inherit: "inherit",
        vars: [
          fill: "--fl-toggle-active-color",
          on_fill: "--fl-toggle-active-color-content",
          on_text: "--fl-toggle-active-text",
          soft: "--fl-toggle-active-soft",
          soft_border: "--fl-toggle-active-soft-border"
        ]
      }
    }
  end
end
