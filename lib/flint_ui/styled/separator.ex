defmodule FlintUI.Styled.Separator do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :separator,
      base: FlintUI.Base.Separator,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add separator",
      css: "styled/separator.css",
      tokens: [:color, :font, :spacing],
      dependencies: [:icon],
      slots: [],
      props: [
        Prop.new(
          name: :type,
          values: ["solid", "dashed", "dotted"],
          default: "solid",
          doc: "The stroke pattern of the line."
        ),
        Prop.new(
          name: :variant,
          values: ["subtle", "default", "strong"],
          default: "default",
          doc:
            "The intensity of the line. `subtle` uses the faint border step, `default` the default border, and `strong` the strong border step. With a color role, the steps follow that role's soft border, fill, and text tokens."
        ),
        Prop.new(
          name: :position,
          values: ["center", "start", "end"],
          default: "center",
          doc:
            "Where the content sits between the line segments: `center` splits the line around it, `start` places it before the line, and `end` places it after the line. Has no effect without content."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "xs",
          allow_custom: true,
          type: :any,
          doc:
            "The line thickness, from `xs` (1px) to `xl` (5px), or a number of pixels converted to rem (`4` becomes `0.25rem`). This is the weight of the line, not its length."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color of the line, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. The label keeps the default text color."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :label,
          type: :string,
          fills_content: true,
          doc:
            "A text label rendered between the line segments when the default slot is not given. The default slot wins when both are set."
        ),
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc:
            "An icon CSS class rendered between the line segments when neither the default slot nor `label` is set. The icon is decorative."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-separator-color",
          default: "var(--fl-color-border)",
          doc:
            "The line color. A color role sets it to the role's fill; a raw color writes it inline."
        ),
        Var.new(
          name: "--fl-separator-size",
          default: "1px",
          doc:
            "The line thickness. The `size` prop sets it from the size scale; a numeric size writes it inline."
        ),
        Var.new(
          name: "--fl-separator-gap",
          default: "var(--fl-spacing-md)",
          doc:
            "The space between the content and each line segment when the separator has content."
        )
      ],
      color_vars: [fill: "--fl-separator-color"]
    }
  end
end
