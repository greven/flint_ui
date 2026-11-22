defmodule FlintUIDocsWeb.Docs.SwitchGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :switch_group

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
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :color, type: :select, default: "primary", label: "Color"}
        ]
      },
      %{tab: :styled, section: :usage, id: :validation, title: "Description and Validation"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :settings,
        title: "Settings",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A switch group places related settings under one legend. Each option is an
      independent switch: it keeps its own name, value, and checked state, so the group does not
      submit a field of its own. Bind one field per option, or pass a `name` with `value` and
      `checked`." />

    <.prose content="`orientation` lays the options out vertically or horizontally. `size` and
      `color` are forwarded to every switch; each switch keeps its own label, sublabel, and
      description." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="fl-w-full fl-max-w-sm">
        <Components.switch_group
          id="notification-settings"
          label="Notifications"
          description="Choose how we reach you."
          orientation={props.orientation}
          size={props.size}
          color={props.color}
        >
          <:switch
            id="notify-email"
            name="notifications[email]"
            label="Email"
            description="Account updates."
            checked
          />
          <:switch
            id="notify-sms"
            name="notifications[sms]"
            label="SMS"
            description="Urgent alerts only."
          />
          <:switch
            id="notify-push"
            name="notifications[push]"
            label="Push"
            description="On this device."
            checked
          />
        </Components.switch_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`description` renders explanatory text below the legend and links it with
      `aria-describedby`. `errors` renders one group-level message per entry and marks the
      fieldset invalid. A group rule such as “enable at least one channel” is validated on the
      server; each switch still keeps its own state." />

    <.preview {assigns} code={~S|<.switch_group
      label="Notifications"
      description="Choose at least one channel."
      required
      errors={["must enable at least one channel"]}
    >
      <:switch name="notifications[email]" label="Email" checked />
      <:switch name="notifications[sms]" label="SMS" />
    </.switch_group>|}>
      <div class="fl-w-full fl-max-w-sm">
        <Components.switch_group
          label="Notifications"
          description="Choose at least one channel."
          required
          errors={["must enable at least one channel"]}
        >
          <:switch name="notifications[email]" label="Email" checked />
          <:switch name="notifications[sms]" label="SMS" />
        </Components.switch_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` disables the whole fieldset, so every switch and hidden mirror are
      disabled. An option can also be disabled on its own without disabling its siblings." />

    <.preview {assigns} code={~S|<.switch_group label="Security" disabled>
      <:switch name="security[two_factor]" label="Two-factor authentication" checked />
      <:switch name="security[alerts]" label="New device alerts" />
    </.switch_group>

    <.switch_group label="Security">
      <:switch name="security[two_factor]" label="Two-factor authentication" />
      <:switch name="security[alerts]" label="New device alerts" disabled />
    </.switch_group>|}>
      <div class="fl-grid-cols-1 fl-w-full fl-max-w-sm fl-gap-xl">
        <Components.switch_group label="Security" disabled>
          <:switch name="security[two_factor]" label="Two-factor authentication" checked />
          <:switch name="security[alerts]" label="New device alerts" />
        </Components.switch_group>

        <Components.switch_group label="Security">
          <:switch name="security[two_factor]" label="Two-factor authentication" />
          <:switch name="security[alerts]" label="New device alerts" disabled />
        </Components.switch_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="A `Phoenix.HTML.FormField` supplies the switch id, name, and current value.
      Pass a different field to every option, so each setting keeps its own boolean on the
      changeset." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="notification-form">
      <.switch_group label="Notifications" description="Choose how we reach you.">
        <:switch field={f[:email_alerts]} label="Email" checked />
        <:switch field={f[:sms_alerts]} label="SMS" />
        <:switch field={f[:push_alerts]} label="Push" />
      </.switch_group>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="switch-group-field-form">
        <div class="fl-w-full fl-max-w-sm">
          <Components.switch_group label="Notifications" description="Choose how we reach you.">
            <:switch field={f[:email_alerts]} label="Email" checked />
            <:switch field={f[:sms_alerts]} label="SMS" />
            <:switch field={f[:push_alerts]} label="Push" />
          </Components.switch_group>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :settings} = assigns) do
    ~H"""
    <.prose content="Grouping independent switches is a settings pattern, not a multi-select. Use
      one group per section of related settings, and keep the group label stable. For a field that
      collects a list of values, use a [checkbox group](/components/checkbox_group)." />

    <.preview {assigns} code={~S|<div class="fl-grid-cols-1 fl-gap-xl">
      <.switch_group label="Account notifications" description="Choose how we reach you.">
        <:switch name="notifications[email]" label="Email" checked />
        <:switch name="notifications[sms]" label="SMS" />
        <:switch name="notifications[push]" label="Push" checked />
      </.switch_group>

      <.switch_group label="Privacy">
        <:switch name="privacy[profile]" label="Public profile" checked />
        <:switch name="privacy[activity]" label="Show recent activity" />
      </.switch_group>
    </div>|}>
      <div class="fl-grid-cols-1 fl-w-full fl-max-w-sm fl-gap-xl">
        <Components.switch_group
          label="Account notifications"
          description="Choose how we reach you."
        >
          <:switch name="notifications[email]" label="Email" checked />
          <:switch name="notifications[sms]" label="SMS" />
          <:switch name="notifications[push]" label="Push" checked />
        </Components.switch_group>

        <Components.switch_group label="Privacy">
          <:switch name="privacy[profile]" label="Public profile" checked />
          <:switch name="privacy[activity]" label="Show recent activity" />
        </Components.switch_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-max-w-sm">
      <Components.switch_group
        id={"#{@parts_id}-notifications"}
        label="Notifications"
        description="Choose how we reach you."
        errors={["must enable at least one channel"]}
      >
        <:switch
          id={"#{@parts_id}-email"}
          name={"#{@parts_id}-email"}
          label="Email"
          sublabel="Recommended"
          description="Account updates."
          checked
        />
        <:switch
          id={"#{@parts_id}-sms"}
          name={"#{@parts_id}-sms"}
          label="SMS"
          description="Urgent alerts only."
          disabled
        />
      </Components.switch_group>
    </div>
    """
  end

  defp code_basic(props) do
    attrs = [
      ~s(id="notification-settings"),
      ~s(label="Notifications"),
      ~s(description="Choose how we reach you."),
      Snippet.attr("orientation", props.orientation, "vertical"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("color", props.color, "primary")
    ]

    body = """
    <:switch id="notify-email" name="notifications[email]" label="Email" description="Account updates." checked />
    <:switch id="notify-sms" name="notifications[sms]" label="SMS" description="Urgent alerts only." />
    <:switch id="notify-push" name="notifications[push]" label="Push" description="On this device." checked />
    """

    Snippet.tag(".switch_group", attrs, body)
  end
end
