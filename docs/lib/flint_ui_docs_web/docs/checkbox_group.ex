defmodule FlintUIDocsWeb.Docs.CheckboxGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :checkbox_group

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
    <.prose content="A checkbox group collects several selections into one form field. Declare each
      option with a `:checkbox` slot; the group appends `[]` to the name, so the server receives a
      list, and adds one hidden empty value so the field is always present." />

    <.prose content="Pass `value` to check the matching options, or set an option's own `checked`
      attribute to force its state. `orientation` lays the options out vertically or horizontally,
      and `variant`, `size`, and `radius` are forwarded to every option." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-md">
        <Components.checkbox_group
          id="languages"
          name="languages"
          label="Programming languages"
          description="Pick the languages you reach for first."
          value={["elixir"]}
          orientation={props.orientation}
          variant={props.variant}
          size={props.size}
          radius={props.radius}
        >
          <:checkbox value="elixir" label="Elixir" sublabel="Recommended" />
          <:checkbox value="rust" label="Rust" />
          <:checkbox value="typescript" label="TypeScript" />
          <:checkbox value="python" label="Python" />
        </Components.checkbox_group>
      </div>
    </.preview>

    <.prose content="Filter the empty value in your handler when nothing is selected:" />

    <.prose content={"```elixir\nselected = Enum.reject(params[\"languages\"] || [], &(&1 == \"\"))\n```"} />
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="The group renders a native `fieldset` with a `legend`, so the label names the
      group for every option. Group errors are linked to the fieldset with `aria-describedby`, and
      `required` marks the group with `aria-required`." />

    <.preview {assigns} code={~S|<.checkbox_group
      name="languages"
      label="Programming languages"
      description="Pick at least one language."
      required
      errors={["must select at least one"]}
    >
      <:checkbox value="elixir" label="Elixir" />
      <:checkbox value="rust" label="Rust" />
    </.checkbox_group>|}>
      <div class="w-full max-w-sm">
        <Components.checkbox_group
          name="languages"
          label="Programming languages"
          description="Pick at least one language."
          required
          errors={["must select at least one"]}
        >
          <:checkbox value="elixir" label="Elixir" />
          <:checkbox value="rust" label="Rust" />
        </Components.checkbox_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` disables the whole fieldset, so every option and the hidden mirror
      are disabled. An option can also be disabled on its own without disabling its siblings." />

    <.preview {assigns} code={~S|<.checkbox_group name="languages" label="Disabled group" disabled>
      <:checkbox value="elixir" label="Elixir" checked />
      <:checkbox value="rust" label="Rust" />
    </.checkbox_group>

    <.checkbox_group name="languages" label="One disabled option">
      <:checkbox value="elixir" label="Elixir" />
      <:checkbox value="rust" label="Rust" disabled />
    </.checkbox_group>|}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.checkbox_group name="languages" label="Disabled group" disabled>
          <:checkbox value="elixir" label="Elixir" checked />
          <:checkbox value="rust" label="Rust" />
        </Components.checkbox_group>

        <Components.checkbox_group name="languages" label="One disabled option">
          <:checkbox value="elixir" label="Elixir" />
          <:checkbox value="rust" label="Rust" disabled />
        </Components.checkbox_group>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="A `Phoenix.HTML.FormField` supplies the group id, name, selected values, and
      errors. Each option's id is the field id with the option index appended." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="languages-form">
      <.checkbox_group field={f[:languages]} label="Programming languages">
        <:checkbox value="elixir" label="Elixir" />
        <:checkbox value="rust" label="Rust" />
        <:checkbox value="typescript" label="TypeScript" />
      </.checkbox_group>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="checkbox-group-field-form">
        <div class="w-full max-w-sm">
          <Components.checkbox_group field={f[:languages]} label="Programming languages">
            <:checkbox value="elixir" label="Elixir" />
            <:checkbox value="rust" label="Rust" />
            <:checkbox value="typescript" label="TypeScript" />
          </Components.checkbox_group>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="A group is one field: validate it as a list, show its errors with `errors`, and
      keep the options in one `fieldset`. Use a standalone [checkbox](/components/checkbox) for a
      single boolean in the same form." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="profile-form">
      <.checkbox field={f[:terms]} label="I accept the terms" />
      <.checkbox_group field={f[:languages]} label="Programming languages">
        <:checkbox value="elixir" label="Elixir" />
        <:checkbox value="rust" label="Rust" />
        <:checkbox value="typescript" label="TypeScript" />
      </.checkbox_group>
      <.button type="button" variant="solid">Save profile</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="checkbox-group-form-example">
        <div class="grid w-full max-w-md gap-4">
          <Components.checkbox field={f[:terms]} label="I accept the terms" />
          <Components.checkbox_group field={f[:languages]} label="Programming languages">
            <:checkbox value="elixir" label="Elixir" />
            <:checkbox value="rust" label="Rust" />
            <:checkbox value="typescript" label="TypeScript" />
          </Components.checkbox_group>
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

    <.preview {assigns} code={~S|<.checkbox_group
      name="plan"
      variant="card"
      label="Choose a plan"
      value={["pro"]}
    >
      <:checkbox value="free" label="Free" sublabel="$0" description="One project." />
      <:checkbox value="pro" label="Pro" sublabel="$19" description="Unlimited projects." />
      <:checkbox value="team" label="Team" sublabel="$49" description="Everything in Pro, plus roles." />
    </.checkbox_group>|}>
      <div class="w-full max-w-md">
        <Components.checkbox_group
          name="plan"
          variant="card"
          label="Choose a plan"
          value={["pro"]}
        >
          <:checkbox value="free" label="Free" sublabel="$0" description="One project." />
          <:checkbox
            value="pro"
            label="Pro"
            sublabel="$19"
            description="Unlimited projects and priority support."
          />
          <:checkbox
            value="team"
            label="Team"
            sublabel="$49"
            description="Everything in Pro, plus roles and permissions."
          />
        </Components.checkbox_group>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-sm">
      <Components.checkbox_group
        id={"#{@parts_id}-languages"}
        name={"#{@parts_id}-languages"}
        label="Programming languages"
        description="Pick the languages you reach for first."
        value={["elixir"]}
      >
        <:checkbox value="elixir" label="Elixir" sublabel="Recommended" />
        <:checkbox value="rust" label="Rust" />
        <:checkbox value="typescript" label="TypeScript" disabled />
      </Components.checkbox_group>
    </div>
    """
  end

  defp code_basic(props) do
    attrs = [
      ~s(id="languages"),
      ~s(name="languages"),
      ~s(label="Programming languages"),
      ~s(description="Pick the languages you reach for first."),
      ~s(value={["elixir"]}),
      Snippet.attr("orientation", props.orientation, "vertical"),
      Snippet.attr("variant", props.variant, "simple"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "sm")
    ]

    body = """
    <:checkbox value="elixir" label="Elixir" sublabel="Recommended" />
    <:checkbox value="rust" label="Rust" />
    <:checkbox value="typescript" label="TypeScript" />
    <:checkbox value="python" label="Python" />
    """

    Snippet.tag(".checkbox_group", attrs, body)
  end
end
