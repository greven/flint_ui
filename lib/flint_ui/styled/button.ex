defmodule FlintUI.Styled.Button do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Slot}

  def entry do
    %Entry{
      name: :button,
      base: FlintUI.Base.Button,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add button",
      css: "styled/button.css",
      tokens: [:color, :radius, :font],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the label."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the label.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "secondary", "outline", "ghost", "destructive", "link"],
          default: "solid",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The control size."
        )
      ]
    }
  end
end
