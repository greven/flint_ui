defmodule FlintUI.Styled.Icon do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :icon,
      base: FlintUI.Base.Icon,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add icon",
      css: "styled/icon.css",
      tokens: [:color],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The icon size."
        )
      ]
    }
  end
end
