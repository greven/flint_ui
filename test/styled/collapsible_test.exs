defmodule FlintUI.Styled.CollapsibleTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:collapsible, ~S'''
      def defaults(assigns) do
        ~H"""
        <.collapsible id="details">
          <:trigger :let={attrs}><button {attrs}>Toggle</button></:trigger>
          <:content :let={attrs}><div {attrs}>Content</div></:content>
        </.collapsible>
        """
      end

      def configured(assigns) do
        ~H"""
        <.collapsible
          id="details"
          open
          disabled
          hidden_until_found
          open_event="opened"
          close_event="closed"
          toggle_event="toggled"
          class="extra"
          data-role="test"
        >
          <:trigger :let={attrs}>
            <button {attrs} class="trigger-extra">Toggle</button>
          </:trigger>
          <:content :let={attrs}>
            <div {attrs} class="content-extra">Content</div>
          </:content>
        </.collapsible>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "adds the presence hook and starts closed", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :collapsible, "data-collapsible") == [""]
    assert attr(document, :collapsible, "data-state") == ["closed"]
    assert part_attr(document, "trigger", "data-part") == ["trigger"]
    assert part_attr(document, "content", "data-part") == ["content"]
  end

  test "forwards the base state and event attributes", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :collapsible, "data-state") == ["open"]
    assert attr(document, :collapsible, "data-disabled") == [""]
    assert attr(document, :collapsible, "data-hidden-until-found") == [""]
    assert attr(document, :collapsible, "data-open-event") == ["opened"]
    assert attr(document, :collapsible, "data-close-event") == ["closed"]
    assert attr(document, :collapsible, "data-toggle-event") == ["toggled"]
    assert attr(document, :collapsible, "class") == ["extra"]
    assert attr(document, :collapsible, "data-role") == ["test"]
  end

  test "forwards the trigger and content slots", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert part(document, "trigger") |> LazyHTML.text() |> String.trim() == "Toggle"
    assert part(document, "content") |> LazyHTML.text() |> String.trim() == "Content"
    assert part_attr(document, "trigger", "class") == ["trigger-extra"]
    assert part_attr(document, "content", "class") == ["content-extra"]
  end
end
