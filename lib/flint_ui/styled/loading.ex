defmodule FlintUI.Styled.Loading do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :loading,
      base: FlintUI.Base.Loading,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add loading",
      css: "styled/loading.css",
      tokens: [:color],
      related: [:loading_text],
      slots: [],
      color_vars: [on_text: :color],
      props: [
        Prop.new(
          name: :variant,
          values: [
            "ring",
            "ring-bg",
            "ring-dash",
            "dots-fade",
            "dots-bounce",
            "bars-scale",
            "infinity"
          ],
          default: "ring",
          doc: "The indicator shape."
        ),
        Prop.new(
          name: :color,
          values: [
            "inherit",
            "neutral",
            "info",
            "success",
            "warning",
            "error",
            "primary",
            "secondary"
          ],
          default: "inherit",
          allow_custom: true,
          doc:
            "The theme color of the indicator, a Tailwind palette color such as `tw:rose` (500) or `tw:rose-700`, or a raw CSS color such as `#1D72FE` for a one-off accent. `inherit` follows the surrounding `currentColor`."
        ),
        Prop.new(
          name: :size,
          values: ["sm", "md", "lg"],
          default: "md",
          doc: "The indicator size."
        )
      ]
    }
  end
end
