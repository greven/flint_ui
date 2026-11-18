defmodule FlintUI.Styled.PopoverTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:popover, ~S'''
      def defaults(assigns) do
        ~H"""
        <.popover id="pop" aria_label="Account">
          <button>Open</button>
          <:content>Account settings</:content>
        </.popover>
        """
      end

      def configured(assigns) do
        ~H"""
        <.popover
          id="pop"
          opened
          dismissible={false}
          open_on_hover
          placement="top"
          align="start"
          offset={12}
          open_delay={120}
          close_delay={80}
          arrow
          class="extra"
          data-role="test"
        >
          <button class="trigger-extra">Open</button>
          <:content>
            <strong>Rich</strong> content
          </:content>
        </.popover>
        """
      end

      def portalled(assigns) do
        ~H"""
        <.popover id="pop" portal portal_target="#portal-root">
          <button>Open</button>
          <:content>Portalled</:content>
        </.popover>
        """
      end

      def generated(assigns) do
        ~H"""
        <.popover>
          <button>Open</button>
          <:content>Generated</:content>
        </.popover>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and forwards the positioning options", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :popover, "data-popover") == [""]
    assert attr(document, :popover, "data-element") == ["popover"]
    assert attr(document, :popover, "data-state") == ["closed"]
    assert attr(document, :popover, "data-opened") == ["false"]
    assert attr(document, :popover, "data-placement") == ["bottom"]
    assert attr(document, :popover, "data-align") == ["center"]
    assert attr(document, :popover, "data-offset") == ["8"]
  end

  test "forwards the configured base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :popover, "data-state") == ["open"]
    assert attr(document, :popover, "data-opened") == ["true"]
    assert attr(document, :popover, "data-dismissible") == []
    assert attr(document, :popover, "data-open-on-hover") == [""]
    assert attr(document, :popover, "data-placement") == ["top"]
    assert attr(document, :popover, "data-align") == ["start"]
    assert attr(document, :popover, "data-offset") == ["12"]
    assert attr(document, :popover, "data-open-delay") == ["120"]
    assert attr(document, :popover, "data-close-delay") == ["80"]
    assert attr(document, :popover, "class") == ["extra"]
    assert attr(document, :popover, "data-role") == ["test"]
  end

  test "renders the trigger first and the dialog content in the top layer", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert count_part(document, "trigger") == 0

    assert LazyHTML.query(document, ~s([data-element="popover"] > button)) |> LazyHTML.text() ==
             "Open"

    assert part_attr(document, "content", "role") == ["dialog"]
    assert part_attr(document, "content", "popover") == ["manual"]
    assert part_attr(document, "content", "data-popover-content") == [""]
    assert part_attr(document, "content", "id") == ["pop-content"]
    assert part_attr(document, "content", "aria-label") == ["Account"]
  end

  test "forwards the trigger class and renders rich content", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert LazyHTML.query(document, "button") |> LazyHTML.attribute("class") == ["trigger-extra"]

    content = part(document, "content")
    assert LazyHTML.text(content) |> String.trim() == "Rich content"
    assert LazyHTML.query(content, "strong") |> LazyHTML.text() == "Rich"
  end

  test "generates an id when none is given", %{wrapper: wrapper} do
    document = render(wrapper, :generated)

    [root_id] = attr(document, :popover, "id")

    assert root_id =~ ~r/^fl-popover-/
    assert part_attr(document, "content", "id") == ["#{root_id}-content"]
  end

  test "renders the arrow only when asked", %{wrapper: wrapper} do
    assert count_part(render(wrapper, :defaults), "arrow") == 0
    assert count_part(render(wrapper, :configured), "arrow") == 1
  end

  test "renders the content through a Phoenix portal when asked", %{wrapper: wrapper} do
    document = render(wrapper, :portalled)
    template = LazyHTML.query(document, "template[data-phx-portal]") |> LazyHTML.to_html()

    assert attr(document, :popover, "data-portal") == [""]
    assert template =~ ~s(data-phx-portal="#portal-root")
    assert template =~ ~s(id="pop-content")
    assert template =~ "Portalled"
  end
end
