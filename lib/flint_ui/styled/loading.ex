defmodule FlintUI.Styled.Loading do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :loading,
      base: FlintUI.Base.Loading,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add loading",
      css: "styled/loading.css",
      tokens: [:color],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["ring", "ring-bg", "dots-fade", "dots-bounce"],
          default: "ring",
          doc: "The indicator shape."
        ),
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The indicator size."
        )
      ]
    }
  end
end
