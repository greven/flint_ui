defmodule FlintUI.IconTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def default_example(assigns) do
      ~H"""
      <.icon name="lucide-house" />
      """
    end

    def icon_example(assigns) do
      ~H"""
      <.icon
        name={@name}
        class={@class}
        label={@label}
        phx-click="clicked"
        data-role="test"
      />
      """
    end
  end

  defp render(overrides \\ %{}) do
    assigns = Map.merge(%{name: "lucide-house", class: nil, label: nil}, Map.new(overrides))
    render_component(&TestComponent.icon_example/1, assigns) |> LazyHTML.from_fragment()
  end

  defp default_fragment do
    render_component(&TestComponent.default_example/1, %{}) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp class_list(html),
    do: attr(html, "class") |> Enum.join(" ") |> String.split(" ", trim: true)

  describe "icon" do
    test "renders a span with the icon class and a default size" do
      html = default_fragment()

      assert tag(html) == ["span"]
      assert attr(html, "data-element") == ["icon"]
      assert "lucide-house" in class_list(html)
      assert "size-4" in class_list(html)
    end

    test "is decorative by default" do
      html = render()

      assert attr(html, "aria-hidden") == ["true"]
      assert attr(html, "role") == []
      assert attr(html, "aria-label") == []
    end

    test "uses class for sizing and color" do
      html = render(class: "size-5 text-red-500")
      classes = class_list(html)

      assert "lucide-house" in classes
      assert "size-5" in classes
      assert "text-red-500" in classes
      refute "size-4" in classes
    end

    test "a label exposes the icon as an image" do
      html = render(label: "Error")

      assert attr(html, "role") == ["img"]
      assert attr(html, "aria-label") == ["Error"]
      assert attr(html, "aria-hidden") == []
    end

    test "passes through global attributes" do
      html = render()

      assert attr(html, "phx-click") == ["clicked"]
      assert attr(html, "data-role") == ["test"]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :icon, type: :element} = FlintUI.Icon.meta()

      parts = FlintUI.Icon.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "icon"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))
    end
  end
end
