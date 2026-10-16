defmodule FlintUI.Base.CardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def full(assigns) do
      ~H"""
      <.card>
        <:title>Title</:title>
        <:description>Description</:description>
        <:action><button type="button">Edit</button></:action>
        <:header>Header extra</:header>
        <p>Body</p>
        <:footer>Footer</:footer>
      </.card>
      """
    end

    def bare(assigns) do
      ~H"""
      <.card>Only body</.card>
      """
    end

    def as_section(assigns) do
      ~H"""
      <.card as="section">
        <:title>Title</:title>
        <p>Body</p>
      </.card>
      """
    end

    def flush_card(assigns) do
      ~H"""
      <.card flush>Body</.card>
      """
    end
  end

  defp html(assigns \\ []) do
    render_component(&TestComponent.full/1, assigns) |> LazyHTML.from_fragment()
  end

  defp parts(document, name) do
    document |> LazyHTML.query(~s([data-part="#{name}"])) |> LazyHTML.attribute("data-part")
  end

  test "renders each region with a data-part hook" do
    document = html()

    root = LazyHTML.query(document, ~s([data-part="root"]))
    assert LazyHTML.attribute(root, "data-element") == ["card"]
    assert LazyHTML.tag(root) == ["div"]

    for name <- ~w(root header title description action header-content body footer) do
      assert parts(document, name) == [name], "expected a [data-part=#{name}] element"
    end
  end

  test "renders a body-only card without the empty regions" do
    document = render_component(&TestComponent.bare/1, %{}) |> LazyHTML.from_fragment()

    assert parts(document, "body") == ["body"]
    assert parts(document, "header") == []
    assert parts(document, "footer") == []
  end

  test "chooses the root element with the as attribute" do
    document = render_component(&TestComponent.as_section/1, %{}) |> LazyHTML.from_fragment()

    assert document |> LazyHTML.query(~s([data-part="root"])) |> LazyHTML.tag() == ["section"]
  end

  test "flags flush on the root only when set" do
    assert html() |> LazyHTML.query(~s([data-part="root"])) |> LazyHTML.attribute("data-flush") ==
             []

    document = render_component(&TestComponent.flush_card/1, %{}) |> LazyHTML.from_fragment()

    assert document
           |> LazyHTML.query(~s([data-part="root"]))
           |> LazyHTML.attribute("data-flush") == [""]
  end

  test "declares its element type and documented parts" do
    assert %FlintUI.Meta{name: :card, type: :layout, status: :draft} =
             FlintUI.Base.Card.meta()

    parts = FlintUI.Base.Card.parts_attrs()
    assert parts.root |> Enum.any?(&(&1.name == "[data-element]"))
    assert parts.body |> Enum.any?(&(&1.value == "body"))
  end
end
