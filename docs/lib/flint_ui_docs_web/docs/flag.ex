defmodule FlintUIDocsWeb.Docs.Flag do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :flag

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  # Keep these names in source so the docs Tailwind plugin generates them.
  @flags ~w(
    flag-pt flag-pt-square
    flag-us flag-us-square
    flag-br flag-jp flag-fr flag-de
  )

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        controls: [
          %{key: :name, type: :select, values: @flags, default: "flag-pt", label: "Flag"},
          %{key: :label, type: :string, default: "", label: "Label (accessible name)"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :radius, type: :select, default: "xs", label: "Radius"},
          %{key: :overlay, type: :select, default: "none", label: "Overlay"},
          %{key: :border, type: :boolean, default: false, label: "Border"},
          %{key: :shadow, type: :boolean, default: false, label: "Shadow"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Flags use the generated `flag-*` classes. See the [Icons & flags guide](/guides/icons) to install Flag Icons with Tailwind or plain CSS." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.flag
        name={props.name}
        size={props.size}
        radius={props.radius}
        overlay={props.overlay}
        border={props.border}
        shadow={props.shadow}
        label={blank_to_nil(props.label)}
      />
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.component(
      ".flag",
      [
        Snippet.attr("name", props.name),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("radius", props.radius, "xs"),
        Snippet.attr("overlay", props.overlay, "none"),
        Snippet.flag("border", props.border),
        Snippet.flag("shadow", props.shadow),
        Snippet.attr("label", blank_to_nil(props.label))
      ]
    )
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
