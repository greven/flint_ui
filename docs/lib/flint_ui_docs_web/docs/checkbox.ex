defmodule FlintUIDocsWeb.Docs.Checkbox do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :checkbox

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
        title: "Description and Validation"
      },
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{tab: :styled, section: :usage, id: :indeterminate, title: "Indeterminate"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :group, title: "In a Checkbox Group"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A checkbox is the native control for a boolean choice. The label wraps the
      native input, so clicking the label or the box toggles it. `sublabel` adds a short qualifier
      and `description` adds a linked description." />

    <.prose content={~S|Use `variant="card"` when the field should read as a selectable surface.
      The `size` and `radius` props follow the shared control and radius scales, and `color` sets
      the checked fill and border. The check mark is an inline SVG that stays a neutral ink.|} />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.checkbox
          name="notifications"
          label="Enable notifications"
          sublabel="Recommended"
          description="We'll send you important updates about your account status and security."
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
    <.prose content="The card variant makes the whole field a clickable surface. The description
      stays inside the card, and the checked state tints the border and background with the
      checkbox `color`." />

    <.preview {assigns} code={~S|<.checkbox
      name="plan"
      variant="card"
      label="Pro plan"
      sublabel="$19 per month"
      description="Everything in Free, plus unlimited projects and priority support."
      color="primary"
      checked
    />|}>
      <div class="grid w-full max-w-md gap-3">
        <Components.checkbox
          name="plan-free"
          variant="card"
          label="Free plan"
          sublabel="$0"
          description="One project and community support."
        />

        <Components.checkbox
          name="plan-pro"
          variant="card"
          label="Pro plan"
          sublabel="$19 per month"
          description="Everything in Free, plus unlimited projects and priority support."
          checked
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`description` renders explanatory text below the checkbox and links it with
      `aria-describedby`. `errors` renders one message per entry and marks the control invalid. A
      `field` carries its own errors once the field has been used." />

    <.preview {assigns} code={~S|<.checkbox
      id="terms"
      name="terms"
      label="I accept the terms"
      description="You must accept the terms to create an account."
      errors={["must be accepted"]}
    />|}>
      <div class="w-full max-w-sm">
        <Components.checkbox
          id="terms-checkbox"
          name="terms"
          label="I accept the terms"
          description="You must accept the terms to create an account."
          errors={["must be accepted"]}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` renders the native attribute and keeps the field out of the form
      payload. `required` renders the native required state." />

    <.preview {assigns} code={~S|<.checkbox name="email" label="Email notifications" disabled />
    <.checkbox name="push" label="Push notifications" disabled checked />
    <.checkbox name="terms" label="I accept the terms" required />|}>
      <div class="grid w-full max-w-sm gap-3">
        <Components.checkbox name="email" label="Email notifications" disabled />
        <Components.checkbox name="push" label="Push notifications" disabled checked />
        <Components.checkbox name="terms" label="I accept the terms" required />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :indeterminate} = assigns) do
    ~H"""
    <.prose content={~S|`indeterminate` paints the mixed/dash state and sets
      `data-indeterminate="true"` on the native input. The `flint.js` bundle mirrors that hook onto
      the native `indeterminate` DOM property, so assistive technology announces the mixed state;
      the dash still renders without JavaScript. It is not a third form value: it does not change
      whether the checkbox submits `checked_value`. Leave `checked` false for a select-all parent
      whose children are partly selected.|} />

    <.prose content="The core bundle installs the sync document-wide, so the checkbox needs no
      `phx-hook` or unique DOM id. The native `:indeterminate` state set by your own JavaScript is
      styled the same way, so a component that sets the property directly still gets the dash." />

    <.preview {assigns} code={~S|<.checkbox
      id="select-all"
      name="select_all"
      label="Select all"
      indeterminate
      description="One or more items are selected."
    />|}>
      <div class="w-full max-w-sm">
        <Components.checkbox
          id="select-all-checkbox"
          name="select_all"
          label="Select all"
          indeterminate
          description="One or more items are selected."
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive `id`, `name`, the current value, and
      errors. Errors only render after the field has been used." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="profile-form">
      <.checkbox field={f[:terms]} label="I accept the terms" />
      <.checkbox field={f[:newsletter]} label="Send me the newsletter" checked />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="checkbox-field-form">
        <div class="grid w-full max-w-sm gap-3">
          <Components.checkbox field={f[:terms]} label="I accept the terms" />
          <Components.checkbox field={f[:newsletter]} label="Send me the newsletter" checked />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content={~S|Checkboxes submit their `checked_value` while checked and their
      `unchecked_value` through a hidden mirror while unchecked. The defaults are `"true"` and
      `"false"`, so a boolean field always receives a value.|} />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="signup-form">
      <.checkbox field={f[:terms]} label="I accept the terms" />
      <.checkbox field={f[:newsletter]} label="Send me the newsletter" checked />
      <.checkbox field={f[:updates]} label="Product updates" description="No more than one email a month." />
      <.button type="button" variant="solid">Create account</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="checkbox-form-example">
        <div class="grid w-full max-w-md gap-4">
          <Components.checkbox field={f[:terms]} label="I accept the terms" />
          <Components.checkbox field={f[:newsletter]} label="Send me the newsletter" checked />
          <Components.checkbox
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

  def render_section(%{section: :examples, id: :group} = assigns) do
    ~H"""
    <.prose content="Use the [checkbox group](/components/checkbox_group) when several checkboxes
      collect one form field. A standalone checkbox is for a single boolean." />

    <.preview {assigns} code={~S|<.checkbox_group name="languages" label="Programming languages">
      <:checkbox value="elixir" label="Elixir" />
      <:checkbox value="rust" label="Rust" />
      <:checkbox value="typescript" label="TypeScript" />
    </.checkbox_group>|}>
      <div class="w-full max-w-sm">
        <Components.checkbox_group name="languages" label="Programming languages">
          <:checkbox value="elixir" label="Elixir" />
          <:checkbox value="rust" label="Rust" />
          <:checkbox value="typescript" label="TypeScript" />
        </Components.checkbox_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-3">
      <Components.checkbox
        id={"#{@parts_id}-terms"}
        name={"#{@parts_id}-terms"}
        label="I accept the terms"
        sublabel="Required"
        description="You must accept the terms to continue."
        errors={["must be accepted"]}
      />

      <Components.checkbox
        id={"#{@parts_id}-card"}
        name={"#{@parts_id}-card"}
        variant="card"
        label="Pro plan"
        sublabel="$19 per month"
        description="Unlimited projects."
        checked
      />
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.component(".checkbox", [
      ~s(name="notifications"),
      ~s(label="Enable notifications"),
      ~s(sublabel="Recommended"),
      ~s(description="We'll send you important updates about your account status and security."),
      Snippet.attr("variant", props.variant, "simple"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "sm"),
      Snippet.attr("color", props.color, "primary")
    ])
  end
end
