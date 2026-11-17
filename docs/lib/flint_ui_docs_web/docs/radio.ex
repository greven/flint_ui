defmodule FlintUIDocsWeb.Docs.Radio do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :radio

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
          %{key: :variant, type: :select, default: "simple", label: "Variant"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :radius, type: :select, default: "sm", label: "Radius"},
          %{key: :color, type: :select, default: "primary", label: "Color"}
        ]
      },
      %{tab: :styled, section: :usage, id: :card, title: "Card"},
      %{
        tab: :styled,
        section: :usage,
        id: :validation,
        title: "Hint and Validation"
      },
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :group, title: "In a Radio Group"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A radio is the native control for one choice among mutually exclusive
      options. Radios that share a `name` form one group: selecting one clears the others and the
      group submits a single value." />

    <.prose content={~S|Use `variant="card"` when the field should read as a selectable surface.
      The `size` prop follows the shared control scale, `radius` shapes the card, and `color` sets
      the selected fill and dot. The indicator stays circular.|} />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.radio
          id="notifications-radio"
          name="notifications"
          value="on"
          label="Enable notifications"
          sublabel="Recommended"
          hint="We'll send you important updates about your account status and security."
          checked
          variant={props.variant}
          size={props.size}
          radius={props.radius}
          color={props.color}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :card} = assigns) do
    ~H"""
    <.prose content="The card variant makes the whole field a clickable surface. The hint
      stays inside the card, and the selected state tints the border and background with the radio
      `color`." />

    <.preview {assigns} code={~S|<.radio
      name="plan"
      value="free"
      variant="card"
      label="Free plan"
      sublabel="$0"
      hint="One project and community support."
    />

    <.radio
      name="plan"
      value="pro"
      variant="card"
      label="Pro plan"
      sublabel="$19 per month"
      hint="Everything in Free, plus unlimited projects and priority support."
      checked
    />|}>
      <div class="grid w-full max-w-md gap-3">
        <Components.radio
          name="plan-card"
          value="free"
          variant="card"
          label="Free plan"
          sublabel="$0"
          hint="One project and community support."
        />

        <Components.radio
          name="plan-card"
          value="pro"
          variant="card"
          label="Pro plan"
          sublabel="$19 per month"
          hint="Everything in Free, plus unlimited projects and priority support."
          checked
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`hint` renders hint text below the radio and links it with
      `aria-describedby`. `errors` renders one message per entry and marks the control invalid. A
      `field` carries its own errors once the field has been used." />

    <.preview {assigns} code={~S|<.radio
      id="plan"
      name="plan"
      value="pro"
      label="Pro plan"
      hint="Choose the plan that fits your team."
      errors={["is not available in your region"]}
    />|}>
      <div class="w-full max-w-sm">
        <Components.radio
          id="plan-radio-errors"
          name="plan-errors"
          value="pro"
          label="Pro plan"
          hint="Choose the plan that fits your team."
          errors={["is not available in your region"]}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` renders the native attribute and keeps the radio out of the form
      payload. `required` renders the native required state; in a group, use the group's own
      `required` prop instead." />

    <.preview
      {assigns}
      code={~S|<.radio name="plan" value="free" label="Free plan" checked disabled />
    <.radio name="plan" value="pro" label="Pro plan" disabled />
    <.radio name="plan" value="team" label="Team plan" required />|}
    >
      <div class="grid w-full max-w-sm gap-3">
        <Components.radio name="plan-disabled" value="free" label="Free plan" checked disabled />
        <Components.radio name="plan-disabled" value="pro" label="Pro plan" disabled />
        <Components.radio name="plan-required" value="team" label="Team plan" required />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive `id`, `name`, and errors. Every radio
      in the group should use the same field and its own `value`; the option whose value matches the
      field's current selection is checked. Each option's id is the field id with the option value
      appended, so its label and hint stay unique." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="plan-form">
      <.radio field={f[:plan]} value="free" label="Free plan" />
      <.radio field={f[:plan]} value="pro" label="Pro plan" />
      <.radio field={f[:plan]} value="team" label="Team plan" />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="radio-field-form">
        <div class="grid w-full max-w-sm gap-3">
          <Components.radio field={f[:plan]} value="free" label="Free plan" />
          <Components.radio field={f[:plan]} value="pro" label="Pro plan" />
          <Components.radio field={f[:plan]} value="team" label="Team plan" />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content={~S|A radio group submits exactly one value under its shared `name`. There is no
      hidden empty value, so while nothing is selected the server receives no parameter for the
      field. Validate the field as required when a choice is mandatory.|} />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="signup-form">
      <.radio field={f[:plan]} value="free" label="Free" hint="One project." />
      <.radio field={f[:plan]} value="pro" label="Pro" hint="Unlimited projects." checked />
      <.radio field={f[:plan]} value="team" label="Team" hint="Roles and permissions." />
      <.button type="button" variant="solid">Create account</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="radio-form-example">
        <div class="grid w-full max-w-md gap-4">
          <Components.radio field={f[:plan]} value="free" label="Free" hint="One project." />
          <Components.radio
            field={f[:plan]}
            value="pro"
            label="Pro"
            hint="Unlimited projects."
            checked
          />
          <Components.radio
            field={f[:plan]}
            value="team"
            label="Team"
            hint="Roles and permissions."
          />
          <Components.button type="button" variant="solid">Create account</Components.button>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :group} = assigns) do
    ~H"""
    <.prose content="Use the [radio group](/components/radio_group) when several radios collect one
      form field. The group adds the fieldset, legend, hint, and errors around the options." />

    <.preview {assigns} code={~S|<.radio_group name="plan" label="Plan">
      <:radio value="free" label="Free" />
      <:radio value="pro" label="Pro" />
      <:radio value="team" label="Team" />
    </.radio_group>|}>
      <div class="w-full max-w-sm">
        <Components.radio_group name="plan" label="Plan">
          <:radio value="free" label="Free" />
          <:radio value="pro" label="Pro" />
          <:radio value="team" label="Team" />
        </Components.radio_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-3">
      <Components.radio
        id={"#{@parts_id}-pro"}
        name={"#{@parts_id}-plan"}
        value="pro"
        label="Pro plan"
        sublabel="Recommended"
        hint="Unlimited projects and priority support."
        errors={["is not available in your region"]}
      />

      <Components.radio
        id={"#{@parts_id}-team"}
        name={"#{@parts_id}-plan-card"}
        value="team"
        variant="card"
        label="Team plan"
        sublabel="$49 per month"
        hint="Everything in Pro, plus roles."
        checked
      />
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.component(".radio", [
      ~s(id="notifications-radio"),
      ~s(name="notifications"),
      ~s(value="on"),
      ~s(label="Enable notifications"),
      ~s(sublabel="Recommended"),
      ~s(hint="We'll send you important updates about your account status and security."),
      "checked",
      Snippet.attr("variant", props.variant, "simple"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "sm"),
      Snippet.attr("color", props.color, "primary")
    ])
  end
end
