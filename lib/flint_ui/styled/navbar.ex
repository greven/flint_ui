defmodule FlintUI.Styled.Navbar do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :navbar,
      base: FlintUI.Base.Navbar,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navbar navbar_item navbar_menu navbar_menu_item",
      css: "styled/navbar.css",
      tokens: [:color, :font, :spacing, :radius, :duration, :ease, :control],
      related: [{:navbar_item, nav: true}, {:navbar_menu, nav: true}],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["segmented", "outlined", "minimal"],
          default: "segmented",
          doc:
            "The visual treatment of the navbar. Choose from `segmented`, `outlined` or `minimal`."
        ),
        Prop.new(
          name: :color,
          values: ["neutral", "info", "success", "warning", "danger", "primary", "secondary"],
          default: "neutral",
          allow_custom: true,
          doc:
            "The theme color the active state is built from, a palette hue such as `pink` or `cyan`, or a raw CSS color such as `#1D72FE` for a one-off accent."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The control size of the items, menu triggers, and menu items."
        ),
        Prop.new(
          name: :gap,
          values: ["0", "xs", "sm", "md", "lg", "xl", "2xl", "3xl"],
          default: "xs",
          doc:
            "The space between items on the shared `--fl-spacing-*` scale. The same gap separates wrapped lines. `0` joins the items with no gap."
        ),
        Prop.new(
          name: :grow,
          values: [true, false],
          default: false,
          doc:
            "Whether the items share the available width. Ignored when `scrollable` or `fadable` is set."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between"],
          default: "start",
          doc:
            "Where the items sit in the list. `between` uses space-between. Ignored when `grow` fills the row."
        )
      ],
      color_vars: [
        fill: "--fl-navbar-color",
        on_text: "--fl-navbar-text-active",
        soft: "--fl-navbar-active"
      ],
      vars: [
        Var.new(
          name: "--fl-navbar-gap",
          default: "var(--fl-spacing-xs)",
          doc:
            "The space between items; the `gap` prop sets it from the spacing scale. The same gap separates wrapped lines."
        ),
        Var.new(
          name: "--fl-navbar-text",
          default: "var(--fl-color-text-muted)",
          doc: "The resting label color of items and menu triggers."
        ),
        Var.new(
          name: "--fl-navbar-text-active",
          default: "var(--fl-color-text)",
          doc:
            "The label color of an active item or an open menu trigger. The selected color's on-soft tone is used in the minimal variant; neutral keeps the plain foreground text."
        ),
        Var.new(
          name: "--fl-navbar-highlight",
          default: "var(--fl-color-surface-subtle)",
          doc: "The hover background behind an item or menu trigger."
        ),
        Var.new(
          name: "--fl-navbar-active",
          default: "var(--fl-color-surface-strong)",
          doc:
            "The background behind an active item in the minimal variant. The selected color's soft tone is used; neutral keeps `surface-strong`."
        ),
        Var.new(
          name: "--fl-navbar-color",
          default: "var(--fl-color-text)",
          doc: "The active indicator color in the outlined variant, following the `color` prop."
        )
      ]
    }
  end
end
