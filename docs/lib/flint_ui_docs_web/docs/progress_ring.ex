defmodule FlintUIDocsWeb.Docs.ProgressRing do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :progress_ring

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @steps ["Waiting", "Cloning", "Migrating", "Deploying", "Done"]
  @sizes ~w(xs sm md lg xl)
  @thicknesses ~w(xs sm md lg xl)

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
          %{key: :thickness, type: :select, default: "md", label: "Thickness"},
          %{key: :color, type: :select, default: "primary", label: "Color"},
          %{key: :show_status, type: :boolean, default: true, label: "Status"}
        ]
      },
      %{tab: :styled, section: :usage, id: :sizes, title: "Sizes"},
      %{tab: :styled, section: :usage, id: :thickness, title: "Thickness"},
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
        id: :indeterminate,
        title: "Indeterminate",
        controls: [
          %{key: :indeterminate, type: :select, default: "spin", label: "Animation"}
        ]
      },
      %{tab: :styled, section: :usage, id: :status, title: "Status"},
      %{
        tab: :styled,
        section: :examples,
        id: :dashboard,
        title: "Dashboard",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={~S|A progress ring shows how far along a task has run in a circle.
      Set `value` against `max`; the arc fills clockwise from twelve o'clock by the
      ratio of the two. `max` defaults to 100, and values outside the scale are
      clamped, so a server-side count can be passed directly.|} />

    <.prose content={~S|`size` sets the diameter and `thickness` sets the stroke width as
      a share of that diameter, so the ring stays proportional as it grows. `color` sets
      the arc; the track stays neutral. `show_status` prints the rounded percentage in
      the centre of the ring. The same percentage is exposed as `aria-valuetext`, so
      assistive technology hears it even when `max` is not 100.|} />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <Components.progress_ring
        value="72"
        max="100"
        label="Upload progress"
        show_status={props.show_status}
        size={props.size}
        thickness={props.thickness}
        color={props.color}
      />
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :sizes} = assigns) do
    ~H"""
    <.prose content={~S|`size` changes the outer diameter and scales the status text with
      it: `xs` is 2.5rem, `sm` 3rem, `md` 4rem, `lg` 6rem, and `xl` 8rem. Override
      `--fl-progress-ring-size` for a one-off diameter that the scale does not cover.|} />

    <.preview {assigns} code={code_sizes()}>
      <div class="flex flex-wrap items-end justify-center gap-8">
        <Components.progress_ring
          :for={size <- sizes()}
          value="72"
          label={"Storage used, #{size}"}
          size={size}
          show_status
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :thickness} = assigns) do
    ~H"""
    <.prose content={~S|`thickness` sets the stroke width as a percentage of the
      diameter: `xs` is 3%, `sm` 4%, `md` 6%, `lg` 8%, and `xl` 10%. The proportional
      scale keeps a thick ring from swallowing a small one. Override
      `--fl-progress-ring-thickness` with a unitless value for a custom stroke.|} />

    <.preview {assigns} code={code_thicknesses()}>
      <div class="flex flex-wrap items-center justify-center gap-8">
        <Components.progress_ring
          :for={thickness <- thicknesses()}
          value="64"
          label={"Disk usage, #{thickness} thickness"}
          size="lg"
          thickness={thickness}
          color="success"
          show_status
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :steps} = assigns) do
    ~H"""
    <.prose content={~S|`max` also accepts a list of step labels. The last label is the
      maximum, so the labels spread evenly from 0% to 100%: five labels run from 0 to 4,
      so `value="3"` fills three quarters of the ring and shows "Deploying" under it. The
      active label replaces the percentage as the accessible value text. The first label
      is the idle state and stays muted; the rest use the selected color. Steps are
      hidden while the ring is indeterminate.|} />

    <.preview :let={props} {assigns} code={&code_steps/1}>
      <Components.progress_ring
        value={props.value}
        max={steps()}
        label="Deployment"
        color={props.color}
        show_status
      />
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :indeterminate} = assigns) do
    ~H"""
    <.prose content={~S|When a task cannot report progress, omit `value`. The ring
      becomes indeterminate: it carries no `aria-valuenow` and moves instead. The
      `indeterminate` prop chooses the motion: `spin` (the default) turns a fixed arc,
      and `sweep` grows and shrinks the arc while it turns. The prop only selects the
      animation; omitting `value` is still what makes the ring indeterminate.|} />

    <.prose content={~S|The motion is decorative and stops under
      `prefers-reduced-motion`, where the arc becomes a static quarter circle. A status
      is hidden while the ring is indeterminate, since there is no percentage to show.|} />

    <.preview :let={props} {assigns} code={&code_indeterminate/1}>
      <div class="flex flex-wrap items-center justify-center gap-10">
        <Components.progress_ring
          label="Uploading"
          size="lg"
          indeterminate={props.indeterminate}
        />
        <Components.progress_ring
          label="Processing"
          size="lg"
          color="success"
          indeterminate={props.indeterminate}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :status} = assigns) do
    ~H"""
    <.prose content={~S|`show_status` renders the rounded percentage in the centre of
      the ring. The status is decorative and hidden from assistive technology, because
      the progressbar already announces the same percentage through `aria-valuetext`. A
      zero value shows `0%`; a value at the maximum shows `100%`.|} />

    <.preview {assigns} code={code_status()}>
      <div class="flex flex-wrap items-center justify-center gap-8">
        <Components.progress_ring value="0" label="Starting" show_status />
        <Components.progress_ring value="35" label="Indexing" show_status />
        <Components.progress_ring value="100" label="Finished" color="success" show_status />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :dashboard} = assigns) do
    ~H"""
    <.prose content={~S|Rings suit compact summaries, such as a storage card or a
      deployment tile, where a linear bar would take more room than the value deserves.
      Each ring keeps its own accessible name and percentage, so a row of them reads as
      a set of independent tasks.|} />

    <.preview {assigns} code={code_dashboard()}>
      <div class="flex flex-wrap items-center justify-center gap-10">
        <Components.progress_ring
          value="82"
          label="Storage used"
          size="lg"
          color="warning"
          show_status
        />
        <Components.progress_ring
          value="3"
          max={steps()}
          label="Deployment"
          size="lg"
          color="info"
          show_status
        />
        <Components.progress_ring
          value="100"
          label="Backup complete"
          size="lg"
          color="success"
          show_status
        />
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.progress_ring
      value="3"
      max={steps()}
      label="Deployment"
      show_status
      size="lg"
      thickness="md"
      color="primary"
    />
    """
  end

  defp code_basic(props) do
    Snippet.component(".progress_ring", [
      ~s(value="72"),
      ~s(max="100"),
      ~s(label="Upload progress"),
      Snippet.flag("show_status", props.show_status),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("thickness", props.thickness, "md"),
      Snippet.attr("color", props.color, "primary")
    ])
  end

  defp steps, do: @steps

  defp sizes, do: @sizes

  defp thicknesses, do: @thicknesses

  defp code_sizes do
    Enum.map_join(@sizes, "\n", fn size ->
      Snippet.component(".progress_ring", [
        ~s(value="72"),
        ~s(label={"Storage used, #{size}"}),
        ~s(size="#{size}"),
        "show_status"
      ])
    end)
  end

  defp code_thicknesses do
    Enum.map_join(@thicknesses, "\n", fn thickness ->
      Snippet.component(".progress_ring", [
        ~s(value="64"),
        ~s(label={"Disk usage, #{thickness} thickness"}),
        ~s(size="lg"),
        ~s(thickness="#{thickness}"),
        ~s(color="success"),
        "show_status"
      ])
    end)
  end

  defp code_steps(props) do
    Snippet.component(".progress_ring", [
      Snippet.attr("value", props.value, "3"),
      Snippet.attr("max", @steps),
      ~s(label="Deployment"),
      Snippet.attr("color", props.color, "primary"),
      "show_status"
    ])
  end

  defp code_indeterminate(props) do
    Snippet.component(".progress_ring", [
      ~s(label="Uploading"),
      Snippet.attr("indeterminate", props.indeterminate, "spin")
    ])
  end

  defp code_status do
    Enum.join(
      [
        Snippet.component(".progress_ring", [
          ~s(value="0"),
          ~s(label="Starting"),
          "show_status"
        ]),
        Snippet.component(".progress_ring", [
          ~s(value="35"),
          ~s(label="Indexing"),
          "show_status"
        ]),
        Snippet.component(".progress_ring", [
          ~s(value="100"),
          ~s(label="Finished"),
          ~s(color="success"),
          "show_status"
        ])
      ],
      "\n"
    )
  end

  defp code_dashboard do
    Enum.join(
      [
        Snippet.component(".progress_ring", [
          ~s(value="82"),
          ~s(label="Storage used"),
          ~s(size="lg"),
          ~s(color="warning"),
          "show_status"
        ]),
        Snippet.component(".progress_ring", [
          ~s(value="3"),
          Snippet.attr("max", @steps),
          ~s(label="Deployment"),
          ~s(size="lg"),
          ~s(color="info"),
          "show_status"
        ]),
        Snippet.component(".progress_ring", [
          ~s(value="100"),
          ~s(label="Backup complete"),
          ~s(size="lg"),
          ~s(color="success"),
          "show_status"
        ])
      ],
      "\n"
    )
  end
end
