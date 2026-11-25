defmodule FlintUI.Styled.NavlistGroup do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Var}

  def entry do
    %Entry{
      name: :navlist_group,
      base: FlintUI.Base.NavlistGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add navlist_group",
      css: "styled/navlist_group.css",
      tokens: [:color, :font, :spacing, :radius, :duration, :ease, :control],
      related: [:navlist],
      dependencies: [:icon],
      slots: [],
      props: [],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          doc: "An icon CSS class rendered before the header label. The icon is decorative."
        ),
        Attr.new(
          name: :trailing_icon,
          type: :string,
          doc:
            "An icon CSS class rendered after the header label and before the disclosure indicator. The icon is decorative."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-navlist-group-indent",
          default: "var(--fl-spacing-md)",
          doc: "How far the group's child list is indented from the header."
        ),
        Var.new(
          name: "--fl-navlist-group-text",
          default: "var(--fl-color-text-muted)",
          doc: "The color of the group header label."
        )
      ]
    }
  end
end
