defmodule FlintUI.Base.ButtonTest do
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

    def button_with_tabindex(assigns) do
      ~H"""
      <.button
        href={@href}
        disabled={@disabled}
        loading={@loading}
        tabindex={@tabindex}
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

    test "renders loading as a focusable pending state without disabling" do
      html = render(loading: true)

      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "data-loading") == [""]
      assert attr(html, "data-disabled") == []
      assert attr(html, "disabled") == []
      assert attr(html, "tabindex") == []
      assert attr(html, "data-pending-submit") == []
    end

    test "a pending submit button renders as a non-submitting button" do
      html = render(type: "submit", loading: true)

      assert tag(html) == ["button"]
      assert attr(html, "type") == ["button"]
      assert attr(html, "data-pending-submit") == [""]
      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "disabled") == []
    end

    test "a ready submit button keeps its submit type" do
      html = render(type: "submit")

      assert attr(html, "type") == ["submit"]
      assert attr(html, "data-pending-submit") == []
    end

    test "a pending reset button keeps its reset type" do
      html = render(type: "reset", loading: true)

      assert attr(html, "type") == ["reset"]
      assert attr(html, "data-pending-submit") == []
    end

    test "loading and disabled render a hard-disabled pending button" do
      html = render(loading: true, disabled: true)

      assert attr(html, "disabled") == [""]
      assert attr(html, "data-disabled") == [""]
      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "data-loading") == [""]
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
      assert attr(html, "role") == []
      assert attr(html, "tabindex") == []
      assert attr(html, "aria-disabled") == []
      assert attr(html, "aria-busy") == []
    end

    test "an empty href renders the action button form" do
      html = render(href: "")

      assert tag(html) == ["button"]
      assert attr(html, "href") == []
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

    test "a loading link drops its destination but stays discoverable" do
      html = render(href: "/foo", loading: true)

      assert tag(html) == ["a"]
      assert attr(html, "href") == []
      assert attr(html, "role") == ["link"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "tabindex") == ["0"]
      assert attr(html, "data-loading") == [""]
      assert attr(html, "data-disabled") == []
    end

    test "a pending navigate link drops its LiveView navigation metadata" do
      html = render(navigate: "/foo", loading: true)

      assert tag(html) == ["a"]
      assert attr(html, "href") == []
      assert attr(html, "data-phx-link") == []
      assert attr(html, "role") == ["link"]
      assert attr(html, "tabindex") == ["0"]
    end

    test "a pending patch link drops its LiveView navigation metadata" do
      html = render(patch: "/foo", loading: true)

      assert tag(html) == ["a"]
      assert attr(html, "href") == []
      assert attr(html, "data-phx-link") == []
      assert attr(html, "role") == ["link"]
      assert attr(html, "tabindex") == ["0"]
    end

    test "a disabled or pending link keeps a caller-supplied tabindex exactly once" do
      assigns = %{href: "/foo", disabled: true, loading: false, tabindex: "-1"}
      html = render_component(&TestComponent.button_with_tabindex/1, assigns)

      assert attr(LazyHTML.from_fragment(html), "tabindex") == ["-1"]

      assigns = %{href: "/foo", disabled: false, loading: true, tabindex: "-1"}
      html = render_component(&TestComponent.button_with_tabindex/1, assigns)

      assert attr(LazyHTML.from_fragment(html), "tabindex") == ["-1"]
    end

    test "a loading and disabled link combines both states" do
      html = render(href: "/foo", loading: true, disabled: true)

      assert tag(html) == ["a"]
      assert attr(html, "href") == []
      assert attr(html, "role") == ["link"]
      assert attr(html, "tabindex") == ["0"]
      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "data-loading") == [""]
      assert attr(html, "data-disabled") == [""]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :button, type: :action} = FlintUI.Base.Button.meta()

      parts = FlintUI.Base.Button.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "button"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))

      assert Enum.any?(parts.root, &(&1.name == "aria-busy"))
      assert Enum.any?(parts.root, &(&1.name == "aria-disabled"))
      assert Enum.any?(parts.root, &(&1.name == "role"))
      assert Enum.any?(parts.root, &(&1.name == "tabindex"))
      assert Enum.any?(parts.root, &(&1.name == "[data-pending-submit]"))
    end

    test "documents keyboard interactions" do
      assert [
               %FlintUI.Meta.Keyboard{keys: "Tab"},
               %FlintUI.Meta.Keyboard{keys: "Enter"},
               %FlintUI.Meta.Keyboard{keys: "Space"}
             ] = FlintUI.Base.Button.keyboard()
    end
  end
end
