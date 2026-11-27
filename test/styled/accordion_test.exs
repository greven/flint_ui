defmodule FlintUI.Styled.AccordionTest do
  use FlintUI.StyledCase, async: true

  alias FlintUI.TestDOM

  setup_all do
    wrapper =
      compile_wrapper!(:accordion, ~S'''
      def defaults(assigns) do
        ~H"""
        <.accordion id="faq">
          <FlintUI.accordion_item id="one" label="One">
            <:panel>Body</:panel>
          </FlintUI.accordion_item>
        </.accordion>
        """
      end

      def configured(assigns) do
        ~H"""
        <.accordion
          id="faq"
          variant="contained"
          surface="soft"
          shadow={false}
          indicator_position="left"
          transition={false}
          duration={350}
          class="extra"
          style="color: red"
          data-role="test"
        >
          <FlintUI.accordion_item id="one" label="One">
            <:panel>Body</:panel>
          </FlintUI.accordion_item>
        </.accordion>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the styled marker and defaults", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :accordion, "data-accordion") == [""]
    assert attr(document, :accordion, "data-variant") == ["simple"]
    assert attr(document, :accordion, "data-surface") == ["solid"]
    assert attr(document, :accordion, "data-shadow") == [""]
    assert attr(document, :accordion, "data-indicator-position") == ["right"]
    assert attr(document, :accordion, "data-transition") == [""]

    assert TestDOM.style_var(document, ~s([data-element="accordion"]), "--fl-accordion-duration") ==
             "200ms"
  end

  test "maps the configured props and merges the duration into style", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :accordion, "data-variant") == ["contained"]
    assert attr(document, :accordion, "data-surface") == ["soft"]
    assert attr(document, :accordion, "data-shadow") == []
    assert attr(document, :accordion, "data-indicator-position") == ["left"]
    assert attr(document, :accordion, "data-transition") == []
    assert attr(document, :accordion, "class") == ["extra"]
    assert attr(document, :accordion, "data-role") == ["test"]

    styles = TestDOM.style_vars(document, ~s([data-element="accordion"]))

    assert styles["--fl-accordion-duration"] == "350ms"
    assert styles["color"] == "red"
  end
end
