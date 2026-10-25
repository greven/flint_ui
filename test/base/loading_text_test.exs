defmodule FlintUI.Base.LoadingTextTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

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
  defp count(%LazyHTML{} = html, needle), do: count(LazyHTML.to_html(html), needle)

  defp count(html, needle) when is_binary(html) do
    length(Regex.scan(~r/#{Regex.escape(needle)}/, html))
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

  test "renders a span root with the copy" do
    html = render()

    assert tag(html) == ["span"]
    assert attr(html, "data-element") == ["loading_text"]
    assert attr(html, "data-part") == ["root"]
    assert attr(html, "data-variant") == ["dots"]
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
    refute raw(text: "<b>Hi</b>") =~ "<b>"
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

      assert LazyHTML.attribute(LazyHTML.query(html, ~s([data-part="dot"])), "style") == [
               "animation-duration: 700ms; animation-delay: 0ms",
               "animation-duration: 700ms; animation-delay: 100ms",
               "animation-duration: 700ms; animation-delay: 200ms"
             ]
    end

    test "dots default to a 1400ms cycle" do
      assert raw(%{}) =~ "animation-duration: 1400ms"
    end
  end

  describe "variants" do
    test "blink pulses the text part" do
      html = raw(variant: "blink")

      assert html =~ ~s(data-variant="blink")
      assert html =~ ~s(data-part="text")
      assert html =~ "animation-duration: 2000ms"
      assert count(html, ~s(data-part="dot")) == 0
      refute html =~ "<animate"
    end

    test "shimmer animates the text part" do
      html = raw(variant: "shimmer")

      assert html =~ ~s(data-variant="shimmer")
      assert html =~ ~s(data-part="text")
      assert html =~ "animation-duration: 2000ms"
      assert count(html, ~s(data-part="dot")) == 0
      refute html =~ "<animate"
    end

    test "wave splits the copy into graphemes" do
      html = raw(variant: "wave", text: "Ab c", duration: 1000)

      assert html =~ ~s(data-variant="wave")
      assert count(html, ~s(data-part="char")) == 4
      assert part_text(html, "text") == "Ab c"
      assert count(html, ~s(data-part="dot")) == 0
      assert html =~ "animation-delay: 0ms"
      assert html =~ "animation-delay: 250ms"
      assert html =~ "animation-delay: 500ms"
      assert html =~ "animation-delay: 750ms"
      refute html =~ "<animate"
    end

    test "each variant has its own default duration" do
      assert raw(variant: "dots") =~ "animation-duration: 1400ms"
      assert raw(variant: "blink") =~ "animation-duration: 2000ms"
      assert raw(variant: "shimmer") =~ "animation-duration: 2000ms"
      assert raw(variant: "wave") =~ "animation-duration: 1000ms"
    end

    test "duration overrides the variant default" do
      assert raw(variant: "blink", duration: 300) =~ "animation-duration: 300ms"
      assert raw(variant: "shimmer", duration: 300) =~ "animation-duration: 300ms"
      assert raw(variant: "wave", duration: 500) =~ "animation-duration: 500ms"
    end

    test "raises on an unknown variant" do
      assert_raise ArgumentError, fn -> raw(variant: "nope") end
    end
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :loading_text, type: :element} =
             FlintUI.Base.LoadingText.meta()

    parts = FlintUI.Base.LoadingText.parts_attrs()

    assert %FlintUI.Meta.PartAttr{value: "loading_text"} =
             Enum.find(parts.root, &(&1.name == "[data-element]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-variant]"} =
             Enum.find(parts.root, &(&1.name == "[data-variant]"))

    for part <- [:text, :dots, :dot, :char] do
      assert %FlintUI.Meta.PartAttr{name: "[data-part]"} =
               Enum.find(parts[part], &(&1.name == "[data-part]"))
    end
  end
end
