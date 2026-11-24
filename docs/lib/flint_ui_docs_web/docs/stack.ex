defmodule FlintUIDocsWeb.Docs.Stack do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :stack

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
            values: ~w(div section article aside nav form)
          },
          %{key: :align, type: :select, default: "stretch", label: "Align"},
          %{key: :gap, type: :select, default: "md", label: "Gap"},
          %{key: :justify, type: :select, default: "start", label: "Justify"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "In a Form",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :centered, title: "Centered Content"},
      %{
        tab: :styled,
        section: :examples,
        id: :pile,
        title: "Piled Layers",
        controls: [
          %{key: :limit, type: :select, default: "3", label: "Limit"},
          %{key: :direction, type: :select, default: "up", label: "Direction"},
          %{key: :shrink, type: :select, default: "sm", label: "Shrink"},
          %{key: :gap, type: :select, default: "sm", label: "Gap"}
        ]
      },
      %{tab: :styled, section: :examples, id: :semantic, title: "Semantic Element"},
      %{tab: :css, section: :layout_inputs, id: :inputs, title: "Layout inputs"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A stack lays its children out in a column. `align` sets the cross axis, `gap` sets the space between children on the shared `--fl-spacing-*` scale, and `justify` distributes them on the main axis. `align` defaults to `stretch`, `gap` to `md`, and `justify` to `start`. `as` chooses the element, so the stack can be a `section`, `article`, or `nav` when the grouping is meaningful; it defaults to `div`." />

    <.prose content="`justify` only has a visible effect when the stack is taller than its content, so the demo gives it a fixed block size. The children otherwise keep their own height. Use `class` for sizing and the surrounding layout; the stack only owns the column." />

    <.preview :let={props} {assigns} code={&basic_code/1}>
      <div class="fl-w-full fl-max-w-sm" style="block-size: 18rem">
        <Components.stack
          as={props.as}
          align={props.align}
          gap={props.gap}
          justify={props.justify}
          class="fl-h-full"
        >
          <div class="fl-border fl-border-default fl-rounded-lg fl-bg-subtle fl-p-md">
            <p class="fl-text-highlighted fl-font-medium">Design tokens</p>
            <p class="fl-text-toned fl-text-sm">One source for color and spacing.</p>
          </div>
          <div class="fl-border fl-border-default fl-rounded-lg fl-bg-subtle fl-p-md">
            <p class="fl-text-highlighted fl-font-medium">Components</p>
            <p class="fl-text-toned fl-text-sm">Accessible building blocks.</p>
          </div>
          <div class="fl-border fl-border-default fl-rounded-lg fl-bg-subtle fl-p-md">
            <p class="fl-text-highlighted fl-font-medium">Utilities</p>
            <p class="fl-text-toned fl-text-sm">A small layout and token layer.</p>
          </div>
        </Components.stack>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content={
      ~s|A stack keeps a form's label, field, and action in one rhythm. `gap="sm"` is tighter than the page spacing, so the controls read as one unit while the form still separates itself from the content above it.|
    } />

    <.preview {assigns} code={form_code()}>
      <Components.stack gap="sm" class="fl-w-full fl-max-w-sm">
        <Components.input
          name="stack-email"
          type="email"
          label="Email"
          placeholder="you@example.com"
        />
        <Components.input
          name="stack-password"
          type="password"
          label="Password"
          placeholder="At least 12 characters"
        />
        <Components.button type="submit" class="fl-w-full">Create account</Components.button>
      </Components.stack>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :centered} = assigns) do
    ~H"""
    <.prose content={
      ~s|Center a short empty state with `align="center"` and `justify="center"`. The stack fills the available height through `fl-h-full`, and the wrapper's fixed block size makes the vertical centering visible.|
    } />

    <.preview {assigns} code={centered_code()}>
      <div class="fl-w-full fl-max-w-sm" style="block-size: 18rem">
        <Components.stack align="center" justify="center" gap="sm" class="fl-h-full fl-text-center">
          <Components.icon name="lucide-inbox" class="fl-text-muted fl-text-3xl" />
          <p class="fl-text-highlighted fl-font-semibold">No messages yet</p>
          <p class="fl-text-toned fl-text-sm">New conversations will show up here.</p>
          <Components.button size="sm">Start a conversation</Components.button>
        </Components.stack>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :pile} = assigns) do
    ~H"""
    <.prose content={
      ~s|`pile` overlaps the children as a deck instead of flowing them. The last child is the front layer and earlier children recede along `direction`, narrowing by `shrink`, so append the newest item last. `gap` sets the base distance between layers, and `limit` caps how many stay visible: earlier layers past the limit are hidden. `align` and `justify` no longer apply while piled.|
    } />

    <.prose content={
      ~s|`direction="up"` stacks the layers above the front one, which suits a pile anchored to the bottom of a region; `down` stacks them below. `shrink` tapers the layers behind the front one, and `none` keeps every layer the same width. Both work from the front card outward, so the pile reads the same at every limit. Keep `gap` smaller than the card's edge padding so the peek shows the card edge rather than a slice of its content.|
    } />

    <.prose content={
      ~s|A pile is a preview, not a notification system. Hidden layers leave the accessibility tree, so give the reader a count or a link to the full list, and keep interactive controls on the visible layers. The layers behind the front one are still read in full, so their text should stand on its own even though only a strip of each shows.|
    } />

    <.preview :let={props} {assigns} code={&pile_code/1}>
      <div class="fl-w-full fl-max-w-sm">
        <Components.stack
          pile
          limit={props.limit}
          direction={props.direction}
          shrink={props.shrink}
          gap={props.gap}
        >
          <div class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-sm">
            <p class="fl-text-highlighted fl-text-sm fl-font-medium">Backup complete</p>
            <p class="fl-text-toned fl-text-sm">Nightly snapshot saved.</p>
          </div>
          <div class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-sm">
            <p class="fl-text-highlighted fl-text-sm fl-font-medium">New comment</p>
            <p class="fl-text-toned fl-text-sm">Ada replied to your review.</p>
          </div>
          <div class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-sm">
            <p class="fl-text-highlighted fl-text-sm fl-font-medium">Build passed</p>
            <p class="fl-text-toned fl-text-sm">All checks are green.</p>
          </div>
          <div class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-sm">
            <p class="fl-text-highlighted fl-text-sm fl-font-medium">Pull request merged</p>
            <p class="fl-text-toned fl-text-sm">Two approvals, no conflicts.</p>
          </div>
          <div class="fl-flex fl-items-center fl-gap-sm fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-sm">
            <div class="fl-flex-1">
              <p class="fl-text-highlighted fl-text-sm fl-font-medium">Deploy finished</p>
              <p class="fl-text-toned fl-text-sm">main is live in production.</p>
            </div>
            <Components.button size="sm" variant="ghost">Dismiss</Components.button>
          </div>
        </Components.stack>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :semantic} = assigns) do
    ~H"""
    <.prose content={
      ~s|Use `as` to give the grouping the element it already means. A `section` needs an accessible name, so point `aria-labelledby` at its heading; a `nav` can take `aria-label` instead. The stack still only owns the column, and the chosen element keeps its native semantics.|
    } />

    <.preview {assigns} code={semantic_code()}>
      <div class="fl-w-full fl-max-w-sm">
        <Components.stack
          as="section"
          aria-labelledby="stack-semantic-title"
          gap="sm"
          class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-lg"
        >
          <Components.heading as="h2" size="lg" id="stack-semantic-title">
            Release notes
          </Components.heading>
          <p class="fl-text-toned fl-text-sm">
            Tokens, components, and utilities in one release.
          </p>
          <Components.button size="sm">Read the notes</Components.button>
        </Components.stack>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :layout_inputs, id: :inputs} = assigns) do
    ~H"""
    <.prose content="The styled layer sets `--fl-stack-gap`, `--fl-stack-align`, and `--fl-stack-justify` from the props, and a pile adds `--fl-stack-pile-offset` and `--fl-stack-pile-shrink`. Override one of them on a single stack with `style` when the scale is not enough, and keep the prop for the common case. `--fl-stack-gap` still drives the base offset, so changing it loosens or tightens the whole deck." />

    <.preview {assigns} code={layout_inputs_code()} code_only />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.stack gap="sm" class="fl-w-full fl-max-w-sm">
      <div class="fl-border fl-border-default fl-rounded-lg fl-bg-subtle fl-p-md">First</div>
      <div class="fl-border fl-border-default fl-rounded-lg fl-bg-subtle fl-p-md">Second</div>
    </Components.stack>
    """
  end

  defp basic_code(props) do
    Snippet.tag(
      ".stack",
      [
        Snippet.attr("as", props.as, "div"),
        Snippet.attr("align", props.align, "stretch"),
        Snippet.attr("gap", props.gap, "md"),
        Snippet.attr("justify", props.justify, "start")
      ],
      """
      <div class="fl-border fl-rounded-lg fl-p-md">Design tokens</div>
      <div class="fl-border fl-rounded-lg fl-p-md">Components</div>
      <div class="fl-border fl-rounded-lg fl-p-md">Utilities</div>
      """
    )
  end

  defp form_code do
    """
    <.stack gap="sm" class="fl-max-w-sm">
      <.input name="email" type="email" label="Email" />
      <.input name="password" type="password" label="Password" />
      <.button type="submit">Create account</.button>
    </.stack>
    """
    |> String.trim()
  end

  defp centered_code do
    """
    <div class="fl-h-full" style="block-size: 18rem">
      <.stack align="center" justify="center" gap="sm" class="fl-h-full fl-text-center">
        <p class="fl-text-highlighted fl-font-semibold">No messages yet</p>
        <p class="fl-text-toned fl-text-sm">New conversations will show up here.</p>
        <.button size="sm">Start a conversation</.button>
      </.stack>
    </div>
    """
    |> String.trim()
  end

  defp pile_code(props) do
    Snippet.tag(
      ".stack",
      [
        Snippet.flag("pile", true),
        Snippet.attr("limit", props.limit, "3"),
        Snippet.attr("direction", props.direction, "up"),
        Snippet.attr("shrink", props.shrink, "sm"),
        Snippet.attr("gap", props.gap, "sm")
      ],
      """
      <div class="fl-rounded-lg fl-border fl-bg-surface fl-p-sm">Backup complete</div>
      <div class="fl-rounded-lg fl-border fl-bg-surface fl-p-sm">New comment</div>
      <div class="fl-rounded-lg fl-border fl-bg-surface fl-p-sm">Deploy finished</div>
      """
    )
  end

  defp semantic_code do
    """
    <.stack as="section" aria-labelledby="release-title" gap="sm">
      <.heading as="h2" size="lg" id="release-title">Release notes</.heading>
      <p>Tokens, components, and utilities in one release.</p>
      <.button size="sm">Read the notes</.button>
    </.stack>
    """
    |> String.trim()
  end

  defp layout_inputs_code do
    """
    <.stack gap="md" style="--fl-stack-gap: var(--fl-spacing-lg)">
      <div>First</div>
      <div>Second</div>
    </.stack>
    """
    |> String.trim()
  end
end
