defmodule FlintUI.Base.RadioTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.radio
        id={@id}
        name={@name}
        value={@value}
        label={@label}
        sublabel={@sublabel}
        checked={@checked}
        hint={@hint}
        errors={@errors}
        disabled={@disabled}
        required={@required}
        class={@class}
      />
      """
    end

    def field_radio(assigns) do
      ~H"""
      <.radio
        field={@field}
        value={@value}
        label={@label}
        hint="Choose carefully."
      />
      """
    end

    def field_checked(assigns) do
      ~H"""
      <.radio field={@field} value="pro" checked={@checked} label="Pro" />
      """
    end

    def inner_block(assigns) do
      ~H"""
      <.radio name="plan" value="pro" label="Ignored">
        <strong>Pro plan</strong>
      </.radio>
      """
    end

    def group_basic(assigns) do
      ~H"""
      <.radio_group
        id={@id}
        name={@name}
        label={@label}
        hint={@hint}
        value={@value}
        errors={@errors}
        disabled={@disabled}
        required={@required}
      >
        <:radio value="free" label="Free" sublabel="Recommended" />
        <:radio value="pro" label="Pro" />
        <:radio value="team" label="Team" disabled />
      </.radio_group>
      """
    end

    def group_field(assigns) do
      ~H"""
      <.radio_group field={@field} label="Plan" hint="Pick one.">
        <:radio value="free" label="Free" />
        <:radio value="pro" label="Pro" />
      </.radio_group>
      """
    end

    def group_checked_override(assigns) do
      ~H"""
      <.radio_group name="plan" value="free">
        <:radio value="free" label="Free" checked={false} />
        <:radio value="pro" label="Pro" checked={true} />
      </.radio_group>
      """
    end

    def group_inner_block(assigns) do
      ~H"""
      <.radio_group name="plan">
        <:radio value="pro" label="Ignored">
          <strong>Pro plan</strong>
        </:radio>
      </.radio_group>
      """
    end
  end

  @defaults %{
    id: "plan-pro",
    name: "plan",
    value: "pro",
    label: "Pro",
    sublabel: nil,
    checked: nil,
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

  defp group_root(html), do: LazyHTML.query(html, ~s(fieldset[data-element="radio_group"]))
  defp group_root_attr(html, name), do: LazyHTML.attribute(group_root(html), name)

  describe "standalone radio" do
    test "renders the field, label, indicator, and native control" do
      html = render()

      assert root_attr(html, "data-element") == ["radio"]
      assert root_attr(html, "data-disabled") == []
      assert root_attr(html, "data-invalid") == []
      assert root_attr(html, "data-required") == []

      assert LazyHTML.attribute(label(html), "for") == ["plan-pro"]
      assert LazyHTML.text(label(html)) =~ "Pro"

      indicator = LazyHTML.query(html, ~s([data-part="indicator"]))
      assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]

      assert LazyHTML.tag(control(html)) == ["input"]
      assert control_attr(html, "type") == ["radio"]
      assert control_attr(html, "id") == ["plan-pro"]
      assert control_attr(html, "name") == ["plan"]
      assert control_attr(html, "value") == ["pro"]
      assert control_attr(html, "checked") == []
    end

    test "renders no hidden unchecked mirror" do
      assert Enum.count(hidden(render())) == 0
    end

    test "renders the sublabel inside the label" do
      html = render(sublabel: "Recommended")

      sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
      assert LazyHTML.text(sublabel) |> String.trim() == "Recommended"
      assert LazyHTML.text(label(html)) =~ "Recommended"
    end

    test "custom inner content replaces the label" do
      html = render_component(&TestComponent.inner_block/1, %{}) |> LazyHTML.from_fragment()

      assert LazyHTML.text(label(html)) =~ "Pro plan"
      refute LazyHTML.text(label(html)) =~ "Ignored"
    end

    test "puts the caller class on the radio root" do
      html = render(class: "accent-primary")
      assert root_attr(html, "class") == ["accent-primary"]
      assert control_attr(html, "class") == []
    end
  end

  describe "selected state" do
    test "an explicit checked attribute wins" do
      assert render(checked: true) |> control_attr("checked") == [""]
      assert render(checked: false) |> control_attr("checked") == []
    end

    test "checks itself against the field's current value" do
      form = Phoenix.Component.to_form(%{"plan" => "pro"}, as: :user)

      html =
        render_component(&TestComponent.field_radio/1, %{
          field: form[:plan],
          value: "pro",
          label: "Pro"
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "checked") == [""]
      assert control_attr(html, "id") == ["user_plan-pro"]
      assert control_attr(html, "name") == ["user[plan]"]
    end

    test "does not check when the field's value differs" do
      form = Phoenix.Component.to_form(%{"plan" => "free"}, as: :user)

      html =
        render_component(&TestComponent.field_radio/1, %{
          field: form[:plan],
          value: "pro",
          label: "Pro"
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "checked") == []
    end

    test "an explicit checked wins over the field value" do
      form = Phoenix.Component.to_form(%{"plan" => "free"}, as: :user)

      html =
        render_component(&TestComponent.field_checked/1, %{
          field: form[:plan],
          checked: true
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "checked") == [""]
    end
  end

  describe "field structs" do
    test "derives the id and hides unused errors" do
      form =
        Phoenix.Component.to_form(%{},
          as: :user,
          errors: [plan: {"is required", [validation: :required]}]
        )

      html =
        render_component(&TestComponent.field_radio/1, %{
          field: form[:plan],
          value: "pro",
          label: "Pro"
        })
        |> LazyHTML.from_fragment()

      assert control_attr(html, "id") == ["user_plan-pro"]
      assert root_attr(html, "data-invalid") == []
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
    end

    test "renders errors once the field has been used" do
      form =
        Phoenix.Component.to_form(%{"plan" => "pro"},
          as: :user,
          errors: [plan: {"is required", [validation: :required]}]
        )

      html =
        render_component(&TestComponent.field_radio/1, %{
          field: form[:plan],
          value: "pro",
          label: "Pro"
        })
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == [""]
      assert control_attr(html, "aria-invalid") == ["true"]

      assert control_attr(html, "aria-describedby") == [
               "user_plan-pro-hint user_plan-pro-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) =~ "is required"
    end
  end

  describe "errors and hint" do
    test "links every message and the hint to the control" do
      html =
        render(
          errors: ["is invalid", "is not available"],
          hint: "Choose the plan that fits."
        )

      errors = LazyHTML.query(html, ~s([data-part="error"]))
      assert Enum.count(errors) == 2

      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"] > [data-part="error_icon"]))) ==
               2

      assert LazyHTML.attribute(LazyHTML.query(html, "#plan-pro-error-1"), "id") == [
               "plan-pro-error-1"
             ]

      hint = LazyHTML.query(html, ~s([data-part="hint"]))
      assert LazyHTML.attribute(hint, "id") == ["plan-pro-hint"]

      assert control_attr(html, "aria-describedby") == [
               "plan-pro-hint plan-pro-error-1 plan-pro-error-2"
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
    test "reflects both states on the root and control" do
      html = render(disabled: true, required: true)

      assert root_attr(html, "data-disabled") == [""]
      assert root_attr(html, "data-required") == [""]
      assert control_attr(html, "disabled") == [""]
      assert control_attr(html, "required") == [""]
    end
  end

  describe "radio group" do
    defp render_group(overrides \\ %{}) do
      assigns =
        Map.merge(
          %{
            id: "plan",
            name: "plan",
            label: "Plan",
            hint: nil,
            value: nil,
            errors: [],
            disabled: false,
            required: false
          },
          Map.new(overrides)
        )

      render_component(&TestComponent.group_basic/1, assigns) |> LazyHTML.from_fragment()
    end

    test "renders a fieldset, legend, and options without a list suffix" do
      html = render_group()

      fieldset = LazyHTML.query(html, "fieldset")
      assert LazyHTML.attribute(fieldset, "data-element") == ["radio_group"]
      assert LazyHTML.attribute(fieldset, "data-part") == ["root"]

      legend = LazyHTML.query(html, "legend")
      assert LazyHTML.text(legend) |> String.trim() == "Plan"

      options = LazyHTML.query(html, ~s([data-part="options"] [data-element="radio"]))
      assert Enum.count(options) == 3

      names = Enum.map(control(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["plan"], ["plan"], ["plan"]]
    end

    test "renders no hidden empty input" do
      assert Enum.count(hidden(render_group())) == 0
    end

    test "checks only the option matching the group value" do
      html = render_group(value: "pro")

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["pro"]]
    end

    test "an option's checked attribute wins over the group value" do
      html =
        render_component(&TestComponent.group_checked_override/1, %{})
        |> LazyHTML.from_fragment()

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["pro"]]
    end

    test "renders option ids from the group id" do
      html = render_group()
      ids = Enum.map(control(html), &LazyHTML.attribute(&1, "id"))
      assert ids == [["plan-0"], ["plan-1"], ["plan-2"]]
    end

    test "renders option sublabels and inner content" do
      html = render_group()
      sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
      assert LazyHTML.text(sublabel) |> String.trim() == "Recommended"

      html =
        render_component(&TestComponent.group_inner_block/1, %{})
        |> LazyHTML.from_fragment()

      assert LazyHTML.text(LazyHTML.query(html, "label")) =~ "Pro plan"
      refute LazyHTML.text(LazyHTML.query(html, "label")) =~ "Ignored"
    end

    test "a disabled group disables the fieldset and leaves options to the fieldset" do
      html = render_group(disabled: true)

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "disabled") == [""]
      assert group_root_attr(html, "data-disabled") == [""]

      assert control(html)
             |> Enum.take(2)
             |> Enum.map(&LazyHTML.attribute(&1, "disabled")) == [[], []]
    end

    test "an option can be disabled on its own" do
      html = render_group()

      disabled = LazyHTML.query(html, ~s([data-part="control"][value="team"]))

      assert LazyHTML.attribute(disabled, "disabled") == [""]
    end

    test "required is exposed on the group and the native options" do
      html = render_group(required: true)

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "aria-required") == ["true"]
      assert group_root_attr(html, "data-required") == [""]

      for option <- control(html) do
        assert LazyHTML.attribute(option, "required") == [""]
      end
    end

    test "renders group errors and links them to the fieldset" do
      html = render_group(errors: ["pick a plan"], hint: "Choose one.")

      fieldset = LazyHTML.query(html, "fieldset")
      assert LazyHTML.attribute(fieldset, "aria-invalid") == ["true"]

      assert LazyHTML.attribute(fieldset, "aria-describedby") == [
               "plan-hint plan-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, "#plan-error-1")) |> String.trim() ==
               "pick a plan"

      assert LazyHTML.query(html, ~s(#plan-error-1 [data-part="error_icon"])) != []
    end

    test "derives the group from a field" do
      form = Phoenix.Component.to_form(%{"plan" => "pro"}, as: :user)

      html =
        render_component(&TestComponent.group_field/1, %{field: form[:plan]})
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(LazyHTML.query(html, "fieldset"), "data-part") == ["root"]
      names = Enum.map(control(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["user[plan]"], ["user[plan]"]]

      assert Enum.map(control(html), &LazyHTML.attribute(&1, "id")) ==
               [["user_plan-0"], ["user_plan-1"]]

      checked = LazyHTML.query(html, ~s([data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["pro"]]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :radio, type: :form} = FlintUI.Base.Radio.meta()

      parts = FlintUI.Base.Radio.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert %FlintUI.Meta.PartAttr{value: "radio"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:control], &(&1.name == "aria-describedby"))
      assert Enum.any?(parts[:sublabel], &(&1.name == "[data-part]"))
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.Radio.keyboard(), &(&1.keys == "Space"))
      assert Enum.any?(FlintUI.Base.Radio.keyboard(), &(&1.keys == "Arrow keys"))

      assert Enum.any?(
               FlintUI.Base.Radio.states(),
               &(&1.name == "disabled" and &1.selector =~ ~s([data-element="radio"]))
             )
    end

    test "the group declares its own contract" do
      assert %FlintUI.Meta{name: :radio_group, type: :form} = FlintUI.Base.RadioGroup.meta()

      parts = FlintUI.Base.RadioGroup.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert Enum.map(parts, &elem(&1, 0)) ==
               [:root, :label, :options, :hint, :error, :error_icon]
    end
  end
end
