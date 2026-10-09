defmodule FlintUI.ToggleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias Phoenix.LiveView.JS

  defmodule TestComponent do
    use FlintUI

    def toggle_example(assigns) do
      ~H"""
      <.toggle
        pressed={@pressed}
        disabled={@disabled}
        type={@type}
        on_click={@on_click}
        data-role="test"
      >
        Bold
      </.toggle>
      """
    end
  end

  @defaults %{pressed: false, disabled: false, type: "button", on_click: nil}

  defp raw(overrides \\ %{}) do
    render_component(&TestComponent.toggle_example/1, Map.merge(@defaults, Map.new(overrides)))
  end

  defp render(overrides \\ %{}) do
    raw(overrides) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp ops(on_click) do
    %JS{ops: ops} =
      FlintUI.Toggle.build_attrs(%{
        type: "button",
        pressed: false,
        disabled: false,
        on_click: on_click
      }).root["phx-click"]

    Enum.map(ops, &hd/1)
  end

  describe "rendering" do
    test "renders a native button with a safe default type" do
      html = render()

      assert tag(html) == ["button"]
      assert attr(html, "type") == ["button"]
      assert attr(html, "data-element") == ["toggle"]
      assert attr(html, "data-part") == ["root"]
    end

    test "reflects the pressed state with aria-pressed and data-state" do
      html = render()

      assert attr(html, "aria-pressed") == ["false"]
      assert attr(html, "data-state") == ["off"]
      assert attr(html, "aria-disabled") == []

      html = render(pressed: true)

      assert attr(html, "aria-pressed") == ["true"]
      assert attr(html, "data-state") == ["on"]
    end

    test "reflects the disabled state" do
      html = render(disabled: true)

      assert attr(html, "disabled") == [""]
      assert attr(html, "data-disabled") == [""]
    end

    test "passes through global attributes" do
      html = render()

      assert attr(html, "data-role") == ["test"]
    end
  end

  describe "interaction" do
    test "always toggles aria-pressed and data-state client-side" do
      assert attr(render(), "phx-click") != []
      assert raw() =~ "toggle_attr"
      assert ops(nil) == ["toggle_attr", "toggle_attr"]
    end

    test "runs an event name before toggling" do
      assert ops("save") == ["push", "toggle_attr", "toggle_attr"]
    end

    test "runs a JS command before toggling" do
      assert ops(JS.push("save")) == ["push", "toggle_attr", "toggle_attr"]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :toggle, type: :element, status: :draft} = FlintUI.Toggle.meta()

      parts = FlintUI.Toggle.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "toggle"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))

      assert %FlintUI.Meta.PartAttr{value: ~s("on" | "off")} =
               Enum.find(parts.root, &(&1.name == "[data-state]"))

      assert Enum.any?(parts.root, &(&1.name == "aria-pressed"))
    end

    test "documents keyboard interactions" do
      assert [%FlintUI.Meta.Keyboard{keys: "Enter"}, %FlintUI.Meta.Keyboard{keys: "Space"}] =
               FlintUI.Toggle.keyboard()
    end
  end
end
