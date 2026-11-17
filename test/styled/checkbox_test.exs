defmodule FlintUI.Styled.CheckboxTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:checkbox, ~S'''
      def basic(assigns) do
        ~H"""
        <.checkbox
          id="notifications"
          name="notifications"
          label="Enable notifications"
          sublabel={@sublabel}
          hint={@hint}
          checked={@checked}
          errors={@errors}
          variant={@variant}
          size={@size}
          radius={@radius}
          color={@color}
          class={@class}
        />
        """
      end

      def field_checkbox(assigns) do
        ~H"""
        <.checkbox field={@field} label="Terms" />
        """
      end

      def custom(assigns) do
        ~H"""
        <.checkbox name="terms" label="Ignored">
          <strong>Custom label</strong>
        </.checkbox>
        """
      end

      def indeterminate(assigns) do
        ~H"""
        <.checkbox
          name="select_all"
          label="Select all"
          checked={false}
          indeterminate
        />
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
        variant: "simple",
        size: "md",
        radius: "sm",
        color: "primary",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the checkbox root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :checkbox, "data-element") == ["checkbox"]
    assert attr(document, :checkbox, "data-checkbox") == [""]
    assert attr(document, :checkbox, "data-variant") == ["simple"]
    assert attr(document, :checkbox, "data-size") == ["md"]
    assert attr(document, :checkbox, "data-radius") == ["sm"]
    assert attr(document, :checkbox, "data-color") == ["primary"]
  end

  test "renders every variant, size, and radius value", %{wrapper: wrapper} do
    for variant <- ~w(simple card),
        size <- ~w(xs sm md lg xl),
        radius <- ~w(none xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(variant: variant, size: size, radius: radius))

      assert attr(document, :checkbox, "data-variant") == [variant]
      assert attr(document, :checkbox, "data-size") == [size]
      assert attr(document, :checkbox, "data-radius") == [radius]
    end
  end

  test "keeps the root hooks off the native control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(variant: "card", size: "lg", radius: "xl"))

    assert part_attr(document, "control", "data-part") == ["control"]
    assert part_attr(document, "control", "data-size") == []
    assert part_attr(document, "control", "data-variant") == []
  end

  test "forwards the caller class to the checkbox root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary"))

    assert attr(document, :checkbox, "class") == ["accent-primary"]
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

  test "forwards indeterminate to the native control", %{wrapper: wrapper} do
    document = render(wrapper, :indeterminate, %{})

    assert part_attr(document, "control", "data-indeterminate") == ["true"]
    assert part_attr(document, "control", "checked") == []
  end

  test "writes a raw color to the root inputs", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :checkbox, "data-color") == []

    assert attr(document, :checkbox, "style") |> Enum.join(" ") =~
             "--fl-checkbox-color: #1D72FE"
  end

  test "forwards a field struct and its errors", %{wrapper: wrapper} do
    form =
      Phoenix.Component.to_form(%{"terms" => false},
        as: :user,
        errors: [terms: {"must be accepted", []}]
      )

    document = render(wrapper, :field_checkbox, %{field: form[:terms]})

    assert part_attr(document, "control", "id") == ["user_terms"]
    assert part_attr(document, "control", "name") == ["user[terms]"]
    assert attr(document, :checkbox, "data-invalid") == [""]
  end

  test "renders a hint and errors", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(hint: "We only use this for receipts.", errors: ["is invalid"])
      )

    assert LazyHTML.text(part(document, "hint")) |> String.trim() ==
             "We only use this for receipts."

    assert LazyHTML.text(part(document, "error")) |> String.trim() == "is invalid"
  end
end
