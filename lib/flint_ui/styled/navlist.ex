defmodule FlintUI.Styled.Navlist do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :navlist,
      base: FlintUI.Base.Navlist,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navlist navlist_item navlist_group",
      css: "styled/navlist.css",
      tokens: [:color, :font, :spacing, :radius, :duration, :ease],
      related: [{:navlist_item, nav: true}, {:navlist_group, nav: true}],
      slots: [],
      props: [
        Prop.new(
          name: :rail,
          values: [true, false],
          default: false,
          doc:
            "Whether the top-level list draws a vertical rail at its inline start. Group child lists always draw a rail. With a rail, an active item marks the rail segment; without one, it uses a background fill."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-navlist-gap",
          default: "2px",
          doc: "The space between navlist items."
        ),
        Var.new(
          name: "--fl-navlist-rail-color",
          default: "var(--fl-color-border)",
          doc: "The inactive color of the rail."
        ),
        Var.new(
          name: "--fl-navlist-rail-active",
          default: "var(--fl-color-text)",
          doc: "The color of the rail segment next to the active item."
        ),
        Var.new(
          name: "--fl-navlist-active",
          default: "var(--fl-color-surface-strong)",
          doc: "The background behind an active item when the list has no rail."
        ),
        Var.new(
          name: "--fl-navlist-text-active",
          default: "var(--fl-color-text)",
          doc: "The label color of the active item."
        )
      ]
    }
  end
end
