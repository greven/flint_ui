defmodule FlintUI.Styled.AlertTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:alert, ~S'''
      def defaults(assigns) do
        ~H"""
        <.alert title="Heads up">Your trial ends in three days.</.alert>
        """
      end

      def intent(assigns) do
        ~H"""
        <.alert intent="error" title="Failure">We could not save your changes.</.alert>
        """
      end

      def color_override(assigns) do
        ~H"""
        <.alert intent="error" color="info">Overridden color.</.alert>
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.alert intent="warning" color="#1D72FE">Custom color.</.alert>
        """
      end

      def hidden_icon(assigns) do
        ~H"""
        <.alert intent="success" show_icon={false}>Saved.</.alert>
        """
      end

      def explicit_icon(assigns) do
        ~H"""
        <.alert intent="error" show_icon={false}>
          <:icon><span id="custom-icon">!</span></:icon>
          Failure.
        </.alert>
        """
      end

      def actions(assigns) do
        ~H"""
        <.alert title="Storage almost full">
          You have used 90% of your plan.
          <:actions>
            <button type="button">Upgrade</button>
          </:actions>
        </.alert>
        """
      end

      def closable(assigns) do
        ~H"""
        <.alert id="billing-alert" with_close close_event="dismiss_alert">
          Your trial ends in three days.
        </.alert>
        """
      end

      def layout(assigns) do
        ~H"""
        <.alert orientation="horizontal" spacing="lg" padded={false} shadow>
          Body.
        </.alert>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp icon(document) do
    LazyHTML.query(document, ~s([data-element="icon"]))
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :alert)) == ["div"]
    assert attr(document, :alert, "data-alert") == [""]
    assert attr(document, :alert, "data-variant") == ["subtle"]
    assert attr(document, :alert, "data-color") == ["neutral"]
    assert attr(document, :alert, "data-spacing") == ["xs"]
    assert attr(document, :alert, "data-shadow") == []
    assert attr(document, :alert, "data-intent") == []
    assert attr(document, :alert, "data-orientation") == ["vertical"]
    assert attr(document, :alert, "data-padded") == [""]
    assert attr(document, :alert, "role") == ["status"]
    assert icon(document) |> LazyHTML.to_html() == ""
  end

  test "an intent drives the default color, icon, and role", %{wrapper: wrapper} do
    document = render(wrapper, :intent)

    assert attr(document, :alert, "data-intent") == ["error"]
    assert attr(document, :alert, "data-color") == ["error"]
    assert attr(document, :alert, "role") == ["alert"]
    assert icon(document) |> LazyHTML.attribute("class") == ["lucide-circle-x"]
  end

  test "an explicit color overrides the intent color but keeps its icon", %{wrapper: wrapper} do
    document = render(wrapper, :color_override)

    assert attr(document, :alert, "data-intent") == ["error"]
    assert attr(document, :alert, "data-color") == ["info"]
    assert icon(document) |> LazyHTML.attribute("class") == ["lucide-circle-x"]
  end

  test "a raw color sets the public alert inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:alert, "style") |> List.first()

    assert attr(document, :alert, "data-color") == []
    assert style =~ "--fl-alert-color: #1D72FE"
    assert style =~ "--fl-alert-color-content:"
    assert style =~ "--fl-alert-text: light-dark("
    assert icon(document) |> LazyHTML.attribute("class") == ["lucide-circle-exclamation-point"]
  end

  test "show_icon hides the default icon", %{wrapper: wrapper} do
    document = render(wrapper, :hidden_icon)

    assert attr(document, :alert, "data-color") == ["success"]
    assert icon(document) |> LazyHTML.to_html() == ""
  end

  test "an explicit icon always renders and wins over the default", %{wrapper: wrapper} do
    document = render(wrapper, :explicit_icon)

    assert LazyHTML.query(document, "#custom-icon") |> LazyHTML.text() == "!"
    assert icon(document) |> LazyHTML.attribute("class") == []

    text =
      document
      |> root(:alert)
      |> LazyHTML.text()
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    assert text == "! Failure."
  end

  test "forwards the actions slot below the body", %{wrapper: wrapper} do
    document = render(wrapper, :actions)

    actions = part(document, "actions")
    assert actions != []
    assert LazyHTML.text(actions) =~ "Upgrade"
  end

  test "renders the close button and its server event", %{wrapper: wrapper} do
    document = render(wrapper, :closable)

    close = part(document, "close")
    assert LazyHTML.tag(close) == ["button"]
    assert LazyHTML.attribute(close, "aria-label") == ["Dismiss"]

    assert LazyHTML.query(close, ~s([data-element="icon"])) |> LazyHTML.attribute("class") == [
             "lucide-x"
           ]

    click = LazyHTML.attribute(close, "phx-click") |> List.first()
    assert click =~ "closest"
    assert click =~ "fl:alert:close"
    assert click =~ "hide"
    assert click =~ "dismiss_alert"
    assert click =~ "billing-alert"
  end

  test "maps layout props onto the root hooks", %{wrapper: wrapper} do
    document = render(wrapper, :layout)

    assert attr(document, :alert, "data-orientation") == ["horizontal"]
    assert attr(document, :alert, "data-spacing") == ["lg"]
    assert attr(document, :alert, "data-padded") == []
    assert attr(document, :alert, "data-shadow") == [""]
  end
end
