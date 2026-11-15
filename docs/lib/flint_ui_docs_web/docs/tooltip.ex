defmodule FlintUIDocsWeb.Docs.Tooltip do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :tooltip

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
          %{key: :placement, type: :select, default: "top", label: "Placement"},
          %{key: :align, type: :select, default: "center", label: "Align"},
          %{key: :arrow, type: :boolean, default: true, label: "Arrow"},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :rich,
        title: "Rich Content",
        group_title: "Examples"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :delay,
        title: "Hover Delay"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Wrap the tooltip around the element that should trigger it and pass a short label with `text`. The first element in
      the default slot becomes the trigger; the hook marks it and wires its description, so there are no attributes to spread. The component generates its own DOM id, so pass `id` only when you need a stable handle from your own CSS or JS. `placement` and `align`
      pick the preferred position, and the content flips and shifts on its own when it would leave the viewport." />
    <.preview :let={props} {assigns} code={&usage_code/1}>
      <Components.tooltip
        text="Save changes"
        placement={props.placement}
        align={props.align}
        arrow={props.arrow}
        disabled={props.disabled}
      >
        <Components.button variant="surface" size="sm">Save</Components.button>
      </Components.tooltip>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :rich} = assigns) do
    ~H"""
    <.prose content="A tooltip is a description, not a surface: use the `:content` slot for formatting, but never put links or buttons inside it.
      When the content needs to be reachable or interactive, reach for a popover instead." />
    <.preview {assigns} code={rich_code()}>
      <div class="flex items-center gap-2 text-sm font-medium text-default">
        Save Warning
        <Components.tooltip>
          <Components.button variant="ghost" size="xs" icon="lucide-info" square />
          <:content>
            <p>Save often to not <u><strong>LOSE PROGRESS</strong></u>!</p>
            <p>
              Save by pressing
              <Components.kbd size="xs" variant="outline">Alt</Components.kbd>
              + <Components.kbd size="xs" variant="outline">F4</Components.kbd>.
            </p>
          </:content>
        </Components.tooltip>
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :delay} = assigns) do
    ~H"""
    <.prose content="The default `200` ms delay stops a quick cursor sweep across a row of icon buttons from flashing a tooltip on every one.
      Raise it for dense toolbars, or set `0` to open immediately." />
    <.preview {assigns} code={delay_code()}>
      <div class="flex items-center gap-4">
        <Components.tooltip text="Opens immediately" delay={0}>
          <Components.button variant="surface" size="sm">delay={0}</Components.button>
        </Components.tooltip>

        <Components.tooltip text="Opens after 800 ms" delay={800}>
          <Components.button variant="surface" size="sm">delay={800}</Components.button>
        </Components.tooltip>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-3 py-6">
      <span class="text-xs text-muted">Static preview of the parts</span>
      <div class="flex flex-col items-center gap-4">
        <span
          data-element="tooltip"
          data-part="root"
          data-tooltip
          data-state="open"
        >
          <button
            data-part="trigger"
            data-state="open"
            type="button"
            class="rounded-md border border-default bg-surface px-3 py-1.5 text-sm font-medium text-default shadow-sm"
          >
            Save
          </button>
          <span
            role="tooltip"
            data-part="content"
            data-state="open"
            data-side="bottom"
            class="relative"
          >
            Save changes <span data-part="arrow" aria-hidden="true"></span>
          </span>
        </span>
      </div>
    </div>
    """
  end

  defp usage_code(props) do
    Snippet.tag(".tooltip", code_attrs(props), trigger_body())
  end

  defp code_attrs(props) do
    [
      ~s(text="Save changes"),
      Snippet.attr("placement", props.placement, "top"),
      Snippet.attr("align", props.align, "center"),
      Snippet.flag("arrow", props.arrow),
      Snippet.flag("disabled", props.disabled)
    ]
  end

  defp trigger_body do
    ~s(<.button variant="surface" size="sm">Save</.button>)
  end

  defp rich_code do
    """
    <div class="flex items-center gap-2 text-sm font-medium text-default">
    Save Warning
    <.tooltip>
      <.button variant="ghost" size="xs" icon="lucide-info" square />
      <:content>
        <p>Save often to not <u><strong>LOSE PROGRESS</strong></u>!</p>
        <p>
          Save by pressing
          <.kbd size="xs" variant="outline">Alt</.kbd>
          + <.kbd size="xs" variant="outline">F4</.kbd>.
        </p>
      </:content>
    </.tooltip>
    </div>
    """
    |> String.trim()
  end

  defp delay_code do
    """
    <.tooltip text="Opens immediately" delay={0}>
      <.button variant="surface" size="sm">delay={0}</.button>
    </.tooltip>
    """
    |> String.trim()
  end
end
