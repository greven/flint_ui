defmodule FlintUI.Styled.NavbarMenu do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Var}

  def entry do
    %Entry{
      name: :navbar_menu,
      base: FlintUI.Base.NavbarMenu,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navbar_menu navbar_menu_item",
      css: "styled/navbar_menu.css",
      tokens: [:color, :font, :spacing, :radius, :elevation, :duration, :ease, :control],
      related: [{:navbar_menu_item, nav: true}, :navbar],
      dependencies: [:icon],
      slots: [],
      props: [],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          doc: "An icon CSS class rendered before the trigger label. The icon is decorative."
        ),
        Attr.new(
          name: :trailing_icon,
          type: :string,
          doc:
            "An icon CSS class rendered after the trigger label and before the disclosure indicator. The icon is decorative."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-navbar-menu-surface",
          default: "var(--fl-color-surface-raised)",
          doc:
            "The background color of the menu panel. It feeds `--fl-elevation-fill`, so the panel uses the shared raised-surface trim and elevation."
        ),
        Var.new(
          name: "--fl-navbar-menu-border",
          default: "var(--fl-color-border)",
          doc:
            "The border color of the menu panel. It feeds `--fl-elevation-border`; tune the depth with `--fl-elevation-level`."
        ),
        Var.new(
          name: "--fl-navbar-menu-text",
          default: "var(--fl-color-text)",
          doc: "The text color of the menu content."
        ),
        Var.new(
          name: "--fl-navbar-menu-min-width",
          default: "13rem",
          doc: "The smallest width of the menu panel before its content wraps."
        ),
        Var.new(
          name: "--fl-navbar-menu-offset",
          default: "var(--fl-spacing-xs)",
          doc:
            "The gap between the trigger and the menu panel. The navbar hook reads this value when it positions the panel in the top layer."
        )
      ]
    }
  end
end
