defmodule FlintUI.Styled.Group do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :group,
      base: FlintUI.Base.Group,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add group",
      css: "styled/group.css",
      tokens: [:color, :radius, :spacing, :control],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-group-gap",
          default: "0",
          doc:
            "The gap between children; `attached` sets it to `0` and `framed` derives it from `size`."
        ),
        Var.new(
          name: "--fl-group-padding",
          default: "0",
          doc: "The framed shell padding; derived from `size` and `0` for attached groups."
        )
      ],
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
