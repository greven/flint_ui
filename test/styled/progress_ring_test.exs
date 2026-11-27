defmodule FlintUI.Styled.ProgressRingTest do
  use FlintUI.StyledCase, async: true

  alias FlintUI.TestDOM

  setup_all do
    wrapper =
      compile_wrapper!(:progress_ring, ~S'''
      def basic(assigns) do
        ~H"""
        <.progress_ring
          value={@value}
          max={@max}
          label={@label}
          show_status={@show_status}
          size={@size}
          thickness={@thickness}
          color={@color}
          indeterminate={@indeterminate}
          class={@class}
          style={@style}
          data-test="progress-ring"
        />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        value: 40,
        max: 100,
        label: "Upload progress",
        show_status: false,
        size: "md",
        thickness: "md",
        color: "primary",
        indeterminate: "spin",
        class: nil,
        style: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the ring root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :progress_ring, "data-element") == ["progress_ring"]
    assert attr(document, :progress_ring, "data-progress_ring") == [""]
    assert attr(document, :progress_ring, "data-size") == ["md"]
    assert attr(document, :progress_ring, "data-thickness") == ["md"]
    assert attr(document, :progress_ring, "data-color") == ["primary"]
    assert attr(document, :progress_ring, "data-indeterminate") == ["spin"]
    assert attr(document, :progress_ring, "data-state") == []
    assert attr(document, :progress_ring, "role") == ["progressbar"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))
      assert attr(document, :progress_ring, "data-size") == [size]
    end
  end

  test "renders every thickness value", %{wrapper: wrapper} do
    for thickness <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(thickness: thickness))
      assert attr(document, :progress_ring, "data-thickness") == [thickness]
    end
  end

  test "renders every color role", %{wrapper: wrapper} do
    for color <- ~w(neutral info success warning danger primary secondary) do
      document = render(wrapper, :basic, defaults(color: color))
      assert attr(document, :progress_ring, "data-color") == [color]
    end
  end

  test "renders every indeterminate motion", %{wrapper: wrapper} do
    for indeterminate <- ~w(spin sweep) do
      document = render(wrapper, :basic, defaults(value: nil, indeterminate: indeterminate))

      assert attr(document, :progress_ring, "data-state") == ["indeterminate"]
      assert attr(document, :progress_ring, "data-indeterminate") == [indeterminate]
      assert attr(document, :progress_ring, "aria-valuenow") == []
    end
  end

  test "writes a raw color to the root CSS input", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :progress_ring, "data-color") == []

    assert attr(document, :progress_ring, "style") |> Enum.join() =~
             "--fl-progress-ring-color: #1D72FE"
  end

  test "keeps the presentational hooks off the drawing parts", %{wrapper: wrapper} do
    document =
      render(wrapper, :basic, defaults(size: "lg", thickness: "xl", color: "danger"))

    assert part_attr(document, "svg", "data-size") == []
    assert part_attr(document, "track", "data-thickness") == []
    assert part_attr(document, "segment", "data-color") == []
  end

  test "forwards the caller class and style to the root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary", style: "width: 20rem"))

    assert attr(document, :progress_ring, "class") == ["accent-primary"]
    assert attr(document, :progress_ring, "style") |> Enum.join() =~ "width: 20rem"
    refute part_attr(document, "svg", "style") |> Enum.join() =~ "width"
  end

  test "forwards the headless contract", %{wrapper: wrapper} do
    document =
      render(wrapper, :basic, defaults(show_status: true, value: 72, max: 90))

    assert attr(document, :progress_ring, "aria-valuenow") == ["72"]
    assert attr(document, :progress_ring, "aria-valuemax") == ["90"]
    assert attr(document, :progress_ring, "aria-valuetext") == ["80%"]
    assert attr(document, :progress_ring, "aria-label") == ["Upload progress"]
    assert LazyHTML.text(part(document, "status")) |> String.trim() == "80%"
    assert TestDOM.style_var(document, ~s([data-part="segment"]), "stroke-dashoffset") == "20"
  end

  test "forwards a step list and marks the active label", %{wrapper: wrapper} do
    steps = ["Waiting", "Cloning", "Migrating", "Deploying", "Done"]
    document = render(wrapper, :basic, defaults(value: 3, max: steps))

    assert attr(document, :progress_ring, "aria-valuemax") == ["4"]
    assert attr(document, :progress_ring, "aria-valuenow") == ["3"]
    assert attr(document, :progress_ring, "aria-valuetext") == ["Deploying"]
    assert count_part(document, "step") == 5

    active = LazyHTML.query(document, ~s([data-part="step"][data-active]))

    assert LazyHTML.text(active) |> String.trim() == "Deploying"
  end

  test "forwards an omitted value as indeterminate", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(value: nil))

    assert attr(document, :progress_ring, "data-state") == ["indeterminate"]
    assert attr(document, :progress_ring, "data-indeterminate") == ["spin"]
    assert attr(document, :progress_ring, "aria-valuenow") == []
    assert part_attr(document, "segment", "style") == []
  end
end
