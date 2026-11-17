defmodule FlintUI.Styled.SwitchGroupTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:switch_group, ~S'''
      def basic(assigns) do
        ~H"""
        <.switch_group
          id="notifications"
          label="Notifications"
          description={@description}
          orientation={@orientation}
          size={@size}
          color={@color}
          disabled={@disabled}
          class={@class}
        >
          <:switch name="notifications[email]" label="Email" description="Account updates." checked />
          <:switch name="notifications[sms]" label="SMS" />
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

      def inner_group(assigns) do
        ~H"""
        <.switch_group label="Notifications">
          <:switch name="notifications[email]" label="Ignored">
            <strong>Email</strong>
          </:switch>
        </.switch_group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        description: nil,
        orientation: "vertical",
        size: "md",
        color: "primary",
        disabled: false,
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps orientation onto the group root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :switch_group, "data-element") == ["switch_group"]
    assert attr(document, :switch_group, "data-switch_group") == [""]
    assert attr(document, :switch_group, "data-orientation") == ["vertical"]
  end

  test "renders every orientation", %{wrapper: wrapper} do
    for orientation <- ~w(vertical horizontal) do
      document = render(wrapper, :basic, defaults(orientation: orientation))
      assert attr(document, :switch_group, "data-orientation") == [orientation]
    end
  end

  test "forwards size and color to every switch", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", color: "success"))

    roots = LazyHTML.query(document, ~s([data-element="switch"][data-switch]))
    assert Enum.count(roots) == 2

    for root <- roots do
      assert LazyHTML.attribute(root, "data-size") == ["lg"]
      assert LazyHTML.attribute(root, "data-color") == ["success"]
    end
  end

  test "writes a raw color to every switch root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    roots = LazyHTML.query(document, ~s([data-element="switch"][data-switch]))

    for root <- roots do
      assert LazyHTML.attribute(root, "data-color") == []
      assert LazyHTML.attribute(root, "style") |> Enum.join(" ") =~ "--fl-switch-color: #1D72FE"
    end
  end

  test "renders the legend, description, and independent switches", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(description: "Choose how we reach you."))

    assert LazyHTML.text(LazyHTML.query(document, "legend")) |> String.trim() == "Notifications"

    assert LazyHTML.text(
             LazyHTML.query(
               document,
               ~s([data-element="switch_group"] > [data-part="description"])
             )
           )
           |> String.trim() == "Choose how we reach you."

    names =
      document
      |> LazyHTML.query(~s([data-element="switch"] [data-part="control"]))
      |> Enum.map(&LazyHTML.attribute(&1, "name"))

    assert names == [["notifications[email]"], ["notifications[sms]"]]
  end

  test "disables every switch with the group", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(disabled: true))

    assert attr(document, :switch_group, "disabled") == [""]

    roots = LazyHTML.query(document, ~s([data-element="switch"][data-switch]))
    assert Enum.all?(roots, &(LazyHTML.attribute(&1, "data-disabled") == [""]))

    controls = LazyHTML.query(document, ~s([data-element="switch"] [data-part="control"]))
    assert Enum.all?(controls, &(LazyHTML.attribute(&1, "disabled") == [""]))
  end

  test "forwards one field per option", %{wrapper: wrapper} do
    form = Component.to_form(%{"email_alerts" => true}, as: :user)

    document =
      render(wrapper, :field_group, %{email: form[:email_alerts], sms: form[:sms_alerts]})

    controls = LazyHTML.query(document, ~s([data-element="switch"] [data-part="control"]))

    assert Enum.map(controls, &LazyHTML.attribute(&1, "name")) == [
             ["user[email_alerts]"],
             ["user[sms_alerts]"]
           ]

    checked = LazyHTML.query(document, ~s([data-element="switch"] [data-part="control"][checked]))
    assert Enum.map(checked, &LazyHTML.attribute(&1, "name")) == [["user[email_alerts]"]]
  end

  test "renders custom option content", %{wrapper: wrapper} do
    document = render(wrapper, :inner_group, %{})

    assert LazyHTML.text(LazyHTML.query(document, "strong")) == "Email"
  end

  test "keeps the caller class on the group root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "settings"))

    assert attr(document, :switch_group, "class") == ["settings"]
    assert part_attr(document, "control", "class") == []
  end
end
