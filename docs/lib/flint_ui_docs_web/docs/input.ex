defmodule FlintUIDocsWeb.Docs.Input do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :input

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{tab: :styled, section: :usage, id: :hint, title: "Label and Hint"},
      %{tab: :styled, section: :usage, id: :affixes, title: "Prefix and Suffix"},
      %{tab: :styled, section: :usage, id: :types, title: "Types"},
      %{tab: :styled, section: :usage, id: :select, title: "Select"},
      %{tab: :styled, section: :usage, id: :textarea, title: "Textarea"},
      %{tab: :styled, section: :usage, id: :checkbox, title: "Checkbox"},
      %{tab: :styled, section: :usage, id: :validation, title: "Validation"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled and Read-only"},
      %{
        tab: :styled,
        section: :usage,
        id: :size,
        title: "Size",
        controls: [%{key: :size, type: :select, default: "md", label: "Size"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :radius,
        title: "Radius",
        controls: [%{key: :radius, type: :select, default: "md", label: "Radius"}]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :migration,
        title: "Migrating from CoreComponents"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="`<.input>` replaces the `input/1` that `phx.new` generates in `MyAppWeb.CoreComponents`.
      It accepts the same attributes and the same input types, so existing forms keep working after
      `mix flint.add input` swaps the implementation." />

    <.prose content="Pass `name`, `type`, and `label` for a standalone field, or a `field` struct from a form." />

    <.preview
      {assigns}
      code={~S(<.input name="email" type="email" label="Email" placeholder="you@example.com" />)}
    >
      <div class="w-full max-w-sm">
        <Components.input
          name="email"
          type="email"
          label="Email"
          placeholder="you@example.com"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    form = Phoenix.Component.to_form(%{"email" => "ada@example.com"}, as: :user)
    assigns = Map.put(assigns, :form, form)

    ~H"""
    <.prose content="A `Phoenix.HTML.FormField` fills in `id`, `name`, `value`, and errors, so the field stays in
      step with the changeset. Errors only render once the field has been used, matching Phoenix's behavior." />

    <.preview {assigns} code={&code_field/1}>
      <div class="w-full max-w-sm">
        <Components.input field={@form[:email]} type="email" label="Email" />
      </div>
    </.preview>

    <.prose content="For a `multiple` field the name gets a `[]` suffix automatically." />
    """
  end

  def render_section(%{section: :usage, id: :hint} = assigns) do
    ~H"""
    <.prose content="`hint` renders hint text under the control and links it with `aria-describedby`, so
      it is read with the field rather than announced as separate copy." />

    <.preview
      {assigns}
      code={
        ~S|<.input name="email" label="Email" hint="We only use this for receipts." value="ada@example.com" />|
      }
    >
      <div class="w-full max-w-sm">
        <Components.input
          name="email"
          label="Email"
          hint="We only use this for receipts."
          value="ada@example.com"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :affixes} = assigns) do
    ~H"""
    <.prose content="Four slots frame the control. `inner_prefix` and `inner_suffix` sit inside the control border;
      `outer_prefix` and `outer_suffix` sit outside it." />

    <.prose content="The inner slots are inside the `<label>`, so keep them decorative or textual. Put interactive
      content, such as a clear or reveal button, in an outer slot." />

    <.prose content="An outer slot renders as an addon: it borrows the control's fill and height, joins its border so
      the group has a single seam, and keeps only its free end rounded. A `<.button>` placed directly in an outer slot
      takes the segment over instead; give it the same `size` as the input." />

    <.preview {assigns} code={&code_affixes/1}>
      <div class="grid w-full max-w-sm gap-4">
        <Components.input
          name="search"
          type="search"
          label="Search"
          placeholder="Search components"
        >
          <:inner_prefix>
            <Components.icon name="lucide-search" class="size-4" />
          </:inner_prefix>
          <:inner_suffix>
            <Components.kbd size="xs" variant="outline" aria-hidden="true">⌘K</Components.kbd>
          </:inner_suffix>
        </Components.input>

        <Components.input name="domain" label="Domain" value="acme">
          <:outer_prefix>https://</:outer_prefix>
          <:outer_suffix>.example.com</:outer_suffix>
        </Components.input>

        <Components.input name="price" label="Price" value="42.00">
          <:inner_prefix>$</:inner_prefix>
          <:inner_suffix>USD</:inner_suffix>
        </Components.input>

        <Components.input name="invite" label="Invite link" value="acme.test/join/42">
          <:outer_suffix>
            <Components.button type="button" variant="surface">Copy</Components.button>
          </:outer_suffix>
        </Components.input>
      </div>
    </.preview>

    <.prose content="The slots render for text inputs, `select`, and `textarea`. The `checkbox` and `hidden`
      branches do not render them." />
    """
  end

  def render_section(%{section: :usage, id: :types} = assigns) do
    ~H"""
    <.prose content="`type` accepts the same values as the core component: `text`, `email`, `password`, `search`,
      `tel`, `url`, `number`, `date`, `time`, `datetime-local`, `month`, `week`, `color`, `file`, plus the
      dedicated `select`, `textarea`, `checkbox`, and `hidden` branches." />

    <.preview {assigns} code={&code_types/1} collapsed>
      <div class="grid w-full gap-4 sm:grid-cols-2">
        <Components.input
          :for={{type, value} <- type_demos()}
          name={"demo-#{type}"}
          type={type}
          label={type}
          value={value}
        />
      </div>
    </.preview>

    <.prose content="A `hidden` input renders only the control, without a label or errors:" />
    <.prose content={"```heex\n<.input field={@form[:token]} type=\"hidden\" />\n```"} />
    """
  end

  def render_section(%{section: :usage, id: :select} = assigns) do
    ~H"""
    <.prose content="`select` takes `options` in the shape `options_for_select/2` accepts, an optional `prompt`,
      and `multiple`. The native control keeps its OS arrow and popup; a richer Select component will cover
      custom option lists later." />

    <.preview {assigns} code={&code_select/1}>
      <div class="grid w-full max-w-sm gap-4">
        <Components.input
          name="role"
          type="select"
          label="Role"
          prompt="Choose a role"
          options={[Admin: "admin", Editor: "editor", Viewer: "viewer"]}
        />

        <Components.input
          name="roles[]"
          type="select"
          label="Roles"
          multiple
          value={["editor"]}
          options={[Admin: "admin", Editor: "editor", Viewer: "viewer"]}
        />
      </div>
    </.preview>

    <.prose content="With a `field`, `multiple` derives the `[]` suffix for the name." />
    """
  end

  def render_section(%{section: :usage, id: :textarea} = assigns) do
    ~H"""
    <.prose content="`textarea` takes `rows` like any textarea and grows with its content. The theme keeps the
      value and padding in step with the other controls and leaves `resize` native." />

    <.prose content={"For a standalone textarea field with `sublabel`, `description`, and `hint`, use\n      [Textarea](/components/textarea). `type=\"textarea\"` stays for `CoreComponents` parity and for the\n      prefix and suffix slots."} />

    <.preview
      {assigns}
      code={
        ~S|<.input name="bio" type="textarea" label="Bio" rows="4" hint="A short introduction." value="I write accessible interfaces." />|
      }
    >
      <div class="w-full max-w-sm">
        <Components.input
          name="bio"
          type="textarea"
          label="Bio"
          rows="4"
          hint="A short introduction."
          value="I write accessible interfaces."
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :checkbox} = assigns) do
    ~H"""
    <.prose content={"`checkbox` renders the hidden `\"false\"` input before the checkbox, so an unchecked box still submits a value. The label is the checkbox's accessible name."} />

    <.preview
      {assigns}
      code={
        ~S|<.input name="remember_me" type="checkbox" label="Remember me on this device" value={true} />|
      }
    >
      <div class="grid w-full max-w-sm gap-4">
        <Components.input
          name="remember_me"
          type="checkbox"
          label="Remember me on this device"
          value={true}
        />

        <Components.input
          name="newsletter"
          type="checkbox"
          label="Send me the newsletter"
          hint="No more than one email a month."
        />

        <Components.input
          name="terms"
          type="checkbox"
          label="I accept the terms"
          disabled
        />
      </div>
    </.preview>

    <.prose content="The theme paints the box and check mark on a decorative indicator while the native input stays
      focusable above it, so forced-colors mode and assistive technology still see a real checkbox." />
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="An invalid field marks the control with `aria-invalid` and links its hint and error
      messages with `aria-describedby`. Errors are text, not color alone; each message leads with a decorative
      warning icon that assistive technology skips, so the error reads at a glance." />

    <.preview {assigns} code={&code_validation/1}>
      <div class="w-full max-w-sm">
        <Components.input
          id="validation-email"
          name="email"
          type="email"
          label="Email"
          value="ada@"
          hint="We only use this for receipts."
          errors={["is invalid", "is already taken"]}
        />
      </div>
    </.preview>

    <.prose content="`errors` accepts translated strings and raw `{message, options}` tuples. Tuples are
      interpolated like the `translate_error/1` that `phx.new` generates; Gettext applications can point
      `:translate_error` at their own function. See the Base tab for the configuration." />
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` and `readonly` pass straight through to the native control. The field dims as a unit
      when it is disabled; a read-only field keeps its value legible." />

    <.preview {assigns} code={&code_disabled/1}>
      <div class="grid w-full max-w-sm gap-4">
        <Components.input
          name="disabled-email"
          type="email"
          label="Disabled"
          value="ada@example.com"
          disabled
        />

        <Components.input
          name="readonly-email"
          type="email"
          label="Read-only"
          value="ada@example.com"
          readonly
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="`size` sets the control height, padding, type, and indicator from the shared control scale.
      It accepts `xs`, `sm`, `md`, `lg`, and `xl`, and defaults to `md`." />

    <.prose content="A numeric `size` is the native HTML `size` attribute instead: a character width on a text
      input or a row count on a listbox select." />

    <.preview :let={props} {assigns} code={&code_size/1}>
      <div class="grid w-full max-w-sm gap-4">
        <Components.input name="sized-email" label="Email" size={props.size} value="ada@example.com" />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :radius} = assigns) do
    ~H"""
    <.prose content="`radius` follows the shared radius scale, from `none` for square corners to `xl`.
      The default is `md`; the color swatch follows the same radius." />

    <.preview :let={props} {assigns} code={&code_radius/1}>
      <div class="grid w-full max-w-sm gap-4">
        <Components.input
          name="radius-email"
          label="Email"
          radius={props.radius}
          value="ada@example.com"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="Use `Phoenix.Component.form/1` and `to_form/2` as usual; FlintUI only replaces the input.
      The code panel shows the real form markup and the LiveView assign it needs." />

    <.preview {assigns} codes={&code_form/1}>
      <div class="grid w-full max-w-md gap-4">
        <Components.input name="profile-name" label="Name" value="Ada Lovelace" />
        <Components.input
          name="profile-email"
          type="email"
          label="Email"
          value="ada@example.com"
        />
        <Components.input
          name="profile-role"
          type="select"
          label="Role"
          value="admin"
          options={[Admin: "admin", User: "user"]}
        />
        <Components.input
          name="profile-bio"
          type="textarea"
          label="Bio"
          rows="3"
          value="I write accessible interfaces."
        />
        <Components.input
          name="profile-terms"
          type="checkbox"
          label="I accept the terms"
          value={true}
        />
        <Components.button type="button" variant="solid">Save</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :migration} = assigns) do
    ~H"""
    <.prose content="`mix flint.add input` generates the styled wrapper and removes `input/1` from
      `MyAppWeb.CoreComponents`, because both modules are imported into your HTML helpers and two
      `input/1` functions would make `<.input>` ambiguous. The private `error/1` helper goes with it when
      nothing else uses it." />

    <.prose content="Templates do not change: `field`, `type`, `options`, `prompt`, `multiple`, `checked`,
      `errors`, `class`, and `error_class` all keep their meaning. `class` is additive here rather than
      replacing the defaults, and the theme tokens style the field." />

    <.preview {assigns} codes={&code_migration/1} code_only />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-4">
      <Components.input
        id={"#{@parts_id}-email"}
        name={"#{@parts_id}-email"}
        label="Email"
        value="ada@example.com"
        hint="We only use this for receipts."
        errors={["is already taken"]}
      />

      <Components.input
        id={"#{@parts_id}-search"}
        name={"#{@parts_id}-search"}
        label="Search"
        value="accessibility"
      >
        <:outer_prefix>https://</:outer_prefix>
        <:inner_prefix>@</:inner_prefix>
        <:inner_suffix>.com</:inner_suffix>
        <:outer_suffix>Open</:outer_suffix>
      </Components.input>

      <Components.input
        id={"#{@parts_id}-remember"}
        name={"#{@parts_id}-remember"}
        type="checkbox"
        label="Remember me"
        value={true}
      />
    </div>
    """
  end

  defp type_demos do
    [
      {"text", "Ada Lovelace"},
      {"email", "ada@example.com"},
      {"password", "correct horse"},
      {"search", "accessibility"},
      {"tel", "+1 555 0100"},
      {"url", "https://example.com"},
      {"number", "42"},
      {"date", nil},
      {"time", nil},
      {"datetime-local", nil},
      {"month", nil},
      {"week", nil},
      {"color", nil},
      {"file", nil}
    ]
  end

  defp code_field(_) do
    """
    <.form for={@form} id="user-form">
      <.input field={@form[:email]} type="email" label="Email" />
    </.form>
    """
  end

  defp code_affixes(_) do
    """
    <.input name="search" type="search" label="Search" placeholder="Search components">
      <:inner_prefix><.icon name="lucide-search" class="size-4" /></:inner_prefix>
      <:inner_suffix><.kbd size="xs" variant="outline" aria-hidden="true">⌘K</.kbd></:inner_suffix>
    </.input>

    <.input name="domain" label="Domain" value="acme">
      <:outer_prefix>https://</:outer_prefix>
      <:outer_suffix>.example.com</:outer_suffix>
    </.input>

    <.input name="price" label="Price" value="42.00">
      <:inner_prefix>$</:inner_prefix>
      <:inner_suffix>USD</:inner_suffix>
    </.input>

    <.input name="invite" label="Invite link" value="acme.test/join/42">
      <:outer_suffix>
        <.button type="button" variant="surface">Copy</.button>
      </:outer_suffix>
    </.input>
    """
  end

  defp code_types(_) do
    """
    <.input name="email" type="email" label="email" value="ada@example.com" />
    <.input name="date" type="date" label="date" />
    <.input name="file" type="file" label="file" />
    <.input name="token" type="hidden" value={@token} />
    """
  end

  defp code_select(_) do
    """
    <.input
      name="role"
      type="select"
      label="Role"
      prompt="Choose a role"
      options={["Admin": "admin", "Editor": "editor", "Viewer": "viewer"]}
    />

    <.input
      name="roles[]"
      type="select"
      label="Roles"
      multiple
      value={["editor"]}
      options={["Admin": "admin", "Editor": "editor", "Viewer": "viewer"]}
    />
    """
  end

  defp code_validation(_) do
    """
    <.input
      name="email"
      type="email"
      label="Email"
      value="ada@"
      hint="We only use this for receipts."
      errors={["is invalid", "is already taken"]}
    />

    # A form field carries its own errors:
    <.input field={@form[:email]} type="email" label="Email" />
    """
  end

  defp code_disabled(_) do
    """
    <.input name="email" type="email" label="Disabled" value="ada@example.com" disabled />
    <.input name="email" type="email" label="Read-only" value="ada@example.com" readonly />
    """
  end

  defp code_size(props) do
    Snippet.component(".input", [
      Snippet.attr("name", "email"),
      Snippet.attr("label", "Email"),
      Snippet.attr("value", "ada@example.com"),
      Snippet.attr("size", props.size, "md")
    ])
  end

  defp code_radius(props) do
    Snippet.component(".input", [
      Snippet.attr("name", "email"),
      Snippet.attr("label", "Email"),
      Snippet.attr("value", "ada@example.com"),
      Snippet.attr("radius", props.radius, "md")
    ])
  end

  defp code_form(_) do
    [
      %{
        label: "HEEx",
        code: """
        <.form for={@form} id="profile-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} label="Name" />
          <.input field={@form[:email]} type="email" label="Email" />
          <.input
            field={@form[:role]}
            type="select"
            label="Role"
            options={["Admin": "admin", "User": "user"]}
            prompt="Choose a role"
          />
          <.input field={@form[:bio]} type="textarea" label="Bio" rows="4" />
          <.input field={@form[:terms]} type="checkbox" label="I accept the terms" />
          <.button type="submit" variant="solid">Save</.button>
        </.form>
        """
      },
      %{
        label: "LiveView",
        lang: :elixir,
        code: """
        def mount(_params, _session, socket) do
          {:ok, assign(socket, form: to_form(%{"role" => "user"}))}
        end

        def handle_event("save", %{"user" => params}, socket) do
          # validate and persist, then reset the form
          {:noreply, assign(socket, form: to_form(params, as: :user))}
        end
        """
      }
    ]
  end

  defp code_migration(_) do
    [
      %{label: "Shell", code: "mix flint.add input"},
      %{
        label: "HEEx",
        code: """
        <%!-- No template change: the generated <.input> accepts the core API. --%>
        <.input field={@form[:email]} type="email" label="Email" />
        """
      },
      %{
        label: "Elixir",
        lang: :elixir,
        code: """
        # Keep Gettext error messages
        config :flint_ui, :translate_error, {MyAppWeb.CoreComponents, :translate_error}
        """
      }
    ]
  end
end
