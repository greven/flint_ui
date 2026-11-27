defmodule FlintUI.Base.LoadingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.TestDOM

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

  defp animation_duration(document, selector) do
    TestDOM.style_var(document, selector, "animation-duration")
  end

  defp style_values(document, selector, name) do
    document
    |> LazyHTML.query(selector)
    |> LazyHTML.attribute("style")
    |> Enum.map(&TestDOM.style_vars/1)
    |> Enum.map(& &1[name])
  end

  defp count_style(document, selector, name, value) do
    document
    |> style_values(selector, name)
    |> Enum.count(&(&1 == value))
  end

  test "renders an svg spinner, decorative by default" do
    html = render()

    assert tag(html) == ["svg"]
    assert attr(html, "data-element") == ["loading"]
    assert attr(html, "data-variant") == ["ring"]
    assert attr(html, "data-loading-indicator") == [""]
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
      document = render(variant: "ring")

      assert attr(document, "data-variant") == ["ring"]
      assert TestDOM.count(document, "circle") == 1
      assert TestDOM.count(document, ~s([data-part="arc"])) == 1
      assert animation_duration(document, ~s([data-part="arc"])) == "600ms"
      assert TestDOM.empty?(document, "animate")
    end

    test "ring-bg adds a background track" do
      document = render(variant: "ring-bg")

      assert attr(document, "data-variant") == ["ring-bg"]
      assert TestDOM.count(document, "circle") == 2
      assert TestDOM.count(document, ~s([data-part="track"])) == 1
      assert TestDOM.count(document, ~s([data-part="arc"])) == 1
      assert TestDOM.empty?(document, "animate")
    end

    test "ring-dash morphs the arc with two staggered animations" do
      document = render(variant: "ring-dash", duration: nil)

      assert attr(document, "data-variant") == ["ring-dash"]
      assert TestDOM.count(document, "circle") == 2
      assert TestDOM.count(document, ~s([data-part="track"])) == 1
      assert TestDOM.count(document, ~s([data-part="arc"])) == 1
      assert animation_duration(document, ~s([data-part="arc"])) == "1333ms, 1000ms"
      assert TestDOM.empty?(document, "animate")
    end

    test "variants fall back to their own default duration" do
      assert animation_duration(render(variant: "ring", duration: nil), ~s([data-part="arc"])) ==
               "600ms"

      assert animation_duration(
               render(variant: "dots-bounce", duration: nil),
               ~s([data-part="dot"])
             ) == "600ms"

      assert animation_duration(
               render(variant: "bars-scale", duration: nil),
               ~s([data-part="bar"])
             ) == "600ms"

      assert animation_duration(
               render(variant: "infinity", duration: nil),
               ~s([data-part="loop"])
             ) ==
               "2000ms"
    end

    test "every ring variant shares the same weight and radius" do
      for variant <- ~w(ring ring-bg ring-dash) do
        document = render(variant: variant, weight: nil)

        assert TestDOM.attr(document, ~s([data-part="arc"]), "r") == "9.5"
        assert TestDOM.attr(document, ~s([data-part="arc"]), "stroke-width") == "2.0"
      end
    end

    test "variants fall back to their own default weight" do
      assert TestDOM.attr(render(variant: "dots-fade", weight: nil), ~s([data-part="dot"]), "r") ==
               "2.0"

      assert TestDOM.attr(
               render(variant: "bars-scale", weight: nil),
               ~s([data-part="bar"]),
               "width"
             ) ==
               "2.8"
    end

    test "weight sets the ring stroke, dot radius, and bar width" do
      assert TestDOM.attr(
               render(variant: "ring", weight: 3),
               ~s([data-part="arc"]),
               "stroke-width"
             ) ==
               "3"

      assert TestDOM.attr(render(variant: "dots-fade", weight: 3), ~s([data-part="dot"]), "r") ==
               "3"

      document = render(variant: "bars-scale", weight: 4)
      assert TestDOM.count(document, ~s([width="4"])) == 5
    end

    test "raises on a non-positive weight" do
      assert_raise ArgumentError, fn -> raw(variant: "ring", weight: 0) end
    end

    test "dots-fade staggers three dots' opacity" do
      document = render(variant: "dots-fade")

      assert TestDOM.count(document, "circle") == 3
      assert TestDOM.count(document, ~s([data-part="dot"])) == 3

      delays = style_values(document, ~s([data-part="dot"]), "animation-delay")
      assert "-200ms" in delays
      assert "-400ms" in delays
      assert TestDOM.empty?(document, "animate")
    end

    test "dots-bounce staggers three dots' transform" do
      document = render(variant: "dots-bounce")

      assert TestDOM.count(document, "circle") == 3
      assert TestDOM.count(document, ~s([data-part="dot"])) == 3

      delays = style_values(document, ~s([data-part="dot"]), "animation-delay")
      assert "-200ms" in delays
      assert "-400ms" in delays
      assert TestDOM.empty?(document, "animate")
    end

    test "bars-scale draws five staggered bars" do
      document = render(variant: "bars-scale")

      assert TestDOM.count(document, "rect") == 5
      assert TestDOM.count(document, ~s([data-part="bar"])) == 5
      assert TestDOM.count(document, ~s([data-index])) == 5

      delays = style_values(document, ~s([data-part="bar"]), "animation-delay")

      for delay <- ~w(-66ms -133ms -200ms -266ms) do
        assert delay in delays
      end

      assert TestDOM.empty?(document, "animate")
    end

    test "infinity draws one continuously dashed loop" do
      document = render(variant: "infinity", duration: nil)
      loop = ~s([data-part="loop"])

      assert attr(document, "data-variant") == ["infinity"]
      assert TestDOM.count(document, "path") == 1
      assert TestDOM.count(document, loop) == 1
      assert TestDOM.attr(document, loop, "stroke-width") == "2.0"

      assert TestDOM.attr(document, loop, "stroke-dasharray") ==
               "41.054228515625 10.26355712890625"

      assert animation_duration(document, loop) == "2000ms"
      assert TestDOM.empty?(document, "animate")
    end

    test "infinity scales the stroke with weight" do
      document = render(variant: "infinity", weight: 3)

      assert TestDOM.attr(document, ~s([data-part="loop"]), "stroke-width") == "3"
    end

    test "duration publishes the cycle length on every animated part" do
      document = render(variant: "dots-fade", duration: 300)

      assert count_style(document, ~s([data-part="dot"]), "animation-duration", "300ms") == 3

      delays = style_values(document, ~s([data-part="dot"]), "animation-delay")
      assert "-100ms" in delays
      assert "-200ms" in delays
    end

    test "ring-dash scales both cycles from duration" do
      document = render(variant: "ring-dash", duration: 1500)

      assert animation_duration(document, ~s([data-part="arc"])) == "2000ms, 1500ms"
    end

    test "raises on an unknown variant" do
      assert_raise ArgumentError, fn -> raw(variant: "nope") end
    end
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :loading, type: :feedback} = FlintUI.Base.Loading.meta()

    parts = FlintUI.Base.Loading.parts_attrs()

    assert %FlintUI.Meta.PartAttr{value: "loading"} =
             Enum.find(parts[:root], &(&1.name == "[data-element]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-variant]"} =
             Enum.find(parts[:root], &(&1.name == "[data-variant]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-loading-indicator]"} =
             Enum.find(parts[:root], &(&1.name == "[data-loading-indicator]"))

    for part <- [:track, :arc, :dot, :bar, :loop] do
      assert %FlintUI.Meta.PartAttr{name: "[data-part]"} =
               Enum.find(parts[part], &(&1.name == "[data-part]"))
    end
  end
end
