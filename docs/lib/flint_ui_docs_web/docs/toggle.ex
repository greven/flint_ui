defmodule FlintUIDocsWeb.Docs.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :toggle

  alias FlintUIDocsWeb.Components
  alias Phoenix.LiveView.JS

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
        controls: [%{key: :toggled, type: :boolean, default: false, label: "Toggled"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :variant,
        title: "Variant",
        controls: [
          %{key: :variant, type: :select, default: "ghost", label: "Variant"},
          %{key: :active_variant, type: :select, default: "soft", label: "Active variant"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [
          %{key: :color, type: :select, default: "neutral", label: "Color"},
          %{key: :active_color, type: :select, default: "primary", label: "Active color"}
        ]
      },
      %{tab: :styled, section: :usage, id: :icon, title: "Icon"},
      %{tab: :styled, section: :usage, id: :content, title: "Stateful Content"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{
        tab: :styled,
        section: :examples,
        id: :group,
        title: "Toggle Group",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :event, title: "Server Event"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="This component supports all of the same `attrs` and `slots` as `<.button>` so use
      the [button docs](/components/button) as a reference." />
    <.prose content="Use the `inner_block` (default) slot to set the content of the toggle and `toggled` to
      set its state from the server." />

    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.toggle active_color="success" toggled={props.toggled}>
        <.icon name="lucide-letter-b" /> Bold
      </Components.toggle>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Every variant the button ships is available to the toggle. By default `ghost`
      is used for the `off` state and `soft` for the `on` state. Use `active_variant` to change the
      treatment between states or pass `inherit` to keep the same `variant` in both states." />

    <.preview :let={props} {assigns} code={&code_variant/1}>
      <div class="flex items-center gap-3">
        <Components.toggle
          variant={props.variant}
          active_variant={props.active_variant}
          active_color="primary"
        >
          Play
        </Components.toggle>
        <Components.toggle
          variant={props.variant}
          active_variant={props.active_variant}
          active_color="primary"
          toggled
        >
          Play
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use `color` for the untoggled control and `active_color` for the toggled one.
      You can use `inherit` (the default) in `active_color` to keep the same color as in the `color` attribute." />

    <.preview :let={props} {assigns} code={&code_color/1}>
      <div class="flex items-center gap-3">
        <Components.toggle color={props.color} active_color={props.active_color} active_variant="soft">
          Bold
        </Components.toggle>
        <Components.toggle
          color={props.color}
          active_color={props.active_color}
          active_variant="soft"
          toggled
        >
          Bold
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :icon} = assigns) do
    ~H"""
    <.prose content="Use the `icon` attr to render a decorative icon before the content. The
      `:leading` and `:trailing` slots place any content before or after it. For an icon-only toggle,
      combine `square` with an `aria-label` so it keeps an accessible name." />

    <.preview {assigns} code={&code_icon/1} collapsed>
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle active_variant="soft" icon="lucide-letter-b">Bold</Components.toggle>
        <Components.toggle active_variant="subtle" color="success" icon="lucide-leaf">
          Organic
        </Components.toggle>
        <Components.toggle active_variant="soft">
          <:trailing><.icon name="lucide-bookmark" /></:trailing>
          Saved
        </Components.toggle>
        <Components.toggle active_variant="ghost">
          <:off><.icon name="ph-heart" />Like</:off>
          <:on><.icon name="ph-heart-duotone" class="text-rose-600" />Like</:on>
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :content} = assigns) do
    ~H"""
    <.prose content="Use the `:on` and `:off` slots to render different content per state. The
      state content joins the toggle's layout, so its labels and icons get the same gap and icon
      treatment as the default slot." />
    <.prose content={"Keep the accessible name stable. An `aria-pressed` toggle already announces
      its state, so a label that also changes (\"Mute\" to \"Unmute\") makes the announcement
      ambiguous."} />
    <.preview {assigns} code={&code_content/1}>
      <Components.toggle
        active_color="primary"
        class="data-[state=on]:ring data-[state=on]:ring-primary"
        aria-label="Mute"
        square
      >
        <:on><.icon name="lucide-volume-2" /></:on>
        <:off><.icon name="lucide-volume-x" /></:off>
      </Components.toggle>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="Set `disabled` to prevent activation. A toggle always renders a button, so it
      uses the native `disabled` attribute and leaves the tab order." />
    <.preview {assigns} code={&code_disabled/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle
          :for={variant <- variants()}
          variant={variant}
          active_variant="soft"
          active_color="primary"
          class="capitalize"
          disabled
        >
          {variant}
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :group} = assigns) do
    ~H"""
    <.prose content="A toggle composes with `<.group>` like a button, so a row of toggles reads as a single control." />
    <.preview {assigns} code={&code_group/1}>
      <Components.group variant="attached">
        <Components.toggle
          variant="surface"
          active_variant="subtle"
          aria-label="Bold"
          icon="lucide-letter-b"
        />
        <Components.toggle
          variant="surface"
          active_variant="subtle"
          aria-label="Italic"
          icon="lucide-italic"
        />
        <Components.toggle
          variant="surface"
          active_variant="subtle"
          aria-label="Underline"
          icon="lucide-underline"
        />
      </Components.group>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :event} = assigns) do
    ~H"""
    <.prose content="Pass `phx-click` to run a `Phoenix.LiveView.JS` command or push a server event
      when the toggle is clicked. The toggle runs its own state update first, then your `phx-click`,
      so the client state and `aria-pressed` change on the same click and reconcile with `toggled`
      on the next render." />
    <.preview {assigns} code={&code_event/1}>
      <Components.toggle
        active_variant="soft"
        active_color="primary"
        phx-click={JS.push("toggle-muted")}
      >
        <:on><.icon name="lucide-volume-x" /></:on>
        <:off><.icon name="lucide-volume-2" /></:off>
      </Components.toggle>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.toggle active_variant="soft" active_color="primary" toggled>
      <:on><Components.icon name="lucide-volume-x" /></:on>
      <:off><Components.icon name="lucide-volume-2" /></:off>
    </Components.toggle>
    """
  end

  defp variants, do: ~w(solid soft subtle surface outline ghost link)

  defp main_code(props) do
    """
    <.toggle active_color="success"#{if props.toggled, do: " toggled"}>
      <.icon name="lucide-letter-b" /> Bold
    </.toggle>
    """
  end

  defp code_variant(props) do
    """
    <.toggle variant="#{props.variant}" active_variant="#{props.active_variant}" active_color="primary">
      Play
    </.toggle>
    <.toggle variant="#{props.variant}" active_variant="#{props.active_variant}" active_color="primary" toggled>
      Play
    </.toggle>
    """
  end

  defp code_color(props) do
    """
    <.toggle color="#{props.color}" active_color="#{props.active_color}" active_variant="soft">
      Bold
    </.toggle>
    <.toggle color="#{props.color}" active_color="#{props.active_color}" active_variant="soft" toggled>
      Bold
    </.toggle>
    """
  end

  defp code_content(_) do
    """
    <.toggle
      active_color="primary"
      class="data-[state=on]:ring data-[state=on]:ring-primary"
      aria-label="Mute"
      square
    >
      <:on><.icon name="lucide-volume-2" /></:on>
      <:off><.icon name="lucide-volume-x" /></:off>
    </.toggle>
    """
  end

  defp code_icon(_) do
    """
    <.toggle active_variant="soft" icon="lucide-letter-b">Bold</.toggle>
    <.toggle active_variant="subtle" color="success" icon="lucide-leaf">Organic</.toggle>
    <.toggle active_variant="soft">
      <:trailing><.icon name="lucide-bookmark" /></:trailing>
      Saved
    </.toggle>
    <.toggle active_variant="ghost">
      <:off><.icon name="ph-heart" />Like</:off>
      <:on><.icon name="ph-heart-duotone" class="text-rose-600" />Like</:on>
    </.toggle>
    """
  end

  defp code_disabled(_) do
    """
    <.toggle variant="solid" active_variant="soft" active_color="primary" disabled>solid</.toggle>
    <.toggle variant="ghost" active_variant="soft" active_color="primary" disabled>ghost</.toggle>
    """
  end

  defp code_group(_) do
    """
    <.group variant="attached">
      <.toggle variant="surface" active_variant="subtle" aria-label="Bold" icon="lucide-letter-b" />
      <.toggle variant="surface" active_variant="subtle" aria-label="Italic" icon="lucide-italic" />
      <.toggle variant="surface" active_variant="subtle" aria-label="Underline" icon="lucide-underline" />
    </.group>
    """
  end

  defp code_event(_) do
    """
    <.toggle active_variant="soft" active_color="primary" phx-click={JS.push("toggle-muted")}>
      <:on><.icon name="lucide-volume-x" /></:on>
      <:off><.icon name="lucide-volume-2" /></:off>
    </.toggle>
    """
  end
end
