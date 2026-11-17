defmodule FlintUIDocsWeb.Docs.Switch do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :switch

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
          %{key: :color, type: :select, default: "primary", label: "Color"}
        ]
      },
      %{tab: :styled, section: :usage, id: :labels, title: "State Labels"},
      %{tab: :styled, section: :usage, id: :validation, title: "Description and Validation"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :settings,
        title: "Settings",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :form, title: "A Complete Form"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={~S|A switch is a binary control for turning a setting on or off. It uses the
      native checkbox with `role="switch"`, so assistive technology announces an on/off switch
      rather than a checkbox. The label wraps the control, and clicking the label or the track
      toggles it.|} />

    <.prose content="Use `sublabel` for a short qualifier, `description` for linked helper text, and
      `color` for the on track. `size` follows the shared control scale; the track and thumb scale
      with it." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.switch
          id="notifications-switch"
          name="notifications"
          label="Enable notifications"
          sublabel="Recommended"
          description="We'll send you important updates about your account status and security."
          checked
          size={props.size}
          color={props.color}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :labels} = assigns) do
    ~H"""
    <.prose content={~S|The `:on` and `:off` slots render short text inside the track, opposite
      the thumb. Both render in the DOM; the theme keeps the one that matches the checked state.
      The labels are decorative and hidden from assistive technology, because the native switch
      already announces whether it is on or off. Keep the accessible name in `label`.|} />

    <.prose content="The labels are sized in `em`, so they scale with `size`: about 7px at the
      `md` size." />

    <.preview {assigns} code={~S|<.switch name="wifi" label="Wi-Fi">
      <:on>ON</:on>
      <:off>OFF</:off>
    </.switch>
    <.switch name="bluetooth" label="Bluetooth" checked>
      <:on>ON</:on>
      <:off>OFF</:off>
    </.switch>|}>
      <div class="grid w-full max-w-sm gap-3">
        <Components.switch name="wifi" label="Wi-Fi">
          <:on>ON</:on>
          <:off>OFF</:off>
        </Components.switch>
        <Components.switch name="bluetooth" label="Bluetooth" checked>
          <:on>ON</:on>
          <:off>OFF</:off>
        </Components.switch>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`description` renders explanatory text below the switch and links it with
      `aria-describedby`. `errors` renders one message per entry and marks the control invalid. A
      `field` carries its own errors once the field has been used." />

    <.preview {assigns} code={~S|<.switch
      id="two-factor"
      name="two_factor"
      label="Two-factor authentication"
      description="Required for administrator accounts."
      errors={["must be enabled for admin accounts"]}
    />|}>
      <div class="w-full max-w-sm">
        <Components.switch
          id="two-factor-switch"
          name="two_factor"
          label="Two-factor authentication"
          description="Required for administrator accounts."
          errors={["must be enabled for admin accounts"]}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` renders the native attribute and keeps the switch out of the form
      payload. `required` renders the native required state." />

    <.preview {assigns} code={~S|<.switch name="email" label="Email notifications" disabled />
    <.switch name="push" label="Push notifications" disabled checked />
    <.switch name="security" label="Security alerts" required />|}>
      <div class="grid w-full max-w-sm gap-3">
        <Components.switch name="email" label="Email notifications" disabled />
        <Components.switch name="push" label="Push notifications" disabled checked />
        <Components.switch name="security" label="Security alerts" required />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive `id`, `name`, the current value, and
      errors. Errors only render after the field has been used." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="preferences-form">
      <.switch field={f[:notifications]} label="Enable notifications" />
      <.switch field={f[:newsletter]} label="Send me the newsletter" checked />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="switch-field-form">
        <div class="grid w-full max-w-sm gap-3">
          <Components.switch field={f[:notifications]} label="Enable notifications" />
          <Components.switch field={f[:newsletter]} label="Send me the newsletter" checked />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :settings} = assigns) do
    ~H"""
    <.prose content="A switch is a good fit for settings that apply as soon as they change. Keep
      the label stable between states: the switch already announces whether it is on or off, so a
      label that also changes makes the announcement ambiguous." />

    <.prose content="Use a [switch group](/components/switch_group) when related settings belong
      under one legend; each switch keeps its own field." />

    <.preview {assigns} code={~S|<div class="grid gap-4">
      <.switch
        name="notifications"
        label="Notifications"
        description="Account updates."
        checked
      />
      <.switch name="marketing" label="Product news" description="No more than one email a month." />
      <.switch name="two_factor" label="Two-factor authentication" checked />
    </div>|}>
      <div class="grid w-full max-w-md gap-4">
        <Components.switch
          name="notifications"
          label="Notifications"
          description="Account updates."
          checked
        />
        <Components.switch
          name="marketing"
          label="Product news"
          description="No more than one email a month."
        />
        <Components.switch name="two_factor" label="Two-factor authentication" checked />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content={~S|A switch submits its `checked_value` while on and its `unchecked_value`
      through a hidden mirror while off. The defaults are `"true"` and `"false"`, so a boolean
      field always receives a value.|} />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="signup-prefs-form">
      <.switch field={f[:notifications]} label="Enable notifications" checked />
      <.switch field={f[:newsletter]} label="Send me the newsletter" />
      <.switch
        field={f[:updates]}
        label="Product updates"
        description="No more than one email a month."
      />
      <.button type="button" variant="solid">Create account</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="switch-form-example">
        <div class="grid w-full max-w-md gap-4">
          <Components.switch field={f[:notifications]} label="Enable notifications" checked />
          <Components.switch field={f[:newsletter]} label="Send me the newsletter" />
          <Components.switch
            field={f[:updates]}
            label="Product updates"
            description="No more than one email a month."
          />
          <Components.button type="button" variant="solid">Create account</Components.button>
        </div>
      </.form>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-3">
      <Components.switch
        id={"#{@parts_id}-notifications"}
        name={"#{@parts_id}-notifications"}
        label="Enable notifications"
        sublabel="Recommended"
        description="Account updates."
        checked
      >
        <:on>ON</:on>
        <:off>OFF</:off>
      </Components.switch>

      <Components.switch
        id={"#{@parts_id}-two-factor"}
        name={"#{@parts_id}-two-factor"}
        label="Two-factor authentication"
        description="Required for administrator accounts."
        errors={["must be enabled for admin accounts"]}
      />
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.component(".switch", [
      ~s(id="notifications-switch"),
      ~s(name="notifications"),
      ~s(label="Enable notifications"),
      ~s(sublabel="Recommended"),
      ~s(description="We'll send you important updates about your account status and security."),
      "checked",
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("color", props.color, "primary")
    ])
  end
end
