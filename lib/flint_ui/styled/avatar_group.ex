defmodule FlintUI.Styled.AvatarGroup do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :avatar_group,
      base: FlintUI.Base.AvatarGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add avatar_group",
      css: "styled/avatar_group.css",
      tokens: [:avatar, :color],
      related: [:avatar],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc: "The avatar size, cascaded onto the group's direct avatar children."
        ),
        Prop.new(
          name: :overlap,
          values: ["none", "xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "How far neighbouring avatars overlap. `none` keeps them separate; larger values increase the overlap."
        ),
        Prop.new(
          name: :ring,
          values: [true, false],
          default: false,
          doc: "Adds a ring in the surrounding surface color between overlapping avatars."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-avatar-group-overlap",
          default: "0.25",
          doc:
            "The overlap as a fraction of the avatar size. `0` keeps avatars separate; `0.25` overlaps a quarter."
        ),
        Var.new(
          name: "--fl-avatar-group-ring-width",
          default: "2px",
          doc: "The width of the surface ring between avatars."
        ),
        Var.new(
          name: "--fl-avatar-group-ring-color",
          default: "var(--fl-color-surface)",
          doc: "The ring color. Match it to the surrounding surface on a tinted card or image."
        )
      ]
    }
  end
end
