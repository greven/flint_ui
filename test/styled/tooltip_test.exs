defmodule FlintUI.Styled.TooltipTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:tooltip, ~S'''
      def defaults(assigns) do
        ~H"""
        <.tooltip id="tip" text="Save changes">
          <button>Save</button>
        </.tooltip>
        """
      end

      def configured(assigns) do
        ~H"""
        <.tooltip
          id="tip"
          placement="bottom"
          align="start"
          offset={12}
          delay={0}
          arrow={true}
          disabled
          class="extra"
          data-role="test"
        >
          <button class="trigger-extra">Help</button>
          <:content>
            <strong>Rich</strong> hint
          </:content>
        </.tooltip>
        """
      end
      def generated(assigns) do
        ~H"""
        <.tooltip text="Save changes">
          <button>Save</button>
        </.tooltip>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the positioning options", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :tooltip, "data-tooltip") == [""]
    assert attr(document, :tooltip, "data-element") == ["tooltip"]
    assert attr(document, :tooltip, "data-state") == ["closed"]
    assert attr(document, :tooltip, "data-placement") == ["top"]
    assert attr(document, :tooltip, "data-align") == ["center"]
    assert attr(document, :tooltip, "data-offset") == ["4"]
  end

  test "forwards the configured base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :tooltip, "data-placement") == ["bottom"]
    assert attr(document, :tooltip, "data-align") == ["start"]
    assert attr(document, :tooltip, "data-offset") == ["12"]
    assert attr(document, :tooltip, "data-delay") == ["0"]
    assert attr(document, :tooltip, "data-disabled") == [""]
    assert attr(document, :tooltip, "class") == ["extra"]
    assert attr(document, :tooltip, "data-role") == ["test"]
  end

  test "renders the default slot as the trigger", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert count_part(document, "trigger") == 0

    assert LazyHTML.query(document, ~s([data-element="tooltip"] > button)) |> LazyHTML.text() ==
             "Save"
  end

  test "wires the tooltip content into the top layer", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert part_attr(document, "content", "role") == ["tooltip"]
    assert part_attr(document, "content", "popover") == ["manual"]
    assert part_attr(document, "content", "id") == ["tip-content"]
  end

  test "forwards the trigger class and renders rich content", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert LazyHTML.query(document, "button") |> LazyHTML.attribute("class") == ["trigger-extra"]

    content = part(document, "content")
    assert LazyHTML.text(content) |> String.trim() == "Rich hint"
    assert LazyHTML.query(content, "strong") |> LazyHTML.text() == "Rich"
  end

  test "renders the text attribute as content", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert part(document, "content") |> LazyHTML.text() |> String.trim() == "Save changes"
  end

  test "generates an id when none is given", %{wrapper: wrapper} do
    document = render(wrapper, :generated)

    [root_id] = attr(document, :tooltip, "id")

    assert root_id =~ ~r/^fl-tooltip-/
    assert part_attr(document, "content", "id") == ["#{root_id}-content"]
  end

  test "omits the arrow by default and renders it when enabled", %{wrapper: wrapper} do
    assert count_part(render(wrapper, :defaults), "arrow") == 0
    assert count_part(render(wrapper, :configured), "arrow") == 1
  end
end
