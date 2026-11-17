defmodule FlintUI.Styled.Textarea do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :textarea,
      base: FlintUI.Base.Textarea,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add textarea",
      css: "styled/textarea.css",
      tokens: [:color, :radius, :font, :spacing, :control, :field, :duration, :ease],
      related: [:input, :label],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The textarea text size and field padding, from the shared control scale."
        ),
        Prop.new(
          name: :radius,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The corner radius of the control, from `none` for square corners to `xl`, following the shared radius scale."
        ),
        Prop.new(
          name: :resize,
          values: ["none", "vertical", "horizontal", "both"],
          default: "vertical",
          doc:
            "The resize handle the browser exposes on the control. Ignored while `autogrow` is set."
        ),
        Prop.new(
          name: :autogrow,
          values: [true, false],
          default: false,
          doc:
            "Grows and shrinks with its content using CSS `field-sizing`. The browser keeps the size, so manual resizing is off."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :min_rows,
          type: :integer,
          default: 2,
          doc:
            "The minimum visible rows while `autogrow` is set. Also the fallback `rows` value in browsers without `field-sizing`."
        ),
        Attr.new(
          name: :max_rows,
          type: :integer,
          default: 8,
          doc:
            "The maximum visible rows while `autogrow` is set. Past it the control scrolls instead of growing."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-textarea-fill",
          default: "var(--fl-color-surface)",
          doc: "The control background."
        ),
        Var.new(
          name: "--fl-textarea-border",
          default: "var(--fl-color-border)",
          doc: "The control border color at rest."
        ),
        Var.new(
          name: "--fl-textarea-placeholder",
          default: "var(--fl-color-text-dimmed)",
          doc: "The placeholder text color."
        ),
        Var.new(
          name: "--fl-textarea-min-rows",
          default: "2",
          doc: "The minimum visible rows while `autogrow` is set; `min_rows` writes it inline."
        ),
        Var.new(
          name: "--fl-textarea-max-rows",
          default: "8",
          doc: "The maximum visible rows while `autogrow` is set; `max_rows` writes it inline."
        )
      ]
    }
  end
end
