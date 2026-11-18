defmodule FlintUI.Styled.Button do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Slot}

  def entry do
    %Entry{
      name: :button,
      base: FlintUI.Base.Button,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add button",
      css: nil,
      tokens: [:color, :radius, :font, :spacing, :shadow, :control, :duration, :ease],
      primitives: [:control],
      related: [:group],
      dependencies: [:icon],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the button's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the button's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          primitive: :control,
          values: ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"],
          default: "surface",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :dashed,
          primitive: :control,
          values: [true, false],
          default: false,
          doc:
            "Whether the button's border is dashed. Composes with any variant; variants without a visible border are unaffected."
        ),
        Prop.new(
          name: :color,
          primitive: :control,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the variant is built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
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
            "Whether the button renders as a full-radius pill. The control keeps its height and padding; combine it with `square` for a circular icon-only button."
        ),
        Prop.new(
          name: :square,
          primitive: :control,
          values: [true, false],
          default: false,
          doc:
            "Whether the button is square. Use it for icon-only buttons; the width follows the selected size."
        ),
        Prop.new(
          name: :wide,
          primitive: :control,
          values: [true, false],
          default: false,
          doc: "Whether the button fills the width of its container."
        ),
        Prop.new(
          name: :justify,
          primitive: :control,
          values: ["start", "center", "end", "between"],
          default: "center",
          doc:
            "Where the content sits when the button is wider than its content. `between` pushes the leading and trailing content to the edges."
        ),
        Prop.new(
          name: :depth,
          primitive: :control,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and surface buttons show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
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
      color_vars: [
        fill: "--fl-control-color",
        on_fill: "--fl-control-color-content",
        on_text: "--fl-control-text"
      ]
    }
  end
end
