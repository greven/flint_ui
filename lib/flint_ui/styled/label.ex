defmodule FlintUI.Styled.Label do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :label,
      base: FlintUI.Base.Label,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add label",
      css: "styled/label.css",
      tokens: [:color, :font, :spacing, :control],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The label size, from the shared control scale."
        )
      ]
    }
  end
end
