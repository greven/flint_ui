defmodule FlintUIDocsWeb.Docs.Cluster do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :cluster

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
          %{
            key: :as,
            type: :select,
            default: "div",
            label: "Element",
            values: ~w(div section article aside nav)
          },
          %{key: :align, type: :select, default: "center", label: "Align"},
          %{key: :gap, type: :select, default: "md", label: "Gap"},
          %{key: :justify, type: :select, default: "start", label: "Justify"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :buttons,
        title: "Button row",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :between, title: "Space Between"},
      %{tab: :styled, section: :examples, id: :split, title: "Wrapped Split"},
      %{tab: :styled, section: :examples, id: :list, title: "Semantic List"},
      %{tab: :css, section: :layout_inputs, id: :inputs, title: "Layout inputs"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~s|A cluster lays its children out in a row and wraps them onto new lines when the row runs out of space. `gap` sets the space between children on the shared `--fl-spacing-*` scale and applies to both axes, `align` sets the cross-axis alignment, and `justify` distributes each line. The defaults are `align="center"`, `gap="md"`, and `justify="start"`.|
    } />

    <.prose content="The cluster adapts to the available inline size without breakpoints: children wrap, and the same gap separates the lines. Use `class` to cap the row's width and let the content decide where it breaks. `as` chooses the element, so the cluster can be a `section`, `article`, or `nav` when the grouping is meaningful; it defaults to `div`." />

    <.preview :let={props} {assigns} code={&basic_code/1}>
      <div class="fl-w-full fl-max-w-sm fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.cluster
          as={props.as}
          align={props.align}
          gap={props.gap}
          justify={props.justify}
          class="fl-text-sm"
        >
          <span class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs">
            Design
          </span>
          <span class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs">
            Shipped
          </span>
          <span class="fl-bg-warning-soft fl-text-warning fl-rounded-full fl-px-sm fl-py-xs">
            Review
          </span>
          <span class="fl-bg-surface fl-border fl-border-default fl-text-toned fl-rounded-full fl-px-sm fl-py-xs">
            Backlog
          </span>
          <span class="fl-bg-info-soft fl-text-info fl-rounded-full fl-px-sm fl-py-xs">
            Planned
          </span>
          <span class="fl-bg-surface fl-border fl-border-default fl-text-toned fl-rounded-full fl-px-sm fl-py-xs">
            Paused
          </span>
        </Components.cluster>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :buttons} = assigns) do
    ~H"""
    <.prose content={
      ~s|A cluster is the natural row for a set of actions. `gap="sm"` keeps the buttons close enough to read as one group, and because the row wraps, the same row works on a narrow screen without a breakpoint.|
    } />

    <.preview {assigns} code={buttons_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.cluster gap="sm">
          <Components.button>Save changes</Components.button>
          <Components.button variant="outline">Preview</Components.button>
          <Components.button variant="ghost">Cancel</Components.button>
        </Components.cluster>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :between} = assigns) do
    ~H"""
    <.prose content={
      ~s|`justify="between"` pushes the leading content and the trailing actions to opposite ends. It is the same pattern as the `fl-split` utility, with the props and wrapping semantics of the component. Unlike a fixed split, the cluster still wraps: when the row runs out of space, the actions drop below the title and return to the left edge. Use `justify="split"` when the trailing group should stay at the inline end after it wraps.|
    } />

    <.preview {assigns} code={between_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.cluster
          justify="between"
          gap="sm"
          class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
        >
          <div>
            <p class="fl-text-highlighted fl-font-medium">Team members</p>
            <p class="fl-text-toned fl-text-sm">12 people have access.</p>
          </div>
          <Components.cluster gap="xs">
            <Components.button size="sm" variant="outline">Manage</Components.button>
            <Components.button size="sm">Invite</Components.button>
          </Components.cluster>
        </Components.cluster>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :split} = assigns) do
    ~H"""
    <.prose content={
      ~s|`justify="split"` keeps the leading children at the start and pins the last child to the inline end on every line. When the row is wide it looks like `between`; when the trailing group wraps, it stays right aligned instead of returning to the left edge. The last child can be a nested cluster of actions, so the whole group moves together.|
    } />

    <.preview {assigns} code={split_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <div class="fl-max-w-xs">
          <Components.cluster
            justify="split"
            gap="sm"
            class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
          >
            <div>
              <p class="fl-text-highlighted fl-font-medium">Deployment pipeline</p>
              <p class="fl-text-toned fl-text-sm">Production is healthy.</p>
            </div>
            <Components.cluster gap="xs">
              <Components.button size="sm" variant="outline">View details</Components.button>
              <Components.button size="sm">Redeploy</Components.button>
            </Components.cluster>
          </Components.cluster>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :list} = assigns) do
    ~H"""
    <.prose content={
      ~s|`as="ul"` or `as="ol"` gives the cluster the native list structure, so assistive technology announces a list of items. Render `li` children; the styled layer removes the markers, margin, and indent for you, and the native list semantics stay.|
    } />

    <.preview {assigns} code={list_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.cluster as="ul" aria-label="Release statuses" gap="sm">
          <li class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
            Design
          </li>
          <li class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
            Shipped
          </li>
          <li class="fl-bg-warning-soft fl-text-warning fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
            Review
          </li>
          <li class="fl-bg-surface fl-border fl-border-default fl-text-toned fl-rounded-full fl-px-sm fl-py-xs fl-text-sm">
            Backlog
          </li>
        </Components.cluster>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :layout_inputs, id: :inputs} = assigns) do
    ~H"""
    <.prose content={
      ~s|The styled layer sets `--fl-cluster-gap`, `--fl-cluster-align`, and `--fl-cluster-justify` from the props. Override one of them on a single cluster with `style` when the spacing scale is not enough, and keep the prop for the common case. `justify="split"` is the one value that also touches a child: it sets the distribution to `flex-start` and pins the last child with an auto inline-start margin.|
    } />

    <.preview {assigns} code={layout_inputs_code()} code_only />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.cluster gap="sm">
      <span class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs">
        Design
      </span>
      <span class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs">
        Shipped
      </span>
      <span class="fl-bg-warning-soft fl-text-warning fl-rounded-full fl-px-sm fl-py-xs">
        Review
      </span>
    </Components.cluster>
    """
  end

  defp basic_code(props) do
    Snippet.tag(
      ".cluster",
      [
        Snippet.attr("as", props.as, "div"),
        Snippet.attr("align", props.align, "center"),
        Snippet.attr("gap", props.gap, "md"),
        Snippet.attr("justify", props.justify, "start")
      ],
      """
      <span class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs">Design</span>
      <span class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs">Shipped</span>
      <span class="fl-bg-warning-soft fl-text-warning fl-rounded-full fl-px-sm fl-py-xs">Review</span>
      """
    )
  end

  defp buttons_code do
    """
    <.cluster gap="sm">
      <.button>Save changes</.button>
      <.button variant="outline">Preview</.button>
      <.button variant="ghost">Cancel</.button>
    </.cluster>
    """
    |> String.trim()
  end

  defp between_code do
    """
    <.cluster justify="between" gap="sm">
      <div>
        <p>Team members</p>
        <p>12 people have access.</p>
      </div>
      <.cluster gap="xs">
        <.button size="sm" variant="outline">Manage</.button>
        <.button size="sm">Invite</.button>
      </.cluster>
    </.cluster>
    """
    |> String.trim()
  end

  defp split_code do
    """
    <.cluster justify="split" gap="sm">
      <div>
        <p>Deployment pipeline</p>
        <p>Production is healthy.</p>
      </div>
      <.cluster gap="xs">
        <.button size="sm" variant="outline">View details</.button>
        <.button size="sm">Redeploy</.button>
      </.cluster>
    </.cluster>
    """
    |> String.trim()
  end

  defp list_code do
    """
    <.cluster as="ul" aria-label="Release statuses" gap="sm">
      <li class="fl-bg-primary-soft fl-text-primary fl-rounded-full fl-px-sm fl-py-xs">Design</li>
      <li class="fl-bg-success-soft fl-text-success fl-rounded-full fl-px-sm fl-py-xs">Shipped</li>
    </.cluster>
    """
    |> String.trim()
  end

  defp layout_inputs_code do
    """
    <.cluster gap="md" style="--fl-cluster-gap: var(--fl-spacing-lg)">
      <span>First</span>
      <span>Second</span>
    </.cluster>
    """
    |> String.trim()
  end
end
