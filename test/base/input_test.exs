defmodule FlintUI.Base.InputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def text_input(assigns) do
      ~H"""
      <.input
        id={@id}
        name={@name}
        label={@label}
        value={@value}
        type={@type}
        errors={@errors}
        hint={@hint}
        class={@class}
        error_class={@error_class}
        disabled={@disabled}
        readonly={@readonly}
        aria-describedby={@describedby}
      />
      """
    end

    def passthrough(assigns) do
      ~H"""
      <.input
        name="search"
        type="search"
        placeholder="Search"
        required
        phx-change="search"
        autocomplete="off"
        phx-debounce="200"
      />
      """
    end

    def field(assigns) do
      ~H"""
      <.input field={@field} type={@type} label={@label} hint={@hint} />
      """
    end

    def multiple_field(assigns) do
      ~H"""
      <.input field={@field} type="select" multiple options={[A: "a", B: "b"]} />
      """
    end

    def field_with_id(assigns) do
      ~H"""
      <.input field={@field} id="custom-email" type="email" />
      """
    end

    def select(assigns) do
      ~H"""
      <.input
        name={@name}
        label={@label}
        type="select"
        options={[Admin: "admin", User: "user"]}
        value={@value}
        prompt={@prompt}
        multiple={@multiple}
      />
      """
    end

    def textarea_input(assigns) do
      ~H"""
      <.input name="bio" label="Bio" type="textarea" value={@value} rows="4" />
      """
    end

    def checkbox_input(assigns) do
      ~H"""
      <.input
        name="remember_me"
        label="Remember me"
        type="checkbox"
        value={@value}
        checked={@checked}
        disabled={@disabled}
      />
      """
    end

    def affixes(assigns) do
      ~H"""
      <.input name="search" label="Search" value={@value}>
        <:outer_prefix><span data-test="outer-prefix">https://</span></:outer_prefix>
        <:inner_prefix><span data-test="inner-prefix">@</span></:inner_prefix>
        <:inner_suffix><span data-test="inner-suffix">.com</span></:inner_suffix>
        <:outer_suffix><button type="button">Open</button></:outer_suffix>
      </.input>
      """
    end

    def classed_affixes(assigns) do
      ~H"""
      <.input name="search" label="Search">
        <:outer_prefix class="affix-outer-prefix">https://</:outer_prefix>
        <:inner_prefix class="affix-inner-prefix">@</:inner_prefix>
        <:inner_suffix class="affix-inner-suffix">.com</:inner_suffix>
        <:outer_suffix class="affix-outer-suffix">Open</:outer_suffix>
      </.input>
      """
    end

    def checkbox_affixes(assigns) do
      ~H"""
      <.input name="remember_me" type="checkbox" label="Remember me">
        <:inner_prefix>inside</:inner_prefix>
        <:outer_suffix>outside</:outer_suffix>
      </.input>
      """
    end

    def hidden(assigns) do
      ~H"""
      <.input name="token" type="hidden" value={@value} />
      """
    end
  end

  @defaults %{
    id: nil,
    name: nil,
    label: nil,
    value: nil,
    type: "text",
    errors: [],
    hint: nil,
    class: nil,
    error_class: nil,
    disabled: false,
    readonly: false,
    describedby: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.text_input/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp control(html), do: LazyHTML.query(html, ~s([data-part="control"]))
  defp control_attr(html, name), do: LazyHTML.attribute(control(html), name)
  defp label(html), do: LazyHTML.query(html, ~s([data-part="label"]))

  describe "text input" do
    test "renders the field, label, and a native control" do
      html = render(id: "user_email", name: "user[email]", label: "Email", value: "a@b.test")

      assert root_attr(html, "data-element") == ["input"]
      assert root_attr(html, "data-type") == ["text"]
      assert root_attr(html, "data-invalid") == []
      assert root_attr(html, "data-disabled") == []

      assert LazyHTML.attribute(label(html), "for") == ["user_email"]
      assert LazyHTML.text(label(html)) =~ "Email"

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="label_text"]))) |> String.trim() ==
               "Email"

      assert Enum.count(LazyHTML.query(label(html), ~s([data-part="control"]))) == 1

      assert LazyHTML.tag(control(html)) == ["input"]
      assert control_attr(html, "type") == ["text"]
      assert control_attr(html, "id") == ["user_email"]
      assert control_attr(html, "name") == ["user[email]"]
      assert control_attr(html, "value") == ["a@b.test"]
      assert control_attr(html, "aria-invalid") == []
    end

    test "renders the control even without a label or id" do
      html = render()

      assert control_attr(html, "type") == ["text"]
      assert control_attr(html, "id") == []
      assert Enum.count(label(html)) == 1
    end

    test "puts the caller class and error_class on the native control" do
      html = render(class: "input")
      assert control_attr(html, "class") == ["input"]

      html = render(class: "input", errors: ["is invalid"], error_class: "is-invalid")
      assert control_attr(html, "class") == ["input is-invalid"]
    end

    test "passes native and LiveView attributes through to the control" do
      html =
        render_component(&TestComponent.passthrough/1, %{}) |> LazyHTML.from_fragment()

      assert control_attr(html, "placeholder") == ["Search"]
      assert control_attr(html, "required") == [""]
      assert control_attr(html, "phx-change") == ["search"]
      assert control_attr(html, "phx-debounce") == ["200"]
      assert control_attr(html, "autocomplete") == ["off"]
    end
  end

  describe "field structs" do
    test "derives id, name, and value from the field" do
      form = Phoenix.Component.to_form(%{"email" => "a@b.test"}, as: :user)

      html =
        render_component(&TestComponent.field/1, %{
          field: form[:email],
          type: "email",
          label: "Email",
          hint: nil
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "id") == ["user_email"]
      assert control_attr(html, "name") == ["user[email]"]
      assert control_attr(html, "value") == ["a@b.test"]
      assert control_attr(html, "type") == ["email"]
    end

    test "a multiple field derives a bracketed name" do
      form = Phoenix.Component.to_form(%{"tags" => ["a"]}, as: :post)

      html =
        render_component(&TestComponent.multiple_field/1, %{field: form[:tags]})
        |> LazyHTML.from_fragment()

      assert control_attr(html, "name") == ["post[tags][]"]
      assert control_attr(html, "multiple") == [""]
    end

    test "hides field errors until the field has been used" do
      form =
        Phoenix.Component.to_form(%{},
          as: :user,
          errors: [email: {"can't be blank", [validation: :required]}]
        )

      html =
        render_component(&TestComponent.field/1, %{
          field: form[:email],
          type: "email",
          label: "Email",
          hint: nil
        })
        |> LazyHTML.from_fragment()

      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
      assert root_attr(html, "data-invalid") == []
    end

    test "renders field errors once the field has been used" do
      form =
        Phoenix.Component.to_form(%{"email" => ""},
          as: :user,
          errors: [email: {"can't be blank", [validation: :required]}]
        )

      html =
        render_component(&TestComponent.field/1, %{
          field: form[:email],
          type: "email",
          label: "Email",
          hint: nil
        })
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == [""]
      assert control_attr(html, "aria-invalid") == ["true"]
      assert control_attr(html, "aria-describedby") == ["user_email-error-1"]
      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) =~ "can't be blank"
    end

    test "an explicit id wins over the field id" do
      form = Phoenix.Component.to_form(%{"email" => "a@b.test"}, as: :user)

      html =
        render_component(&TestComponent.field_with_id/1, %{field: form[:email]})
        |> LazyHTML.from_fragment()

      assert control_attr(html, "id") == ["custom-email"]
    end
  end

  describe "errors and hint" do
    test "renders every error with an id and links it to the control" do
      html =
        render(
          id: "email",
          errors: ["is invalid", "is already taken"],
          hint: "Use your work address"
        )

      errors = LazyHTML.query(html, ~s([data-part="error"]))

      assert Enum.count(errors) == 2

      assert LazyHTML.attribute(LazyHTML.query(html, ~s(#email-error-1)), "id") ==
               ["email-error-1"]

      assert LazyHTML.attribute(LazyHTML.query(html, ~s(#email-error-2)), "id") ==
               ["email-error-2"]

      assert LazyHTML.text(LazyHTML.query(html, ~s(#email-error-1))) |> String.trim() ==
               "is invalid"

      assert LazyHTML.text(LazyHTML.query(html, ~s(#email-error-2))) |> String.trim() ==
               "is already taken"

      hint = LazyHTML.query(html, ~s([data-part="hint"]))
      assert LazyHTML.attribute(hint, "id") == ["email-hint"]
      assert LazyHTML.text(hint) |> String.trim() == "Use your work address"

      assert control_attr(html, "aria-describedby") == [
               "email-hint email-error-1 email-error-2"
             ]

      assert control_attr(html, "aria-invalid") == ["true"]
    end

    test "prefixes every error with a decorative warning icon" do
      html = render(id: "email", errors: ["is invalid", "is already taken"])

      icons = LazyHTML.query(html, ~s([data-part="error"] > [data-part="error_icon"]))

      assert Enum.count(icons) == 2
      assert LazyHTML.attribute(icons, "aria-hidden") == ["true", "true"]
      assert LazyHTML.attribute(icons, "focusable") == ["false", "false"]
      assert LazyHTML.text(icons) |> String.trim() == ""
      assert LazyHTML.query(html, ~s([data-part="error_icon"] path)) != []
    end

    test "appends generated ids to a caller-supplied aria-describedby" do
      html = render(id: "email", describedby: "hint", errors: ["is invalid"])

      assert control_attr(html, "aria-describedby") == ["hint email-error-1"]
    end

    test "interpolates raw error tuples" do
      html = render(errors: [{"should be at most %{count} characters", [count: 5]}])

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) |> String.trim() ==
               "should be at most 5 characters"
    end

    test "uses the configured translator for error tuples" do
      Application.put_env(:flint_ui, :translate_error, {__MODULE__, :translate, []})

      try do
        html = render(errors: [{"raw", []}])

        assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) |> String.trim() ==
                 "translated raw"
      after
        Application.delete_env(:flint_ui, :translate_error)
      end
    end

    test "does not link errors without an id" do
      html = render(errors: ["is invalid"])

      assert control_attr(html, "aria-describedby") == []
      assert LazyHTML.attribute(LazyHTML.query(html, ~s([data-part="error"])), "id") == []
    end
  end

  def translate({message, _opts}), do: "translated " <> message

  describe "disabled and readonly" do
    test "reflects both states on the root and the native control" do
      html = render(disabled: true, readonly: true)

      assert root_attr(html, "data-disabled") == [""]
      assert root_attr(html, "data-readonly") == [""]
      assert control_attr(html, "disabled") == [""]
      assert control_attr(html, "readonly") == [""]
    end
  end

  describe "select" do
    test "renders options, prompt, and the selected value" do
      html =
        render_component(&TestComponent.select/1, %{
          name: "role",
          label: "Role",
          value: "user",
          prompt: "Select a role",
          multiple: false
        })
        |> LazyHTML.from_fragment()

      assert LazyHTML.tag(control(html)) == ["select"]
      assert control_attr(html, "name") == ["role"]
      assert control_attr(html, "multiple") == []

      assert Enum.count(LazyHTML.query(html, "option")) == 3
      assert LazyHTML.text(LazyHTML.query(html, ~s(option[value=""]))) == "Select a role"

      assert LazyHTML.attribute(LazyHTML.query(html, ~s(option[value="user"])), "selected") == [
               ""
             ]

      indicator = LazyHTML.query(html, ~s([data-part="select_indicator"]))
      assert LazyHTML.tag(indicator) == ["span"]
      assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]
      assert Enum.count(LazyHTML.query(indicator, "svg path")) == 1
    end

    test "renders a multiple select" do
      html =
        render_component(&TestComponent.select/1, %{
          name: "roles",
          label: "Roles",
          value: ["admin"],
          prompt: nil,
          multiple: true
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "multiple") == [""]

      assert LazyHTML.attribute(LazyHTML.query(html, ~s(option[value="admin"])), "selected") == [
               ""
             ]

      assert Enum.count(LazyHTML.query(html, ~s([data-part="select_indicator"]))) == 0
    end

    test "the prompt is optional" do
      html =
        render_component(&TestComponent.select/1, %{
          name: "role",
          label: "Role",
          value: nil,
          prompt: nil,
          multiple: false
        })
        |> LazyHTML.from_fragment()

      assert Enum.count(LazyHTML.query(html, "option")) == 2
    end
  end

  describe "textarea" do
    test "renders the value and native attributes" do
      html =
        render_component(&TestComponent.textarea_input/1, %{value: "Hello"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.tag(control(html)) == ["textarea"]
      assert control_attr(html, "rows") == ["4"]
      assert LazyHTML.text(control(html)) |> String.trim() == "Hello"
    end
  end

  describe "checkbox" do
    test "renders the hidden false input and the visible checkbox" do
      html =
        render_component(&TestComponent.checkbox_input/1, %{
          value: nil,
          checked: nil,
          disabled: false
        })
        |> LazyHTML.from_fragment()

      hidden = LazyHTML.query(html, ~s(input[type="hidden"]))
      assert LazyHTML.attribute(hidden, "name") == ["remember_me"]
      assert LazyHTML.attribute(hidden, "value") == ["false"]

      assert control_attr(html, "type") == ["checkbox"]
      assert control_attr(html, "name") == ["remember_me"]
      assert control_attr(html, "value") == ["true"]
      assert control_attr(html, "checked") == []

      indicator = LazyHTML.query(html, ~s([data-part="indicator"]))
      assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]

      check = LazyHTML.query(html, ~s([data-part="indicator"] > [data-part="check"]))
      assert LazyHTML.attribute(check, "aria-hidden") == ["true"]
      assert Enum.count(LazyHTML.query(check, "path")) == 2

      assert LazyHTML.text(label(html)) =~ "Remember me"
    end

    test "checks the box from the value" do
      html =
        render_component(&TestComponent.checkbox_input/1, %{
          value: true,
          checked: nil,
          disabled: false
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "checked") == [""]
    end

    test "explicit checked wins over the value" do
      html =
        render_component(&TestComponent.checkbox_input/1, %{
          value: true,
          checked: false,
          disabled: false
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "checked") == []
    end

    test "forwards disabled to both inputs" do
      html =
        render_component(&TestComponent.checkbox_input/1, %{
          value: nil,
          checked: nil,
          disabled: true
        })
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(LazyHTML.query(html, ~s(input[type="hidden"])), "disabled") == [
               ""
             ]

      assert control_attr(html, "disabled") == [""]
      assert root_attr(html, "data-disabled") == [""]
    end
  end

  describe "hidden" do
    test "renders only the input" do
      html =
        render_component(&TestComponent.hidden/1, %{value: "abc"}) |> LazyHTML.from_fragment()

      assert Enum.count(LazyHTML.query(html, ~s([data-part="label"]))) == 0
      assert Enum.count(LazyHTML.query(html, ~s([data-part="control"]))) == 0

      input = LazyHTML.query(html, ~s(input[type="hidden"]))
      assert LazyHTML.attribute(input, "name") == ["token"]
      assert LazyHTML.attribute(input, "value") == ["abc"]
      assert LazyHTML.attribute(input, "data-element") == ["input"]
      assert LazyHTML.attribute(input, "data-type") == ["hidden"]
    end
  end

  describe "prefix and suffix slots" do
    test "renders the four slots around the native control" do
      html =
        render_component(&TestComponent.affixes/1, %{value: "ada"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="outer_prefix"]))) |> String.trim() ==
               "https://"

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="inner_prefix"]))) |> String.trim() ==
               "@"

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="inner_suffix"]))) |> String.trim() ==
               ".com"

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="outer_suffix"]))) |> String.trim() ==
               "Open"

      assert Enum.count(LazyHTML.query(html, ~s([data-part="outer_suffix"] button))) == 1
      assert Enum.count(LazyHTML.query(label(html), ~s([data-part="outer_suffix"]))) == 0
      assert Enum.count(LazyHTML.query(label(html), ~s([data-part="inner_prefix"]))) == 1

      assert Enum.count(
               LazyHTML.query(
                 html,
                 ~s([data-part="row"] > [data-part="outer_prefix"] + [data-part="label"])
               )
             ) == 1

      assert Enum.count(
               LazyHTML.query(
                 html,
                 ~s([data-part="box"] > [data-part="inner_prefix"] + [data-part="control"] + [data-part="inner_suffix"])
               )
             ) == 1

      assert Enum.count(LazyHTML.query(html, ~s([data-part="control"][name="search"]))) == 1
    end

    test "omits the slot wrappers when the slots are absent" do
      html = render()

      for part <- ~w(outer_prefix inner_prefix inner_suffix outer_suffix) do
        assert Enum.count(LazyHTML.query(html, ~s([data-part="#{part}"]))) == 0
      end

      assert Enum.count(LazyHTML.query(html, ~s([data-part="row"]))) == 1
      assert Enum.count(LazyHTML.query(html, ~s([data-part="box"]))) == 1
    end

    test "puts each slot's class on the wrapper it renders" do
      html =
        render_component(&TestComponent.classed_affixes/1, %{}) |> LazyHTML.from_fragment()

      for part <- ~w(outer_prefix inner_prefix inner_suffix outer_suffix) do
        class = "affix-" <> String.replace(part, "_", "-")

        assert LazyHTML.attribute(LazyHTML.query(html, ~s([data-part="#{part}"])), "class") == [
                 class
               ]
      end
    end

    test "checkbox and hidden inputs do not render the slots" do
      html =
        render_component(&TestComponent.checkbox_affixes/1, %{}) |> LazyHTML.from_fragment()

      refute LazyHTML.text(html) =~ "inside"
      refute LazyHTML.text(html) =~ "outside"
      assert Enum.count(LazyHTML.query(html, ~s([data-part="row"]))) == 0
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :input, type: :form} = FlintUI.Base.Input.meta()

      parts = FlintUI.Base.Input.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert %FlintUI.Meta.PartAttr{value: "input"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:control], &(&1.name == "aria-describedby"))
      assert Enum.any?(parts[:check], &(&1.name == "aria-hidden"))
      assert Enum.any?(parts[:error], &(&1.name == "id"))
      assert Enum.any?(parts[:error_icon], &(&1.name == "aria-hidden"))
      assert Enum.any?(parts[:indicator], &(&1.name == "aria-hidden"))

      for part <- ~w(row outer_prefix label_text box inner_prefix inner_suffix outer_suffix) do
        assert Keyword.has_key?(parts, String.to_existing_atom(part))
      end
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.Input.keyboard(), &(&1.keys == "Tab"))

      assert Enum.any?(
               FlintUI.Base.Input.states(),
               &(&1.name == "invalid" and &1.selector =~ ~s([data-element="input"]))
             )
    end
  end
end
