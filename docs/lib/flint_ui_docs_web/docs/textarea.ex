defmodule FlintUIDocsWeb.Docs.Textarea do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :textarea

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
          %{key: :radius, type: :select, default: "md", label: "Radius"},
          %{key: :resize, type: :select, default: "vertical", label: "Resize"}
        ]
      },
      %{tab: :styled, section: :usage, id: :description, title: "Description and Validation"},
      %{tab: :styled, section: :usage, id: :rows, title: "Rows and Resize"},
      %{
        tab: :styled,
        section: :usage,
        id: :autogrow,
        title: "Autogrow",
        controls: [
          %{key: :autogrow, type: :boolean, default: true, label: "Autogrow"},
          %{key: :min_rows, type: :number, default: 2, label: "Min rows"},
          %{key: :max_rows, type: :number, default: 8, label: "Max rows"}
        ]
      },
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled and Read-only"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :input, title: "Textarea or Input?"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A textarea collects multi-line free text. It keeps the native `<textarea>`, so line
      breaks, the resize handle, and the keyboard behavior stay the browser's." />

    <.prose content="`label` names the control through `for`; pass an `id` or bind a `field`, which
      supplies one. `name` is only the form parameter and does not create an id. `sublabel` adds a
      short qualifier in the muted tier. `size` and `radius` follow the shared control and radius
      scales, and `resize` picks which resize handle the browser shows." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-sm">
        <Components.textarea
          id="textarea-basic-bio"
          name="bio"
          label="Bio"
          sublabel="Optional"
          description="A short introduction for your profile."
          rows="4"
          value="I write accessible interfaces."
          size={props.size}
          radius={props.radius}
          resize={props.resize}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :description} = assigns) do
    ~H"""
    <.prose content="`description` renders explanatory text between the label and the control, like the
      Label component's description. `hint` renders supporting text below the control, where the input
      field puts its hint. Both link from the control with `aria-describedby`, and `errors` adds one
      paragraph per message and marks the control invalid. Errors only show for a form field once it
      has been used." />

    <.preview {assigns} code={~S|<.textarea
      id="username"
      name="username"
      label="Username"
      description="Shown on your public profile."
      hint="Three to twenty characters."
      value="ada"
      errors={["is too short", "is already taken"]}
    />|}>
      <div class="grid w-full max-w-sm gap-6">
        <Components.textarea
          id="textarea-description-username"
          name="username"
          label="Username"
          description="Shown on your public profile."
          hint="Three to twenty characters."
          value="ada"
          errors={["is too short", "is already taken"]}
        />

        <Components.textarea
          id="textarea-description-bio"
          name="bio"
          label="Bio"
          description="A short introduction for your profile."
          hint="Markdown is welcome."
          rows="3"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :rows} = assigns) do
    ~H"""
    <.prose content="`rows` sets the visible line count; it is a native attribute, not a component prop.
      `resize` chooses the browser handle: `vertical` is the default, `none` removes it, and
      `horizontal` and `both` let the control grow sideways. The theme sets a minimum height so a
      textarea never collapses below a usable size." />

    <.preview
      {assigns}
      code={~S|<.textarea id="note" name="note" label="Note" rows="2" resize="none" />
    <.textarea id="message" name="message" label="Message" rows="6" resize="vertical" />|}
    >
      <div class="grid w-full max-w-sm gap-6">
        <Components.textarea
          id="textarea-rows-note"
          name="note"
          label="Note"
          rows="2"
          resize="none"
          value="Short note"
        />
        <Components.textarea
          id="textarea-rows-message"
          name="message"
          label="Message"
          rows="6"
          resize="vertical"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :autogrow} = assigns) do
    ~H"""
    <.prose content="`autogrow` lets the field grow and shrink with its content using the CSS
      `field-sizing` property. There is no measuring script and no layout shift, because the browser
      sizes the control during normal layout. `min_rows` sets the empty height and `max_rows` caps
      it; past the cap the field scrolls." />

    <.prose content="The browser keeps the size while autogrow is on, so manual resizing is off even
      when `resize` asks for a handle. In a browser without `field-sizing`, the field falls back to
      the native `rows` height: `min_rows`, unless you pass `rows` yourself." />

    <.preview :let={props} {assigns} code={&code_autogrow/1}>
      <div class="w-full max-w-sm">
        <Components.textarea
          id="textarea-autogrow-message"
          name="autogrow_message"
          label="Message"
          autogrow={props.autogrow}
          min_rows={props.min_rows}
          max_rows={props.max_rows}
          placeholder="Start typing to add a message"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` dims the field and removes it from the tab order. `readonly` keeps the
      value selectable and focusable while preventing edits, so assistive technology still reads it.
      Both map to the native attribute, and both reach the field's state hooks." />

    <.preview
      {assigns}
      code={~S|<.textarea id="bio" name="bio" label="Bio" value="Unavailable" disabled />
    <.textarea id="terms" name="terms" label="Terms" value="Read-only copy" readonly />|}
    >
      <div class="grid w-full max-w-sm gap-6">
        <Components.textarea
          id="textarea-disabled-bio"
          name="bio"
          label="Bio"
          value="Unavailable"
          disabled
        />
        <Components.textarea
          id="textarea-readonly-terms"
          name="terms"
          label="Terms"
          rows="3"
          value="Read-only copy"
          readonly
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive the id, name, value, and errors. The
      field drives the value, so the textarea stays in step with the form after a validation round
      trip." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="profile-form">
      <.textarea field={f[:bio]} label="Bio" rows="4" />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="textarea-field-form">
        <div class="w-full max-w-sm">
          <Components.textarea field={f[:bio]} label="Bio" rows="4" />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="A text input and a textarea share the same field contract, so one form can mix
      them without a second set of conventions." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:profile} id="profile-form">
      <.input field={f[:name]} label="Name" />
      <.textarea field={f[:bio]} label="Bio" rows="6" description="Markdown is welcome." />
      <.button type="submit">Save profile</.button>
    </.form>|}>
      <.form :let={f} for={%{}} as={:profile} id="textarea-example-form">
        <div class="grid w-full max-w-sm gap-4">
          <Components.input field={f[:name]} label="Name" placeholder="Ada Lovelace" />

          <Components.textarea
            field={f[:bio]}
            label="Bio"
            rows="6"
            description="Markdown is welcome."
          />

          <Components.button type="submit">Save profile</Components.button>
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :input} = assigns) do
    ~H"""
    <.prose content="The `input` component's `textarea` type stays available for `CoreComponents` parity,
      including the inner and outer prefix and suffix slots. Use this component when you want the
      standalone field contract shared by checkbox, radio, label, and switch: `sublabel`,
      `description`, and the same error and state hooks." />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-sm">
      <Components.textarea
        id={"#{@parts_id}-bio"}
        name={"#{@parts_id}-bio"}
        label="Bio"
        sublabel="Optional"
        description="A short introduction for your profile."
        hint="Markdown is welcome."
        value="I write accessible interfaces."
        rows="4"
        errors={["is too long"]}
      />
    </div>
    """
  end

  defp code_basic(props) do
    attrs = [
      ~s(id="bio"),
      ~s(name="bio"),
      ~s(label="Bio"),
      ~s(sublabel="Optional"),
      ~s(description="A short introduction for your profile."),
      ~s(rows="4"),
      ~s(value="I write accessible interfaces."),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "md"),
      Snippet.attr("resize", props.resize, "vertical")
    ]

    Snippet.component(".textarea", attrs)
  end

  defp code_autogrow(props) do
    Snippet.component(".textarea", [
      ~s(id="message"),
      ~s(name="message"),
      ~s(label="Message"),
      Snippet.flag("autogrow", props.autogrow),
      ~s(min_rows={#{props.min_rows}}),
      ~s(max_rows={#{props.max_rows}}),
      ~s(placeholder="Start typing to add a message")
    ])
  end
end
