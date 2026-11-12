defmodule FlintUI.Styled.Avatar do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :avatar,
      base: FlintUI.Base.Avatar,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add avatar",
      css: "styled/avatar.css",
      tokens: [:avatar, :color, :font, :radius],
      related: [{:avatar_group, nav: true}],
      dependencies: [:icon],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          allow_custom: true,
          type: :any,
          doc:
            "The avatar size, from `xs` to `xl`, or a number of pixels converted to rem (`40` becomes `2.5rem`)."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "none",
          doc:
            "The corner radius, from `none` for square corners to `xl`, following the shared radius scale. Only applies to `shape=\"square\"`; the default circle stays round."
        ),
        Prop.new(
          name: :shape,
          values: ["circle", "square"],
          default: "circle",
          doc: "The avatar shape. `circle` is the default; `square` uses `radius`."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The fallback fill, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. Pass `initials` to derive a stable color from `alt`; initials keep a white label unless white falls below 3:1 on that fill."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :fallback_icon,
          type: :string,
          default: "lucide-user",
          doc:
            "The Lucide class used when neither `alt` nor `text` is available for the fallback. Set it to `nil` to render an empty fallback."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-avatar-size",
          default: "var(--fl-avatar-size-md)",
          doc: "The avatar diameter. Set by `size`; a numeric `size` writes this input directly."
        ),
        Var.new(
          name: "--fl-avatar-color",
          default: "var(--fl-color-inverted)",
          doc: "The fallback fill. Initials and the default icon sit on this fill."
        ),
        Var.new(
          name: "--fl-avatar-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The fallback label color on the fill."
        )
      ],
      color_vars: [
        fill: "--fl-avatar-color",
        on_fill: "--fl-avatar-color-content"
      ]
    }
  end
end
