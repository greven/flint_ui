defmodule FlintUI.Base.SwitchGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.switch_group
        id={@id}
        label={@label}
        description={@description}
        errors={@errors}
        disabled={@disabled}
        required={@required}
        class={@class}
      >
        <:switch
          name="notifications[email]"
          label="Email"
          description="Account updates."
          checked
        />
        <:switch name="notifications[sms]" label="SMS" description="Urgent alerts only." />
        <:switch name="notifications[push]" label="Push" disabled />
      </.switch_group>
      """
    end

    def field_group(assigns) do
      ~H"""
      <.switch_group label="Notifications">
        <:switch field={@email} label="Email" />
        <:switch field={@sms} label="SMS" />
      </.switch_group>
      """
    end

    def inner_block(assigns) do
      ~H"""
      <.switch_group label="Notifications">
        <:switch name="notifications[email]" label="Ignored">
          <strong>Email alerts</strong>
        </:switch>
      </.switch_group>
      """
    end
  end

  @defaults %{
    id: "notifications",
    label: "Notifications",
    description: nil,
    errors: [],
    disabled: false,
    required: false,
    class: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp fieldset(html), do: LazyHTML.query(html, "fieldset")
  defp fieldset_attr(html, name), do: LazyHTML.attribute(fieldset(html), name)
  defp switches(html), do: LazyHTML.query(html, ~s([data-part="options"] [data-element="switch"]))
  defp controls(html), do: LazyHTML.query(html, ~s([data-element="switch"] [data-part="control"]))

  describe "switch group" do
    test "renders a fieldset, legend, and one switch per option" do
      html = render()

      assert fieldset_attr(html, "data-element") == ["switch_group"]
      assert fieldset_attr(html, "data-part") == ["root"]
      assert fieldset_attr(html, "data-disabled") == []
      assert fieldset_attr(html, "data-invalid") == []
      assert fieldset_attr(html, "data-required") == []

      assert LazyHTML.text(LazyHTML.query(html, "legend")) |> String.trim() == "Notifications"
      assert Enum.count(switches(html)) == 3

      names = Enum.map(controls(html), &LazyHTML.attribute(&1, "name"))

      assert names == [
               ["notifications[email]"],
               ["notifications[sms]"],
               ["notifications[push]"]
             ]

      assert Enum.all?(controls(html), &(LazyHTML.attribute(&1, "role") == ["switch"]))
    end

    test "derives option ids from the group id and links each description" do
      html = render()

      ids = Enum.map(controls(html), &LazyHTML.attribute(&1, "id"))

      assert ids == [
               ["notifications-0"],
               ["notifications-1"],
               ["notifications-2"]
             ]

      email =
        LazyHTML.query(
          html,
          ~s([data-element="switch"] [data-part="control"][name="notifications[email]"])
        )

      assert LazyHTML.attribute(email, "aria-describedby") == ["notifications-0-description"]

      description = LazyHTML.query(html, "#notifications-0-description")
      assert LazyHTML.text(description) |> String.trim() == "Account updates."
    end

    test "keeps the checked state of each independent switch" do
      html = render()

      checked = LazyHTML.query(html, ~s([data-element="switch"] [data-part="control"][checked]))

      assert Enum.map(checked, &LazyHTML.attribute(&1, "name")) == [["notifications[email]"]]
    end

    test "derives the group description and error ids" do
      html = render(description: "Choose how we reach you.", errors: ["enable at least one"])

      assert fieldset_attr(html, "aria-invalid") == ["true"]

      assert fieldset_attr(html, "aria-describedby") == [
               "notifications-description notifications-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, "#notifications-description")) |> String.trim() ==
               "Choose how we reach you."

      assert LazyHTML.text(LazyHTML.query(html, "#notifications-error-1")) |> String.trim() ==
               "enable at least one"

      assert LazyHTML.query(html, ~s(#notifications-error-1 [data-part="error_icon"])) != []
    end

    test "a disabled group disables every switch and the fieldset" do
      html = render(disabled: true)

      assert fieldset_attr(html, "disabled") == [""]
      assert fieldset_attr(html, "data-disabled") == [""]

      assert Enum.all?(switches(html), &(LazyHTML.attribute(&1, "data-disabled") == [""]))
      assert Enum.all?(controls(html), &(LazyHTML.attribute(&1, "disabled") == [""]))
    end

    test "an option can be disabled on its own" do
      html = render()

      push =
        LazyHTML.query(
          html,
          ~s([data-element="switch"] [data-part="control"][name="notifications[push]"])
        )

      assert LazyHTML.attribute(push, "disabled") == [""]

      email =
        LazyHTML.query(
          html,
          ~s([data-element="switch"] [data-part="control"][name="notifications[email]"])
        )

      assert LazyHTML.attribute(email, "disabled") == []
    end

    test "required is exposed on the group" do
      html = render(required: true)

      assert fieldset_attr(html, "aria-required") == ["true"]
      assert fieldset_attr(html, "data-required") == [""]
    end

    test "puts the caller class on the group root" do
      html = render(class: "settings")
      assert fieldset_attr(html, "class") == ["settings"]
      refute Enum.any?(switches(html), &(LazyHTML.attribute(&1, "class") == ["settings"]))
    end

    test "custom option content replaces the label" do
      html =
        render_component(&TestComponent.inner_block/1, %{}) |> LazyHTML.from_fragment()

      label = LazyHTML.query(html, ~s([data-element="switch"] label))

      assert LazyHTML.text(label) =~ "Email alerts"
      refute LazyHTML.text(label) =~ "Ignored"
    end

    test "binds one field per option" do
      form = Phoenix.Component.to_form(%{"email_alerts" => true}, as: :user)

      html =
        render_component(&TestComponent.field_group/1, %{
          email: form[:email_alerts],
          sms: form[:sms_alerts]
        })
        |> LazyHTML.from_fragment()

      names = Enum.map(controls(html), &LazyHTML.attribute(&1, "name"))
      assert names == [["user[email_alerts]"], ["user[sms_alerts]"]]

      ids = Enum.map(controls(html), &LazyHTML.attribute(&1, "id"))
      assert ids == [["user_email_alerts"], ["user_sms_alerts"]]

      checked = LazyHTML.query(html, ~s([data-element="switch"] [data-part="control"][checked]))
      assert Enum.map(checked, &LazyHTML.attribute(&1, "name")) == [["user[email_alerts]"]]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :switch_group, type: :form} =
               FlintUI.Base.SwitchGroup.meta()

      parts = FlintUI.Base.SwitchGroup.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert Enum.map(parts, &elem(&1, 0)) ==
               [:root, :label, :options, :description, :error, :error_icon]
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.SwitchGroup.keyboard(), &(&1.keys == "Space"))

      assert Enum.any?(
               FlintUI.Base.SwitchGroup.states(),
               &(&1.name == "disabled" and &1.selector =~ ~s([data-element="switch_group"]))
             )
    end
  end
end
