defmodule FlintUI.Styled.Toggle do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Slot}

  def entry do
    %Entry{
      name: :toggle,
      base: FlintUI.Base.Toggle,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add toggle",
      css: "styled/toggle.css",
      tokens: [:color, :radius, :font],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the label."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the label.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "outline", "ghost"],
          default: "solid",
          doc: "How the pressed state is emphasized."
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
