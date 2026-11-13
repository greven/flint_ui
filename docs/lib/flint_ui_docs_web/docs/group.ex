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
        section: :usage,
        id: :basic,
        title: "Usage",
        controls: [
          %{key: :orientation, type: :select, default: "horizontal", label: "Orientation"},
          %{key: :variant, type: :select, default: "attached", label: "Variant"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.group
        orientation={props.orientation}
        variant={props.variant}
        size={props.size}
      >
        <Components.button variant="surface">Copy</Components.button>
        <Components.button variant="surface">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.group>
      <Components.button variant="surface">Copy</Components.button>
      <Components.button variant="surface">Paste</Components.button>
    </Components.group>
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
      <.button variant="surface">Copy</.button>
      <.button variant="surface">Paste</.button>
      """
      |> String.trim()
    )
  end
end
