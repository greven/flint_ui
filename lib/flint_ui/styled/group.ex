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
            "The gap between children; `attached` sets it to `0`, while every other group derives it from `size`."
        ),
        Var.new(
          name: "--fl-group-padding",
          default: "0",
          doc: "The shell padding; derived from `size` and `0` when the group has no `surface`."
        ),
        Var.new(
          name: "--fl-group-surface",
          default: "var(--fl-color-surface)",
          doc:
            "The shell surface; `surface` selects it. Set it to `transparent` for an outline-only frame."
        )
      ],
      props: [
        Prop.new(
          name: :attached,
          values: [true, false],
          default: false,
          doc:
            "Whether the children are joined into one block, sharing a seam. The group still only arranges them; each control keeps its own behavior."
        ),
        Prop.new(
          name: :surface,
          values: ["none", "solid", "soft", "strong", "transparent"],
          default: "none",
          resolved: ["none"],
          doc:
            "Set a surface to wrap the group in a padded, bordered shell; `none` (the default) leaves it bare. `solid` is the base surface, `soft` and `strong` step up the neutral ladder, and `transparent` keeps the frame without a fill. The shell composes with `attached`."
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
