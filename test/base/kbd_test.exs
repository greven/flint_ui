defmodule FlintUI.Base.KbdTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <.kbd id="key" data-role="test">K</.kbd>
      """
    end

    def chord(assigns) do
      ~H"""
      <span><.kbd>⌘</.kbd>
      +
      <.kbd>K</.kbd></span>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="kbd"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)

  defp count(document) do
    document
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(~r/data-element="kbd"/, &1)))
  end

  test "renders the native kbd element" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(root(document)) == ["kbd"]
    assert attr(document, "data-element") == ["kbd"]
    assert attr(document, "data-part") == ["root"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "K"
  end

  test "forwards global attributes to the root" do
    document = render(&TestComponent.plain/1)

    assert attr(document, "id") == ["key"]
    assert attr(document, "data-role") == ["test"]
  end

  test "renders one element per key in a chord" do
    document = render(&TestComponent.chord/1)

    assert count(document) == 2

    text =
      document
      |> LazyHTML.text()
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    assert text == "⌘ + K"
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :kbd, type: :element, status: :draft} =
               FlintUI.Base.Kbd.meta()

      parts = FlintUI.Base.Kbd.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "kbd"} =
               Enum.find(parts[:root], &(&1.name == "[data-element]"))

      assert Enum.any?(parts[:root], &(&1.name == "[data-part]"))
    end
  end
end
