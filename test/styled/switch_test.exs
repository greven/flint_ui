defmodule FlintUI.Styled.SwitchTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:switch, ~S'''
      def basic(assigns) do
        ~H"""
        <.switch
          id="notifications"
          name="notifications"
          label="Enable notifications"
          sublabel={@sublabel}
          hint={@hint}
          checked={@checked}
          errors={@errors}
          size={@size}
          color={@color}
          class={@class}
        />
        """
      end

      def field_switch(assigns) do
        ~H"""
        <.switch field={@field} label="Notifications" />
        """
      end

      def custom(assigns) do
        ~H"""
        <.switch name="notifications" label="Ignored">
          <strong>Custom label</strong>
        </.switch>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        sublabel: "Recommended",
        hint: nil,
        checked: nil,
        errors: [],
        size: "md",
        color: "primary",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the switch root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :switch, "data-element") == ["switch"]
    assert attr(document, :switch, "data-switch") == [""]
    assert attr(document, :switch, "data-size") == ["md"]
    assert attr(document, :switch, "data-color") == ["primary"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))
      assert attr(document, :switch, "data-size") == [size]
    end
  end

  test "keeps the root hooks off the native control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", color: "error"))

    assert part_attr(document, "control", "data-part") == ["control"]
    assert part_attr(document, "control", "role") == ["switch"]
    assert part_attr(document, "control", "data-size") == []
    assert part_attr(document, "control", "data-color") == []
  end

  test "forwards the caller class to the switch root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary"))

    assert attr(document, :switch, "class") == ["accent-primary"]
    assert part_attr(document, "control", "class") == []
  end

  test "renders the label and sublabel", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert LazyHTML.text(part(document, "label")) =~ "Enable notifications"
    assert LazyHTML.text(part(document, "sublabel")) |> String.trim() == "Recommended"
  end

  test "custom inner content replaces the label", %{wrapper: wrapper} do
    document = render(wrapper, :custom, %{})

    assert LazyHTML.text(part(document, "label")) =~ "Custom label"
    refute LazyHTML.text(part(document, "label")) =~ "Ignored"
  end

  test "writes a raw color to the root inputs", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :switch, "data-color") == []

    assert attr(document, :switch, "style") |> Enum.join(" ") =~
             "--fl-switch-color: #1D72FE"
  end

  test "forwards a field struct and its errors", %{wrapper: wrapper} do
    form =
      Phoenix.Component.to_form(%{"notifications" => false},
        as: :user,
        errors: [notifications: {"must be enabled", []}]
      )

    document = render(wrapper, :field_switch, %{field: form[:notifications]})

    assert part_attr(document, "control", "id") == ["user_notifications"]
    assert part_attr(document, "control", "name") == ["user[notifications]"]
    assert attr(document, :switch, "data-invalid") == [""]
  end

  test "renders a hint and errors", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(hint: "Only administrators can change this.", errors: ["is not available"])
      )

    assert LazyHTML.text(part(document, "hint")) |> String.trim() ==
             "Only administrators can change this."

    assert LazyHTML.text(part(document, "error")) |> String.trim() == "is not available"
  end
end
