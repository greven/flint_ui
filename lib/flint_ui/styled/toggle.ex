defmodule FlintUI.Styled.Toggle do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Slot}

  @colors ["neutral", "info", "success", "warning", "error", "primary", "secondary"]
  @variants ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"]

  def entry do
    %Entry{
      name: :toggle,
      base: FlintUI.Base.Toggle,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add toggle",
      css: "styled/toggle.css",
      primitives: [:control],
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
          primitive: :control,
          values: @variants,
          default: "ghost",
          doc: "The visual treatment of the untoggled control."
        ),
        Prop.new(
          name: :active_variant,
          primitive: :control,
          state: "on",
          values: ["inherit"] ++ @variants,
          default: "soft",
          resolved: ["inherit"],
          doc: "The visual treatment of the toggled control. `inherit` follows `variant` instead."
        ),
        Prop.new(
          name: :dashed,
          primitive: :control,
          values: [true, false],
          default: false,
          doc:
            "Whether the toggle's border is dashed. Composes with any variant; variants without a visible border are unaffected."
        ),
        Prop.new(
          name: :color,
          primitive: :control,
          values: @colors,
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the untoggled control and its variants are built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :active_color,
          primitive: :control,
          values: ["inherit"] ++ @colors,
          default: "inherit",
          allow_custom: true,
          resolved: ["inherit"],
          doc:
            "The theme color of the toggled control. `inherit` follows `color`. Accepts the same roles, Tailwind palette colors, and raw colors as `color`."
        ),
        Prop.new(
          name: :size,
          primitive: :control,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size."
        ),
        Prop.new(
          name: :radius,
          primitive: :control,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius, from `none` for square corners to `xl`, following the shared radius scale. Use `pill` for a full-radius pill."
        ),
        Prop.new(
          name: :pill,
          primitive: :control,
          values: [true, false],
          default: false,
          doc:
            "Whether the toggle renders as a full-radius pill. The control keeps its height and padding; combine it with `square` for a circular icon-only toggle."
        ),
        Prop.new(
          name: :square,
          primitive: :control,
          values: [true, false],
          default: false,
          doc:
            "Whether the toggle is square. Use it for icon-only toggles; the width follows the selected size."
        ),
        Prop.new(
          name: :wide,
          primitive: :control,
          values: [true, false],
          default: false,
          doc: "Whether the toggle fills the width of its container."
        ),
        Prop.new(
          name: :justify,
          primitive: :control,
          values: ["start", "center", "end", "between"],
          default: "center",
          doc:
            "Where the content sits when the toggle is wider than its content. `between` pushes the leading and trailing content to the edges."
        ),
        Prop.new(
          name: :depth,
          primitive: :control,
          values: [true, false],
          default: true,
          doc:
            "Whether the solid and surface treatments show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
        ),
        Prop.new(
          name: :inset,
          primitive: :control,
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
      color_vars: [
        fill: "--fl-control-color",
        on_fill: "--fl-control-color-content",
        on_text: "--fl-control-text"
      ],
      active_color: %{
        prop: :active_color,
        inherit: "inherit",
        vars: [
          fill: "--fl-control-active-color",
          on_fill: "--fl-control-active-color-content",
          on_text: "--fl-control-active-text",
          soft: "--fl-control-active-soft",
          soft_border: "--fl-control-active-soft-border"
        ]
      }
    }
  end
end
