defmodule FlintUI.Base.ToggleTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias Phoenix.LiveView.JS

  defmodule TestComponent do
    use FlintUI

    def toggle_example(assigns) do
      ~H"""
      <.toggle
        toggled={@toggled}
        disabled={@disabled}
        loading={@loading}
        type={@type}
        phx-click={@phx_click}
        data-role="test"
      >
        Bold
      </.toggle>
      """
    end
  end

  @defaults %{
    toggled: false,
    disabled: false,
    loading: false,
    type: "button",
    phx_click: nil
  }

  defp raw(overrides \\ %{}) do
    render_component(&TestComponent.toggle_example/1, Map.merge(@defaults, Map.new(overrides)))
  end

  defp render(overrides \\ %{}) do
    raw(overrides) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp ops(html) do
    html
    |> attr("phx-click")
    |> hd()
    |> JSON.decode!()
    |> Enum.map(&hd/1)
  end

  describe "rendering" do
    test "renders a native button with a safe default type" do
      html = render()

      assert tag(html) == ["button"]
      assert attr(html, "type") == ["button"]
      assert attr(html, "data-element") == ["toggle"]
      assert attr(html, "data-part") == ["root"]
    end

    test "reflects the toggled state with aria-pressed and data-state" do
      html = render()

      assert attr(html, "aria-pressed") == ["false"]
      assert attr(html, "data-state") == ["off"]
      assert attr(html, "aria-disabled") == []

      html = render(toggled: true)

      assert attr(html, "aria-pressed") == ["true"]
      assert attr(html, "data-state") == ["on"]
    end

    test "reflects the disabled state" do
      html = render(disabled: true)

      assert attr(html, "disabled") == [""]
      assert attr(html, "data-disabled") == [""]
    end

    test "loading is pending, not disabled" do
      html = render(loading: true)

      assert attr(html, "data-loading") == [""]
      assert attr(html, "aria-busy") == ["true"]
      assert attr(html, "aria-disabled") == ["true"]
      assert attr(html, "disabled") == []
      assert attr(html, "data-disabled") == []
    end

    test "a pending submit keeps the state hook but does not submit" do
      html = render(loading: true, type: "submit")

      assert attr(html, "type") == ["button"]
      assert attr(html, "data-pending-submit") == [""]
      assert attr(html, "data-state") == ["off"]

      html = render(type: "submit")

      assert attr(html, "type") == ["submit"]
      assert attr(html, "data-pending-submit") == []
    end

    test "passes through global attributes" do
      html = render()

      assert attr(html, "data-role") == ["test"]
    end
  end

  describe "interaction" do
    test "always toggles aria-pressed and data-state client-side" do
      html = render()

      assert attr(html, "phx-click") != []
      assert raw() =~ "toggle_attr"
      assert ops(html) == ["toggle_attr", "toggle_attr"]
    end

    test "toggles before running a caller event name" do
      assert ops(render(phx_click: "save")) == ["toggle_attr", "toggle_attr", "push"]
    end

    test "toggles before running a caller JS command" do
      assert ops(render(phx_click: JS.push("save"))) == ["toggle_attr", "toggle_attr", "push"]
    end

    test "renders the composed click once" do
      assert length(Regex.scan(~r/phx-click=/, raw(phx_click: JS.push("save")))) == 1
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :toggle, type: :action, status: :draft} =
               FlintUI.Base.Toggle.meta()

      parts = FlintUI.Base.Toggle.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "toggle"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert %FlintUI.Meta.PartAttr{value: ~s("on" | "off")} =
               Enum.find(parts[:root], &(&1.name == "[data-state]"))

      assert Enum.any?(parts[:root], &(&1.name == "aria-pressed"))
      assert Enum.any?(parts[:root], &(&1.name == "[data-loading]"))
      assert Enum.any?(parts[:root], &(&1.name == "aria-busy"))
      assert Enum.any?(parts[:root], &(&1.name == "[data-pending-submit]"))
    end

    test "documents keyboard interactions" do
      assert [
               %FlintUI.Meta.Keyboard{keys: "Tab"},
               %FlintUI.Meta.Keyboard{keys: "Enter"},
               %FlintUI.Meta.Keyboard{keys: "Space"}
             ] = FlintUI.Base.Toggle.keyboard()
    end

    test "documents the state selectors" do
      names = FlintUI.Base.Toggle.states() |> Enum.map(& &1.name)

      assert names == ["on", "off", "disabled", "loading", "pending-submit"]
    end
  end
end
