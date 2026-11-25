defmodule FlintUI.Styled.Navbar do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :navbar,
      base: FlintUI.Base.Navbar,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navbar navbar_item navbar_menu navbar_menu_item",
      css: "styled/navbar.css",
      tokens: [:color, :font, :spacing, :radius, :duration, :ease],
      related: [{:navbar_item, nav: true}, {:navbar_menu, nav: true}],
      slots: [],
      props: [],
      vars: [
        Var.new(
          name: "--fl-navbar-gap",
          default: "var(--fl-spacing-xs)",
          doc: "The space between navbar items."
        ),
        Var.new(
          name: "--fl-navbar-text",
          default: "var(--fl-color-text-muted)",
          doc: "The resting label color of items and menu triggers."
        ),
        Var.new(
          name: "--fl-navbar-text-active",
          default: "var(--fl-color-text)",
          doc: "The label color of an active item or an open menu trigger."
        ),
        Var.new(
          name: "--fl-navbar-highlight",
          default: "var(--fl-color-surface-subtle)",
          doc: "The hover background behind an item or menu trigger."
        ),
        Var.new(
          name: "--fl-navbar-active",
          default: "var(--fl-color-surface-strong)",
          doc: "The background behind an active item or menu trigger."
        )
      ]
    }
  end
end
