defmodule FlintUI.Base.AlertTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

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

    def actions(assigns) do
      ~H"""
      <.alert title="Storage almost full">
        You have used 90% of your plan.
        <:actions>
          <button type="button">Upgrade</button>
          <button type="button">Dismiss</button>
        </:actions>
      </.alert>
      """
    end

    def with_icon(assigns) do
      ~H"""
      <.alert>
        <:icon><span id="custom-icon">!</span></:icon>
        Body
      </.alert>
      """
    end

    def closable(assigns) do
      ~H"""
      <.alert
        id="billing-alert"
        with_close
        close_event="dismiss_alert"
        close_label="Close billing notice"
        title="Billing"
      >
        Your trial ends in three days.
      </.alert>
      """
    end

    def horizontal(assigns) do
      ~H"""
      <.alert orientation="horizontal" padded={false}>
        Body
      </.alert>
      """
    end

    def role_override(assigns) do
      ~H"""
      <.alert intent="error" role="none">Body</.alert>
      """
    end

    def only_title(assigns) do
      ~H"""
      <.alert title="Only a title"></.alert>
      """
    end

    def invalid_intent(assigns) do
      ~H"""
      <.alert intent="bogus">Body</.alert>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="alert"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)
  defp part(document, name), do: LazyHTML.query(document, ~s([data-part="#{name}"]))

  test "renders a status region with title and body by default" do
    document = render(&TestComponent.defaults/1)

    assert LazyHTML.tag(root(document)) == ["div"]
    assert attr(document, "data-element") == ["alert"]
    assert attr(document, "data-part") == ["root"]
    assert attr(document, "data-intent") == []
    assert attr(document, "data-orientation") == ["vertical"]
    assert attr(document, "data-padded") == [""]
    assert attr(document, "role") == ["status"]

    assert part(document, "title") |> LazyHTML.text() |> String.trim() == "Heads up"

    assert part(document, "body") |> LazyHTML.text() |> String.trim() ==
             "Your trial ends in three days."
  end

  test "an error intent defaults the alert role and exposes the intent hook" do
    document = render(&TestComponent.intent/1)

    assert attr(document, "data-intent") == ["error"]
    assert attr(document, "role") == ["alert"]
  end

  test "an explicit role wins over the intent default" do
    document = render(&TestComponent.role_override/1)

    assert attr(document, "data-intent") == ["error"]
    assert attr(document, "role") == ["none"]
  end

  test "renders repeated actions below the body" do
    document = render(&TestComponent.actions/1)

    actions = part(document, "actions")
    assert actions != []
    assert LazyHTML.text(actions) =~ "Upgrade"
    assert LazyHTML.text(actions) =~ "Dismiss"
  end

  test "renders an explicit icon slot" do
    document = render(&TestComponent.with_icon/1)

    icon = part(document, "icon")
    assert icon != []
    assert LazyHTML.query(document, "#custom-icon") |> LazyHTML.text() == "!"
  end

  test "renders a close button with an accessible name and a close command" do
    document = render(&TestComponent.closable/1)

    close = part(document, "close")
    assert LazyHTML.tag(close) == ["button"]
    assert LazyHTML.attribute(close, "type") == ["button"]
    assert LazyHTML.attribute(close, "aria-label") == ["Close billing notice"]

    click = LazyHTML.attribute(close, "phx-click") |> List.first()
    assert click =~ "closest"
    assert click =~ ~s([data-element=\\"alert\\"])
    assert click =~ "fl:alert:close"
    assert click =~ "hide"
    assert click =~ "dismiss_alert"
    assert click =~ "billing-alert"

    assert attr(document, "id") == ["billing-alert"]
  end

  test "orientation and padding are forwarded to the root hooks" do
    document = render(&TestComponent.horizontal/1)

    assert attr(document, "data-orientation") == ["horizontal"]
    assert attr(document, "data-padded") == []
  end

  test "renders a title without a body" do
    document = render(&TestComponent.only_title/1)

    assert part(document, "title") != []
    assert part(document, "body") |> LazyHTML.to_html() == ""
  end

  test "declares its element type and documented parts" do
    assert %FlintUI.Meta{name: :alert, type: :feedback, status: :draft} =
             FlintUI.Base.Alert.meta()

    parts = FlintUI.Base.Alert.parts_attrs()

    assert Enum.any?(parts.root, &(&1.name == "[data-element]"))
    assert Enum.any?(parts.root, &(&1.name == "[data-intent]"))
    assert Enum.any?(parts.root, &(&1.name == "[data-orientation]"))
    assert Enum.any?(parts.root, &(&1.name == "[data-padded]"))
    assert Enum.any?(parts.close, &(&1.name == "aria-label"))
    assert Enum.any?(parts.close, &(&1.name == "phx-click"))
  end

  test "maps each intent to its default icon" do
    assert FlintUI.Base.Alert.intent_icon("neutral") == "lucide-info"
    assert FlintUI.Base.Alert.intent_icon("info") == "lucide-info"
    assert FlintUI.Base.Alert.intent_icon("success") == "lucide-circle-check"
    assert FlintUI.Base.Alert.intent_icon("warning") == "lucide-circle-exclamation-point"
    assert FlintUI.Base.Alert.intent_icon("error") == "lucide-circle-x"
    assert FlintUI.Base.Alert.intent_icon(nil) == nil
  end

  test "rejects an unknown intent" do
    assert_raise ArgumentError, ~r/invalid alert intent/, fn ->
      render(&TestComponent.invalid_intent/1)
    end
  end

  test "close_alert/2 returns a JS command" do
    assert %Phoenix.LiveView.JS{} = FlintUI.Base.Alert.close_alert("billing-alert")
    assert %Phoenix.LiveView.JS{} = FlintUI.Base.Alert.close_alert(%Phoenix.LiveView.JS{}, "x")
  end
end
