defmodule FlintUI.Styled.RadioTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:radio, ~S'''
      def basic(assigns) do
        ~H"""
        <.radio
          id="plan-pro"
          name="plan"
          value="pro"
          label="Pro"
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

      def field_radio(assigns) do
        ~H"""
        <.radio field={@field} value="pro" label="Pro" />
        """
      end

      def custom(assigns) do
        ~H"""
        <.radio name="plan" value="pro" label="Ignored">
          <strong>Custom label</strong>
        </.radio>
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

  test "maps its props onto the radio root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :radio, "data-element") == ["radio"]
    assert attr(document, :radio, "data-radio") == [""]
    assert attr(document, :radio, "data-variant") == ["simple"]
    assert attr(document, :radio, "data-size") == ["md"]
    assert attr(document, :radio, "data-radius") == ["sm"]
    assert attr(document, :radio, "data-color") == ["primary"]
  end

  test "renders every variant, size, and radius value", %{wrapper: wrapper} do
    for variant <- ~w(simple card),
        size <- ~w(xs sm md lg xl),
        radius <- ~w(none xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(variant: variant, size: size, radius: radius))

      assert attr(document, :radio, "data-variant") == [variant]
      assert attr(document, :radio, "data-size") == [size]
      assert attr(document, :radio, "data-radius") == [radius]
    end
  end

  test "keeps the root hooks off the native control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(variant: "card", size: "lg", radius: "xl"))

    assert part_attr(document, "control", "data-part") == ["control"]
    assert part_attr(document, "control", "data-size") == []
    assert part_attr(document, "control", "data-variant") == []
  end

  test "forwards the caller class to the radio root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary"))

    assert attr(document, :radio, "class") == ["accent-primary"]
    assert part_attr(document, "control", "class") == []
  end

  test "renders the label and sublabel", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert LazyHTML.text(part(document, "label")) =~ "Pro"
    assert LazyHTML.text(part(document, "sublabel")) |> String.trim() == "Recommended"
  end

  test "custom inner content replaces the label", %{wrapper: wrapper} do
    document = render(wrapper, :custom, %{})

    assert LazyHTML.text(part(document, "label")) =~ "Custom label"
    refute LazyHTML.text(part(document, "label")) =~ "Ignored"
  end

  test "writes a raw color to the root inputs", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :radio, "data-color") == []

    assert attr(document, :radio, "style") |> Enum.join(" ") =~
             "--fl-radio-color: #1D72FE"
  end

  test "forwards a field struct and its errors", %{wrapper: wrapper} do
    form =
      Phoenix.Component.to_form(%{"plan" => "pro"},
        as: :user,
        errors: [plan: {"is required", []}]
      )

    document = render(wrapper, :field_radio, %{field: form[:plan]})

    assert part_attr(document, "control", "id") == ["user_plan-pro"]
    assert part_attr(document, "control", "name") == ["user[plan]"]
    assert part_attr(document, "control", "checked") == [""]
    assert attr(document, :radio, "data-invalid") == [""]
  end

  test "renders a hint and errors", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(hint: "Choose the plan that fits.", errors: ["is invalid"])
      )

    assert LazyHTML.text(part(document, "hint")) |> String.trim() ==
             "Choose the plan that fits."

    assert LazyHTML.text(part(document, "error")) |> String.trim() == "is invalid"
  end
end
