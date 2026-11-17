defmodule FlintUIDocsWeb.Docs.Label do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :label

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
        controls: [%{key: :size, type: :select, default: "md", label: "Size"}]
      },
      %{tab: :styled, section: :usage, id: :description, title: "Description"},
      %{tab: :styled, section: :usage, id: :sublabel, title: "Sublabel"},
      %{tab: :styled, section: :usage, id: :required, title: "Required"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "In a Form",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A label names the control it points at. Put the control's id in `for`; the browser
      associates the two without wrapping the control, so the label can sit above its field in any layout." />

    <.prose content="The default slot is the label text and wins over `label`. `size` follows the shared
      control type scale, from `xs` to `xl`, and defaults to `md`." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="grid w-full max-w-sm gap-2">
        <Components.label for="label-basic-email" size={props.size}>Email</Components.label>
        <Components.input
          id="label-basic-email"
          name="label-basic-email"
          type="email"
          value="ada@example.com"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :description} = assigns) do
    ~H"""
    <.prose content="`description` adds explanatory text beneath the label row. It stays outside the
      native `<label>`, so it does not join the control's accessible name. When `for` is set the
      description gets the id `<for>-description`; link it from the control with `aria-describedby`." />

    <.preview {assigns} code={~S|<.label for="email" description="We only use this for receipts.">
      Email
    </.label>

    <.input
      id="email"
      name="email"
      type="email"
      aria-describedby="email-description"
    />|}>
      <div class="grid w-full max-w-sm gap-2">
        <Components.label for="label-description-email" description="We only use this for receipts.">
          Email
        </Components.label>

        <Components.input
          id="label-description-email"
          name="label-description-email"
          type="email"
          aria-describedby="label-description-email-description"
        />
      </div>
    </.preview>

    <.prose content="Without `for`, the id follows the label's root `id` instead. With neither, the
      description is visual only." />
    """
  end

  def render_section(%{section: :usage, id: :sublabel} = assigns) do
    ~H"""
    <.prose content="`sublabel` adds a short qualifier after the label text in the muted text tier. Use
      it for a marker such as `Optional` or `Recommended`, not for a second sentence of instructions.
      The sublabel stays inside the label, so it is announced with the label text." />

    <.preview {assigns} code={~S|<.label for="email" sublabel="Optional">Email</.label>|}>
      <div class="grid w-full max-w-sm gap-3">
        <Components.label for="label-sublabel-email" sublabel="Optional">Email</Components.label>
        <Components.label for="label-sublabel-phone" sublabel="Recommended">
          Phone
        </Components.label>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :required} = assigns) do
    ~H"""
    <.prose content="`required` adds a decorative asterisk after the label text. The marker is hidden
      from assistive technology; the control still needs its native `required` or `aria-required`
      state, which assistive technology announces." />

    <.preview {assigns} code={~S|<.label for="email" required>Email</.label>
    <.input id="email" name="email" type="email" required />|}>
      <div class="grid w-full max-w-sm gap-2">
        <Components.label for="label-required-email" required>Email</Components.label>
        <Components.input
          id="label-required-email"
          name="label-required-email"
          type="email"
          required
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="Pair a label with any control through `for`. In a form, derive both ids from the
      field: the field supplies the control id, and the label appends `-description` to it." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="profile-form">
      <.label for="user_name" sublabel="Optional">Name</.label>
      <.input field={f[:name]} />

      <.label for="user_email" description="We only use this for receipts.">Email</.label>
      <.input field={f[:email]} type="email" aria-describedby="user_email-description" />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="label-form-example">
        <div class="grid w-full max-w-sm gap-2">
          <Components.label for="user_name" sublabel="Optional">Name</Components.label>
          <Components.input field={f[:name]} />

          <Components.label for="user_email" description="We only use this for receipts.">
            Email
          </Components.label>
          <Components.input
            field={f[:email]}
            type="email"
            aria-describedby="user_email-description"
          />
        </div>
      </.form>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-4">
      <Components.label
        for={"#{@parts_id}-email"}
        required
        description="We only use this for receipts."
      >
        Email
      </Components.label>

      <Components.label for={"#{@parts_id}-name"} size="lg" sublabel="Optional">
        Name
      </Components.label>
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.tag(
      ".label",
      [
        ~s(for="email"),
        Snippet.attr("size", props.size, "md")
      ],
      "Email"
    )
  end
end
