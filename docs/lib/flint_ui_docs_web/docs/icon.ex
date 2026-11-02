defmodule FlintUIDocsWeb.Docs.Icon do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :icon

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :main,
        controls: [
          %{key: :name, type: :string, default: "lucide-house", label: "Icon (lucide-…)"},
          %{key: :label, type: :string, default: "", label: "Label (accessible name)"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ],
        code: &main_code/1
      }
    ]
  end

  @impl true
  def render_section(%{section: :main} = assigns) do
    ~H"""
    <.preview :let={props} {assigns}>
      <Components.icon name={props.name} label={blank_to_nil(props.label)} size={props.size} />
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.component(
      ".icon",
      [
        Snippet.attr("name", props.name),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("label", blank_to_nil(props.label))
      ]
    )
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
