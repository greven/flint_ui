defmodule FlintUIDocsWeb.Docs.KnownDate do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :known_date

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
          %{key: :radius, type: :select, default: "md", label: "Radius"}
        ]
      },
      %{tab: :styled, section: :usage, id: :locale, title: "Locale-Aware Order"},
      %{tab: :styled, section: :usage, id: :value, title: "Canonical ISO Value"},
      %{tab: :styled, section: :usage, id: :validation, title: "Hint and Validation"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled and Read-only"},
      %{tab: :styled, section: :usage, id: :field, title: "Form Fields"},
      %{
        tab: :styled,
        section: :examples,
        id: :form,
        title: "A Complete Form",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A known date collects a date the user already knows, such as a birthday or an
      expiration, through separate day, month, and year fields. It follows the UK Government Design
      System date input pattern: a labeled `<fieldset>` wraps three plain text inputs, so the user
      types each part themselves. There is no calendar, no auto-advance, and no clever parsing." />

    <.prose content="The group label is a `<legend>`; each part has its own `Day`, `Month`, or `Year`
      label. `sublabel` adds a short muted qualifier beside the group label, and `description` and
      `hint` follow the same contract as the other form fields." />

    <.preview :let={props} {assigns} code={&code_basic/1}>
      <div class="w-full max-w-md">
        <Components.known_date
          id="known-date-basic"
          name="date_of_birth"
          label="Date of birth"
          sublabel="Optional"
          description="As printed on your birth certificate."
          hint="For example, 27 3 2007"
          value="2007-03-27"
          size={props.size}
          radius={props.radius}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :locale} = assigns) do
    ~H"""
    <.prose content="`locale` accepts a BCP-47 locale and changes the order of the three fields. Most
      of the world reads day, month, year; `en-US` reads month, day, year; and locales such as
      `ja-JP`, `zh-CN`, `ko-KR`, `hu-HU`, `lt-LT`, and `sv-SE` read year, month, day. The labels stay
      the same; only their position changes." />

    <.prose content="When `locale` is omitted, a `lang` attribute from the global attributes is used.
      With neither, the default is the European order: day, month, year." />

    <.preview
      {assigns}
      code={~S|<.known_date id="uk-date" name="uk_date" label="UK order" locale="en-GB" />
    <.known_date id="us-date" name="us_date" label="US order" locale="en-US" />
    <.known_date id="jp-date" name="jp_date" label="Japanese order" locale="ja-JP" />|}
    >
      <div class="grid w-full max-w-sm gap-6">
        <Components.known_date
          id="known-date-locale-gb"
          name="known-date-locale-gb"
          label="UK order"
          locale="en-GB"
        />

        <Components.known_date
          id="known-date-locale-us"
          name="known-date-locale-us"
          label="US order"
          locale="en-US"
        />

        <Components.known_date
          id="known-date-locale-jp"
          name="known-date-locale-jp"
          label="Japanese order"
          locale="ja-JP"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :value} = assigns) do
    ~H"""
    <.prose content="The three visible inputs carry no `name`. The component submits one canonical
      ISO 8601 date (`YYYY-MM-DD`) through a hidden input named `name`, regardless of the field
      order. A partial or invalid date submits nothing." />

    <.prose content="`value` accepts an ISO date or a `Date` to pre-fill the parts. The hidden value
      is composed by `flint.js` as the user types. Without the bundle, the server-rendered value is
      what submits; editing the visible fields does not update it." />

    <.preview
      {assigns}
      code={
        ~S|<.known_date id="passport-date" name="passport_issued" label="When was your passport issued?" value="2007-03-27" />|
      }
    >
      <div class="w-full max-w-md">
        <Components.known_date
          id="known-date-value"
          name="passport_issued"
          label="When was your passport issued?"
          value="2007-03-27"
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :validation} = assigns) do
    ~H"""
    <.prose content="`hint` renders supporting text below the fields and links it from every part
      with `aria-describedby`, so it is read with the field rather than announced as separate copy.
      `errors` adds one paragraph per message, marks the group invalid, and links the same ids from
      each part. Errors only show for a form field once it has been used." />

    <.prose content="The component validates structure itself: every part must be present, the
      month and day must exist for that year, leap days are accepted only in leap years, and the
      year must be four digits. A partial or impossible date submits nothing. `required` adds the
      native attribute to each part, so an incomplete date blocks submission in the browser." />

    <.prose content="`min` and `max` accept an ISO 8601 string or a `Date` and constrain the accepted
      range. Keep business rules in the host's changeset, such as an age restriction or a cross-field
      comparison, and render their messages through `errors`." />

    <.preview
      {assigns}
      code={~S|<.known_date
      id="birthday"
      name="birthday"
      label="Birthday"
      max={Date.utc_today()}
      hint="For example, 27 3 2007"
      errors={["is not a real date", "must be in the past"]}
    />

    <.known_date
      id="passport-expiry"
      name="passport_expiry"
      label="Passport expiry"
      min={Date.utc_today()}
      required
    />|}
    >
      <div class="grid w-full max-w-md gap-6">
        <Components.known_date
          id="known-date-validation"
          name="birthday"
          label="Birthday"
          max={Date.utc_today()}
          hint="For example, 27 3 2007"
          errors={["is not a real date", "must be in the past"]}
        />

        <Components.known_date
          id="known-date-validation-expiry"
          name="passport_expiry"
          label="Passport expiry"
          min={Date.utc_today()}
          required
          hint="Must be today or later."
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="`disabled` disables the fieldset, so every part and the hidden value leave the
      form submission. `readonly` keeps the values visible and focusable and keeps the canonical
      date in the submission." />

    <.preview
      {assigns}
      code={
        ~S|<.known_date id="disabled-date" name="disabled_date" label="Birthday" value="2007-03-27" disabled />
    <.known_date id="readonly-date" name="readonly_date" label="Member since" value="2007-03-27" readonly />|
      }
    >
      <div class="grid w-full max-w-sm gap-6">
        <Components.known_date
          id="known-date-disabled"
          name="known-date-disabled"
          label="Birthday"
          value="2007-03-27"
          disabled
        />

        <Components.known_date
          id="known-date-readonly"
          name="known-date-readonly"
          label="Member since"
          value="2007-03-27"
          readonly
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :field} = assigns) do
    ~H"""
    <.prose content="Pass a `Phoenix.HTML.FormField` to derive the group id, the form name, the
      current value, and the errors. The field drives the value, so the parts stay in step with the
      form after a validation round trip." />

    <.preview {assigns} code={~S|<.form :let={f} for={%{}} as={:user} id="passport-form">
      <.known_date field={f[:date_of_birth]} label="Date of birth" />
    </.form>|}>
      <.form :let={f} for={%{}} as={:user} id="known-date-field-form">
        <div class="w-full max-w-md">
          <Components.known_date field={f[:date_of_birth]} label="Date of birth" />
        </div>
      </.form>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :form} = assigns) do
    ~H"""
    <.prose content="Known date shares the label, description, hint, and error contract of the other
      form fields, so it can sit in the same form without a second set of conventions." />

    <.preview
      {assigns}
      code={~S|<.form for={@form} id="account-form" phx-submit="save">
      <.known_date field={@form[:date_of_birth]} label="Date of birth" hint="For example, 27 3 2007" />
      <.known_date field={@form[:passport_expiry]} label="Passport expiry" min="2020-01-01" />
      <.button type="submit">Save details</.button>
    </.form>|}
    >
      <div class="grid w-full max-w-md gap-4">
        <Components.known_date
          id="known-date-form-birth"
          name="date_of_birth"
          label="Date of birth"
          hint="For example, 27 3 2007"
        />

        <Components.known_date
          id="known-date-form-expiry"
          name="passport_expiry"
          label="Passport expiry"
          min="2020-01-01"
        />

        <Components.button type="button" variant="solid">Save details</Components.button>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="w-full max-w-md">
      <Components.known_date
        id={"#{@parts_id}-dob"}
        name={"#{@parts_id}-dob"}
        label="Date of birth"
        sublabel="Optional"
        description="As printed on your birth certificate."
        hint="For example, 27 3 2007"
        value="2007-03-27"
        errors={["is invalid"]}
      />
    </div>
    """
  end

  defp code_basic(props) do
    Snippet.component(".known_date", [
      ~s(id="date-of-birth"),
      ~s(name="date_of_birth"),
      ~s(label="Date of birth"),
      ~s(sublabel="Optional"),
      ~s(description="As printed on your birth certificate."),
      ~s(hint="For example, 27 3 2007"),
      ~s(value="2007-03-27"),
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("radius", props.radius, "md")
    ])
  end
end
