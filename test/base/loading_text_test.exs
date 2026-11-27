defmodule FlintUI.Base.LoadingTextTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.TestDOM

  defmodule TestComponent do
    use FlintUI

    def loading_text_example(assigns) do
      ~H"""
      <.loading_text
        text={@text}
        variant={@variant}
        duration={@duration}
        dots={@dots}
        class={@class}
        data-role="test"
      />
      """
    end
  end

  @defaults %{text: "Loading", variant: "dots", duration: nil, dots: 3, class: nil}

  defp raw(overrides) do
    render_component(
      &TestComponent.loading_text_example/1,
      Map.merge(@defaults, Map.new(overrides))
    )
  end

  defp render(overrides \\ %{}) do
    raw(overrides) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp count(%LazyHTML{} = html, attr_selector) do
    selector = "[#{String.trim_trailing(attr_selector, "=")}]"
    TestDOM.count(html, selector)
  end

  defp count(html, selector) when is_binary(html) do
    html
    |> LazyHTML.from_fragment()
    |> count(selector)
  end

  defp part_text(%LazyHTML{} = html, part) do
    html
    |> LazyHTML.query(~s([data-part="#{part}"]))
    |> LazyHTML.text()
    |> String.trim()
  end

  defp part_text(html, part) when is_binary(html) do
    html
    |> LazyHTML.from_fragment()
    |> part_text(part)
  end

  defp style_values(document, selector, name) do
    document
    |> LazyHTML.query(selector)
    |> LazyHTML.attribute("style")
    |> Enum.map(&TestDOM.style_vars/1)
    |> Enum.map(& &1[name])
  end

  test "renders a span root with the copy" do
    html = render()

    assert tag(html) == ["span"]
    assert attr(html, "data-element") == ["loading_text"]
    assert attr(html, "data-part") == ["root"]
    assert attr(html, "data-variant") == ["dots"]
    assert attr(html, "data-loading-indicator") == [""]
    assert part_text(html, "text") == "Loading"
  end

  test "applies class and passes through global attributes" do
    html = render(class: "text-sm text-zinc-500")

    assert attr(html, "class") == ["text-sm text-zinc-500"]
    assert attr(html, "data-role") == ["test"]
  end

  test "renders escaped text" do
    html = render(text: "<b>Hi</b>")

    assert part_text(html, "text") == "<b>Hi</b>"
  end

  describe "dots" do
    test "appends three decorative dots by default" do
      html = render()

      assert count(html, ~s(data-part="dot")) == 3
      assert count(html, ~s(data-index=)) == 3

      dots = LazyHTML.query(html, ~s([data-part="dots"]))
      assert LazyHTML.attribute(dots, "aria-hidden") == ["true"]
    end

    test "the dot count is configurable" do
      assert count(raw(dots: 1), ~s(data-part="dot")) == 1
      assert count(raw(dots: 5), ~s(data-part="dot")) == 5
    end

    test "values below one are treated as one" do
      assert count(raw(dots: 0), ~s(data-part="dot")) == 1
      assert count(raw(dots: -2), ~s(data-part="dot")) == 1
    end

    test "dots start from left to right" do
      html = render(duration: 700)

      dots =
        html
        |> LazyHTML.query(~s([data-part="dot"]))
        |> LazyHTML.attribute("style")
        |> Enum.map(&TestDOM.style_vars/1)

      assert Enum.map(dots, & &1["animation-duration"]) == ["700ms", "700ms", "700ms"]
      assert Enum.map(dots, & &1["animation-delay"]) == ["0ms", "100ms", "200ms"]
    end

    test "dots default to a 1400ms cycle" do
      html = render()

      assert TestDOM.style_var(html, ~s([data-part="dot"]), "animation-duration") == "1400ms"
    end
  end

  describe "variants" do
    test "blink pulses the text part" do
      document = render(variant: "blink")

      assert attr(document, "data-variant") == ["blink"]
      assert TestDOM.count(document, ~s([data-part="text"])) == 1
      assert TestDOM.style_var(document, ~s([data-part="text"]), "animation-duration") == "2000ms"
      assert TestDOM.count(document, ~s([data-part="dot"])) == 0
      assert TestDOM.empty?(document, "animate")
    end

    test "shimmer animates the text part" do
      document = render(variant: "shimmer")

      assert attr(document, "data-variant") == ["shimmer"]
      assert TestDOM.count(document, ~s([data-part="text"])) == 1
      assert TestDOM.style_var(document, ~s([data-part="text"]), "animation-duration") == "2000ms"
      assert TestDOM.count(document, ~s([data-part="dot"])) == 0
      assert TestDOM.empty?(document, "animate")
    end

    test "wave splits the copy into graphemes" do
      document = render(variant: "wave", text: "Ab c", duration: 1000)

      assert attr(document, "data-variant") == ["wave"]
      assert TestDOM.count(document, ~s([data-part="char"])) == 4
      assert part_text(document, "text") == "Ab c"
      assert TestDOM.count(document, ~s([data-part="dot"])) == 0

      assert style_values(document, ~s([data-part="char"]), "animation-delay") == [
               "0ms",
               "250ms",
               "500ms",
               "750ms"
             ]

      assert TestDOM.empty?(document, "animate")
    end

    test "each variant has its own default duration" do
      assert TestDOM.style_var(
               render(variant: "dots"),
               ~s([data-part="dot"]),
               "animation-duration"
             ) ==
               "1400ms"

      assert TestDOM.style_var(
               render(variant: "blink"),
               ~s([data-part="text"]),
               "animation-duration"
             ) == "2000ms"

      assert TestDOM.style_var(
               render(variant: "shimmer"),
               ~s([data-part="text"]),
               "animation-duration"
             ) == "2000ms"

      assert TestDOM.style_var(
               render(variant: "wave"),
               ~s([data-part="char"]),
               "animation-duration"
             ) ==
               "1000ms"
    end

    test "duration overrides the variant default" do
      for {variant, part} <- [{"dots", "dot"}, {"blink", "text"}, {"shimmer", "text"}] do
        document = render(variant: variant, duration: 300)

        assert TestDOM.style_var(document, ~s([data-part="#{part}"]), "animation-duration") ==
                 "300ms"
      end

      assert TestDOM.style_var(
               render(variant: "wave", duration: 500),
               ~s([data-part="char"]),
               "animation-duration"
             ) == "500ms"
    end

    test "raises on an unknown variant" do
      assert_raise ArgumentError, fn -> raw(variant: "nope") end
    end
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :loading_text, type: :feedback} =
             FlintUI.Base.LoadingText.meta()

    parts = FlintUI.Base.LoadingText.parts_attrs()

    assert %FlintUI.Meta.PartAttr{value: "loading_text"} =
             Enum.find(parts[:root], &(&1.name == "[data-element]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-variant]"} =
             Enum.find(parts[:root], &(&1.name == "[data-variant]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-loading-indicator]"} =
             Enum.find(parts[:root], &(&1.name == "[data-loading-indicator]"))

    for part <- [:text, :dots, :dot, :char] do
      assert %FlintUI.Meta.PartAttr{name: "[data-part]"} =
               Enum.find(parts[part], &(&1.name == "[data-part]"))
    end
  end
end
