defmodule FlintUI.Styled.Kbd do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :kbd,
      base: FlintUI.Base.Kbd,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add kbd",
      css: "styled/kbd.css",
      tokens: [:color, :radius, :font, :shadow, :control],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["raised", "subtle", "outline"],
          default: "raised",
          doc:
            "The key treatment. `raised` is a keycap with a heavier bottom edge, `subtle` is a soft tinted key with a faint edge, and `outline` is a flat key with a full border."
        ),
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          doc:
            "The key size. The font and the cap scale together, so the padding stays proportional."
        )
      ],
      vars: []
    }
  end
end
