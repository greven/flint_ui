defmodule FlintUI.Styled.Icon do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :icon,
      base: FlintUI.Base.Icon,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add icon",
      css: "styled/icon.css",
      tokens: [:color],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-icon-size",
          default: "1.25rem",
          doc:
            "The icon box. Icon sets that read this variable, such as the docs' Lucide plugin, follow the selected `size`."
        )
      ],
      props: [
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The icon size."
        )
      ]
    }
  end
end
