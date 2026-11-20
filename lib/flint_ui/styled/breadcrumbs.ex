defmodule FlintUI.Styled.Breadcrumbs do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :breadcrumbs,
      base: FlintUI.Base.Breadcrumbs,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add breadcrumbs",
      css: "styled/breadcrumbs.css",
      tokens: [:color, :font, :spacing],
      related: [{:breadcrumbs_item, nav: true}],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-breadcrumbs-gap",
          default: "var(--fl-spacing-xs)",
          doc: "The space between crumbs and between a crumb and its separator."
        ),
        Var.new(
          name: "--fl-breadcrumbs-separator-color",
          default: "var(--fl-color-text-muted)",
          doc: "The color of the decorative separators."
        )
      ]
    }
  end
end
