defmodule FlintUIDocsWeb.Docs.ProgressGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :progress_group

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
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :color, type: :select, default: "primary", label: "Color"},
          %{key: :radius, type: :select, default: "full", label: "Radius"},
          %{key: :show_status, type: :boolean, default: true, label: "Status"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :status,
        title: "Status"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :icons,
        title: "Icons"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :vertical,
        title: "Vertical",
        controls: [
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :custom_colors,
        title: "Custom Colors",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={~S|A progress group splits one bar into segments that add up to `max`.
      Each `:segment` declares its `value` and, when it needs one, its own `color`. The
      root remains the only progressbar: it announces the summed value, while `show_status`
      prints the rounded total above the bar.|} />

    <.prose content={~S|The legend under the bar names every segment that has a `label`,
      `icon`, or custom content, with the segment color and its rounded percentage. A total
      below `max` leaves free track; a total above it scales the segments by their sum so
      the bar stays full.|} />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.progress_group
          max="128"
          label="Storage"
          show_status={props.show_status}
          size={props.size}
          color={props.color}
          radius={props.radius}
        >
          <:segment label="Compute" value="42" />
          <:segment label="Storage" value="18" color="info" />
          <:segment label="Bandwidth" value="9" color="warning" />
        </Components.progress_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :status} = assigns) do
    ~H"""
    <.prose content={~S|`show_status` prints the total percentage above the bar, with its
      label aligned to the end of the last segment rather than the end of the track. Pass a
      `:status` slot to replace it with custom content; the slot renders even when
      `show_status` is false and is not hidden from assistive technology, so it can carry
      information the root does not announce.|} />

    <.preview {assigns} code={code_status()}>
      <div class="w-full max-w-sm">
        <Components.progress_group max="128" label="Storage">
          <:status>69 GB of 128 GB used</:status>
          <:segment label="Compute" value="42" />
          <:segment label="Storage" value="18" color="info" />
          <:segment label="Bandwidth" value="9" color="warning" />
        </Components.progress_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :icons} = assigns) do
    ~H"""
    <.prose content={~S|An `icon` replaces the segment's color dot. Icons are CSS classes,
      following [Icon](/components/icon): pass a `lucide-*` name and let the host supply the
      class. The icon takes the segment color, and the label keeps the row readable.|} />

    <.preview {assigns} code={code_icons()}>
      <div class="w-full max-w-sm">
        <Components.progress_group max="128" label="Storage" show_status>
          <:segment label="Compute" value="42" icon="lucide-cpu" />
          <:segment label="Storage" value="18" color="info" icon="lucide-database" />
          <:segment label="Bandwidth" value="9" color="warning" icon="lucide-wifi" />
        </Components.progress_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :vertical} = assigns) do
    ~H"""
    <.prose content={~S|`orientation="vertical"` stacks the segments from the bottom and
      places the legend to the right of the bar. The group defaults to ten rems tall; set a
      height with `class` or `style` when the surrounding layout needs a different
      length.|} />

    <.preview :let={props} {assigns} code={&code_vertical/1}>
      <Components.progress_group
        max="128"
        label="Storage"
        orientation={props.orientation}
        show_status
      >
        <:segment label="Compute" value="42" />
        <:segment label="Storage" value="18" color="info" />
        <:segment label="Bandwidth" value="9" color="warning" />
      </Components.progress_group>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :custom_colors} = assigns) do
    ~H"""
    <.prose content={~S|Every segment accepts a raw CSS color or a palette hue, not
      just a semantic role. The legend dot or icon takes the same color. A hue follows the
      active palette; raw colors are a per-instance accent that does not follow the palette
      or the color scheme, so prefer a role or a theme override for app-wide color.|} />

    <.preview {assigns} code={code_custom_colors()}>
      <div class="w-full max-w-sm">
        <Components.progress_group max="128" label="Storage" show_status>
          <:segment label="Compute" value="42" color="purple" />
          <:segment label="Storage" value="18" color="cyan" icon="lucide-database" />
          <:segment label="Bandwidth" value="9" color="orange" />
        </Components.progress_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-sm">
      <Components.progress_group max="128" label="Storage" show_status>
        <:segment label="Compute" value="42" />
        <:segment label="Storage" value="18" color="info" icon="lucide-database" />
        <:segment label="Bandwidth" value="9" color="warning" />
      </Components.progress_group>
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.tag(
      ".progress_group",
      [
        ~s(max="128"),
        ~s(label="Storage"),
        Snippet.flag("show_status", props.show_status),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("color", props.color, "primary"),
        Snippet.attr("radius", props.radius, "full")
      ],
      """
      <:segment label="Compute" value="42" />
      <:segment label="Storage" value="18" color="info" />
      <:segment label="Bandwidth" value="9" color="warning" />
      """
    )
  end

  defp code_status do
    Snippet.tag(
      ".progress_group",
      [~s(max="128"), ~s(label="Storage")],
      """
      <:status>69 GB of 128 GB used</:status>
      <:segment label="Compute" value="42" />
      <:segment label="Storage" value="18" color="info" />
      <:segment label="Bandwidth" value="9" color="warning" />
      """
    )
  end

  defp code_icons do
    Snippet.tag(
      ".progress_group",
      [~s(max="128"), ~s(label="Storage"), "show_status"],
      """
      <:segment label="Compute" value="42" icon="lucide-cpu" />
      <:segment label="Storage" value="18" color="info" icon="lucide-database" />
      <:segment label="Bandwidth" value="9" color="warning" icon="lucide-wifi" />
      """
    )
  end

  defp code_vertical(props) do
    Snippet.tag(
      ".progress_group",
      [
        ~s(max="128"),
        ~s(label="Storage"),
        Snippet.attr("orientation", props.orientation, "horizontal"),
        "show_status"
      ],
      """
      <:segment label="Compute" value="42" />
      <:segment label="Storage" value="18" color="info" />
      <:segment label="Bandwidth" value="9" color="warning" />
      """
    )
  end

  defp code_custom_colors do
    Snippet.tag(
      ".progress_group",
      [~s(max="128"), ~s(label="Storage"), "show_status"],
      """
      <:segment label="Compute" value="42" color="purple" />
      <:segment label="Storage" value="18" color="cyan" icon="lucide-database" />
      <:segment label="Bandwidth" value="9" color="orange" />
      """
    )
  end
end
