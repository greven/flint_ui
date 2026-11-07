defmodule FlintUIDocsWeb.Docs.LoadingText do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :loading_text

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @variants ~w(dots blink shimmer wave)

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        controls: [
          %{key: :text, type: :string, default: "Saving", label: "Text"},
          %{key: :variant, type: :select, values: @variants, default: "dots", label: "Variant"},
          %{key: :color, type: :select, default: "inherit", label: "Color"},
          %{key: :dots, type: :number, default: 3, label: "Dots"},
          %{key: :duration, type: :number, default: nil, label: "Duration (ms)"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.loading_text
        text={props.text}
        variant={variant(props)}
        color={props.color}
        dots={dots(props)}
        duration={duration(props)}
      />
    </.preview>
    """
  end

  defp main_code(props) do
    variant = variant(props)

    Snippet.component(".loading_text", [
      Snippet.attr("text", props.text, nil),
      Snippet.attr("variant", variant, "dots"),
      Snippet.attr("color", props.color, "inherit"),
      dots_attr(variant, props),
      Snippet.attr("duration", duration(props), default_duration(variant))
    ])
  end

  defp dots_attr("dots", props), do: Snippet.attr("dots", dots(props), 3)
  defp dots_attr(_variant, _props), do: nil

  defp variant(%{variant: value}) when value in @variants, do: value
  defp variant(_), do: "dots"

  defp dots(%{dots: value}) when is_integer(value) and value > 0, do: value

  defp dots(%{dots: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> 3
    end
  end

  defp dots(_), do: 3

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> nil
    end
  end

  defp duration(_), do: nil

  defp default_duration(variant), do: FlintUI.Base.LoadingText.default_duration(variant)
end
