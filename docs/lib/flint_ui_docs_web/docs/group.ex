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
          %{key: :variant, type: :select, default: "framed", label: "Variant"},
          %{key: :orientation, type: :select, default: "horizontal", label: "Orientation"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :icons,
        title: "Icons Only",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.group
        label="Text formatting"
        orientation={props.orientation}
        variant={props.variant}
        size={props.size}
      >
        <Components.toggle icon="lucide-letter-b" aria-label="Bold" toggled />
        <Components.toggle icon="lucide-italic" aria-label="Italic" />
        <Components.toggle icon="lucide-underline" aria-label="Underline" />
        <Components.toggle icon="lucide-strikethrough" aria-label="Strikethrough" />
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :icons} = assigns) do
    ~H"""
    <.prose content="For an icon-only group, combine `square` with an `aria-label` so it keeps an accessible name. " />

    <.preview code={&icons_code/1}>
      <Components.group variant="attached">
        <Components.button icon="ph-copy" aria-label="Copy" square />
        <Components.button icon="ph-clipboard" aria-label="Paste" square />
        <Components.button icon="ph-pencil" aria-label="Edit" square />
        <Components.button icon="ph-trash" aria-label="Delete" square />
      </Components.group>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".group",
      [
        ~s(label="Text formatting"),
        Snippet.attr("orientation", props.orientation, "horizontal"),
        Snippet.attr("variant", props.variant, "spaced"),
        Snippet.attr("size", props.size, "md")
      ],
      """
      <.toggle icon="lucide-letter-b" aria-label="Bold" toggled />
      <.toggle icon="lucide-italic" aria-label="Italic" />
      <.toggle icon="lucide-underline" aria-label="Underline" />
      <.toggle icon="lucide-strikethrough" aria-label="Strikethrough" />
      """
      |> String.trim()
    )
  end

  defp icons_code(_) do
    """
    """
  end
end
