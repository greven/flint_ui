defmodule FlintUI.Styled.TabsTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:tabs, ~S'''
      def defaults(assigns) do
        ~H"""
        <.tabs id="account" value="profile" label="Account">
          <:tab value="profile">Profile</:tab>
          <:tab value="billing">Billing</:tab>
          <:panel value="profile">Profile content</:panel>
          <:panel value="billing">Billing content</:panel>
        </.tabs>
        """
      end

      def configured(assigns) do
        ~H"""
        <.tabs
          id="account"
          value="billing"
          label="Account"
          variant="segmented"
          color="primary"
          size="lg"
          grow
          align="spaced"
          class="extra"
          data-role="test"
        >
          <:tab value="profile" class="tab-extra">Profile</:tab>
          <:tab value="billing" disabled class="tab-extra">Billing</:tab>
          <:panel value="profile" focusable={false} class="panel-extra">Profile content</:panel>
          <:panel value="billing">Billing content</:panel>
        </.tabs>
        """
      end

      def custom(assigns) do
        ~H"""
        <.tabs id="custom" value="a" label="Custom">
          <:tab value="a">A</:tab>
          <:tab :let={attrs} value="b" custom aria_label="B tab">
            <button {attrs} type="button">B</button>
          </:tab>
          <:panel value="a">A panel</:panel>
          <:panel value="b">B panel</:panel>
        </.tabs>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.tabs id="account" value="a" label="Account" color="#1D72FE">
          <:tab value="a">A</:tab>
          <:panel value="a">A content</:panel>
        </.tabs>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp tab(document, value) do
    LazyHTML.query(document, ~s([data-part="tab"][data-value="#{value}"]))
  end

  defp panel(document, value) do
    LazyHTML.query(document, ~s([data-part="panel"][data-value="#{value}"]))
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :tabs, "data-tabs") == [""]
    assert attr(document, :tabs, "data-variant") == ["outlined"]
    assert attr(document, :tabs, "data-color") == ["neutral"]
    assert attr(document, :tabs, "data-size") == ["md"]
    assert attr(document, :tabs, "data-align") == ["start"]
    assert attr(document, :tabs, "data-grow") == []
    assert count_part(document, "tab") == 2
    assert count_part(document, "panel") == 2
  end

  test "maps the treatment overrides and forwards tab and panel options", %{
    wrapper: wrapper
  } do
    document = render(wrapper, :configured)

    assert attr(document, :tabs, "data-variant") == ["segmented"]
    assert attr(document, :tabs, "data-color") == ["primary"]
    assert attr(document, :tabs, "data-size") == ["lg"]
    assert attr(document, :tabs, "data-grow") == [""]
    assert attr(document, :tabs, "data-align") == ["spaced"]
    assert attr(document, :tabs, "data-value") == ["billing"]
    assert attr(document, :tabs, "class") == ["extra"]
    assert attr(document, :tabs, "data-role") == ["test"]

    assert LazyHTML.attribute(tab(document, "profile"), "class") == ["tab-extra"]
    assert LazyHTML.attribute(tab(document, "billing"), "class") == ["tab-extra"]
    assert LazyHTML.attribute(tab(document, "billing"), "data-disabled") == [""]
    assert LazyHTML.attribute(panel(document, "profile"), "class") == ["panel-extra"]
    assert LazyHTML.attribute(panel(document, "profile"), "tabindex") == []
    assert LazyHTML.attribute(panel(document, "billing"), "tabindex") == ["0"]
  end

  test "forwards a custom tab's options", %{wrapper: wrapper} do
    document = render(wrapper, :custom)
    custom_tab = tab(document, "b")

    assert LazyHTML.attribute(custom_tab, "aria-label") == ["B tab"]
    assert LazyHTML.attribute(custom_tab, "data-tabs-tab") == []
    assert LazyHTML.attribute(custom_tab, "role") == ["tab"]
  end

  test "a raw color sets the tab color inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:tabs, "style") |> List.first()

    assert attr(document, :tabs, "data-color") == []
    assert style =~ "--fl-tabs-color: #1D72FE"
    assert style =~ "--fl-tabs-text: light-dark("
  end
end
