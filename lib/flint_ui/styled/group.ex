defmodule FlintUI.Styled.Group do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :group,
      base: FlintUI.Base.Group,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add group",
      css: "styled/group.css",
      tokens: [:color, :radius, :spacing, :control],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["attached", "framed"],
          default: "attached",
          doc:
            "How the children are joined. `attached` collapses their seams into one block; `framed` wraps them in a padded, bordered shell."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The group spacing, cascaded onto the child controls."
        )
      ]
    }
  end
end
