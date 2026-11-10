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
      tokens: [:color, :control],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "md",
          allow_custom: true,
          type: :any,
          doc:
            "The icon size, from `xs` to `xl` on the control icon scale, or a number of pixels converted to rem (`40` becomes `2.5rem`)."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-icon-size",
          default: "var(--fl-control-icon-md)",
          doc:
            "The icon box. Icon sets that read this variable, such as the docs' Lucide plugin, follow the selected `size`; a numeric `size` writes this input directly."
        )
      ]
    }
  end
end
