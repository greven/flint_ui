defmodule FlintUI.Base.DropdownItemTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def button_example(assigns) do
      assigns =
        assigns
        |> assign_new(:intent, fn -> "neutral" end)
        |> assign_new(:disabled, fn -> false end)
        |> assign_new(:as, fn -> "button" end)

      ~H"""
      <.dropdown_item
        intent={@intent}
        disabled={@disabled}
        as={@as}
        class="extra"
        data-role="test"
      >
        Settings
      </.dropdown_item>
      """
    end

    def link(assigns) do
      ~H"""
      <.dropdown_item href="https://example.com" target="_blank">Billing</.dropdown_item>
      """
    end

    def navigate(assigns) do
      ~H"""
      <.dropdown_item navigate="/account">Account</.dropdown_item>
      """
    end

    def disabled_link(assigns) do
      ~H"""
      <.dropdown_item href="/account" disabled>Account</.dropdown_item>
      """
    end

    def custom(assigns) do
      ~H"""
      <.dropdown_item custom>
        <p>Signed in as ada@example.com</p>
      </.dropdown_item>
      """
    end

    def as_div(assigns) do
      ~H"""
      <.dropdown_item as="div">Settings</.dropdown_item>
      """
    end
  end

  defp render(function, assigns \\ []) do
    render_component(&apply(TestComponent, function, [&1]), assigns)
    |> LazyHTML.from_fragment()
  end

  defp item(document), do: LazyHTML.query(document, ~s([data-element="dropdown_item"]))

  describe "button form" do
    test "is a native button with the menuitem wiring" do
      document = render(:button_example)
      item = item(document)

      assert LazyHTML.tag(item) == ["button"]
      assert LazyHTML.attribute(item, "type") == ["button"]
      assert LazyHTML.attribute(item, "role") == ["menuitem"]
      assert LazyHTML.attribute(item, "tabindex") == ["-1"]
      assert LazyHTML.attribute(item, "data-part") == ["item"]
      assert LazyHTML.attribute(item, "data-intent") == ["neutral"]
      assert LazyHTML.attribute(item, "data-disabled") == []
      assert LazyHTML.attribute(item, "aria-disabled") == []
      assert LazyHTML.attribute(item, "class") == ["extra"]
      assert LazyHTML.attribute(item, "data-role") == ["test"]
    end

    test "forwards intent" do
      item = item(render(:button_example, intent: "danger"))

      assert LazyHTML.attribute(item, "data-intent") == ["danger"]
    end

    test "renders a disabled button with the native state" do
      item = item(render(:button_example, disabled: true))

      assert LazyHTML.attribute(item, "disabled") == [""]
      assert LazyHTML.attribute(item, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(item, "data-disabled") == [""]
    end

    test "an as=div item keeps the menuitem role and tab stop" do
      item = item(render(:as_div))

      assert LazyHTML.tag(item) == ["div"]
      assert LazyHTML.attribute(item, "role") == ["menuitem"]
      assert LazyHTML.attribute(item, "tabindex") == ["-1"]
    end
  end

  describe "link form" do
    test "renders an anchor with the menuitem role" do
      item = item(render(:link))

      assert LazyHTML.tag(item) == ["a"]
      assert LazyHTML.attribute(item, "href") == ["https://example.com"]
      assert LazyHTML.attribute(item, "target") == ["_blank"]
      assert LazyHTML.attribute(item, "role") == ["menuitem"]
      assert LazyHTML.attribute(item, "tabindex") == ["-1"]
    end

    test "uses the LiveView link for navigate" do
      item = item(render(:navigate))

      assert LazyHTML.tag(item) == ["a"]
      assert LazyHTML.attribute(item, "href") == ["/account"]
      assert LazyHTML.attribute(item, "data-phx-link") == ["redirect"]
      assert LazyHTML.attribute(item, "role") == ["menuitem"]
    end

    test "a disabled link drops its destination and stays discoverable" do
      item = item(render(:disabled_link))

      assert LazyHTML.tag(item) == ["a"]
      assert LazyHTML.attribute(item, "href") == []
      assert LazyHTML.attribute(item, "role") == ["menuitem"]
      assert LazyHTML.attribute(item, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(item, "data-disabled") == [""]
    end
  end

  describe "custom form" do
    test "is a non-interactive content block" do
      item = item(render(:custom))

      assert LazyHTML.tag(item) == ["div"]
      assert LazyHTML.attribute(item, "data-custom") == [""]
      assert LazyHTML.attribute(item, "role") == []
      assert LazyHTML.attribute(item, "tabindex") == []
      assert LazyHTML.text(item) =~ "Signed in as ada@example.com"
    end
  end
end
