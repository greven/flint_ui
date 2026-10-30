defmodule FlintUI.Styled.Tabs do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :tabs,
      base: FlintUI.Base.Tabs,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add tabs",
      css: "styled/tabs.css",
      tokens: [:color, :radius, :font, :spacing, :control, :shadow, :duration, :ease],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-tabs-color",
          default: "var(--fl-color-inverted)",
          doc: "The active indicator and the focus ring."
        ),
        Var.new(
          name: "--fl-tabs-text",
          default: "var(--fl-color-text)",
          doc:
            "The active label color for the segmented and minimal variants. The outlined variant always keeps the label on the foreground text color."
        ),
        Var.new(
          name: "--fl-tabs-surface",
          default: "var(--fl-color-control)",
          doc: "The active tab surface for the segmented and minimal variants."
        )
      ],
      color_vars: [
        fill: "--fl-tabs-color",
        on_text: "--fl-tabs-text"
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["outlined", "segmented", "minimal"],
          default: "outlined",
          doc: "The visual treatment of the tab list."
        ),
        Prop.new(
          name: :color,
          values: ["primary", "secondary", "success", "info", "warning", "error", "neutral"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the active state is built from, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size of the default triggers."
        ),
        Prop.new(
          name: :grow,
          values: [true, false],
          default: false,
          doc:
            "Whether the tabs share the available width. Horizontal only. Ignored when `scrollable` or `fadable` is set."
        ),
        Prop.new(
          name: :align,
          values: ["start", "center", "end", "spaced"],
          default: "start",
          doc:
            "Where the tabs sit in a horizontal tab list. `spaced` uses space-between. Ignored when `grow` fills the row."
        ),
        Prop.new(
          name: :gap,
          values: ["auto", "sm", "md", "lg", "xl"],
          default: "auto",
          doc:
            "The distance between triggers. `auto` follows the variant; raise it for composed triggers such as buttons, which bring their own padding and border."
        )
      ]
    }
  end
end
