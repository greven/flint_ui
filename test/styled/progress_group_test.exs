defmodule FlintUI.Styled.ProgressGroupTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:progress_group, ~S'''
      def basic(assigns) do
        ~H"""
        <.progress_group
          max={@max}
          label={@label}
          orientation={@orientation}
          show_status={@show_status}
          size={@size}
          color={@color}
          radius={@radius}
          class={@class}
          style={@style}
          data-test="progress-group"
        >
          <:segment
            :for={segment <- @segments}
            value={segment.value}
            label={Map.get(segment, :label)}
            icon={Map.get(segment, :icon)}
            color={Map.get(segment, :color)}
            class={Map.get(segment, :class)}
          />
        </.progress_group>
        """
      end

      def custom(assigns) do
        ~H"""
        <.progress_group max="4" label="Build" color={@color}>
          <:segment value="1" label="Fallback">Custom <strong>label</strong></:segment>
          <:segment value="3" icon="lucide-cpu" />
        </.progress_group>
        """
      end

      def custom_status(assigns) do
        ~H"""
        <.progress_group max="100" label="Storage">
          <:status>{@status_text}</:status>
          <:segment value="42" label="Compute" />
          <:segment value="18" label="Storage" />
        </.progress_group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        max: 128,
        label: "Storage",
        orientation: "horizontal",
        show_status: false,
        size: "md",
        color: "primary",
        radius: "full",
        segments: [
          %{value: 42, label: "Compute"},
          %{value: 18, label: "Storage"},
          %{value: 9, label: "Bandwidth"}
        ],
        class: nil,
        style: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the group root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :progress_group, "data-element") == ["progress_group"]
    assert attr(document, :progress_group, "data-progress_group") == [""]
    assert attr(document, :progress_group, "data-size") == ["md"]
    assert attr(document, :progress_group, "data-color") == ["primary"]
    assert attr(document, :progress_group, "data-radius") == ["full"]
    assert attr(document, :progress_group, "data-orientation") == ["horizontal"]
    assert attr(document, :progress_group, "role") == ["progressbar"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))
      assert attr(document, :progress_group, "data-size") == [size]
    end
  end

  test "renders every color role", %{wrapper: wrapper} do
    for color <- ~w(neutral info success warning error primary secondary) do
      document = render(wrapper, :basic, defaults(color: color))
      assert attr(document, :progress_group, "data-color") == [color]
    end
  end

  test "renders every radius value", %{wrapper: wrapper} do
    for radius <- ~w(none xs sm md lg xl full) do
      document = render(wrapper, :basic, defaults(radius: radius))
      assert attr(document, :progress_group, "data-radius") == [radius]
    end
  end

  test "forwards the headless contract", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(show_status: true, orientation: "vertical", max: 138)
      )

    assert attr(document, :progress_group, "aria-valuemax") == ["138"]
    assert attr(document, :progress_group, "aria-valuenow") == ["69"]
    assert attr(document, :progress_group, "aria-valuetext") == ["50%"]
    assert attr(document, :progress_group, "aria-label") == ["Storage"]
    assert attr(document, :progress_group, "aria-orientation") == ["vertical"]
    assert LazyHTML.text(part(document, "status")) |> String.trim() == "50%"
    assert part_attr(document, "status", "style") == []
    assert part_attr(document, "segment", "style") |> hd() == "block-size: 30.434783%"
  end

  test "keeps the group hooks off the track", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", color: "error", radius: "md"))

    assert part_attr(document, "track", "data-size") == []
    assert part_attr(document, "track", "data-color") == []
    assert part_attr(document, "track", "data-radius") == []
  end

  test "moves a per-segment color onto the segment and its legend row", %{wrapper: wrapper} do
    segments = [
      %{value: 42, label: "Compute", color: "primary"},
      %{value: 18, label: "Storage", color: "info"},
      %{value: 9, label: "Bandwidth", color: "warning"}
    ]

    document = render(wrapper, :basic, defaults(segments: segments))

    assert part_attr(document, "segment", "data-color") == ["primary", "info", "warning"]
    assert part_attr(document, "item", "data-color") == ["primary", "info", "warning"]
  end

  test "writes a raw group color to the root CSS input", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(color: "#1D72FE"))

    assert attr(document, :progress_group, "data-color") == []

    assert attr(document, :progress_group, "style")
           |> Enum.join() =~ "--fl-progress-group-color: #1D72FE"
  end

  test "writes a segment hue as a hook and a raw color to the CSS input", %{wrapper: wrapper} do
    segments = [
      %{value: 42, label: "Compute", color: "pink"},
      %{value: 18, label: "Storage", color: "#00A86B"}
    ]

    document = render(wrapper, :basic, defaults(segments: segments))

    assert part_attr(document, "segment", "data-color") == ["pink"]
    assert part_attr(document, "item", "data-color") == ["pink"]

    assert Enum.count(
             part_attr(document, "segment", "style"),
             &(&1 =~ "--fl-progress-group-color:")
           ) == 1

    assert Enum.count(part_attr(document, "item", "style"), &(&1 =~ "--fl-progress-group-color:")) ==
             1
  end

  test "keeps a caller slot class on the segment", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(segments: [%{value: 42, label: "Compute", class: "opacity-50"}])
      )

    assert part_attr(document, "segment", "class") == ["opacity-50"]
  end

  test "aligns the default status with the last segment", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(show_status: true))

    assert LazyHTML.text(part(document, "status")) |> String.trim() == "54%"
    assert part_attr(document, "status", "style") == ["inline-size: 53.90625%"]
  end

  test "forwards a custom status slot", %{wrapper: wrapper} do
    document = render(wrapper, :custom_status, %{status_text: "69 GB of 100 GB used"})

    assert LazyHTML.text(part(document, "status")) |> String.trim() == "69 GB of 100 GB used"
    assert part_attr(document, "status", "aria-hidden") == []
    assert part_attr(document, "status", "style") == ["inline-size: 60%"]
  end

  test "renders an inner block as the legend label", %{wrapper: wrapper} do
    document = render(wrapper, :custom, %{color: "primary"})

    text =
      document
      |> part("label")
      |> LazyHTML.text()
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    assert text == "Custom label"
    assert part_attr(document, "icon", "class") == ["lucide-cpu"]
  end

  test "forwards the caller class and style to the root", %{wrapper: wrapper} do
    document =
      render(wrapper, :basic, defaults(class: "accent-primary", style: "width: 20rem"))

    assert attr(document, :progress_group, "class") == ["accent-primary"]
    assert attr(document, :progress_group, "style") |> Enum.join() =~ "width: 20rem"
    assert part_attr(document, "track", "style") == []
  end
end
