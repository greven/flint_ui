defmodule FlintUI.Styled.Flag do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :flag,
      base: FlintUI.Base.Flag,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add flag",
      css: "styled/flag.css",
      tokens: [:color, :flag, :radius, :shadow],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          allow_custom: true,
          type: :any,
          doc:
            "The flag width, from `xs` to `xl`, or a number of pixels converted to rem (`40` becomes `2.5rem`). Height follows the flag's aspect ratio: 4:3 for `regular`, 1:1 for `square` and `round`."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl", "full"],
          default: "xs",
          doc:
            "The corner radius from the shared radius scale. `round` always uses a full radius."
        ),
        Prop.new(
          name: :overlay,
          values: ["none", "linear", "wave"],
          default: "none",
          doc: "An optional decorative overlay across the flag."
        ),
        Prop.new(
          name: :border,
          values: [true, false],
          default: false,
          doc: "Adds a subtle inset border. Useful on light flags and photo surfaces."
        ),
        Prop.new(
          name: :shadow,
          values: [true, false],
          default: false,
          doc: "Adds the shared small elevation shadow."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-flag-size",
          default: "var(--fl-flag-size-md)",
          doc:
            "The flag width. Set by `size`; a numeric `size` writes this input directly. Height comes from the flag's aspect ratio."
        )
      ]
    }
  end
end
