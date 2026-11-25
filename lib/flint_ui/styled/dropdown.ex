defmodule FlintUI.Styled.Dropdown do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :dropdown,
      base: FlintUI.Base.Dropdown,
      target: "lib/my_app_web/components.ex",
      install:
        "mix flint.add dropdown dropdown_group dropdown_header dropdown_item dropdown_separator dropdown_sub",
      css: "styled/dropdown.css",
      tokens: [:color, :radius, :spacing, :font, :elevation, :duration, :ease, :control],
      related: [
        {:dropdown_item, nav: true},
        {:dropdown_group, nav: true},
        {:dropdown_header, nav: true},
        {:dropdown_separator, nav: true},
        {:dropdown_sub, nav: true}
      ],
      slots: [],
      props: [],
      vars: [
        Var.new(
          name: "--fl-dropdown-surface",
          default: "var(--fl-color-surface-raised)",
          doc:
            "Background color of the menu and its submenus. It feeds `--fl-elevation-fill`, so the menu uses the shared raised-surface trim and elevation."
        ),
        Var.new(
          name: "--fl-dropdown-border",
          default: "var(--fl-color-border)",
          doc:
            "Border color of the menu and its submenus. It feeds `--fl-elevation-border`; tune the depth with `--fl-elevation-level`."
        ),
        Var.new(
          name: "--fl-dropdown-text",
          default: "var(--fl-color-text)",
          doc: "Text color of the menu content."
        ),
        Var.new(
          name: "--fl-dropdown-min-width",
          default: "12rem",
          doc: "Smallest width of the menu before its content wraps."
        ),
        Var.new(
          name: "--fl-dropdown-max-height",
          default: "none",
          doc:
            "Maximum height of the menu. The `max_height` attribute writes it in pixels; the menu scrolls when content exceeds it."
        )
      ]
    }
  end
end
