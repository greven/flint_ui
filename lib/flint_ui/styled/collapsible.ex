defmodule FlintUI.Styled.Collapsible do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :collapsible,
      base: FlintUI.Base.Collapsible,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add collapsible",
      css: "styled/collapsible.css",
      tokens: [:color, :radius],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["bordered", "minimal"],
          default: "bordered",
          doc: "The container treatment."
        )
      ]
    }
  end
end
