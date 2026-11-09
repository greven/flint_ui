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
      tokens: [:color, :radius, :shadow],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc:
            "The flag width. Height follows the flag's aspect ratio: 4:3 for `flag-<country>`, 1:1 for `flag-<country>-square`."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "full"],
          default: "xs",
          doc: "The corner radius from the shared radius scale."
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
          default: "1.5rem",
          doc:
            "The flag width. The generated flag class follows this variable; height comes from the flag's aspect ratio."
        )
      ]
    }
  end
end
