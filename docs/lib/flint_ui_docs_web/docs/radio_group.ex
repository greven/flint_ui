defmodule FlintUIDocsWeb.Docs.RadioGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :radio_group

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
          %{key: :variant, type: :select, default: "simple", label: "Variant"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :radius, type: :select, default: "sm", label: "Radius"}
        ]
      },
      %{tab: :styled, section: :usage, id: :validation, title: "Description and Validation"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :cards, title: "Card Options"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A radio group collects one choice into one form field. Declare each option
      with a `:radio` slot; every option shares the group's `name`, and the selected option submits
      its value under that name. There is no hidden empty value, so an unanswered group sends no
      parameter." />

    <.prose content="Pass `value` to select the matching option, or set an option's own `checked`
      attribute to force its state. `orientation` lays the options out vertically or horizontally,
      and `variant`, `size`, and `radius` are forwarded to every option." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="fl-w-full fl-max-w-md">
        <Components.radio_group
          id="plan"
          name="plan"
          label="Plan"
          description="Choose the plan that fits your team."
          value="pro"
          orientation={props.orientation}
          variant={props.variant}
          size={props.size}
          radius={props.radius}
        >
          <:radio value="free" label="Free" sublabel="$0" />
          <:radio value="pro" label="Pro" sublabel="$19 per month" />
          <:radio value="team" label="Team" sublabel="$49 per month" />
        </Components.radio_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="The group renders a native `fieldset` with a `legend`, so the label names the
      group for every option. Group errors are linked to the fieldset with `aria-describedby`, and
      `required` marks the group with `aria-required` and the native radios as required." />

    <.preview {assigns} code={~S|<.radio_group
      name="plan"
      label="Plan"
      description="Pick one plan to continue."
      required
      errors={["must select a plan"]}
    >
      <:radio value="free" label="Free" />
      <:radio value="pro" label="Pro" />
    </.radio_group>|}>
      <div class="fl-w-full fl-max-w-sm">
        <Components.radio_group
          name="plan"
          label="Plan"
          description="Pick one plan to continue."
          required
          errors={["must select a plan"]}
        >
          <:radio value="free" label="Free" />
          <:radio value="pro" label="Pro" />
        </Components.radio_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` disables the whole fieldset, so every option is disabled by the
      native radio group. An option can also be disabled on its own without disabling its
      siblings." />

    <.preview {assigns} code={~S|<.radio_group name="plan" label="Disabled group" disabled>
      <:radio value="free" label="Free" checked />
      <:radio value="pro" label="Pro" />
    </.radio_group>

    <.radio_group name="plan" label="One disabled option">
      <:radio value="free" label="Free" />
      <:radio value="pro" label="Pro" disabled />
    </.radio_group>|}>
      <div class="fl-grid-cols-1 fl-w-full fl-max-w-sm fl-gap-xl">
        <Components.radio_group name="plan" label="Disabled group" disabled>
          <:radio value="free" label="Free" checked />
          <:radio value="pro" label="Pro" />
        </Components.radio_group>

        <Components.radio_group name="plan" label="One disabled option">
          <:radio value="free" label="Free" />
          <:radio value="pro" label="Pro" disabled />
        </Components.radio_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="A `Phoenix.HTML.FormField` supplies the group id, name, selected value, and
      errors. Each option's id is the field id with the option index appended." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="plan-form">
      <.radio_group field={f[:plan]} label="Plan">
        <:radio value="free" label="Free" />
        <:radio value="pro" label="Pro" />
        <:radio value="team" label="Team" />
      </.radio_group>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="radio-group-field-form">
        <div class="fl-w-full fl-max-w-sm">
          <Components.radio_group field={f[:plan]} label="Plan">
            <:radio value="free" label="Free" />
            <:radio value="pro" label="Pro" />
            <:radio value="team" label="Team" />
          </Components.radio_group>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="A group is one field: validate it as a required single value, show its errors
      with `errors`, and keep the options in one `fieldset`. Use a standalone
      [radio](/components/radio) only when you need one option without the group chrome." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="profile-form">
      <.radio_group field={f[:plan]} label="Plan" description="You can change this later.">
        <:radio value="free" label="Free" description="One project." />
        <:radio value="pro" label="Pro" description="Unlimited projects." />
        <:radio value="team" label="Team" description="Roles and permissions." />
      </.radio_group>
      <.button type="button" variant="solid">Save profile</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="radio-group-form-example">
        <div class="fl-grid-cols-1 fl-w-full fl-max-w-md fl-gap-lg">
          <Components.radio_group
            field={f[:plan]}
            label="Plan"
            description="You can change this later."
          >
            <:radio value="free" label="Free" description="One project." />
            <:radio value="pro" label="Pro" description="Unlimited projects." />
            <:radio value="team" label="Team" description="Roles and permissions." />
          </Components.radio_group>
          <Components.button type="button" variant="solid">Save profile</Components.button>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :cards} = assigns) do
    ~H"""
    <.prose content={~S|Set `variant="card"` to make every option a selectable surface. The
      orientation still controls the layout, and each option can carry its own description.|} />

    <.preview {assigns} code={~S|<.radio_group
      name="plan"
      variant="card"
      label="Choose a plan"
      value="pro"
    >
      <:radio value="free" label="Free" sublabel="$0" description="One project." />
      <:radio value="pro" label="Pro" sublabel="$19" description="Unlimited projects." />
      <:radio value="team" label="Team" sublabel="$49" description="Everything in Pro, plus roles." />
    </.radio_group>|}>
      <div class="fl-w-full fl-max-w-md">
        <Components.radio_group
          name="plan-cards"
          variant="card"
          label="Choose a plan"
          value="pro"
        >
          <:radio value="free" label="Free" sublabel="$0" description="One project." />
          <:radio
            value="pro"
            label="Pro"
            sublabel="$19"
            description="Unlimited projects and priority support."
          />
          <:radio
            value="team"
            label="Team"
            sublabel="$49"
            description="Everything in Pro, plus roles and permissions."
          />
        </Components.radio_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-max-w-sm">
      <Components.radio_group
        id={"#{@parts_id}-plan"}
        name={"#{@parts_id}-plan"}
        label="Plan"
        description="Choose the plan that fits your team."
        value="pro"
      >
        <:radio value="free" label="Free" sublabel="$0" />
        <:radio value="pro" label="Pro" sublabel="Recommended" />
        <:radio value="team" label="Team" disabled />
      </Components.radio_group>
    </div>
    """
  end

  defp code_basic(props) do
    attrs = [
      ~s(id="plan"),
      ~s(name="plan"),
      ~s(label="Plan"),
      ~s(description="Choose the plan that fits your team."),
      ~s(value="pro"),
      Snippet.attr("orientation", props.orientation, "vertical"),
      Snippet.attr("variant", props.variant, "simple"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "sm")
    ]

    body = """
    <:radio value="free" label="Free" sublabel="$0" />
    <:radio value="pro" label="Pro" sublabel="$19 per month" />
    <:radio value="team" label="Team" sublabel="$49 per month" />
    """

    Snippet.tag(".radio_group", attrs, body)
  end
end
