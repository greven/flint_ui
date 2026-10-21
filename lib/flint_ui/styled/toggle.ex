defmodule FlintUI.Styled.Toggle do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Slot, Var}

  def entry do
    %Entry{
      name: :toggle,
      base: FlintUI.Base.Toggle,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add toggle",
      css: "styled/toggle.css",
      tokens: [:color, :radius, :font, :spacing, :control, :duration, :ease],
      slots: [
        Slot.new(name: :leading, doc: "Optional content rendered before the toggle's content."),
        Slot.new(name: :trailing, doc: "Optional content rendered after the toggle's content.")
      ],
      vars: [
        Var.new(
          name: "--fl-toggle-color",
          default: "var(--fl-color-inverted)",
          doc: "The pressed fill and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-toggle-color-foreground",
          default: "var(--fl-color-inverted-foreground)",
          doc: "The label color on the pressed solid fill."
        ),
        Var.new(
          name: "--fl-toggle-text",
          default: "var(--fl-toggle-color)",
          doc: "The label color for text-carrying variants."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["solid", "subtle", "outline", "ghost", "dashed"],
          default: "solid",
          doc: "How the pressed state is emphasized."
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
        )
      ]
    }
  end
end
