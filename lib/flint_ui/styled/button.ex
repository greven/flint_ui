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
      tokens: [:color, :radius, :font, :spacing, :shadow, :control, :duration, :ease],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the button's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the button's content.")
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["subtle", "solid", "outline", "ghost", "dashed", "link"],
          default: "subtle",
          doc: "The visual emphasis of the button."
        ),
        Prop.new(
          name: :color,
          values: ["primary", "secondary", "success", "info", "warning", "error", "neutral"],
          default: "neutral",
          doc: "The theme color the variant is built from."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size."
        ),
        Prop.new(
          name: :depth,
          values: [true, false],
          default: true,
          doc:
            "Whether solid and outline buttons are raised. `true` (default) shows the highlight/line and the theme's `--fl-button-shadow`; `false` renders them flat."
        )
      ]
    }
  end
end
