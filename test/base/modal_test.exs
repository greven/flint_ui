defmodule FlintUI.Base.ModalTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

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
        show_close={false}
        close_label="Dismiss"
        close_on_esc={false}
        close_on_backdrop={false}
        lock_scroll={false}
        open_event="modal_opened"
        close_event="modal_closed"
        toggle_event="modal_toggled"
        class="extra"
        data-role="test"
      >
        <:title>Archive project?</:title>
        <p>This cannot be undone.</p>
      </.modal>
      """
    end

    def named(assigns) do
      ~H"""
      <.modal id="named" aria_label="Account settings">
        <p>Body</p>
      </.modal>
      """
    end

    def labelled(assigns) do
      ~H"""
      <.modal id="labelled" aria_labelledby="custom-title" aria_describedby="custom-body">
        <:title>Ignored title</:title>
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

    def no_body(assigns) do
      ~H"""
      <.modal id="confirm">
        <:title>Confirm</:title>
        <:footer><button type="button">OK</button></:footer>
      </.modal>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="modal"]))
  defp part(document, name), do: LazyHTML.query(document, ~s([data-part="#{name}"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)

  defp part_attr(document, name, attribute) do
    document |> part(name) |> LazyHTML.attribute(attribute)
  end

  test "renders a native dialog with the modal identity and state hooks" do
    document = render(&TestComponent.defaults/1)

    assert LazyHTML.tag(root(document)) == ["dialog"]
    assert attr(document, "id") == ["invite"]
    assert attr(document, "phx-hook") == ["FlintUI.Modal"]
    assert attr(document, "data-part") == ["root"]
    assert attr(document, "data-state") == ["closed"]
    assert attr(document, "data-opened") == ["false"]
    assert attr(document, "role") == ["dialog"]
    assert attr(document, "aria-modal") == ["true"]
  end

  test "renders each region inside the card surface" do
    document = render(&TestComponent.defaults/1)

    for name <- ~w(root content header title description body section footer footer-actions close) do
      assert part(document, name) != [], "expected a [data-part=#{name}] element"
    end

    assert part_attr(document, "content", "tabindex") == ["-1"]

    card = LazyHTML.query(document, ~s([data-element="card"]))
    assert LazyHTML.tag(card) == ["div"]
    assert LazyHTML.attribute(card, "data-part") == ["root"]

    assert LazyHTML.query(document, ~s([data-part="content"] > [data-element="card"])) != []
    assert LazyHTML.query(card, ~s([data-part="header"])) != []
  end

  test "renders the title as the dialog heading" do
    document = render(&TestComponent.defaults/1)

    assert LazyHTML.tag(part(document, "title")) == ["h2"]
  end

  test "wires the title and description as the dialog name and description" do
    document = render(&TestComponent.defaults/1)

    assert part_attr(document, "title", "id") == ["invite-title"]
    assert part_attr(document, "description", "id") == ["invite-description"]
    assert attr(document, "aria-labelledby") == ["invite-title"]
    assert attr(document, "aria-describedby") == ["invite-description"]
  end

  test "honours explicit accessible names" do
    document = render(&TestComponent.named/1)

    assert attr(document, "aria-label") == ["Account settings"]
    assert attr(document, "aria-labelledby") == []
    assert attr(document, "aria-describedby") == []

    document = render(&TestComponent.labelled/1)

    assert attr(document, "aria-labelledby") == ["custom-title"]
    assert attr(document, "aria-describedby") == ["custom-body"]
  end

  test "forwards the open input and configured dismissal options" do
    document = render(&TestComponent.configured/1)

    assert attr(document, "data-opened") == ["true"]
    assert attr(document, "data-close-on-esc") == []
    assert attr(document, "data-close-on-backdrop") == []
    assert attr(document, "data-lock-scroll") == []
    assert attr(document, "data-open-event") == ["modal_opened"]
    assert attr(document, "data-close-event") == ["modal_closed"]
    assert attr(document, "data-toggle-event") == ["modal_toggled"]
    assert attr(document, "role") == ["alertdialog"]
  end

  test "renders the default close button with a client close command" do
    document = render(&TestComponent.defaults/1)

    close = part(document, "close")
    assert LazyHTML.tag(close) == ["button"]
    assert LazyHTML.attribute(close, "type") == ["button"]
    assert LazyHTML.attribute(close, "aria-label") == ["Close"]

    click = LazyHTML.attribute(close, "phx-click") |> List.first()
    assert click =~ "closest"
    assert click =~ "fl:modal:close"
  end

  test "uses the close slot instead of the fallback glyph" do
    document = render(&TestComponent.custom_close/1)

    assert part(document, "close") |> LazyHTML.text() |> String.trim() == "x"
    assert LazyHTML.to_html(part(document, "close-icon")) == ""
  end

  test "falls back to a decorative glyph when no close slot is given" do
    document = render(&TestComponent.defaults/1)

    assert part_attr(document, "close-icon", "aria-hidden") == ["true"]
  end

  test "omits the title, description, and body regions when they are not given" do
    document = render(&TestComponent.no_body/1)

    assert LazyHTML.to_html(part(document, "title")) != ""
    assert LazyHTML.to_html(part(document, "description")) == ""
    assert LazyHTML.to_html(part(document, "body")) == ""
    assert LazyHTML.to_html(part(document, "footer")) != ""
  end

  test "declares its element type, parts, states, events, and keyboard" do
    assert %FlintUI.Meta{name: :modal, type: :overlay, status: :draft} =
             FlintUI.Base.Modal.meta()

    assert Enum.map(FlintUI.Base.Modal.parts_attrs(), &elem(&1, 0)) == [
             :root,
             :content,
             :header,
             :title,
             :description,
             :body,
             :section,
             :footer,
             :footer_actions,
             :close,
             :close_icon
           ]

    assert Enum.any?(FlintUI.Base.Modal.states(), &(&1.name == "open"))
    assert Enum.any?(FlintUI.Base.Modal.events(), &(&1.name == "fl:modal:open"))
    assert Enum.any?(FlintUI.Base.Modal.events(), &(&1.name == "fl:modal:change"))
    assert Enum.any?(FlintUI.Base.Modal.keyboard(), &(&1.keys == "Escape"))
  end

  test "the JS helpers return commands" do
    assert %Phoenix.LiveView.JS{} = FlintUI.Base.Modal.open_modal("invite")
    assert %Phoenix.LiveView.JS{} = FlintUI.Base.Modal.close_modal("invite")
    assert %Phoenix.LiveView.JS{} = FlintUI.Base.Modal.toggle_modal("invite")
  end
end
