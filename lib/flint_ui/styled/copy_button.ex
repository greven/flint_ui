defmodule FlintUI.Styled.CopyButton do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop}

  def entry do
    %Entry{
      name: :copy_button,
      base: FlintUI.Base.CopyButton,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add copy_button",
      css: "styled/copy_button.css",
      tokens: [:color, :radius, :font, :spacing, :shadow, :control, :duration, :ease],
      primitives: [:control],
      related: [:button],
      dependencies: [:icon],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          default: "lucide-copy",
          fills_content: true,
          doc:
            "An icon CSS class rendered in the idle state. The icon is decorative; `label` names the button."
        ),
        Attr.new(
          name: :text,
          type: :string,
          fills_content: true,
          doc:
            "A visible label rendered when the default slot is not given. The default slot wins when both are set."
        ),
        Attr.new(
          name: :success_icon,
          type: :string,
          default: "lucide-check",
          doc:
            "An icon CSS class rendered after a successful copy. The live region announces the result."
        ),
        Attr.new(
          name: :error_icon,
          type: :string,
          default: "lucide-circle-x",
          doc:
            "An icon CSS class rendered after a failed copy. The live region announces the result."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "soft", "subtle", "surface", "outline", "ghost", "link"],
          default: "ghost",
          primitive: :control,
          doc:
            "The visual emphasis. Defaults to the quiet ghost treatment; pass the surrounding variant to match a group."
        ),
        Prop.new(
          name: :dashed,
          values: [true, false],
          default: false,
          primitive: :control,
          doc:
            "Whether the control's border is dashed. Composes with any variant; variants without a visible border are unaffected."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          primitive: :control,
          doc:
            "The theme color the variant is built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "sm",
          primitive: :control,
          doc: "The control size. Defaults to `sm` for a compact copy action."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          primitive: :control,
          doc:
            "The corner radius, from `none` for square corners to `xl`, following the shared radius scale."
        ),
        Prop.new(
          name: :pill,
          values: [true, false],
          default: false,
          primitive: :control,
          doc:
            "Whether the control renders as a full-radius pill. Combine it with `square` for a circular icon-only button."
        ),
        Prop.new(
          name: :square,
          values: [true, false],
          default: false,
          primitive: :control,
          doc:
            "Whether the control is square. Icon-only copy buttons are square automatically; set this to force a square labeled button."
        ),
        Prop.new(
          name: :wide,
          values: [true, false],
          default: false,
          primitive: :control,
          doc: "Whether the control fills the width of its container."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between"],
          default: "center",
          primitive: :control,
          doc:
            "Where the content sits when the control is wider than its content. The copy button has one content group, so `between` behaves like `start`."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          primitive: :control,
          doc:
            "Whether solid and surface treatments show their highlight/inner line. Shadows are always on for solid, subtle, and surface; remove them with `--fl-control-shadow`."
        ),
        Prop.new(
          name: :inset,
          values: ["top", "bottom", "left", "right", "all"],
          default: false,
          multi: true,
          primitive: :control,
          doc:
            "Negates the control's padding on the selected sides so its content aligns with surrounding content. Pass `inset` for every side, or a space-separated combination of `top`, `bottom`, `left`, `right`, and `all`."
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
