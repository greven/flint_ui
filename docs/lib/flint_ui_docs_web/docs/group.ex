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
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{
        tab: :styled,
        section: :usage,
        id: :attached,
        title: "Attached",
        controls: [%{key: :attached, type: :boolean, default: true, label: "Attached"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :surface,
        title: "Surface",
        controls: [%{key: :surface, type: :select, default: "solid", label: "Surface"}]
      },
      %{tab: :styled, section: :usage, id: :orientation, title: "Orientation"},
      %{tab: :styled, section: :usage, id: :size, title: "Size"},
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
    <.prose content="A group lays out related controls as a single unit and does not care what its
      children are: it arranges them but never changes their behavior. Use it in place of a plain
      `div` when the controls share a meaning, and pass `label` so that meaning is announced as a
      `group`." />

    <.preview {assigns} code={&main_code/1}>
      <Components.group label="Text formatting" surface="solid">
        <Components.toggle icon="lucide-letter-b" aria-label="Bold" toggled />
        <Components.toggle icon="lucide-italic" aria-label="Italic" />
        <Components.toggle icon="lucide-underline" aria-label="Underline" />
        <Components.toggle icon="lucide-strikethrough" aria-label="Strikethrough" />
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :attached} = assigns) do
    ~H"""
    <.prose content="Set `attached` to join the children into one block that shares a seam. The
      group still only arranges them, so each control keeps its own size, focus ring, and
      behavior." />

    <.preview :let={props} {assigns} code={&attached_code/1}>
      <Components.group label="Document actions" attached={props.attached}>
        <Components.button variant="surface">Cut</Components.button>
        <Components.button variant="surface">Copy</Components.button>
        <Components.button variant="surface">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :surface} = assigns) do
    ~H"""
    <.prose content="Set `surface` to wrap the group in a padded, bordered shell. The default
      `none` leaves the group bare, `soft` and `strong` step up the neutral ladder, and `ghost`
      keeps the frame without a fill." />
    <.prose content="The shell composes with `attached`, so a joined group can also sit inside a
      frame." />

    <.preview :let={props} {assigns} code={&surface_code/1}>
      <Components.group label="Document actions" surface={props.surface}>
        <Components.button variant="surface">Cut</Components.button>
        <Components.button variant="surface">Copy</Components.button>
        <Components.button variant="surface">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :orientation} = assigns) do
    ~H"""
    <.prose content="Use `orientation` to stack the children vertically. It changes only the
      layout: the group adds no arrow-key navigation, so keyboard behavior stays with the
      controls." />

    <.preview {assigns} code={&orientation_code/1}>
      <Components.group label="Document actions" attached orientation="vertical">
        <Components.button variant="surface">Cut</Components.button>
        <Components.button variant="surface">Copy</Components.button>
        <Components.button variant="surface">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="Use `size` to set the gap and the shell padding, from `xs` to `xl`. The size
      also cascades onto the children, so grouped buttons match the group." />

    <.preview {assigns} code={&size_code/1} collapsed>
      <div class="flex flex-col items-start gap-4">
        <div :for={size <- sizes()} class="flex items-center gap-4">
          <span class="w-6 text-xs font-medium text-muted">{size}</span>
          <Components.group surface="solid" size={size}>
            <Components.button
              variant="ghost"
              icon="lucide-zoom-out"
              aria-label="Zoom out"
              square
            />
            <Components.button variant="ghost" icon="lucide-zoom-in" aria-label="Zoom in" square />
            <Components.button
              variant="ghost"
              icon="lucide-expand"
              aria-label="Fullscreen"
              square
            />
          </Components.group>
        </div>
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :icons} = assigns) do
    ~H"""
    <.prose content="For an icon-only group, combine `square` with an `aria-label` so it keeps an accessible name. " />

    <.preview code={&icons_code/1}>
      <Components.group attached>
        <Components.button icon="ph-copy" aria-label="Copy" square />
        <Components.button icon="ph-clipboard" aria-label="Paste" square />
        <Components.button icon="ph-pencil" aria-label="Edit" square />
        <Components.button icon="ph-trash" aria-label="Delete" square />
      </Components.group>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.group label="Text formatting" surface="solid">
      <Components.toggle icon="lucide-letter-b" aria-label="Bold" toggled />
      <Components.toggle icon="lucide-italic" aria-label="Italic" />
      <Components.toggle icon="lucide-underline" aria-label="Underline" />
      <Components.toggle icon="lucide-strikethrough" aria-label="Strikethrough" />
    </Components.group>
    """
  end

  defp main_code(_props) do
    Snippet.tag(
      ".group",
      [~s(label="Text formatting"), ~s(surface="solid")],
      """
      <.toggle icon="lucide-letter-b" aria-label="Bold" toggled />
      <.toggle icon="lucide-italic" aria-label="Italic" />
      <.toggle icon="lucide-underline" aria-label="Underline" />
      <.toggle icon="lucide-strikethrough" aria-label="Strikethrough" />
      """
      |> String.trim()
    )
  end

  defp attached_code(props) do
    Snippet.tag(
      ".group",
      [~s(label="Document actions"), Snippet.flag("attached", props.attached)],
      """
      <.button variant="surface">Cut</.button>
      <.button variant="surface">Copy</.button>
      <.button variant="surface">Paste</.button>
      """
      |> String.trim()
    )
  end

  defp surface_code(props) do
    Snippet.tag(
      ".group",
      [~s(label="Document actions"), Snippet.attr("surface", props.surface, "none")],
      """
      <.button variant="surface">Cut</.button>
      <.button variant="surface">Copy</.button>
      <.button variant="surface">Paste</.button>
      """
      |> String.trim()
    )
  end

  defp orientation_code(_props) do
    Snippet.tag(
      ".group",
      [~s(label="Document actions"), ~s(attached), ~s(orientation="vertical")],
      """
      <.button variant="surface">Cut</.button>
      <.button variant="surface">Copy</.button>
      <.button variant="surface">Paste</.button>
      """
      |> String.trim()
    )
  end

  defp size_code(_props) do
    Snippet.tag(
      ".group",
      [~s(surface="solid"), ~s(size="sm")],
      """
      <.button variant="ghost" icon="lucide-zoom-out" aria-label="Zoom out" square />
      <.button variant="ghost" icon="lucide-zoom-in" aria-label="Zoom in" square />
      <.button variant="ghost" icon="lucide-expand" aria-label="Fullscreen" square />
      """
      |> String.trim()
    )
  end

  defp sizes, do: ~w(xs sm md lg xl)

  defp icons_code(_) do
    """
    <.group attached>
      <.button icon="ph-copy" aria-label="Copy" square />
      <.button icon="ph-clipboard" aria-label="Paste" square />
      <.button icon="ph-pencil" aria-label="Edit" square />
      <.button icon="ph-trash" aria-label="Delete" square />
    </.group>
    """
  end
end
