defmodule FlintUI.Base.SeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.separator id="rule" data-role="test" />
      """
    end

    def labelled(assigns) do
      ~H"""
      <.separator orientation="vertical" id="rule">or</.separator>
      """
    end

    def decorative(assigns) do
      ~H"""
      <.separator decorative orientation="vertical" id="rule" />
      """
    end

    def thematic(assigns) do
      ~H"""
      <.separator as="hr" id="rule" />
      """
    end

    def blank(assigns) do
      ~H"""
      <.separator id="rule"></.separator>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="separator"]))
  defp content(document), do: LazyHTML.query(document, ~s([data-part="content"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)

  test "renders a non-focusable separator on a div by default" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(root(document)) == ["div"]
    assert attr(document, "data-element") == ["separator"]
    assert attr(document, "data-part") == ["root"]
    assert attr(document, "data-orientation") == ["horizontal"]
    assert attr(document, "role") == ["separator"]
    assert attr(document, "aria-orientation") == []
    assert attr(document, "tabindex") == []
    assert content(document) |> LazyHTML.to_html() == ""
  end

  test "forwards global attributes to the root" do
    document = render(&TestComponent.plain/1)

    assert attr(document, "id") == ["rule"]
    assert attr(document, "data-role") == ["test"]
  end

  test "renders content in a content part and marks a vertical separator" do
    document = render(&TestComponent.labelled/1)

    assert attr(document, "data-orientation") == ["vertical"]
    assert attr(document, "role") == ["separator"]
    assert attr(document, "aria-orientation") == ["vertical"]
    assert content(document) |> LazyHTML.text() |> String.trim() == "or"
  end

  test "decorative drops the role and the orientation for assistive technology" do
    document = render(&TestComponent.decorative/1)

    assert attr(document, "role") == ["none"]
    assert attr(document, "aria-orientation") == []
    assert attr(document, "data-orientation") == ["vertical"]
  end

  test "renders the chosen root element" do
    document = render(&TestComponent.thematic/1)

    assert LazyHTML.tag(root(document)) == ["hr"]
    assert attr(document, "role") == ["separator"]
  end

  test "treats a blank default slot as no content" do
    document = render(&TestComponent.blank/1)

    assert content(document) |> LazyHTML.to_html() == ""
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :separator, type: :layout, status: :draft} =
               FlintUI.Base.Separator.meta()

      parts = FlintUI.Base.Separator.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "separator"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:root], &(&1.name == "[data-part]"))
      assert Enum.any?(parts[:root], &(&1.name == "role"))
      assert Enum.any?(parts[:content], &(&1.name == "[data-part]"))
    end
  end
end
