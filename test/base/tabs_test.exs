defmodule FlintUI.Base.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def tabs_example(assigns) do
      assigns =
        assigns
        |> assign_new(:value, fn -> nil end)
        |> assign_new(:label, fn -> "Sections" end)
        |> assign_new(:orientation, fn -> "horizontal" end)
        |> assign_new(:activation_mode, fn -> "automatic" end)
        |> assign_new(:loop, fn -> true end)
        |> assign_new(:disabled, fn -> false end)
        |> assign_new(:findable, fn -> false end)
        |> assign_new(:scrollable, fn -> false end)
        |> assign_new(:fadable, fn -> false end)
        |> assign_new(:change_event, fn -> nil end)
        |> assign_new(:tab_b_disabled, fn -> false end)
        |> assign_new(:panel_focusable, fn -> true end)
        |> assign_new(:tab_class, fn -> nil end)
        |> assign_new(:panel_class, fn -> nil end)

      ~H"""
      <.tabs
        id="test"
        value={@value}
        label={@label}
        orientation={@orientation}
        activation_mode={@activation_mode}
        loop={@loop}
        disabled={@disabled}
        findable={@findable}
        scrollable={@scrollable}
        fadable={@fadable}
        change_event={@change_event}
      >
        <:tab value="a" class={@tab_class}>A</:tab>
        <:tab value="b" disabled={@tab_b_disabled}>B</:tab>
        <:tab value="c">C</:tab>
        <:panel value="a" focusable={@panel_focusable} class={@panel_class}>Panel A</:panel>
        <:panel value="b">Panel B</:panel>
        <:panel value="c">Panel C</:panel>
      </.tabs>
      """
    end

    def tabs_without_panels(assigns) do
      ~H"""
      <.tabs id="switcher" value="list" label="View">
        <:tab value="list">List</:tab>
        <:tab value="grid">Grid</:tab>
      </.tabs>
      """
    end

    def custom_tabs(assigns) do
      ~H"""
      <.tabs id="custom" value="a" label="Custom">
        <:tab value="a">A</:tab>
        <:tab :let={attrs} value="b" custom>
          <FlintUI.button {attrs} class="custom-button">B</FlintUI.button>
        </:tab>
        <:tab :let={attrs} value="c" custom aria_label="C tab">
          <a {attrs} href="/c">C</a>
        </:tab>
        <:tab :let={attrs} value="d" custom>
          <FlintUI.button {attrs} class="custom-link" patch="/d">D</FlintUI.button>
        </:tab>
        <:panel value="a">Panel A</:panel>
        <:panel value="b">Panel B</:panel>
        <:panel value="c">Panel C</:panel>
        <:panel value="d">Panel D</:panel>
      </.tabs>
      """
    end

    def disabled_first(assigns) do
      ~H"""
      <.tabs id="first-disabled" label="Sections">
        <:tab value="a" disabled>A</:tab>
        <:tab value="b">B</:tab>
        <:panel value="a">Panel A</:panel>
        <:panel value="b">Panel B</:panel>
      </.tabs>
      """
    end
  end

  defp render(assigns \\ []) do
    render_component(&TestComponent.tabs_example/1, assigns)
    |> LazyHTML.from_fragment()
  end

  defp part(html, name), do: LazyHTML.query(html, ~s([data-part="#{name}"]))

  defp tab(html, value) do
    LazyHTML.query(html, ~s([data-tabs-trigger][data-value="#{value}"]))
  end

  defp panel(html, value) do
    LazyHTML.query(html, ~s([data-part="panel"][data-value="#{value}"]))
  end

  defp attr(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  describe "root" do
    test "identifies the component and wires the namespaced hook" do
      root = part(render(), "root")

      assert LazyHTML.attribute(root, "id") == ["test"]
      assert LazyHTML.attribute(root, "phx-hook") == ["FlintUI.Tabs"]
      assert LazyHTML.attribute(root, "data-element") == ["tabs"]
      assert LazyHTML.attribute(root, "data-part") == ["root"]
      assert LazyHTML.attribute(root, "data-orientation") == ["horizontal"]
      assert LazyHTML.attribute(root, "data-activation") == ["automatic"]
      assert LazyHTML.attribute(root, "data-loop") == ["true"]
    end

    test "reflects the active value and falls back to the first enabled tab" do
      assert attr(render(), ~s([data-part="root"]), "data-value") == ["a"]
      assert attr(render(value: "b"), ~s([data-part="root"]), "data-value") == ["b"]
      assert attr(render(value: "nope"), ~s([data-part="root"]), "data-value") == ["a"]
    end

    test "skips a disabled first tab when deriving the fallback" do
      html =
        render_component(&TestComponent.disabled_first/1, %{}) |> LazyHTML.from_fragment()

      assert attr(html, ~s([data-part="root"]), "data-value") == ["b"]
    end

    test "reflects orientation, activation, loop, and disabled" do
      root = ~s([data-part="root"])

      html =
        render(
          orientation: "vertical",
          activation_mode: "manual",
          loop: false,
          disabled: true
        )

      assert attr(html, root, "data-orientation") == ["vertical"]
      assert attr(html, root, "data-activation") == ["manual"]
      assert attr(html, root, "data-loop") == ["false"]
      assert attr(html, root, "data-disabled") == [""]
    end

    test "exposes the server event only when set" do
      root = ~s([data-part="root"])

      assert attr(render(), root, "data-change-event") == []

      assert attr(render(change_event: "tab_changed"), root, "data-change-event") ==
               ["tab_changed"]
    end

    test "flags findable, scrollable, and fadable" do
      root = ~s([data-part="root"])

      assert attr(render(), root, "data-findable") == []
      assert attr(render(), root, "data-scrollable") == []
      assert attr(render(), root, "data-fadable") == []

      html = render(findable: true, scrollable: true, fadable: true)

      assert attr(html, root, "data-findable") == [""]
      assert attr(html, root, "data-scrollable") == [""]
      assert attr(html, root, "data-fadable") == [""]
    end
  end

  describe "tablist" do
    test "has the tab list role and the accessible name" do
      tablist = part(render(), "tablist")

      assert LazyHTML.attribute(tablist, "role") == ["tablist"]
      assert LazyHTML.attribute(tablist, "aria-orientation") == ["horizontal"]
      assert LazyHTML.attribute(tablist, "aria-label") == ["Sections"]
      assert LazyHTML.attribute(tablist, "data-orientation") == ["horizontal"]

      html = render(orientation: "vertical", label: nil)
      tablist = part(html, "tablist")

      assert LazyHTML.attribute(tablist, "aria-orientation") == ["vertical"]
      assert LazyHTML.attribute(tablist, "aria-label") == []
    end
  end

  describe "tabs" do
    test "wire the tab role, ids, and panel references" do
      html = render()
      a = tab(html, "a")

      assert LazyHTML.tag(a) == ["button"]
      assert LazyHTML.attribute(a, "type") == ["button"]
      assert LazyHTML.attribute(a, "role") == ["tab"]
      assert LazyHTML.attribute(a, "id") == ["test-tab-a"]
      assert LazyHTML.attribute(a, "aria-controls") == ["test-panel-a"]
      assert LazyHTML.attribute(a, "aria-selected") == ["true"]
      assert LazyHTML.attribute(a, "tabindex") == ["0"]
      assert LazyHTML.attribute(a, "data-state") == ["active"]
      assert LazyHTML.attribute(a, "data-tabs-tab") == [""]
    end

    test "mark the inactive tabs and hide them from the tab sequence" do
      b = tab(render(), "b")

      assert LazyHTML.attribute(b, "aria-selected") == ["false"]
      assert LazyHTML.attribute(b, "tabindex") == ["-1"]
      assert LazyHTML.attribute(b, "data-state") == ["inactive"]
    end

    test "reflect a disabled tab" do
      b = tab(render(tab_b_disabled: true), "b")

      assert LazyHTML.attribute(b, "disabled") == [""]
      assert LazyHTML.attribute(b, "data-disabled") == [""]
      assert LazyHTML.attribute(b, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(b, "tabindex") == ["-1"]
    end

    test "reflect a disabled root on every tab" do
      html = render(disabled: true)

      for value <- ~w(a b c) do
        assert LazyHTML.attribute(tab(html, value), "disabled") == [""]
        assert LazyHTML.attribute(tab(html, value), "tabindex") == ["-1"]
      end
    end

    test "apply the class slot attribute to the default trigger" do
      a = tab(render(tab_class: "tab-custom"), "a")

      assert LazyHTML.attribute(a, "class") == ["tab-custom"]
    end

    test "omit aria-controls when the tab has no panel" do
      html =
        render_component(&TestComponent.tabs_without_panels/1, %{}) |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(tab(html, "list"), "aria-controls") == []
      assert LazyHTML.attribute(tab(html, "list"), "aria-selected") == ["true"]
      assert LazyHTML.attribute(part(html, "panel"), "data-part") == []
    end
  end

  describe "panels" do
    test "wire the tabpanel role, label, and visibility" do
      html = render()
      a = panel(html, "a")

      assert LazyHTML.tag(a) == ["div"]
      assert LazyHTML.attribute(a, "role") == ["tabpanel"]
      assert LazyHTML.attribute(a, "id") == ["test-panel-a"]
      assert LazyHTML.attribute(a, "aria-labelledby") == ["test-tab-a"]
      assert LazyHTML.attribute(a, "tabindex") == ["0"]
      assert LazyHTML.attribute(a, "hidden") == []
      assert LazyHTML.attribute(a, "data-state") == ["active"]
    end

    test "hide inactive panels" do
      b = panel(render(), "b")

      assert LazyHTML.attribute(b, "hidden") == [""]
      assert LazyHTML.attribute(b, "data-state") == ["inactive"]
    end

    test "drop the tab stop when the panel is not focusable" do
      html = render(value: "a", panel_focusable: false)

      assert LazyHTML.attribute(panel(html, "a"), "tabindex") == []
    end

    test "apply the class slot attribute to the panel" do
      a = panel(render(panel_class: "panel-custom"), "a")

      assert LazyHTML.attribute(a, "class") == ["panel-custom"]
    end

    test "use hidden=until-found for findable inactive panels" do
      html = render(findable: true)

      assert LazyHTML.attribute(panel(html, "a"), "hidden") == []
      assert LazyHTML.attribute(panel(html, "b"), "hidden") == ["until-found"]
      assert LazyHTML.attribute(panel(html, "c"), "hidden") == ["until-found"]
    end
  end

  describe "custom triggers" do
    test "pass the trigger attributes to a composed component" do
      html =
        render_component(&TestComponent.custom_tabs/1, %{}) |> LazyHTML.from_fragment()

      a = tab(html, "a")
      b = tab(html, "b")

      assert LazyHTML.attribute(a, "data-tabs-tab") == [""]
      assert LazyHTML.attribute(a, "data-tabs-trigger") == [""]
      assert LazyHTML.attribute(b, "data-tabs-tab") == []
      assert LazyHTML.attribute(b, "data-tabs-trigger") == [""]
      assert LazyHTML.attribute(b, "data-part") == ["tab"]
      assert LazyHTML.attribute(b, "data-element") == ["button"]
      assert LazyHTML.attribute(b, "role") == ["tab"]
      assert LazyHTML.attribute(b, "id") == ["custom-tab-b"]
      assert LazyHTML.attribute(b, "aria-controls") == ["custom-panel-b"]
      assert LazyHTML.attribute(b, "aria-selected") == ["false"]
      assert LazyHTML.attribute(b, "tabindex") == ["-1"]
      assert LazyHTML.attribute(b, "data-state") == ["inactive"]
      assert LazyHTML.attribute(b, "class") == ["custom-button"]
    end

    test "allow a link trigger and forward its accessible name" do
      html =
        render_component(&TestComponent.custom_tabs/1, %{}) |> LazyHTML.from_fragment()

      c = tab(html, "c")

      assert LazyHTML.tag(c) == ["a"]
      assert LazyHTML.attribute(c, "href") == ["/c"]
      assert LazyHTML.attribute(c, "data-tabs-tab") == []
      assert LazyHTML.attribute(c, "data-tabs-trigger") == [""]
      assert LazyHTML.attribute(c, "data-part") == ["tab"]
      assert LazyHTML.attribute(c, "role") == ["tab"]
      assert LazyHTML.attribute(c, "aria-label") == ["C tab"]
      assert LazyHTML.attribute(c, "aria-controls") == ["custom-panel-c"]
    end

    test "compose a link button as a custom trigger" do
      html =
        render_component(&TestComponent.custom_tabs/1, %{}) |> LazyHTML.from_fragment()

      d = tab(html, "d")

      assert LazyHTML.tag(d) == ["a"]
      assert LazyHTML.attribute(d, "href") == ["/d"]
      assert LazyHTML.attribute(d, "data-phx-link") == ["patch"]
      assert LazyHTML.attribute(d, "data-tabs-trigger") == [""]
      assert LazyHTML.attribute(d, "data-tabs-tab") == []
      assert LazyHTML.attribute(d, "data-part") == ["tab"]
      assert LazyHTML.attribute(d, "data-element") == ["button"]
      assert LazyHTML.attribute(d, "role") == ["tab"]
      assert LazyHTML.attribute(d, "aria-controls") == ["custom-panel-d"]
      assert LazyHTML.attribute(d, "class") == ["custom-link"]
    end
  end

  describe "metadata" do
    test "declares a stable, documented contract" do
      assert %FlintUI.Meta{name: :tabs, type: :navigation, status: :draft} =
               FlintUI.Base.Tabs.meta()

      parts = FlintUI.Base.Tabs.parts_attrs()

      assert Enum.sort(Map.keys(parts)) == [:panel, :root, :tab, :tablist]

      assert %FlintUI.Meta.PartAttr{value: "FlintUI.Tabs"} =
               Enum.find(parts.root, &(&1.name == "phx-hook"))

      assert %FlintUI.Meta.PartAttr{value: ~s("tab")} =
               Enum.find(parts.tab, &(&1.name == "role"))

      assert %FlintUI.Meta.PartAttr{value: ~s("tabpanel")} =
               Enum.find(parts.panel, &(&1.name == "role"))
    end

    test "documents the keyboard and client events" do
      assert Enum.any?(FlintUI.Base.Tabs.keyboard(), &(&1.keys == "ArrowRight / ArrowLeft"))

      assert Enum.any?(
               FlintUI.Base.Tabs.events(),
               &(&1.name == "fl:tabs:before-change")
             )

      assert Enum.any?(FlintUI.Base.Tabs.events(), &(&1.name == "fl:tabs:select"))
      assert Enum.any?(FlintUI.Base.Tabs.events(), &(&1.name == "fl:tabs:change"))
    end
  end

  describe "JS helpers" do
    test "dispatch the select command to the component root" do
      assert %Phoenix.LiveView.JS{ops: ops} = FlintUI.Base.Tabs.select_tab("test", "b")

      assert List.last(ops) == [
               "dispatch",
               %{to: "#test", event: "fl:tabs:select", detail: %{value: "b"}}
             ]
    end

    test "compose onto an existing JS command" do
      js = Phoenix.LiveView.JS.set_attribute(%Phoenix.LiveView.JS{}, {"data-x", "1"})
      %Phoenix.LiveView.JS{ops: ops} = FlintUI.Base.Tabs.select_tab(js, "test", "c")

      assert length(ops) == 2

      assert List.last(ops) == [
               "dispatch",
               %{to: "#test", event: "fl:tabs:select", detail: %{value: "c"}}
             ]
    end

    test "is exposed on FlintUI" do
      assert %Phoenix.LiveView.JS{ops: ops} = FlintUI.select_tab("test", "b")

      assert List.last(ops) == [
               "dispatch",
               %{to: "#test", event: "fl:tabs:select", detail: %{value: "b"}}
             ]
    end
  end
end
