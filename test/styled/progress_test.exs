defmodule FlintUI.Styled.ProgressTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:progress, ~S'''
      def basic(assigns) do
        ~H"""
        <.progress
          value={@value}
          max={@max}
          label={@label}
          orientation={@orientation}
          show_status={@show_status}
          size={@size}
          color={@color}
          radius={@radius}
          striped={@striped}
          animated={@animated}
          indeterminate={@indeterminate}
          class={@class}
          style={@style}
          data-test="progress"
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
        orientation: "horizontal",
        show_status: false,
        size: "md",
        color: "primary",
        radius: "full",
        striped: false,
        animated: false,
        indeterminate: "carousel",
        class: nil,
        style: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the progress root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :progress, "data-element") == ["progress"]
    assert attr(document, :progress, "data-progress") == [""]
    assert attr(document, :progress, "data-size") == ["md"]
    assert attr(document, :progress, "data-color") == ["primary"]
    assert attr(document, :progress, "data-radius") == ["full"]
    assert attr(document, :progress, "data-indeterminate") == ["carousel"]
    assert attr(document, :progress, "data-animated") == []
    assert attr(document, :progress, "data-striped") == []
    assert attr(document, :progress, "data-state") == []
    assert attr(document, :progress, "role") == ["progressbar"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))
      assert attr(document, :progress, "data-size") == [size]
    end
  end

  test "renders every color role", %{wrapper: wrapper} do
    for color <- ~w(neutral info success warning error primary secondary) do
      document = render(wrapper, :basic, defaults(color: color))
      assert attr(document, :progress, "data-color") == [color]
    end
  end

  test "renders every radius value", %{wrapper: wrapper} do
    for radius <- ~w(none xs sm md lg xl full) do
      document = render(wrapper, :basic, defaults(radius: radius))
      assert attr(document, :progress, "data-radius") == [radius]
    end
  end

  test "renders every indeterminate motion", %{wrapper: wrapper} do
    for indeterminate <- ~w(carousel swing elastic) do
      document = render(wrapper, :basic, defaults(value: nil, indeterminate: indeterminate))

      assert attr(document, :progress, "data-state") == ["indeterminate"]
      assert attr(document, :progress, "data-indeterminate") == [indeterminate]
      assert attr(document, :progress, "aria-valuenow") == []
    end
  end

  test "marks a striped fill", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(striped: true))

    assert attr(document, :progress, "data-striped") == [""]
  end

  test "marks an animated fill without requiring striped", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(animated: true))

    assert attr(document, :progress, "data-animated") == [""]
    assert attr(document, :progress, "data-striped") == []
  end

  test "writes a raw color to the root CSS input", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :progress, "data-color") == []
    assert attr(document, :progress, "style") |> Enum.join() =~ "--fl-progress-color: #1D72FE"
  end

  test "keeps the presentational hooks off the track and segment", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", color: "error", striped: true))

    assert part_attr(document, "track", "data-size") == []
    assert part_attr(document, "track", "data-color") == []
    assert part_attr(document, "segment", "data-striped") == []
  end

  test "forwards the caller class and style to the root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "accent-primary", style: "width: 20rem"))

    assert attr(document, :progress, "class") == ["accent-primary"]
    assert attr(document, :progress, "style") |> Enum.join() =~ "width: 20rem"
    assert part_attr(document, "track", "style") == []
  end

  test "forwards the headless contract", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(show_status: true, orientation: "vertical", value: 72, max: 90)
      )

    assert attr(document, :progress, "aria-valuenow") == ["72"]
    assert attr(document, :progress, "aria-valuemax") == ["90"]
    assert attr(document, :progress, "aria-valuetext") == ["80%"]
    assert attr(document, :progress, "aria-label") == ["Upload progress"]
    assert attr(document, :progress, "data-orientation") == ["vertical"]
    assert attr(document, :progress, "aria-orientation") == ["vertical"]
    assert LazyHTML.text(part(document, "status")) |> String.trim() == "80%"
    assert part_attr(document, "segment", "style") == ["block-size: 80%"]
  end

  test "forwards a step list and marks the active label", %{wrapper: wrapper} do
    steps = ["Waiting", "Cloning", "Migrating", "Deploying", "Done"]
    document = render(wrapper, :basic, defaults(value: 3, max: steps))

    assert attr(document, :progress, "aria-valuemax") == ["4"]
    assert attr(document, :progress, "aria-valuenow") == ["3"]
    assert attr(document, :progress, "aria-valuetext") == ["Deploying"]
    assert count_part(document, "step") == 5

    active = LazyHTML.query(document, ~s([data-part="step"][data-active]))

    assert LazyHTML.text(active) |> String.trim() == "Deploying"
  end

  test "forwards an omitted value as indeterminate", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(value: nil))

    assert attr(document, :progress, "data-state") == ["indeterminate"]
    assert attr(document, :progress, "data-indeterminate") == ["carousel"]
    assert attr(document, :progress, "aria-valuenow") == []
    assert part_attr(document, "segment", "style") == []
  end
end
