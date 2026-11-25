defmodule FlintUI.Styled.ModalTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:modal, ~S'''
      def defaults(assigns) do
        ~H"""
        <.modal id="invite">
          <:title>Invite teammate</:title>
          <:description>Send an invitation to join the workspace.</:description>
          <p>Body</p>
          <:footer><button type="button">Cancel</button></:footer>
        </.modal>
        """
      end

      def configured(assigns) do
        ~H"""
        <.modal
          id="archive"
          opened
          role="alertdialog"
          size="lg"
          placement="top"
          backdrop="blur"
          body="separated-footer"
          spacing="lg"
          show_close={false}
          close_on_esc={false}
          close_on_backdrop={false}
          close_event="modal_closed"
          class="extra"
          data-role="test"
        >
          <:title>Archive project?</:title>
          <p>Body</p>
        </.modal>
        """
      end

      def custom_close(assigns) do
        ~H"""
        <.modal id="custom">
          <:close><span id="custom-close">x</span></:close>
          Body
        </.modal>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default size, placement, and backdrop onto the dialog", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :modal)) == ["dialog"]
    assert attr(document, :modal, "data-modal") == [""]
    assert attr(document, :modal, "data-size") == ["md"]
    assert attr(document, :modal, "data-placement") == ["center"]
    assert attr(document, :modal, "data-backdrop") == ["dim"]
    assert attr(document, :modal, "data-state") == ["closed"]
  end

  test "maps the surface props onto the nested card", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    card = LazyHTML.query(document, ~s([data-element="card"]))
    assert LazyHTML.tag(card) == ["div"]
    assert LazyHTML.attribute(card, "data-part") == ["root"]
    assert LazyHTML.attribute(card, "data-card") == [""]
    assert LazyHTML.attribute(card, "data-elevation") == [""]
    assert LazyHTML.attribute(card, "data-outline") == [""]
    assert LazyHTML.attribute(card, "data-shadow") == [""]
    assert LazyHTML.attribute(card, "data-body") == ["divided"]
    assert LazyHTML.attribute(card, "data-spacing") == ["md"]

    assert LazyHTML.query(document, ~s([data-part="content"] > [data-element="card"])) != []
  end

  test "forwards the configured base attributes and styling props", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :modal, "data-size") == ["lg"]
    assert attr(document, :modal, "data-placement") == ["top"]
    assert attr(document, :modal, "data-backdrop") == ["blur"]
    assert attr(document, :modal, "data-opened") == ["true"]
    assert attr(document, :modal, "role") == ["alertdialog"]
    assert attr(document, :modal, "data-close-on-esc") == []
    assert attr(document, :modal, "data-close-on-backdrop") == []
    assert attr(document, :modal, "data-close-event") == ["modal_closed"]
    assert attr(document, :modal, "class") == ["extra"]
    assert attr(document, :modal, "data-role") == ["test"]

    card = LazyHTML.query(document, ~s([data-element="card"]))
    assert LazyHTML.attribute(card, "data-body") == ["separated-footer"]
    assert LazyHTML.attribute(card, "data-spacing") == ["lg"]
  end

  test "forwards the base slots and their accessible wiring", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert part_attr(document, "title", "id") == ["invite-title"]
    assert attr(document, :modal, "aria-labelledby") == ["invite-title"]
    assert attr(document, :modal, "aria-describedby") == ["invite-description"]

    assert part(document, "body") |> LazyHTML.text() |> String.trim() == "Body"
    assert part(document, "footer") |> LazyHTML.text() |> String.trim() == "Cancel"
  end

  test "supplies a close icon unless the caller overrides the close slot", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert part_attr(document, "close", "aria-label") == ["Close"]

    assert LazyHTML.to_html(
             LazyHTML.query(part(document, "close"), ~s([data-element="icon"].lucide-x))
           ) != ""

    document = render(wrapper, :custom_close)

    assert part(document, "close") |> LazyHTML.text() |> String.trim() == "x"

    assert LazyHTML.to_html(LazyHTML.query(part(document, "close"), ~s([data-element="icon"]))) ==
             ""
  end
end
