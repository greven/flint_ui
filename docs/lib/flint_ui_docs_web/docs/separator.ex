defmodule FlintUIDocsWeb.Docs.Separator do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :separator

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
          %{key: :type, type: :select, default: "solid", label: "Type"},
          %{key: :variant, type: :select, default: "default", label: "Variant"},
          %{key: :size, type: :select, default: "xs", label: "Size"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :content,
        title: "Content",
        controls: [%{key: :position, type: :select, default: "center", label: "Position"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}]
      },
      %{tab: :styled, section: :usage, id: :orientation, title: "Orientation"},
      %{
        tab: :styled,
        section: :usage,
        id: :custom_size,
        title: "Custom Size",
        controls: [%{key: :size, type: :number, default: 4, label: "Size (px)"}]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :sections,
        title: "Between Sections",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :toolbar, title: "In a Toolbar"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={"Use the separator to divide content or groups of controls. It renders a `div` with `role=\"separator\"` by default and is not focusable.
      Pass `decorative` when the line is purely visual, and `as=\"hr\"` when the separation is a thematic break in the document."} />
    <.preview :let={props} {assigns} code={&basic_code/1}>
      <div class="w-full max-w-md">
        <p class="font-medium text-md text-highlighted">FlintUI</p>
        <p class="text-sm text-muted">Phoenix LiveView Components</p>
        <Components.separator
          type={props.type}
          variant={props.variant}
          size={props.size}
          class="my-3"
        />
        <div class="w-full flex h-5 items-center space-x-4 text-sm">
          <div class="text-sm">Some</div>
          <Components.separator
            orientation="vertical"
            type={props.type}
            variant={props.variant}
            size={props.size}
          />
          <div class="text-sm">Other</div>
          <Components.separator
            orientation="vertical"
            type={props.type}
            variant={props.variant}
            size={props.size}
          />
          <div class="text-sm">Item</div>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :content} = assigns) do
    ~H"""
    <.prose content="Pass `label` to center a text label on the line, or `icon` for an icon. The default slot takes precedence over both and accepts any content.
      `position` places the content at the `start`, `center`, or `end` of the line; it has no effect on a separator without content." />
    <.preview :let={props} {assigns} code={&content_code/1}>
      <div class="w-full max-w-md space-y-6">
        <Components.separator label="or" position={props.position} />
        <Components.separator icon="lucide-star" position={props.position} />
        <Components.separator position={props.position}>
          <span class="px-2">This week</span>
        </Components.separator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use `color` to tint the line with a semantic role, or with a raw color for a one-off accent. The label keeps the default text color, so the line carries the emphasis." />
    <.preview :let={props} {assigns} code={&color_code/1}>
      <div class="w-full max-w-md space-y-6">
        <Components.separator color={props.color} label={props.color} />
        <Components.separator color="success" label="success" />
        <Components.separator color="error" label="error" />
        <Components.separator color="#1D72FE" label="raw color" />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :orientation} = assigns) do
    ~H"""
    <.prose content={"Use `orientation=\"vertical\"` for a column layout. A vertical separator stretches to the block size of its container, so place it in a flex or grid row and give that row a height."} />
    <.preview {assigns} code={orientation_code()}>
      <div class="flex h-16 items-stretch gap-4 text-sm text-toned">
        <span class="flex items-center">Components</span>
        <Components.separator orientation="vertical" />
        <span class="flex items-center">Docs</span>
        <Components.separator orientation="vertical" variant="strong" />
        <span class="flex items-center">Source</span>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :custom_size} = assigns) do
    ~H"""
    <.prose content="`size` accepts the `xs` to `xl` scale for line weight, or a number of pixels that is converted to rem. A numeric size writes the `--fl-separator-size` input inline, so it can be any value rather than only the scale." />
    <.preview :let={props} {assigns} code={&custom_size_code/1}>
      <div class="w-full max-w-md space-y-6">
        <Components.separator size={props.size} />
        <p class="text-center text-xs text-muted">{props.size}px</p>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :sections} = assigns) do
    ~H"""
    <.prose content={"Use `as=\"hr\"` when the line is a thematic break between document sections. Keep the surrounding headings: the separator marks the break, but the heading carries the structure."} />
    <.preview {assigns} code={sections_code()}>
      <div class="w-full max-w-md">
        <h3 class="text-sm font-semibold text-highlighted">Release notes</h3>
        <p class="mt-1 text-sm text-toned">Everything new in this version.</p>
        <Components.separator as="hr" class="my-5" />
        <h3 class="text-sm font-semibold text-highlighted">Upgrade guide</h3>
        <p class="mt-1 text-sm text-toned">Steps for moving from the previous version.</p>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :toolbar} = assigns) do
    ~H"""
    <.prose content="A vertical separator can group actions in a toolbar without adding a wrapper around each group. The separator is not a toolbar role, so keep the toolbar itself keyboard accessible." />
    <.preview {assigns} code={toolbar_code()}>
      <div class="flex items-stretch gap-2 rounded-lg border border-default bg-surface p-2">
        <Components.button variant="ghost" size="sm" icon="lucide-undo-2">Undo</Components.button>
        <Components.button variant="ghost" size="sm" icon="lucide-redo-2">Redo</Components.button>
        <Components.separator orientation="vertical" size="sm" />
        <Components.button variant="ghost" size="sm" icon="lucide-copy">Copy</Components.button>
        <Components.button variant="ghost" size="sm" icon="lucide-clipboard-paste">Paste</Components.button>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.separator label="or" class="w-full max-w-sm" />
    """
  end

  defp basic_code(props) do
    Snippet.component(".separator", [
      Snippet.attr("type", props.type, "solid"),
      Snippet.attr("variant", props.variant, "default"),
      Snippet.attr("size", props.size, "xs")
    ])
  end

  defp content_code(props) do
    Snippet.tag(
      ".separator",
      [Snippet.attr("position", props.position, "center")],
      "or"
    )
  end

  defp color_code(props) do
    Snippet.component(".separator", [
      Snippet.attr("color", props.color, "neutral"),
      ~s(label="or")
    ])
  end

  defp orientation_code do
    """
    <div class="flex h-16 items-stretch gap-4 text-sm">
      <span class="flex items-center">Components</span>
      <.separator orientation="vertical" />
      <span class="flex items-center">Docs</span>
      <.separator orientation="vertical" variant="strong" />
      <span class="flex items-center">Source</span>
    </div>
    """
    |> String.trim()
  end

  defp custom_size_code(props) do
    Snippet.component(".separator", [~s(size={#{props.size}})])
  end

  defp sections_code do
    """
    <h3>Release notes</h3>
    <p>Everything new in this version.</p>
    <.separator as="hr" class="my-5" />
    <h3>Upgrade guide</h3>
    <p>Steps for moving from the previous version.</p>
    """
    |> String.trim()
  end

  defp toolbar_code do
    """
    <div class="flex items-stretch gap-2">
      <.button variant="ghost" size="sm" icon="lucide-undo-2">Undo</.button>
      <.button variant="ghost" size="sm" icon="lucide-redo-2">Redo</.button>
      <.separator orientation="vertical" size="sm" />
      <.button variant="ghost" size="sm" icon="lucide-copy">Copy</.button>
      <.button variant="ghost" size="sm" icon="lucide-clipboard-paste">Paste</.button>
    </div>
    """
    |> String.trim()
  end
end
