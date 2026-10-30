defmodule FlintUI.Styled.LoadingText do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop}

  def entry do
    %Entry{
      name: :loading_text,
      base: FlintUI.Base.LoadingText,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add loading_text",
      css: "styled/loading_text.css",
      tokens: [:color],
      slots: [],
      color_vars: [on_page: :color],
      props: [
        Prop.new(
          name: :variant,
          values: ["dots", "blink", "shimmer", "wave"],
          default: "dots",
          doc: "The text loading animation."
        ),
        Prop.new(
          name: :color,
          values: [
            "inherit",
            "primary",
            "secondary",
            "success",
            "info",
            "warning",
            "error",
            "neutral"
          ],
          default: "inherit",
          allow_custom: true,
          doc:
            "The theme color of the text, or a raw CSS color such as `#1D72FE` for a one-off accent. `inherit` follows the surrounding `currentColor`."
        )
      ]
    }
  end
end
