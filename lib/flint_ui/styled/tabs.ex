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
          default: "var(--fl-color-surface)",
          doc: "The active tab surface for the segmented and minimal variants."
        ),
        Var.new(
          name: "--fl-tabs-gap",
          default: "var(--fl-spacing-xs)",
          doc:
            "The distance between triggers. Raise it for composed triggers such as buttons, which bring their own padding and border. The segmented variant defaults it to `2px`."
        ),
        Var.new(
          name: "--fl-tabs-content-gap",
          default: "var(--fl-spacing-md)",
          doc:
            "The distance between the tab list and the panels. Set it to `0` to remove the gap."
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
          values: ["neutral", "info", "success", "warning", "error", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the active state is built from, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent."
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
          name: :justify,
          values: ["start", "center", "end", "between"],
          default: "start",
          doc:
            "Where the tabs sit in a horizontal tab list. `between` uses space-between. Ignored when `grow` fills the row."
        )
      ]
    }
  end
end
