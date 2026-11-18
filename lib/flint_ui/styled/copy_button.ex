defmodule FlintUI.Styled.CopyButton do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop}

  def entry do
    %Entry{
      name: :copy_button,
      base: FlintUI.Base.CopyButton,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add copy_button",
      css: "styled/copy_button.css",
      tokens: [:color, :control, :duration, :ease, :font],
      related: [:button],
      dependencies: [:icon],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          default: "lucide-copy",
          fills_content: true,
          doc:
            "An icon CSS class rendered in the idle state. The icon is decorative; `label` names the button."
        ),
        Attr.new(
          name: :success_icon,
          type: :string,
          default: "lucide-check",
          doc:
            "An icon CSS class rendered after a successful copy. The live region announces the result."
        ),
        Attr.new(
          name: :error_icon,
          type: :string,
          default: "lucide-circle-x",
          doc:
            "An icon CSS class rendered after a failed copy. The live region announces the result."
        )
      ],
      props: [
        Prop.new(
          name: :size,
          values: ["xs", "sm", "md", "lg", "xl"],
          default: "sm",
          doc: "The control size."
        )
      ]
    }
  end
end
