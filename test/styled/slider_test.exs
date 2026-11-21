defmodule FlintUI.Styled.SliderTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:slider, ~S'''
      def basic(assigns) do
        ~H"""
        <.slider
          id="volume"
          name="volume"
          label="Volume"
          sublabel={@sublabel}
          description={@description}
          hint={@hint}
          value={@value}
          errors={@errors}
          size={@size}
          color={@color}
          class={@class}
          style={@style}
          data-test="volume-slider"
        />
        """
      end

      def range(assigns) do
        ~H"""
        <.slider
          id="price"
          name="price"
          label="Price range"
          range
          min="0"
          max="8"
          min_value="2"
          max_value="6"
          show_markers
          show_tooltip
          size={@size}
          color={@color}
        />
        """
      end

      def field_slider(assigns) do
        ~H"""
        <.slider field={@field} label="Volume" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        sublabel: "Optional",
        description: nil,
        hint: nil,
        value: 40,
        errors: [],
        size: "md",
        color: "primary",
        class: nil,
        style: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the field root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :slider, "data-element") == ["slider"]
    assert attr(document, :slider, "data-slider") == [""]
    assert attr(document, :slider, "data-size") == ["md"]
    assert attr(document, :slider, "data-color") == ["primary"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))
      assert attr(document, :slider, "data-size") == [size]
    end
  end

  test "renders every color role", %{wrapper: wrapper} do
    for color <- ~w(neutral info success warning danger primary secondary) do
      document = render(wrapper, :basic, defaults(color: color))
      assert attr(document, :slider, "data-color") == [color]
    end
  end

  test "writes a raw color to the root CSS input", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :slider, "data-color") == []
    assert attr(document, :slider, "style") |> Enum.join() =~ "--fl-slider-color: #1D72FE"
  end

  test "keeps the root hooks off the native input", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", color: "danger"))

    assert part_attr(document, "input", "data-size") == []
    assert part_attr(document, "input", "data-color") == []
    assert part_attr(document, "input", "data-test") == ["volume-slider"]
  end

  test "forwards the caller class to the field root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary"))

    assert attr(document, :slider, "class") == ["accent-primary"]
  end

  test "puts a caller style on the field root, not the native inputs", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(style: "width: 20rem"))

    assert attr(document, :slider, "style") |> Enum.join() =~ "width: 20rem"
    assert part_attr(document, "input", "style") == []
  end

  test "renders a range with both thumbs and its props", %{wrapper: wrapper} do
    document = render(wrapper, :range, defaults(size: "lg", color: "success"))

    assert attr(document, :slider, "data-range") == [""]
    assert attr(document, :slider, "data-size") == ["lg"]
    assert attr(document, :slider, "data-color") == ["success"]

    assert part_attr(document, "input", "name") == ["price[]", "price[]"]
    assert part_attr(document, "input", "value") == ["2", "6"]
    assert count_part(document, "marker") == 9
    assert part_attr(document, "tooltip", "data-thumb") == ["min", "max"]
  end

  test "binds a form field through the wrapper", %{wrapper: wrapper} do
    form = Phoenix.Component.to_form(%{"volume" => 30}, as: :user)

    document = render(wrapper, :field_slider, %{field: form[:volume]})

    assert part_attr(document, "input", "id") == ["user_volume-input"]
    assert part_attr(document, "input", "name") == ["user[volume]"]
    assert part_attr(document, "input", "value") == ["30"]
  end
end
