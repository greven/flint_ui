defmodule FlintUI.Styled.Card do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :card,
      base: FlintUI.Base.Card,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add card",
      css: "styled/card.css",
      tokens: [:color, :radius, :font],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["outline", "solid", "soft", "subtle"],
          default: "outline",
          doc: "The neutral surface treatment of the card."
        ),
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The internal spacing of the card."
        ),
        Prop.new(
          name: :divided,
          values: [true, false],
          default: false,
          doc: "Draws a divider between the header, body and footer."
        )
      ]
    }
  end
end
