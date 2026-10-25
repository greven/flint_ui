defmodule FlintUI.Base.LoadingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def loading_example(assigns) do
      ~H"""
      <.loading
        variant={@variant}
        duration={@duration}
        weight={@weight}
        class={@class}
        label={@label}
        data-role="test"
      />
      """
    end
  end

  @defaults %{variant: "ring", duration: 600, weight: nil, class: nil, label: nil}

  defp raw(overrides) do
    render_component(&TestComponent.loading_example/1, Map.merge(@defaults, Map.new(overrides)))
  end

  defp render(overrides \\ %{}) do
    raw(overrides) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp count(html, needle), do: length(Regex.scan(~r/#{Regex.escape(needle)}/, html))

  test "renders an svg spinner, decorative by default" do
    html = render()

    assert tag(html) == ["svg"]
    assert attr(html, "data-element") == ["loading"]
    assert attr(html, "data-variant") == ["ring"]
    assert attr(html, "aria-hidden") == ["true"]
    assert attr(html, "role") == []
    assert attr(html, "aria-label") == []
  end

  test "a label exposes the spinner as a labeled image" do
    html = render(label: "Loading")

    assert attr(html, "role") == ["img"]
    assert attr(html, "aria-label") == ["Loading"]
    assert attr(html, "aria-hidden") == []
  end

  test "ships no built-in size class" do
    html = render()

    assert attr(html, "class") in [[], [""]]
  end

  test "applies class and passes through global attributes" do
    html = render(class: "size-6 text-zinc-500")

    assert attr(html, "class") == ["size-6 text-zinc-500"]
    assert attr(html, "data-role") == ["test"]
  end

  describe "variants" do
    test "ring draws a single rotating arc" do
      html = raw(variant: "ring")

      assert html =~ ~s(data-variant="ring")
      assert count(html, "<circle") == 1
      assert html =~ ~s(data-part="arc")
      assert html =~ "animation-duration: 600ms"
      refute html =~ "<animate"
    end

    test "ring-bg adds a background track" do
      html = raw(variant: "ring-bg")

      assert html =~ ~s(data-variant="ring-bg")
      assert count(html, "<circle") == 2
      assert html =~ ~s(data-part="track")
      assert html =~ ~s(data-part="arc")
      refute html =~ "<animate"
    end

    test "ring-dash morphs the arc with two staggered animations" do
      html = raw(variant: "ring-dash", duration: nil)

      assert html =~ ~s(data-variant="ring-dash")
      assert count(html, "<circle") == 2
      assert html =~ ~s(data-part="track")
      assert html =~ ~s(data-part="arc")
      assert html =~ "animation-duration: 1333ms, 1000ms"
      refute html =~ "<animate"
    end

    test "variants fall back to their own default duration" do
      assert raw(variant: "ring", duration: nil) =~ "animation-duration: 600ms"
      assert raw(variant: "dots-bounce", duration: nil) =~ "animation-duration: 600ms"
      assert raw(variant: "bars-scale", duration: nil) =~ "animation-duration: 600ms"
      assert raw(variant: "infinity", duration: nil) =~ "animation-duration: 2000ms"
    end

    test "every ring variant shares the same weight and radius" do
      for variant <- ~w(ring ring-bg ring-dash) do
        html = raw(variant: variant, weight: nil)
        assert html =~ ~s(r="9.5")
        assert html =~ ~s(stroke-width="2.0")
      end
    end

    test "variants fall back to their own default weight" do
      assert raw(variant: "dots-fade", weight: nil) =~ ~s(r="2.0")
      assert raw(variant: "bars-scale", weight: nil) =~ ~s(width="2.8")
    end

    test "weight sets the ring stroke, dot radius, and bar width" do
      assert raw(variant: "ring", weight: 3) =~ ~s(stroke-width="3")
      assert raw(variant: "dots-fade", weight: 3) =~ ~s(r="3")

      html = raw(variant: "bars-scale", weight: 4)
      assert count(html, ~s(width="4")) == 5
    end

    test "raises on a non-positive weight" do
      assert_raise ArgumentError, fn -> raw(variant: "ring", weight: 0) end
    end

    test "dots-fade staggers three dots' opacity" do
      html = raw(variant: "dots-fade")

      assert count(html, "<circle") == 3
      assert count(html, ~s(data-part="dot")) == 3
      assert html =~ "animation-delay: -200ms"
      assert html =~ "animation-delay: -400ms"
      refute html =~ "<animate"
    end

    test "dots-bounce staggers three dots' transform" do
      html = raw(variant: "dots-bounce")

      assert count(html, "<circle") == 3
      assert count(html, ~s(data-part="dot")) == 3
      assert html =~ "animation-delay: -200ms"
      assert html =~ "animation-delay: -400ms"
      refute html =~ "<animate"
    end

    test "bars-scale draws five staggered bars" do
      html = raw(variant: "bars-scale")

      assert count(html, "<rect") == 5
      assert count(html, ~s(data-part="bar")) == 5
      assert count(html, ~s(data-index)) == 5
      assert html =~ "animation-delay: -66ms"
      assert html =~ "animation-delay: -133ms"
      assert html =~ "animation-delay: -200ms"
      assert html =~ "animation-delay: -266ms"
      refute html =~ "<animate"
    end

    test "infinity draws one continuously dashed loop" do
      html = raw(variant: "infinity", duration: nil)

      assert html =~ ~s(data-variant="infinity")
      assert count(html, "<path") == 1
      assert html =~ ~s(data-part="loop")
      assert html =~ ~s(stroke-width="2.0")
      assert html =~ ~s(stroke-dasharray="41.054228515625 10.26355712890625")
      assert html =~ "animation-duration: 2000ms"
      refute html =~ "<animate"
    end

    test "infinity scales the stroke with weight" do
      html = raw(variant: "infinity", weight: 3)

      assert html =~ ~s(stroke-width="3")
    end

    test "duration publishes the cycle length on every animated part" do
      html = raw(variant: "dots-fade", duration: 300)

      assert count(html, "animation-duration: 300ms") == 3
      assert html =~ "animation-delay: -100ms"
      assert html =~ "animation-delay: -200ms"
    end

    test "ring-dash scales both cycles from duration" do
      html = raw(variant: "ring-dash", duration: 1500)

      assert html =~ "animation-duration: 2000ms, 1500ms"
    end

    test "raises on an unknown variant" do
      assert_raise ArgumentError, fn -> raw(variant: "nope") end
    end
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :loading, type: :element} = FlintUI.Base.Loading.meta()

    parts = FlintUI.Base.Loading.parts_attrs()

    assert %FlintUI.Meta.PartAttr{value: "loading"} =
             Enum.find(parts.root, &(&1.name == "[data-element]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-variant]"} =
             Enum.find(parts.root, &(&1.name == "[data-variant]"))

    for part <- [:track, :arc, :dot, :bar, :loop] do
      assert %FlintUI.Meta.PartAttr{name: "[data-part]"} =
               Enum.find(parts[part], &(&1.name == "[data-part]"))
    end
  end
end
