defmodule FlintUI.LoadingTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def loading_example(assigns) do
      ~H"""
      <.loading
        variant={@variant}
        duration={@duration}
        class={@class}
        label={@label}
        data-role="test"
      />
      """
    end
  end

  @defaults %{variant: "ring", duration: 600, class: nil, label: nil}

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
      assert html =~ "animateTransform"
    end

    test "ring-bg adds a background track" do
      html = raw(variant: "ring-bg")

      assert html =~ ~s(data-variant="ring-bg")
      assert count(html, "<circle") == 2
      assert html =~ "animateTransform"
    end

    test "dots-fade animates three dots' opacity" do
      html = raw(variant: "dots-fade")

      assert count(html, "<circle") == 3
      assert html =~ ~s(attributeName="opacity")
    end

    test "dots-bounce animates three dots' position" do
      html = raw(variant: "dots-bounce")

      assert count(html, "<circle") == 3
      assert html =~ ~s(attributeName="cy")
    end

    test "raises on an unknown variant" do
      assert_raise ArgumentError, fn -> raw(variant: "nope") end
    end
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :loading, type: :element} = FlintUI.Loading.meta()

    parts = FlintUI.Loading.parts_attrs()

    assert %FlintUI.Meta.PartAttr{value: "loading"} =
             Enum.find(parts.root, &(&1.name == "[data-element]"))

    assert %FlintUI.Meta.PartAttr{name: "[data-variant]"} =
             Enum.find(parts.root, &(&1.name == "[data-variant]"))
  end
end
