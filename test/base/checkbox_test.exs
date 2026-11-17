defmodule FlintUI.Base.CheckboxTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.checkbox
        id={@id}
        name={@name}
        label={@label}
        sublabel={@sublabel}
        value={@value}
        checked={@checked}
        indeterminate={@indeterminate}
        checked_value={@checked_value}
        unchecked_value={@unchecked_value}
        hint={@hint}
        errors={@errors}
        disabled={@disabled}
        required={@required}
        class={@class}
      />
      """
    end

    def with_value(assigns) do
      ~H"""
      <.checkbox
        name="role"
        label="Admin"
        value={@value}
        checked_value="admin"
        unchecked_value=""
      />
      """
    end

    def field(assigns) do
      ~H"""
      <.checkbox field={@field} label="Terms" hint="The small print." />
      """
    end

    def field_checked(assigns) do
      ~H"""
      <.checkbox field={@field} checked={@checked} label="Terms" />
      """
    end

    def no_mirror(assigns) do
      ~H"""
      <.checkbox name="remember" label="Remember me" unchecked_value={nil} />
      """
    end

    def inner_block(assigns) do
      ~H"""
      <.checkbox name="terms" label="Ignored">
        <strong>I accept the terms</strong>
      </.checkbox>
      """
    end

    def group_basic(assigns) do
      ~H"""
      <.checkbox_group
        id={@id}
        name={@name}
        label={@label}
        hint={@hint}
        value={@value}
        errors={@errors}
        disabled={@disabled}
        required={@required}
      >
        <:checkbox value="elixir" label="Elixir" sublabel="Recommended" />
        <:checkbox value="rust" label="Rust" />
        <:checkbox value="typescript" label="TypeScript" disabled />
      </.checkbox_group>
      """
    end

    def group_field(assigns) do
      ~H"""
      <.checkbox_group field={@field} label="Languages" hint="Pick a few.">
        <:checkbox value="elixir" label="Elixir" />
        <:checkbox value="rust" label="Rust" />
      </.checkbox_group>
      """
    end

    def group_checked_override(assigns) do
      ~H"""
      <.checkbox_group name="languages" value={["elixir"]}>
        <:checkbox value="elixir" label="Elixir" checked={false} />
        <:checkbox value="rust" label="Rust" checked={true} />
      </.checkbox_group>
      """
    end

    def group_inner_block(assigns) do
      ~H"""
      <.checkbox_group name="languages">
        <:checkbox value="elixir" label="Ignored">
          <strong>Elixir</strong>
        </:checkbox>
      </.checkbox_group>
      """
    end
  end

  @defaults %{
    id: "terms",
    name: "terms",
    label: "I accept the terms",
    sublabel: nil,
    value: nil,
    checked: nil,
    indeterminate: false,
    checked_value: "true",
    unchecked_value: "false",
    hint: nil,
    errors: [],
    disabled: false,
    required: false,
    class: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp control(html), do: LazyHTML.query(html, ~s([data-part="control"]))
  defp control_attr(html, name), do: LazyHTML.attribute(control(html), name)
  defp label(html), do: LazyHTML.query(html, ~s([data-part="label"]))
  defp hidden(html), do: LazyHTML.query(html, ~s(input[type="hidden"]))

  defp group_root(html),
    do: LazyHTML.query(html, ~s(fieldset[data-element="checkbox_group"]))

  defp group_root_attr(html, name), do: LazyHTML.attribute(group_root(html), name)

  describe "standalone checkbox" do
    test "renders the field, label, indicator, and native control" do
      html = render()

      assert root_attr(html, "data-element") == ["checkbox"]
      assert root_attr(html, "data-disabled") == []
      assert root_attr(html, "data-invalid") == []
      assert root_attr(html, "data-required") == []

      assert LazyHTML.attribute(label(html), "for") == ["terms"]
      assert LazyHTML.text(label(html)) =~ "I accept the terms"

      indicator = LazyHTML.query(html, ~s([data-part="indicator"]))
      assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]

      check = LazyHTML.query(html, ~s([data-part="indicator"] > [data-part="check"]))
      assert LazyHTML.attribute(check, "aria-hidden") == ["true"]
      assert Enum.count(LazyHTML.query(check, "path")) == 2

      assert LazyHTML.tag(control(html)) == ["input"]
      assert control_attr(html, "type") == ["checkbox"]
      assert control_attr(html, "id") == ["terms"]
      assert control_attr(html, "name") == ["terms"]
      assert control_attr(html, "value") == ["true"]
      assert control_attr(html, "checked") == []
    end

    test "renders the hidden unchecked mirror" do
      html = render()

      assert LazyHTML.attribute(hidden(html), "name") == ["terms"]
      assert LazyHTML.attribute(hidden(html), "value") == ["false"]
      assert LazyHTML.attribute(hidden(html), "disabled") == []
    end

    test "renders the sublabel inside the label" do
      html = render(sublabel: "Recommended")

      sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
      assert LazyHTML.text(sublabel) |> String.trim() == "Recommended"
      assert LazyHTML.text(label(html)) =~ "Recommended"
    end

    test "custom inner content replaces the label" do
      html =
        render_component(&TestComponent.inner_block/1, %{}) |> LazyHTML.from_fragment()

      assert LazyHTML.text(label(html)) =~ "I accept the terms"
      refute LazyHTML.text(label(html)) =~ "Ignored"
    end

    test "puts the caller class on the checkbox root" do
      html = render(class: "accent-primary")
      assert root_attr(html, "class") == ["accent-primary"]
      assert control_attr(html, "class") == []
    end
  end

  describe "checked state" do
    test "an explicit checked attribute wins" do
      assert render(checked: true) |> control_attr("checked") == [""]
      assert render(checked: false) |> control_attr("checked") == []
    end

    test "indeterminate is a visual data hook and does not check the box" do
      html = render(indeterminate: true)

      assert control_attr(html, "data-indeterminate") == ["true"]
      assert control_attr(html, "checked") == []
      assert control_attr(html, "value") == ["true"]
      assert LazyHTML.attribute(hidden(html), "value") == ["false"]
    end

    test "indeterminate keeps an explicitly checked submission" do
      html = render(indeterminate: true, checked: true)

      assert control_attr(html, "data-indeterminate") == ["true"]
      assert control_attr(html, "checked") == [""]
    end

    test "omits data-indeterminate when false" do
      assert render() |> control_attr("data-indeterminate") == []
    end

    test "derives the state from value and checked_value" do
      html =
        render_component(&TestComponent.with_value/1, %{value: "admin"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == [""]
      assert LazyHTML.attribute(control(html), "value") == ["admin"]
      assert LazyHTML.attribute(hidden(html), "value") == [""]
    end

    test "a non-matching value stays unchecked" do
      html =
        render_component(&TestComponent.with_value/1, %{value: "user"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == []
    end

    test "a boolean field value checks the box" do
      form = Phoenix.Component.to_form(%{"terms" => true}, as: :user)

      html =
        render_component(&TestComponent.field/1, %{field: form[:terms]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == [""]
      assert LazyHTML.attribute(control(html), "id") == ["user_terms"]
      assert LazyHTML.attribute(control(html), "name") == ["user[terms]"]
      assert LazyHTML.attribute(control(html), "value") == ["true"]
    end

    test "an explicit checked wins over the field value" do
      form = Phoenix.Component.to_form(%{"terms" => false}, as: :user)

      html =
        render_component(&TestComponent.field_checked/1, %{
          field: form[:terms],
          checked: true
        })
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == [""]
    end

    test "unchecked_value nil omits the hidden mirror" do
      html =
        render_component(&TestComponent.no_mirror/1, %{})
        |> LazyHTML.from_fragment()

      assert Enum.count(hidden(html)) == 0
    end
  end

  describe "field structs" do
    test "derives the id and hides unused errors" do
      form =
        Phoenix.Component.to_form(%{},
          as: :user,
          errors: [terms: {"must be accepted", [validation: :acceptance]}]
        )

      html =
        render_component(&TestComponent.field/1, %{field: form[:terms]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "id") == ["user_terms"]
      assert root_attr(html, "data-invalid") == []
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
    end

    test "renders errors once the field has been used" do
      form =
        Phoenix.Component.to_form(%{"terms" => false},
          as: :user,
          errors: [terms: {"must be accepted", [validation: :acceptance]}]
        )

      html =
        render_component(&TestComponent.field/1, %{field: form[:terms]})
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == [""]
      assert LazyHTML.attribute(control(html), "aria-invalid") == ["true"]

      assert LazyHTML.attribute(control(html), "aria-describedby") == [
               "user_terms-hint user_terms-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) =~ "must be accepted"
    end
  end

  describe "errors and hint" do
    test "links every message and the hint to the control" do
      html =
        render(
          errors: ["is invalid", "is already taken"],
          hint: "We only use this for receipts."
        )

      errors = LazyHTML.query(html, ~s([data-part="error"]))
      assert Enum.count(errors) == 2

      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"] > [data-part="error_icon"]))) ==
               2

      assert LazyHTML.attribute(LazyHTML.query(html, "#terms-error-1"), "id") == ["terms-error-1"]

      hint = LazyHTML.query(html, ~s([data-part="hint"]))
      assert LazyHTML.attribute(hint, "id") == ["terms-hint"]

      assert control_attr(html, "aria-describedby") == [
               "terms-hint terms-error-1 terms-error-2"
             ]

      assert control_attr(html, "aria-invalid") == ["true"]
    end

    test "interpolates raw error tuples" do
      html = render(errors: [{"should be at most %{count} characters", [count: 5]}])

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) |> String.trim() ==
               "should be at most 5 characters"
    end
  end

  describe "disabled and required" do
    test "reflects both states on the root, control, and mirror" do
      html = render(disabled: true, required: true)

      assert root_attr(html, "data-disabled") == [""]
      assert root_attr(html, "data-required") == [""]
      assert control_attr(html, "disabled") == [""]
      assert control_attr(html, "required") == [""]
      assert LazyHTML.attribute(hidden(html), "disabled") == [""]
    end
  end

  describe "checkbox group" do
    defp render_group(overrides \\ %{}) do
      assigns =
        Map.merge(
          %{
            id: "languages",
            name: "languages",
            label: "Programming languages",
            hint: nil,
            value: [],
            errors: [],
            disabled: false,
            required: false
          },
          Map.new(overrides)
        )

      render_component(&TestComponent.group_basic/1, assigns) |> LazyHTML.from_fragment()
    end

    test "renders a fieldset, legend, and named options" do
      html = render_group()

      fieldset = LazyHTML.query(html, "fieldset")
      assert LazyHTML.attribute(fieldset, "data-element") == ["checkbox_group"]
      assert LazyHTML.attribute(fieldset, "data-part") == ["root"]

      legend = LazyHTML.query(html, "legend")
      assert LazyHTML.text(legend) |> String.trim() == "Programming languages"

      options = LazyHTML.query(html, ~s([data-part="options"] [data-element="checkbox"]))
      assert Enum.count(options) == 3

      names = Enum.map(control(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["languages[]"], ["languages[]"], ["languages[]"]]
      assert hidden(html) |> LazyHTML.attribute("name") == ["languages[]"]
      assert hidden(html) |> LazyHTML.attribute("value") == [""]
      assert hidden(html) |> LazyHTML.attribute("type") == ["hidden"]
    end

    test "appends the list suffix only once" do
      html = render_group(name: "languages[]")

      names = Enum.map(control(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["languages[]"], ["languages[]"], ["languages[]"]]
    end

    test "checks the options in the value list" do
      html = render_group(value: ["elixir", "typescript"])

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      values = Enum.map(checked, &LazyHTML.attribute(&1, "value"))
      assert values == [["elixir"], ["typescript"]]
    end

    test "an option's checked attribute wins over membership" do
      html =
        render_component(&TestComponent.group_checked_override/1, %{})
        |> LazyHTML.from_fragment()

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["rust"]]
    end

    test "renders option ids from the group id" do
      html = render_group()
      ids = Enum.map(control(html), &LazyHTML.attribute(&1, "id"))
      assert ids == [["languages-0"], ["languages-1"], ["languages-2"]]
    end

    test "renders option sublabels and inner content" do
      html = render_group()
      sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
      assert LazyHTML.text(sublabel) |> String.trim() == "Recommended"

      html =
        render_component(&TestComponent.group_inner_block/1, %{})
        |> LazyHTML.from_fragment()

      assert LazyHTML.text(LazyHTML.query(html, "label")) =~ "Elixir"
      refute LazyHTML.text(LazyHTML.query(html, "label")) =~ "Ignored"
    end

    test "a disabled group disables the fieldset and mirror" do
      html = render_group(disabled: true)

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "disabled") == [""]
      assert hidden(html) |> LazyHTML.attribute("disabled") == [""]
      assert group_root_attr(html, "data-disabled") == [""]
    end

    test "an option can be disabled on its own" do
      html = render_group()

      disabled =
        LazyHTML.query(html, ~s([data-part="control"][value="typescript"]))

      assert LazyHTML.attribute(disabled, "disabled") == [""]
    end

    test "required is exposed on the group" do
      html = render_group(required: true)

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "aria-required") == ["true"]
      assert group_root_attr(html, "data-required") == [""]
    end

    test "renders group errors and links them to the fieldset" do
      html = render_group(errors: ["pick at least one"], hint: "Pick a few.")

      fieldset = LazyHTML.query(html, "fieldset")
      assert LazyHTML.attribute(fieldset, "aria-invalid") == ["true"]

      assert LazyHTML.attribute(fieldset, "aria-describedby") == [
               "languages-hint languages-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, "#languages-error-1")) |> String.trim() ==
               "pick at least one"

      assert LazyHTML.query(html, ~s(#languages-error-1 [data-part="error_icon"])) != []
    end

    test "derives the group from a field" do
      form = Phoenix.Component.to_form(%{"languages" => ["rust"]}, as: :user)

      html =
        render_component(&TestComponent.group_field/1, %{field: form[:languages]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "data-part") == ["root"]
      names = Enum.map(control(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["user[languages][]"], ["user[languages][]"]]

      assert Enum.map(control(html), &LazyHTML.attribute(&1, "id")) ==
               [["user_languages-0"], ["user_languages-1"]]

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["rust"]]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :checkbox, type: :form} = FlintUI.Base.Checkbox.meta()

      parts = FlintUI.Base.Checkbox.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert %FlintUI.Meta.PartAttr{value: "checkbox"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:control], &(&1.name == "aria-describedby"))
      assert Enum.any?(parts[:control], &(&1.name == "[data-indeterminate]"))
      assert Enum.any?(parts[:check], &(&1.name == "aria-hidden"))
      assert Enum.any?(parts[:sublabel], &(&1.name == "[data-part]"))
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.Checkbox.keyboard(), &(&1.keys == "Space"))

      assert Enum.any?(
               FlintUI.Base.Checkbox.states(),
               &(&1.name == "disabled" and &1.selector =~ ~s([data-element="checkbox"]))
             )

      assert Enum.any?(
               FlintUI.Base.Checkbox.states(),
               &(&1.name == "indeterminate" and &1.selector =~ "data-indeterminate")
             )
    end

    test "the group declares its own contract" do
      assert %FlintUI.Meta{name: :checkbox_group, type: :form} =
               FlintUI.Base.CheckboxGroup.meta()

      parts = FlintUI.Base.CheckboxGroup.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert Enum.map(parts, &elem(&1, 0)) ==
               [:root, :label, :options, :hint, :error, :error_icon]
    end
  end
end
