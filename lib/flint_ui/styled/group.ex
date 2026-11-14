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
      related: [:button, :toggle],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-group-gap",
          default: "0",
          doc:
            "The gap between children; `attached` sets it to `0`, while `spaced` and `framed` derive it from `size`."
        ),
        Var.new(
          name: "--fl-group-padding",
          default: "0",
          doc:
            "The `framed` shell padding; derived from `size` and `0` for `spaced` and `attached` groups."
        ),
        Var.new(
          name: "--fl-group-surface",
          default: "var(--fl-color-surface)",
          doc:
            "The `framed` shell surface; `surface` selects it. Set it to `transparent` for an outline-only frame."
        )
      ],
      props: [
        Prop.new(
          name: :variant,
          values: ["spaced", "attached", "framed"],
          default: "spaced",
          doc:
            "How the children are joined. `spaced` keeps a gap between them without a shell; `attached` collapses their seams into one block; `framed` wraps them in a padded, bordered shell."
        ),
        Prop.new(
          name: :surface,
          values: ["solid", "soft", "strong", "ghost"],
          default: "solid",
          doc:
            "The `framed` shell surface. `solid` is the base surface, `soft` and `strong` step up the neutral ladder, and `ghost` keeps the frame but removes the fill. The shell-less variants have no surface, so the value has no effect there."
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
