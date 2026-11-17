defmodule FlintUI.Base.SwitchTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.switch
        id={@id}
        name={@name}
        label={@label}
        sublabel={@sublabel}
        value={@value}
        checked={@checked}
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
      <.switch
        name="notifications"
        label="Notifications"
        value={@value}
        checked_value="on"
        unchecked_value=""
      />
      """
    end

    def field_switch(assigns) do
      ~H"""
      <.switch field={@field} label="Notifications" hint="Account and security updates." />
      """
    end

    def field_checked(assigns) do
      ~H"""
      <.switch field={@field} checked={@checked} label="Notifications" />
      """
    end

    def no_mirror(assigns) do
      ~H"""
      <.switch name="remember" label="Remember me" unchecked_value={nil} />
      """
    end

    def inner_block(assigns) do
      ~H"""
      <.switch name="notifications" label="Ignored">
        <strong>Enable notifications</strong>
      </.switch>
      """
    end
  end

  @defaults %{
    id: "notifications",
    name: "notifications",
    label: "Enable notifications",
    sublabel: nil,
    value: nil,
    checked: nil,
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

  describe "standalone switch" do
    test "renders the field, label, track, thumb, and native control" do
      html = render()

      assert root_attr(html, "data-element") == ["switch"]
      assert root_attr(html, "data-disabled") == []
      assert root_attr(html, "data-invalid") == []
      assert root_attr(html, "data-required") == []

      assert LazyHTML.attribute(label(html), "for") == ["notifications"]
      assert LazyHTML.text(label(html)) =~ "Enable notifications"

      indicator = LazyHTML.query(html, ~s([data-part="indicator"]))
      assert LazyHTML.attribute(indicator, "aria-hidden") == []

      thumb = LazyHTML.query(html, ~s([data-part="indicator"] > [data-part="thumb"]))
      assert LazyHTML.attribute(thumb, "aria-hidden") == ["true"]

      assert LazyHTML.tag(control(html)) == ["input"]
      assert control_attr(html, "type") == ["checkbox"]
      assert control_attr(html, "role") == ["switch"]
      assert control_attr(html, "id") == ["notifications"]
      assert control_attr(html, "name") == ["notifications"]
      assert control_attr(html, "value") == ["true"]
      assert control_attr(html, "checked") == []
    end

    test "renders the hidden off mirror" do
      html = render()

      assert LazyHTML.attribute(hidden(html), "name") == ["notifications"]
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

      assert LazyHTML.text(label(html)) =~ "Enable notifications"
      refute LazyHTML.text(label(html)) =~ "Ignored"
    end

    test "puts the caller class on the switch root" do
      html = render(class: "accent-primary")
      assert root_attr(html, "class") == ["accent-primary"]
      assert control_attr(html, "class") == []
    end
  end

  describe "on state" do
    test "an explicit checked attribute wins" do
      assert render(checked: true) |> control_attr("checked") == [""]
      assert render(checked: false) |> control_attr("checked") == []
    end

    test "derives the state from value and checked_value" do
      html =
        render_component(&TestComponent.with_value/1, %{value: "on"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == [""]
      assert LazyHTML.attribute(control(html), "value") == ["on"]
      assert LazyHTML.attribute(hidden(html), "value") == [""]
    end

    test "a non-matching value stays off" do
      html =
        render_component(&TestComponent.with_value/1, %{value: "off"})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == []
    end

    test "a boolean field value turns the switch on" do
      form = Phoenix.Component.to_form(%{"notifications" => true}, as: :user)

      html =
        render_component(&TestComponent.field_switch/1, %{field: form[:notifications]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "checked") == [""]
      assert LazyHTML.attribute(control(html), "id") == ["user_notifications"]
      assert LazyHTML.attribute(control(html), "name") == ["user[notifications]"]
      assert LazyHTML.attribute(control(html), "value") == ["true"]
    end

    test "an explicit checked wins over the field value" do
      form = Phoenix.Component.to_form(%{"notifications" => false}, as: :user)

      html =
        render_component(&TestComponent.field_checked/1, %{
          field: form[:notifications],
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
          errors: [notifications: {"must be enabled", [validation: :acceptance]}]
        )

      html =
        render_component(&TestComponent.field_switch/1, %{field: form[:notifications]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(control(html), "id") == ["user_notifications"]
      assert root_attr(html, "data-invalid") == []
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
    end

    test "renders errors once the field has been used" do
      form =
        Phoenix.Component.to_form(%{"notifications" => false},
          as: :user,
          errors: [notifications: {"must be enabled", [validation: :acceptance]}]
        )

      html =
        render_component(&TestComponent.field_switch/1, %{field: form[:notifications]})
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == [""]
      assert LazyHTML.attribute(control(html), "aria-invalid") == ["true"]

      assert LazyHTML.attribute(control(html), "aria-describedby") == [
               "user_notifications-hint user_notifications-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) =~
               "must be enabled"
    end
  end

  describe "errors and hint" do
    test "links every message and the hint to the control" do
      html =
        render(
          errors: ["must be enabled", "is not available"],
          hint: "Only administrators can change this."
        )

      errors = LazyHTML.query(html, ~s([data-part="error"]))
      assert Enum.count(errors) == 2

      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"] > [data-part="error_icon"]))) ==
               2

      assert LazyHTML.attribute(LazyHTML.query(html, "#notifications-error-1"), "id") == [
               "notifications-error-1"
             ]

      hint = LazyHTML.query(html, ~s([data-part="hint"]))
      assert LazyHTML.attribute(hint, "id") == ["notifications-hint"]

      assert control_attr(html, "aria-describedby") == [
               "notifications-hint notifications-error-1 notifications-error-2"
             ]

      assert control_attr(html, "aria-invalid") == ["true"]
    end

    test "interpolates raw error tuples" do
      html = render(errors: [{"must be on for %{role} accounts", [role: "admin"]}])

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) |> String.trim() ==
               "must be on for admin accounts"
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

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :switch, type: :form} = FlintUI.Base.Switch.meta()

      parts = FlintUI.Base.Switch.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert %FlintUI.Meta.PartAttr{value: "switch"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:control], &(&1.name == "role" and &1.value == ~s("switch")))
      assert Enum.any?(parts[:control], &(&1.name == "aria-describedby"))
      assert Enum.any?(parts[:thumb], &(&1.name == "aria-hidden"))
      assert Enum.any?(parts[:sublabel], &(&1.name == "[data-part]"))
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.Switch.keyboard(), &(&1.keys == "Space"))

      assert Enum.any?(
               FlintUI.Base.Switch.states(),
               &(&1.name == "disabled" and &1.selector =~ ~s([data-element="switch"]))
             )
    end
  end
end
