defmodule FlintUIDocsWeb.Docs.Indicator do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :indicator

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
        controls: [
          %{key: :position, type: :select, default: "top-right", label: "Position"},
          %{key: :inset, type: :boolean, default: false, label: "Inset"},
          %{key: :ring, type: :boolean, default: false, label: "Ring"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :label,
        title: "Label and Dot",
        group_title: "Examples"
      },
      %{tab: :styled, section: :usage, id: :color, title: "Color"},
      %{tab: :styled, section: :usage, id: :size, title: "Size"},
      %{tab: :styled, section: :examples, id: :ring, title: "Surface Ring"},
      %{tab: :styled, section: :examples, id: :live, title: "Live Count"},
      %{tab: :styled, section: :examples, id: :inline, title: "Inline vs Corner"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the default slot for the anchor and the `label` attribute for the badge.
      The badge is positioned over a corner; `position`, `inset`, and `ring` shape the placement." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.indicator
        label="3"
        position={props.position}
        inset={props.inset}
        ring={props.ring}
      >
        <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :label} = assigns) do
    ~H"""
    <.prose content="`label` is the visible badge content. Omit it and a `full` badge renders as a dot.
      The badge is decorative by default, so the anchor keeps the count in its accessible name." />
    <.preview {assigns} code={&code_label/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.indicator label="3">
          <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
            <Components.icon name="lucide-mail" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="12" color="info" size="sm">
          <Components.button variant="subtle" square aria-label="Notifications, 12 unread">
            <Components.icon name="lucide-bell" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="success" size="sm">
          <Components.button variant="subtle" square aria-label="Ada Lovelace, online">
            <Components.icon name="lucide-user" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :color} = assigns) do
    ~H"""
    <.prose content="`color` accepts the semantic roles, or a raw CSS color such as `#1D72FE` for a
      one-off accent. Raw colors do not participate in presets; prefer a role for app-wide color." />
    <.preview {assigns} code={&code_color/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.indicator
          :for={color <- ~w(neutral info success warning error primary secondary)}
          label="3"
          color={color}
        >
          <Components.button
            variant="subtle"
            square
            aria-label={"#{String.capitalize(color)} notifications, 3 unread"}
          >
            <Components.icon name="lucide-bell" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="3" color="#1D72FE">
          <Components.button
            variant="subtle"
            square
            aria-label="Custom notifications, 3 unread"
          >
            <Components.icon name="lucide-bell" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :size} = assigns) do
    ~H"""
    <.prose content="`size` follows the Badge scale. Keep the badge smaller than the anchor so the
      overlay reads as an annotation rather than a second control." />
    <.preview {assigns} code={&code_size/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.indicator
          :for={size <- ~w(xs sm md lg xl)}
          label="3"
          size={size}
        >
          <Components.button
            variant="subtle"
            square
            aria-label={"Inbox, 3 unread (#{size})"}
          >
            <Components.icon name="lucide-mail" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :ring} = assigns) do
    ~H"""
    <.prose content="`ring` paints a ring in the surrounding surface color so the badge reads as a
      cutout. Match `--fl-indicator-ring-color` to a tinted surface." />
    <.preview {assigns} code={&code_ring/1} collapsed>
      <div
        class="flex flex-wrap items-center gap-6 rounded-xl bg-muted p-8"
        style="--fl-indicator-ring-color: var(--fl-color-surface-muted)"
      >
        <Components.indicator label="3" ring>
          <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
            <Components.icon name="lucide-mail" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="12" color="info" size="sm" ring>
          <Components.button variant="subtle" square aria-label="Notifications, 12 unread">
            <Components.icon name="lucide-bell" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="success" size="sm" ring>
          <Components.button variant="subtle" square aria-label="Ada Lovelace, online">
            <Components.icon name="lucide-user" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :live} = assigns) do
    ~H"""
    <.prose content="Give the badge `badge_label` to expose it with its own accessible name, and
      `status` to announce a changing count as a live region. Keep the anchor's name short in
      that case." />
    <.preview {assigns} code={&code_live/1} collapsed>
      <Components.indicator label="3" badge_label="3 unread messages" status>
        <Components.button variant="subtle" square aria-label="Inbox">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :inline} = assigns) do
    ~H"""
    <.prose content="Keep a badge inline inside a control when the count belongs to that control's
      label; see the Badge “Inside a Button” example. Use an indicator when the badge is an
      overlay on a control that already has its own accessible name." />
    <.preview {assigns} code={&code_inline/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.button variant="subtle">
          Inbox
          <Components.badge variant="solid" color="error" size="xs" radius="full">3</Components.badge>
        </Components.button>

        <Components.indicator label="3">
          <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
            <Components.icon name="lucide-mail" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".indicator",
      [
        Snippet.attr("label", "3"),
        Snippet.attr("position", props.position, "top-right"),
        Snippet.flag("inset", props.inset),
        Snippet.flag("ring", props.ring)
      ],
      """
      <.button variant="subtle" square aria-label="Inbox, 3 unread">
        <.icon name="lucide-mail" />
      </.button>
      """
    )
  end

  defp code_label(_) do
    """
    <.indicator label="3">
      <.button variant="subtle" square aria-label="Inbox, 3 unread">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="12" color="info" size="sm">
      <.button variant="subtle" square aria-label="Notifications, 12 unread">
        <.icon name="lucide-bell" />
      </.button>
    </.indicator>

    <.indicator color="success" size="sm">
      <.button variant="subtle" square aria-label="Ada Lovelace, online">
        <.icon name="lucide-user" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_color(_) do
    """
    <.indicator label="3" color="error">
      <.button variant="subtle" square aria-label="Error notifications, 3 unread">
        <.icon name="lucide-bell" />
      </.button>
    </.indicator>

    <.indicator label="3" color="#1D72FE">
      <.button variant="subtle" square aria-label="Custom notifications, 3 unread">
        <.icon name="lucide-bell" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_size(_) do
    """
    <.indicator label="3" size="xs">
      <.button variant="subtle" square aria-label="Inbox, 3 unread (xs)">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="3" size="sm">
      <.button variant="subtle" square aria-label="Inbox, 3 unread (sm)">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="3" size="md">
      <.button variant="subtle" square aria-label="Inbox, 3 unread (md)">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="3" size="lg">
      <.button variant="subtle" square aria-label="Inbox, 3 unread (lg)">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="3" size="xl">
      <.button variant="subtle" square aria-label="Inbox, 3 unread (xl)">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_ring(_) do
    """
    <div style="--fl-indicator-ring-color: var(--fl-color-surface-muted)">
      <.indicator label="3" ring>
        <.button variant="subtle" square aria-label="Inbox, 3 unread">
          <.icon name="lucide-mail" />
        </.button>
      </.indicator>
    </div>
    """
    |> String.trim()
  end

  defp code_live(_) do
    """
    <.indicator label="3" badge_label="3 unread messages" status>
      <.button variant="subtle" square aria-label="Inbox">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_inline(_) do
    """
    <.button variant="subtle">
      Inbox
      <.badge variant="solid" color="error" size="xs" radius="full">3</.badge>
    </.button>

    <.indicator label="3">
      <.button variant="subtle" square aria-label="Inbox, 3 unread">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end
end
