defmodule FlintUIDocsWeb.Docs.Progress do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :progress

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @steps ["Waiting", "Cloning", "Migrating", "Deploying", "Done"]

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
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :color, type: :select, default: "primary", label: "Color"},
          %{key: :radius, type: :select, default: "full", label: "Radius"},
          %{key: :show_status, type: :boolean, default: true, label: "Status"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :steps,
        title: "Steps",
        controls: [
          %{
            key: :value,
            type: :select,
            default: "3",
            label: "Step",
            values: ["0", "1", "2", "3", "4"]
          },
          %{key: :color, type: :select, default: "primary", label: "Color"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :striped,
        title: "Striped",
        controls: [
          %{key: :striped, type: :boolean, default: true, label: "Striped"},
          %{key: :animated, type: :boolean, default: false, label: "Animated"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :indeterminate,
        title: "Indeterminate",
        controls: [
          %{key: :indeterminate, type: :select, default: "swing", label: "Animation"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :orientation,
        title: "Vertical",
        controls: [
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"}
        ]
      },
      %{tab: :styled, section: :usage, id: :status, title: "Status"},
      %{
        tab: :styled,
        section: :examples,
        id: :uploads,
        title: "Upload Queue",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={~S|A progress bar shows how far along a task has run. Set `value`
      against `max`; the bar fills by the ratio of the two. `max` defaults to 100, and
      values outside the scale are clamped, so a server-side count can be passed
      directly. Omit `value` for an indeterminate bar, shown below.|} />

    <.prose content={~S|`size` controls the track thickness and the status text, `radius`
      controls the corners, and `color` sets the fill. `show_status` prints the rounded
      percentage above the bar. The same percentage is exposed as `aria-valuetext`, so
      assistive technology hears it even when `max` is not 100.|} />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.progress
          value="40"
          max="100"
          label="Upload progress"
          show_status={props.show_status}
          size={props.size}
          color={props.color}
          radius={props.radius}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :steps} = assigns) do
    ~H"""
    <.prose content={~S|`max` also accepts a list of step labels. The last label is the
      maximum, so the labels spread evenly from 0% to 100%: five labels run from 0 to 4,
      so `value="3"` fills 75% and shows "Deploying" under the bar. The active label
      replaces the percentage as the accessible value text. The first label is the idle
      state and stays muted; the rest use the selected color. Steps are hidden while the
      bar is indeterminate.|} />

    <.preview :let={props} {assigns} code={&code_steps/1}>
      <div class="w-full max-w-sm">
        <Components.progress
          value={props.value}
          max={steps()}
          label="Deployment"
          color={props.color}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :striped} = assigns) do
    ~H"""
    <.prose content={~S|`striped` adds a static diagonal overlay to the fill. Set
      `animated` to scroll the same stripes; `animated` implies the pattern, so the two
      attributes can be used together or on their own. The stripes mix toward the track
      color, so the pattern reads on every color role without a second color input.|} />

    <.preview :let={props} {assigns} code={&code_striped/1}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.progress
          value="60"
          label="Uploading"
          show_status
          striped={props.striped}
          animated={props.animated}
        />
        <Components.progress
          value="60"
          label="Syncing"
          show_status
          color="success"
          striped={props.striped}
          animated={props.animated}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :indeterminate} = assigns) do
    ~H"""
    <.prose content={~S|When a task cannot report progress, omit `value`. The bar becomes
      indeterminate: it carries no `aria-valuenow` and moves instead. The `indeterminate`
      prop chooses the motion: `carousel` (the default) travels forward, `swing` moves
      between the ends, and `elastic` stretches and shrinks. The prop only selects the
      animation; omitting `value` is still what makes the bar indeterminate.|} />

    <.prose content={~S|The motion is decorative and stops under
      `prefers-reduced-motion`, where the segment becomes a static full track. A status
      is hidden while the bar is indeterminate, since there is no percentage to show.|} />

    <.preview :let={props} {assigns} code={&code_indeterminate/1}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.progress label="Uploading" indeterminate={props.indeterminate} />
        <Components.progress
          label="Processing"
          indeterminate={props.indeterminate}
          color="success"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :orientation} = assigns) do
    ~H"""
    <.prose content={~S|`orientation="vertical"` puts the track on its side and fills it
      from the bottom. A vertical bar defaults to ten rems tall; set a height with
      `class` or `style` when the surrounding layout needs a different length. The status
      stays above the track and centres over it.|} />

    <.preview :let={props} {assigns} code={&code_vertical/1}>
      <div class="flex items-end gap-8">
        <Components.progress
          value="72"
          label="Storage used"
          orientation={props.orientation}
          show_status
          class="h-44"
        />
        <Components.progress value="35" label="Bandwidth" orientation={props.orientation} />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :status} = assigns) do
    ~H"""
    <.prose content={~S|`show_status` renders the rounded percentage above the bar. The
      status is decorative and hidden from assistive technology, because the progressbar
      already announces the same percentage through `aria-valuetext`. A zero value shows
      `0%`; a value at the maximum shows `100%`.|} />

    <.preview {assigns} code={code_status()}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.progress value="0" label="Starting" show_status />
        <Components.progress value="35" label="Indexing" show_status />
        <Components.progress value="100" label="Finished" show_status color="success" />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :uploads} = assigns) do
    ~H"""
    <.prose content={~S|A queue can mix determinate and indeterminate bars under one
      heading, with static or moving stripes. Each bar keeps its own accessible name, so
      the status text can stay visual while the bar itself announces the same
      percentage.|} />

    <.preview {assigns} code={code_uploads()}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.progress
          value="100"
          label="Design files"
          show_status
          color="success"
          striped
        />
        <Components.progress value="62" label="Photos" show_status animated />
        <Components.progress label="Video" indeterminate="swing" />
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-sm">
      <Components.progress
        value="3"
        max={steps()}
        label="Deployment"
        show_status
        size="md"
        color="primary"
        radius="full"
        striped
      />
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.component(".progress", [
      ~s(value="40"),
      ~s(max="100"),
      ~s(label="Upload progress"),
      Snippet.flag("show_status", props.show_status),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("color", props.color, "primary"),
      Snippet.attr("radius", props.radius, "full")
    ])
  end

  defp steps, do: @steps

  defp code_steps(props) do
    Snippet.component(".progress", [
      Snippet.attr("value", props.value, "3"),
      Snippet.attr("max", @steps),
      ~s(label="Deployment"),
      Snippet.attr("color", props.color, "primary")
    ])
  end

  defp code_striped(props) do
    Snippet.component(".progress", [
      ~s(value="60"),
      ~s(label="Uploading"),
      "show_status",
      Snippet.flag("striped", props.striped),
      Snippet.flag("animated", props.animated)
    ])
  end

  defp code_indeterminate(props) do
    Snippet.component(".progress", [
      ~s(label="Uploading"),
      Snippet.attr("indeterminate", props.indeterminate, "carousel")
    ])
  end

  defp code_vertical(props) do
    Snippet.component(".progress", [
      ~s(value="72"),
      ~s(label="Storage used"),
      Snippet.attr("orientation", props.orientation, "horizontal"),
      "show_status",
      ~s(class="h-44")
    ])
  end

  defp code_status do
    Enum.join(
      [
        Snippet.component(".progress", [~s(value="0"), ~s(label="Starting"), "show_status"]),
        Snippet.component(".progress", [~s(value="35"), ~s(label="Indexing"), "show_status"]),
        Snippet.component(".progress", [
          ~s(value="100"),
          ~s(label="Finished"),
          ~s(color="success"),
          "show_status"
        ])
      ],
      "\n"
    )
  end

  defp code_uploads do
    Enum.join(
      [
        Snippet.component(".progress", [
          ~s(value="100"),
          ~s(label="Design files"),
          ~s(color="success"),
          "show_status",
          "striped"
        ]),
        Snippet.component(".progress", [
          ~s(value="62"),
          ~s(label="Photos"),
          "show_status",
          "animated"
        ]),
        Snippet.component(".progress", [~s(label="Video"), ~s(indeterminate="swing")])
      ],
      "\n"
    )
  end
end
