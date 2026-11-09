defmodule FlintUI.Base.FlagTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def default_example(assigns) do
      ~H"""
      <.flag name="flag-pt" />
      """
    end

    def flag_example(assigns) do
      ~H"""
      <.flag
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
    assigns = Map.merge(%{name: "flag-pt", class: nil, label: nil}, Map.new(overrides))
    render_component(&TestComponent.flag_example/1, assigns) |> LazyHTML.from_fragment()
  end

  defp default_fragment do
    render_component(&TestComponent.default_example/1, %{}) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp class_list(html),
    do: attr(html, "class") |> Enum.join(" ") |> String.split(" ", trim: true)

  describe "flag" do
    test "renders a span with the flag class and no built-in size" do
      html = default_fragment()

      assert tag(html) == ["span"]
      assert attr(html, "data-element") == ["flag"]
      assert class_list(html) == ["flag-pt"]
    end

    test "is decorative by default" do
      html = render()

      assert attr(html, "aria-hidden") == ["true"]
      assert attr(html, "role") == []
      assert attr(html, "aria-label") == []
    end

    test "keeps extra classes" do
      html = render(class: "rounded shadow")
      classes = class_list(html)

      assert "flag-pt" in classes
      assert "rounded" in classes
      assert "shadow" in classes
    end

    test "a label exposes the flag as an image" do
      html = render(label: "Portugal")

      assert attr(html, "role") == ["img"]
      assert attr(html, "aria-label") == ["Portugal"]
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
      assert %FlintUI.Meta{name: :flag, type: :element} = FlintUI.Base.Flag.meta()

      parts = FlintUI.Base.Flag.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "flag"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))
    end
  end
end
