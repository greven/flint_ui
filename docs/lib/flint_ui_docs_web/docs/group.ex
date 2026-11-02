defmodule FlintUIDocsWeb.Docs.Group do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :group

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
          %{key: :orientation, type: :select, default: "horizontal", label: "Orientation"},
          %{key: :variant, type: :select, default: "attached", label: "Variant"},
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
      <Components.group
        orientation={props.orientation}
        variant={props.variant}
        size={props.size}
      >
        <Components.button variant="outline">Copy</Components.button>
        <Components.button variant="outline">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".group",
      [
        Snippet.attr("orientation", props.orientation, "horizontal"),
        Snippet.attr("variant", props.variant, "attached"),
        Snippet.attr("size", props.size, "md")
      ],
      """
      <.button variant="outline">Copy</.button>
      <.button variant="outline">Paste</.button>
      """
      |> String.trim()
    )
  end
end
