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
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{
        tab: :styled,
        section: :usage,
        id: :label,
        title: "Label",
        controls: [%{key: :label, type: :string, default: "68", label: "Label"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :position,
        title: "Position",
        controls: [
          %{key: :position, type: :select, default: "bottom-right", label: "Position"},
          %{key: :offset, type: :number, default: -5, label: "Offset"},
          %{key: :size, type: :select, default: "sm", label: "Size"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [
          %{key: :color, type: :select, default: "error", label: "Color"},
          %{key: :variant, type: :select, default: "solid", label: "Variant"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :size,
        title: "Size",
        controls: [%{key: :size, type: :select, default: "xs", label: "Size"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :inset,
        title: "Inset",
        controls: [%{key: :inset, type: :boolean, default: false, label: "Inset"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :ring,
        title: "Ring",
        controls: [%{key: :ring, type: :boolean, default: true, label: "Ring"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :attention,
        title: "Attention"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :dot,
        title: "Dot",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :inline, title: "Inline vs Corner"},
      %{tab: :styled, section: :examples, id: :live, title: "Live Count"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the default slot for the anchor and the `label` attribute for the badge.
      The badge sits over a corner, the next sections cover the attributes that shape it." />
    <.preview {assigns} code={&code_basic/1}>
      <Components.indicator label="3">
        <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :label} = assigns) do
    ~H"""
    <.prose content="`label` is the visible badge content. The badge is decorative by default, so keep
      the count in the anchor's accessible name." />
    <.preview :let={props} {assigns} code={&code_label/1}>
      <Components.indicator color="neutral" label={props.label}>
        <Components.button variant="subtle" square aria-label={"#{props.label} items"}>
          <Components.icon name="lucide-box" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :position} = assigns) do
    ~H"""
    <.prose content="`position` picks the anchor corner the badge sits on. Left and right follow the
      writing direction. `offset` nudges the badge along both axes: positive values push it
      outward, and negative values pull it in. It is useful when the anchor has a large border
      radius." />
    <.preview :let={props} {assigns} code={&code_position/1}>
      <Components.indicator
        color="info"
        size={props.size}
        position={props.position}
        offset={props.offset}
        ring
      >
        <Components.button
          variant="solid"
          size="lg"
          radius="full"
          square
          aria-label="Feathers"
        >
          <Components.icon name="lucide-feather" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="`color` accepts the semantic roles, or a raw CSS color such as `#1D72FE` for a
      one-off accent. `variant` can change the badge's emphasis, but this is a small element: keep
      the default `solid` for the clearest contrast and reach for a quieter variant only when the
      anchor already explains the state." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.indicator label="3" color={props.color} variant={props.variant}>
        <Components.button variant="subtle" square aria-label="Notifications, 3 unread">
          <Components.icon name="lucide-bell" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="`size` follows the Badge scale. A dot uses the smaller marker scale instead, see [Dot](#example-indicator-dot).
      Keep the badge smaller than the anchor so the overlay reads as an annotation rather
      than a second control." />
    <.preview :let={props} {assigns} code={&code_size/1}>
      <Components.indicator label="3" size={props.size}>
        <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :inset} = assigns) do
    ~H"""
    <.prose content="Set `inset` to place the badge fully inside the anchor's corner instead of
      letting it straddle the edge." />
    <.preview :let={props} {assigns} code={&code_inset/1}>
      <Components.indicator label="3" inset={props.inset}>
        <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :ring} = assigns) do
    ~H"""
    <.prose content={~S(
      Set `ring` to paint a ring in the surrounding surface color so the badge reads
      as a cutout.

      Match `--fl-indicator-ring-color` to the surface behind the indicator.)} />
    <.preview :let={props} {assigns} code={&code_ring/1} collapsed>
      <Components.indicator label="3" ring={props.ring}>
        <Components.button variant="subtle" square aria-label="Inbox, 3 unread">
          <Components.icon name="lucide-mail" />
        </Components.button>
      </Components.indicator>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :attention} = assigns) do
    ~H"""
    <.prose content="`attention` adds a subtle animation so the badge catches the eye. `pulse`
      fades the badge's opacity like Tailwind's `animate-pulse`, `ping` scales a filled halo behind
      it like `animate-ping`, `bounce` gives it a short vertical hop, and `heartbeat` gives it a
      double scale beat like Animate.css's `heartBeat`. It defaults to `none`. The ping halo follows
      the badge's fill, and `--fl-ping-color` overrides it. All effects stop under
      `prefers-reduced-motion`." />

    <.preview {assigns} code={&code_attention/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.indicator label="1" attention="ping">
          <Components.button variant="subtle" square aria-label="Inbox, 1 unread">
            <Components.icon name="lucide-mail" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="4" color="info" attention="pulse">
          <Components.button variant="subtle" square aria-label="Inbox, 4 unread">
            <Components.icon name="lucide-mailbox" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="7" color="success" attention="bounce">
          <Components.button variant="subtle" square aria-label="New Mail">
            <Components.icon name="lucide-at-sign" />
          </Components.button>
        </Components.indicator>

        <Components.indicator label="9" color="neutral" attention="heartbeat">
          <Components.button variant="subtle" square aria-label="Inbox, 9 unread">
            <Components.icon name="lucide-inbox" />
          </Components.button>
        </Components.indicator>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :dot} = assigns) do
    ~H"""
    <.prose content="Omit `label` and the badge renders as a dot on the marker scale: 6, 8, 12, 16,
      and 18px from `xs` to `xl`. Set `--fl-indicator-dot-size` on the indicator or a container to
      override the diameter. A bare dot is decorative, so name the state on the anchor, as in
      `Ada Lovelace, online`, and do not rely on color alone." />
    <.preview {assigns} code={&code_dot/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.indicator color="dark" size="xs" ring>
          <Components.button variant="subtle" square aria-label="Ada Lovelace, stealth">
            <Components.icon name="lucide-user-x" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="success" size="sm">
          <Components.button variant="subtle" square aria-label="Ada Lovelace, online">
            <Components.icon name="lucide-user" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="warning" size="md">
          <Components.button variant="subtle" square aria-label="Ada Lovelace, away">
            <Components.icon name="lucide-user" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="error" size="lg">
          <Components.button variant="subtle" square aria-label="Ada Lovelace, offline">
            <Components.icon name="lucide-user" />
          </Components.button>
        </Components.indicator>

        <Components.indicator color="info" size="xl">
          <Components.button variant="subtle" square aria-label="Ada Lovelace, in a meeting">
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

  defp code_basic(_) do
    """
    <.indicator label="3">
      <.button variant="subtle" square aria-label="Inbox, 3 unread">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_label(props) do
    Snippet.tag(
      ".indicator",
      [Snippet.attr("label", props.label)],
      """
      <.button variant="subtle" color="neutral" square aria-label="#{props.label} items">
        <.icon name="lucide-box" />
      </.button>
      """
    )
  end

  defp code_position(props) do
    Snippet.tag(
      ".indicator",
      [
        Snippet.attr("size", props.size, "xs"),
        Snippet.attr("color", "info"),
        Snippet.attr("position", props.position, "top-right"),
        Snippet.attr("offset", props.offset, 0),
        Snippet.attr("ring", true)
      ],
      """
      <.button variant="solid" size="lg" radius="full" square aria-label="Feathers">
        <.icon name="lucide-feather" />
      </.button>
      """
    )
  end

  defp code_color(props) do
    Snippet.tag(
      ".indicator",
      [
        Snippet.attr("label", "3"),
        Snippet.attr("color", props.color, "error"),
        Snippet.attr("variant", props.variant, "solid")
      ],
      anchor_code()
    )
  end

  defp code_size(props) do
    Snippet.tag(
      ".indicator",
      [Snippet.attr("label", "3"), Snippet.attr("size", props.size, "xs")],
      anchor_code()
    )
  end

  defp code_inset(props) do
    Snippet.tag(
      ".indicator",
      [Snippet.attr("label", "3"), Snippet.flag("inset", props.inset)],
      anchor_code()
    )
  end

  defp code_attention(_) do
    """
    <.indicator label="1" attention="ping">
      <.button variant="subtle" square aria-label="Inbox, 1 unread">
        <.icon name="lucide-mail" />
      </.button>
    </.indicator>

    <.indicator label="4" color="info" attention="pulse">
      <.button variant="subtle" square aria-label="Inbox, 4 unread">
        <.icon name="lucide-mailbox" />
      </.button>
    </.indicator>

    <.indicator label="7" color="success" attention="bounce">
      <.button variant="subtle" square aria-label="New Mail">
        <.icon name="lucide-at-sign" />
      </.button>
    </.indicator>

    <.indicator label="9" color="neutral" attention="heartbeat">
      <.button variant="subtle" square aria-label="Inbox, 9 unread">
        <.icon name="lucide-inbox" />
      </.button>
    </.indicator>
    """
    |> String.trim()
  end

  defp code_ring(props) do
    indicator =
      Snippet.tag(
        ".indicator",
        [Snippet.attr("label", "3"), Snippet.flag("ring", props.ring)],
        anchor_code()
      )

    """
    #{indent(indicator)}
    """
    |> String.trim()
  end

  defp code_dot(_) do
    """
    <.indicator color="neutral" size="xs" ring>
      <.button variant="subtle" square aria-label="Ada Lovelace, stealth">
        <.icon name="lucide-user-x" />
      </.button>
    </.indicator>

    <.indicator color="success" size="sm">
      <.button variant="subtle" square aria-label="Ada Lovelace, online">
        <.icon name="lucide-user" />
      </.button>
    </.indicator>

    <.indicator color="warning" size="md">
      <.button variant="subtle" square aria-label="Ada Lovelace, away">
        <.icon name="lucide-user" />
      </.button>
    </.indicator>

    <.indicator color="error" size="lg">
      <.button variant="subtle" square aria-label="Ada Lovelace, offline">
        <.icon name="lucide-user" />
      </.button>
    </.indicator>

    <.indicator color="info" size="xl">
      <.button variant="subtle" square aria-label="Ada Lovelace, in a meeting">
        <.icon name="lucide-user" />
      </.button>
    </.indicator>
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

  defp anchor_code(icon \\ "mail") do
    """
    <.button variant="subtle" square aria-label="Inbox, 3 unread">
      <.icon name="lucide-#{icon}" />
    </.button>
    """
  end

  defp indent(code) do
    code
    |> String.split("\n")
    |> Enum.map_join("\n", &("  " <> &1))
  end
end
