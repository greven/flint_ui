defmodule FlintUIDocsWeb.Docs.Popover do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :popover

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet
  alias FlintUIDocsWeb.DocsComponents

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
          %{key: :placement, type: :select, default: "bottom", label: "Placement"},
          %{key: :align, type: :select, default: "center", label: "Align"},
          %{key: :arrow, type: :boolean, default: false, label: "Arrow"},
          %{key: :opened, type: :boolean, default: false, label: "Initially open"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Wrap the popover around the element that should trigger it. The first element in the default slot becomes the trigger.
      The hook marks it and wires `aria-haspopup`, `aria-expanded`, and `aria-controls`, so there are no attributes to spread. Pass a stable `id`
      when the content contains a control that has to close the popover. The content is a dialog named after the trigger unless you pass `aria_label`
      or `aria_labelledby`. `placement`, `align`, and `offset` position it; it flips and shifts on its own near the viewport edge." />
    <.preview :let={props} {assigns} code={&usage_code/1}>
      <div class="w-full max-w-74 flex justify-center">
        <Components.popover
          id={"#{@preview_id}-popover"}
          placement={props.placement}
          align={props.align}
          arrow={props.arrow}
          opened={props.opened}
          aria_label="Account actions"
        >
          <Components.button variant="surface" size="sm">Open</Components.button>
          <:content>
            <DocsComponents.content_placeholder class="h-40 w-64" />
          </:content>
        </Components.popover>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-3 py-6">
      <span class="text-xs text-muted">Static preview of the parts</span>
      <div data-element="popover" data-part="root" data-popover data-state="open">
        <button
          data-part="trigger"
          data-state="open"
          type="button"
          class="rounded-md border border-default bg-surface px-3 py-1.5 text-sm font-medium text-default shadow-sm"
        >
          Open
        </button>
        <div
          data-part="content"
          data-popover-content
          data-state="open"
          data-side="bottom"
          class="relative mt-3 w-64"
        >
          <p class="text-sm font-semibold text-highlighted">Popover content</p>
          <p class="mt-1 text-xs text-toned">Positioned next to the trigger.</p>
          <span data-part="arrow" aria-hidden="true"></span>
        </div>
      </div>
    </div>
    """
  end

  defp usage_code(props) do
    Snippet.tag(
      ".popover",
      [
        ~s(id="account"),
        ~s(aria_label="Account actions"),
        Snippet.attr("placement", props.placement, "bottom"),
        Snippet.attr("align", props.align, "center"),
        Snippet.flag("arrow", props.arrow),
        Snippet.flag("opened", props.opened)
      ],
      usage_body()
    )
  end

  defp usage_body do
    """
    <.button variant="surface" size="sm">Open</.button>
    <:content>
      <p>Content</p>
    </:content>
    """
    |> String.trim()
  end
end
