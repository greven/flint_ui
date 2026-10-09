defmodule FlintUI.ButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def button_example(assigns) do
      ~H"""
      <.button
        type={@type}
        disabled={@disabled}
        loading={@loading}
        href={@href}
        navigate={@navigate}
        patch={@patch}
        phx-click="clicked"
        data-role="test"
      >
        Click
      </.button>
      """
    end
  end

  @defaults %{
    type: "button",
    disabled: false,
    loading: false,
    href: nil,
    navigate: nil,
    patch: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.button_example/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  describe "action button" do
    test "renders a native button with a safe default type" do
      html = render()

      assert tag(html) == ["button"]
      assert attr(html, "type") == ["button"]
      assert attr(html, "data-element") == ["button"]
      assert attr(html, "tabindex") == []
    end

    test "reflects disabled through the native attribute and data flag" do
      html = render(disabled: true)

      assert attr(html, "disabled") == [""]
      assert attr(html, "data-disabled") == [""]
      assert attr(html, "aria-disabled") == []
    end

    test "renders loading with aria-busy and suppresses interaction" do
      html = render(loading: true)

      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "data-loading") == [""]
      assert attr(html, "data-disabled") == [""]
      assert attr(html, "disabled") == [""]
    end

    test "passes through global attributes" do
      html = render()

      assert attr(html, "phx-click") == ["clicked"]
      assert attr(html, "data-role") == ["test"]
    end
  end

  describe "link" do
    test "renders a link when href is given" do
      html = render(href: "/foo")

      assert tag(html) == ["a"]
      assert attr(html, "href") == ["/foo"]
      assert attr(html, "data-element") == ["button"]
      assert attr(html, "type") == []
      assert attr(html, "disabled") == []
    end

    test "renders a LiveView navigate link" do
      html = render(navigate: "/foo")

      assert tag(html) == ["a"]
      assert attr(html, "href") == ["/foo"]
      assert attr(html, "data-phx-link") == ["redirect"]
    end

    test "renders a LiveView patch link" do
      html = render(patch: "/foo")

      assert tag(html) == ["a"]
      assert attr(html, "data-phx-link") == ["patch"]
    end

    test "a disabled link drops its destination but stays discoverable" do
      html = render(href: "/foo", disabled: true)

      assert tag(html) == ["a"]
      assert attr(html, "href") == []
      assert attr(html, "role") == ["link"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "tabindex") == ["0"]
      assert attr(html, "data-disabled") == [""]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :button, type: :element} = FlintUI.Button.meta()

      parts = FlintUI.Button.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "button"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))

      assert Enum.any?(parts.root, &(&1.name == "aria-busy"))
    end

    test "documents keyboard interactions" do
      assert [%FlintUI.Meta.Keyboard{keys: "Enter"}, %FlintUI.Meta.Keyboard{keys: "Space"}] =
               FlintUI.Button.keyboard()
    end
  end
end
