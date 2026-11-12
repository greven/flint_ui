defmodule FlintUI.Styled.AccordionItemTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:accordion_item, ~S'''
      def defaults(assigns) do
        ~H"""
        <FlintUI.accordion id="faq">
          <.accordion_item id="one" label="One">
            <:panel>Body</:panel>
          </.accordion_item>
        </FlintUI.accordion>
        """
      end

      def configured(assigns) do
        ~H"""
        <FlintUI.accordion id="faq">
          <.accordion_item
            id="one"
            label="Fallback"
            expanded
            disabled
            heading="h2"
            class="extra"
            data-role="test"
          >
            <:header class="header-extra" phx-click="go" data-role="header">Custom</:header>
            <:indicator class="indicator-extra"><span>+</span></:indicator>
            <:panel class="panel-extra">Body</:panel>
          </.accordion_item>
        </FlintUI.accordion>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the styled marker and forwards the item state", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :accordion_item, "data-accordion_item") == [""]
    assert attr(document, :accordion_item, "data-state") == ["closed"]
    assert part_attr(document, "trigger", "data-part") == ["trigger"]
    assert part_attr(document, "panel", "data-part") == ["panel"]
  end

  test "forwards the configured attributes, header, indicator, and panel", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :accordion_item, "data-state") == ["open"]
    assert attr(document, :accordion_item, "data-disabled") == [""]
    assert attr(document, :accordion_item, "class") == ["extra"]
    assert attr(document, :accordion_item, "data-role") == ["test"]

    header = part(document, "trigger")
    assert LazyHTML.tag(header) == ["button"]
    assert document |> part("header") |> LazyHTML.text() |> String.trim() == "Custom"
    assert LazyHTML.attribute(header, "class") == ["header-extra"]
    assert LazyHTML.attribute(header, "phx-click") == ["go"]
    assert LazyHTML.attribute(header, "data-role") == ["header"]

    assert document |> part("heading") |> LazyHTML.tag() == ["h2"]

    indicator = part(document, "indicator")
    assert LazyHTML.tag(indicator) == ["span"]
    assert LazyHTML.attribute(indicator, "class") == ["indicator-extra"]
    assert LazyHTML.attribute(indicator, "aria-hidden") == ["true"]
    assert LazyHTML.text(indicator) |> String.trim() == "+"

    assert part_attr(document, "panel", "class") == ["panel-extra"]
  end
end
