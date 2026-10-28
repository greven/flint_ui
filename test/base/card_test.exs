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
        <:header_actions><button type="button">Edit</button></:header_actions>
        <:header_actions><button type="button">Remove</button></:header_actions>
        <:header>Header extra</:header>
        <p>Body</p>
        <:section>Extra section</:section>
        <:section>Full bleed</:section>
        <:footer>Footer</:footer>
        <:footer_actions><button type="button">View</button></:footer_actions>
      </.card>
      """
    end

    def bare(assigns) do
      ~H"""
      <.card>Only section</.card>
      """
    end

    def unpadded(assigns) do
      ~H"""
      <.card padded={false}>
        <p>Body</p>
        <:section>Extra section</:section>
        <:footer>Footer</:footer>
      </.card>
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

    def horizontal(assigns) do
      ~H"""
      <.card orientation="horizontal">
        <:section>One</:section>
        <:section>Two</:section>
      </.card>
      """
    end

    def titled(assigns) do
      ~H"""
      <.card title_id="card-title" aria-labelledby="card-title">
        <:title>Title</:title>
        <p>Body</p>
      </.card>
      """
    end

    def actions_only(assigns) do
      ~H"""
      <.card>
        <:header_actions><button type="button">Edit</button></:header_actions>
        <:footer_actions><button type="button">View</button></:footer_actions>
      </.card>
      """
    end
  end

  defp html(assigns \\ []) do
    render_component(&TestComponent.full/1, assigns) |> LazyHTML.from_fragment()
  end

  defp parts(document, name) do
    document |> LazyHTML.query(~s([data-part="#{name}"])) |> LazyHTML.attribute("data-part")
  end

  defp attr(document, selector, name) do
    document |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end

  test "renders each region with a data-part hook" do
    document = html()

    root = LazyHTML.query(document, ~s([data-part="root"]))
    assert LazyHTML.attribute(root, "data-element") == ["card"]
    assert LazyHTML.tag(root) == ["div"]

    for name <-
          ~w(root header title description header-actions header-content body footer footer-content footer-actions) do
      assert parts(document, name) == [name], "expected a [data-part=#{name}] element"
    end

    assert parts(document, "section") == ["section", "section", "section"]
  end

  test "nests body sections inside the body region" do
    document = html()

    body = LazyHTML.query(document, ~s([data-part="body"]))
    sections = LazyHTML.query(body, ~s([data-part="section"]))

    assert Enum.count(sections) == 3
    assert LazyHTML.query(document, ~s([data-part="root"] > [data-part="body"])) != []
  end

  test "renders the implicit first section from the default slot" do
    document = render_component(&TestComponent.bare/1, %{}) |> LazyHTML.from_fragment()

    section = LazyHTML.query(document, ~s([data-part="section"]))
    assert LazyHTML.attribute(section, "data-padded") == [""]
    assert String.trim(LazyHTML.text(section)) == "Only section"
    assert parts(document, "header") == []
    assert parts(document, "footer") == []
  end

  test "omits the body region when the card only has actions" do
    document =
      render_component(&TestComponent.actions_only/1, %{})
      |> LazyHTML.from_fragment()

    assert parts(document, "body") == []
  end

  test "applies the root padding option to every section" do
    document = html()

    sections = LazyHTML.query(document, ~s([data-part="section"]))

    assert Enum.map(sections, &LazyHTML.attribute(&1, "data-padded")) == [
             [""],
             [""],
             [""]
           ]

    document =
      render_component(&TestComponent.unpadded/1, %{})
      |> LazyHTML.from_fragment()

    sections = LazyHTML.query(document, ~s([data-part="section"]))
    assert Enum.map(sections, &LazyHTML.attribute(&1, "data-padded")) == [[], []]
  end

  test "merges repeated action slots into their regions" do
    document = html()

    header_actions = LazyHTML.query(document, ~s([data-part="header-actions"]))
    assert LazyHTML.text(header_actions) =~ "Edit"
    assert LazyHTML.text(header_actions) =~ "Remove"

    footer_actions = LazyHTML.query(document, ~s([data-part="footer-actions"]))
    assert LazyHTML.text(footer_actions) =~ "View"
  end

  test "renders header and footer regions when they only contain actions" do
    document =
      render_component(&TestComponent.actions_only/1, %{})
      |> LazyHTML.from_fragment()

    assert parts(document, "header") == ["header"]
    assert parts(document, "header-actions") == ["header-actions"]
    assert parts(document, "footer") == ["footer"]
    assert parts(document, "footer-actions") == ["footer-actions"]
  end

  test "defaults to vertical orientation" do
    assert attr(html(), ~s([data-part="root"]), "data-orientation") == ["vertical"]
  end

  test "reports a horizontal orientation" do
    document = render_component(&TestComponent.horizontal/1, %{}) |> LazyHTML.from_fragment()

    assert attr(document, ~s([data-part="root"]), "data-orientation") == ["horizontal"]
  end

  test "chooses the root element with the as attribute" do
    document = render_component(&TestComponent.as_section/1, %{}) |> LazyHTML.from_fragment()

    assert document |> LazyHTML.query(~s([data-part="root"])) |> LazyHTML.tag() == ["section"]
  end

  test "gives the title an id for aria-labelledby" do
    document = render_component(&TestComponent.titled/1, %{}) |> LazyHTML.from_fragment()

    title = LazyHTML.query(document, ~s([data-part="title"]))
    assert LazyHTML.attribute(title, "id") == ["card-title"]

    root = LazyHTML.query(document, ~s([data-part="root"]))
    assert LazyHTML.attribute(root, "aria-labelledby") == ["card-title"]
  end

  test "declares its element type and documented parts" do
    assert %FlintUI.Meta{name: :card, type: :element, status: :draft} =
             FlintUI.Base.Card.meta()

    parts = FlintUI.Base.Card.parts_attrs()
    assert parts.root |> Enum.any?(&(&1.name == "[data-element]"))
    assert parts.root |> Enum.any?(&(&1.name == "[data-orientation]"))
    assert parts.body |> Enum.any?(&(&1.name == "[data-part]"))
    assert parts.section |> Enum.any?(&(&1.name == "[data-padded]"))
    refute parts.section |> Enum.any?(&(&1.name == "[data-divider]"))
    refute parts.footer |> Enum.any?(&(&1.name == "[data-divider]"))
    assert parts.header_actions |> Enum.any?(&(&1.name == "[data-part]"))
    assert parts.footer_content |> Enum.any?(&(&1.name == "[data-part]"))
    assert parts.footer_actions |> Enum.any?(&(&1.name == "[data-part]"))
  end
end
