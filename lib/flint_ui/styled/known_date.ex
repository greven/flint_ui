defmodule FlintUI.Styled.KnownDate do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :known_date,
      base: FlintUI.Base.KnownDate,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add known_date",
      css: "styled/known_date.css",
      primitives: [:field],
      tokens: [:color, :radius, :font, :spacing, :control, :field, :duration, :ease],
      related: [:input, :textarea],
      props: [
        Prop.new(
          name: :size,
          primitive: :field,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The part label and input size, from the shared control scale. The field widths follow the part labels."
        ),
        Prop.new(
          name: :radius,
          primitive: :field,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius of the part inputs, from `none` for square corners to `xl`, following the shared radius scale."
        )
      ]
    }
  end
end
