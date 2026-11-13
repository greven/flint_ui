defmodule FlintUIDocsWeb.Docs.Kbd do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :kbd

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
          %{key: :variant, type: :select, default: "raised", label: "Variant"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :variants,
        title: "Variants"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :size,
        title: "Size"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :shortcuts,
        title: "Keyboard Shortcuts",
        group_title: "Examples"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :inline,
        title: "Inline with Text"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the default slot for the key's label. Render one `.kbd` per key and keep the separators between them,
      so a shortcut reads as text while every key keeps its own cap." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <span class="inline-flex flex-wrap items-center gap-1.5">
        <Components.kbd variant={props.variant} size={props.size}>⌘</Components.kbd>
        <span class="text-sm text-dimmed" aria-hidden="true">+</span>
        <Components.kbd variant={props.variant} size={props.size}>⌥</Components.kbd>
        <span class="text-sm text-dimmed" aria-hidden="true">+</span>
        <Components.kbd variant={props.variant} size={props.size}>M</Components.kbd>
      </span>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :variants} = assigns) do
    ~H"""
    <.prose content="`raised` is the default keycap, `subtle` is a soft neutral tint with a faint edge, and `outline` is a flat key with a full border. All three share the same size scale and cap geometry, so they line up in a row." />
    <.preview {assigns} code={variants_code()}>
      <div class="flex flex-wrap items-center gap-6">
        <div :for={variant <- ~w(raised subtle outline)} class="flex flex-col items-center gap-2">
          <Components.kbd variant={variant}>K</Components.kbd>
          <span class="text-xs text-muted">{variant}</span>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="Use `size` to scale the key, from `xs` to `xl`. The font and the cap grow together, so the padding stays proportional and mixed sizes still line up. The default size is `md`." />
    <.preview {assigns} code={&size_code/1}>
      <div class="flex flex-wrap items-end gap-4">
        <div :for={{size, label} <- sizes()} class="flex flex-col items-center gap-2">
          <Components.kbd size={size}>K</Components.kbd>
          <span class="text-xs text-muted">{label}</span>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :shortcuts} = assigns) do
    ~H"""
    <.prose content="Use the `subtle` variant when a key sits next to text and should stay quiet, such as a shortcut hint. Keep the key names literal: `⌘`, `⇧`, and `⌥` on macOS, `Ctrl`, `Shift`, and `Alt` elsewhere." />
    <.preview {assigns} code={shortcut_code()}>
      <div class="w-full max-w-sm space-y-2">
        <div class="flex items-center justify-between gap-4 rounded-md border border-default bg-surface px-3 py-2">
          <span class="text-sm text-toned">Search</span>
          <span class="inline-flex items-center gap-1">
            <Components.kbd variant="subtle" size="sm">⌘</Components.kbd>
            <span class="text-xs text-dimmed" aria-hidden="true">+</span>
            <Components.kbd variant="subtle" size="sm">K</Components.kbd>
          </span>
        </div>
        <div class="flex items-center justify-between gap-4 rounded-md border border-default bg-surface px-3 py-2">
          <span class="text-sm text-toned">Command palette</span>
          <span class="inline-flex items-center gap-1">
            <Components.kbd variant="subtle" size="sm">Ctrl</Components.kbd>
            <span class="text-xs text-dimmed" aria-hidden="true">+</span>
            <Components.kbd variant="subtle" size="sm">Shift</Components.kbd>
            <span class="text-xs text-dimmed" aria-hidden="true">+</span>
            <Components.kbd variant="subtle" size="sm">P</Components.kbd>
          </span>
        </div>
        <div class="flex items-center justify-between gap-4 rounded-md border border-default bg-surface px-3 py-2">
          <span class="text-sm text-toned">Close dialog</span>
          <Components.kbd variant="subtle" size="sm">Esc</Components.kbd>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :inline} = assigns) do
    ~H"""
    <.prose content="A key sits inline with body text. Keep the key label short and make sure the shortcut is also available through a visible action, because a key hint alone is not a control." />
    <.preview {assigns} code={inline_code()}>
      <p class="max-w-prose text-sm text-toned">
        Press
        <Components.kbd variant="subtle" size="sm">Esc</Components.kbd>
        to close the dialog, or
        <Components.kbd variant="subtle" size="sm">⌘</Components.kbd>
        <span class="text-dimmed" aria-hidden="true">+</span>
        <Components.kbd variant="subtle" size="sm">K</Components.kbd>
        to search.
      </p>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.kbd>K</Components.kbd>
      <Components.kbd variant="subtle">Esc</Components.kbd>
      <Components.kbd variant="outline">Tab</Components.kbd>
    </div>
    """
  end

  defp main_code(props) do
    attrs = [
      Snippet.attr("variant", props.variant, "raised"),
      Snippet.attr("size", props.size, "md")
    ]

    Enum.map_join(~w(⌘ ⌥ M), " + ", &Snippet.tag(".kbd", attrs, &1))
  end

  defp variants_code do
    """
    <.kbd variant="raised">K</.kbd>
    <.kbd variant="subtle">K</.kbd>
    <.kbd variant="outline">K</.kbd>
    """
    |> String.trim()
  end

  defp size_code(_) do
    """
    <.kbd size="xs">K</.kbd>
    <.kbd size="sm">K</.kbd>
    <.kbd size="md">K</.kbd>
    <.kbd size="lg">K</.kbd>
    <.kbd size="xl">K</.kbd>
    """
    |> String.trim()
  end

  defp shortcut_code do
    """
    <div class="flex items-center justify-between gap-4">
      <span>Search</span>
      <span class="inline-flex items-center gap-1">
        <.kbd variant="subtle" size="sm">⌘</.kbd>
        <span aria-hidden="true">+</span>
        <.kbd variant="subtle" size="sm">K</.kbd>
      </span>
    </div>

    <div class="flex items-center justify-between gap-4">
      <span>Command palette</span>
      <span class="inline-flex items-center gap-1">
        <.kbd variant="subtle" size="sm">Ctrl</.kbd>
        <span aria-hidden="true">+</span>
        <.kbd variant="subtle" size="sm">Shift</.kbd>
        <span aria-hidden="true">+</span>
        <.kbd variant="subtle" size="sm">P</.kbd>
      </span>
    </div>

    <div class="flex items-center justify-between gap-4">
      <span>Close dialog</span>
      <.kbd variant="subtle" size="sm">Esc</.kbd>
    </div>
    """
    |> String.trim()
  end

  defp inline_code do
    """
    <p>
      Press <.kbd variant="subtle" size="sm">Esc</.kbd> to close the dialog, or
      <.kbd variant="subtle" size="sm">⌘</.kbd> + <.kbd variant="subtle" size="sm">K</.kbd> to search.
    </p>
    """
    |> String.trim()
  end

  defp sizes do
    [
      {"xs", "Extra small"},
      {"sm", "Small"},
      {"md", "Medium"},
      {"lg", "Large"},
      {"xl", "Extra large"}
    ]
  end
end
