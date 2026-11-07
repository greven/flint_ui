defmodule FlintUIDocsWeb.Docs.Loading do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :loading

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @variants ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        controls: [
          %{key: :variant, type: :select, values: @variants, default: "ring", label: "Variant"},
          %{key: :color, type: :select, default: "inherit", label: "Color"},
          %{key: :duration, type: :number, default: nil, label: "Duration (ms, blank = default)"},
          %{key: :weight, type: :number, default: nil, label: "Weight (blank = default)"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.loading
        variant={variant(props)}
        color={props.color}
        size={props.size}
        duration={duration(props)}
        weight={weight(props)}
      />
    </.preview>
    """
  end

  defp main_code(props) do
    variant = variant(props)

    Snippet.component(
      ".loading",
      [
        Snippet.attr("variant", variant, "ring"),
        Snippet.attr("color", props.color, "inherit"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("duration", duration(props), default_duration(variant)),
        Snippet.attr("weight", weight(props), default_weight(variant))
      ]
    )
  end

  defp variant(%{variant: value}) when value in @variants, do: value
  defp variant(_), do: "ring"

  defp default_duration(variant), do: FlintUI.Base.Loading.default_duration(variant)

  defp default_weight(variant), do: FlintUI.Base.Loading.default_weight(variant)

  defp weight(%{weight: value}) when is_number(value) and value > 0, do: value

  defp weight(props), do: default_weight(variant(props))

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> nil
    end
  end

  defp duration(props), do: default_duration(variant(props))
end
