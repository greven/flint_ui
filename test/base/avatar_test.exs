defmodule FlintUI.Base.AvatarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def image(assigns) do
      ~H"""
      <FlintUI.avatar
        src="https://example.com/jane.jpg"
        name="Jane Doe"
        alt="Jane"
        loading="lazy"
        width="80"
        class="extra"
        data-role="test"
      />
      """
    end

    def no_src(assigns) do
      ~H"""
      <FlintUI.avatar name="Cher" />
      """
    end

    def custom_fallback(assigns) do
      ~H"""
      <FlintUI.avatar name="Jane Doe">
        <:fallback><span id="custom">X</span></:fallback>
      </FlintUI.avatar>
      """
    end

    def decorative(assigns) do
      ~H"""
      <FlintUI.avatar name="Jane Doe" alt="" />
      """
    end

    def nameless(assigns) do
      ~H"""
      <FlintUI.avatar />
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="avatar"]))
  defp image(document), do: LazyHTML.query(document, ~s([data-part="image"]))
  defp fallback(document), do: LazyHTML.query(document, ~s([data-part="fallback"]))
  defp attr(node, name), do: LazyHTML.attribute(node, name)
  defp text(node), do: node |> LazyHTML.text() |> String.trim()

  test "renders the image and its image attributes" do
    document = render(&TestComponent.image/1)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert attr(root(document), "data-status") == ["loading"]
    assert attr(root(document), "class") == ["extra"]

    assert attr(image(document), "src") == ["https://example.com/jane.jpg"]
    assert attr(image(document), "alt") == ["Jane"]
    assert attr(image(document), "loading") == ["lazy"]
    assert attr(image(document), "width") == ["80"]
    assert attr(image(document), "data-role") == ["test"]
  end

  test "renders initials behind the image while it loads" do
    document = render(&TestComponent.image/1)

    assert attr(fallback(document), "data-fallback") == ["initials"]
    assert attr(fallback(document), "hidden") == []
    assert attr(fallback(document), "aria-hidden") == ["true"]
    assert attr(fallback(document), "role") == ["img"]
    assert attr(fallback(document), "aria-label") == ["Jane"]
    assert attr(fallback(document), "title") == ["Jane"]
    assert text(fallback(document)) == "JD"

    html = LazyHTML.to_html(document)

    assert :binary.match(html, ~s(data-part="fallback")) <
             :binary.match(html, ~s(data-part="image"))
  end

  test "renders the fallback when src is absent" do
    document = render(&TestComponent.no_src/1)

    assert LazyHTML.to_html(image(document)) == ""
    assert attr(root(document), "data-status") == ["fallback"]
    assert attr(fallback(document), "hidden") == []
    assert attr(fallback(document), "data-fallback") == ["initials"]
    assert attr(fallback(document), "role") == ["img"]
    assert attr(fallback(document), "aria-label") == ["Cher"]
    assert attr(fallback(document), "aria-hidden") == []
    assert text(fallback(document)) == "C"
  end

  test "a fallback slot replaces initials" do
    document = render(&TestComponent.custom_fallback/1)

    assert attr(fallback(document), "data-fallback") == ["slot"]
    assert text(fallback(document)) == "X"
    assert document |> LazyHTML.query(~s(#custom)) |> LazyHTML.text() == "X"
  end

  test "an empty alt makes the fallback decorative" do
    document = render(&TestComponent.decorative/1)

    assert attr(fallback(document), "title") == []
    assert attr(fallback(document), "role") == []
    assert attr(fallback(document), "aria-label") == []
    assert attr(fallback(document), "aria-hidden") == ["true"]
    assert text(fallback(document)) == "JD"
  end

  test "an avatar with no name or image renders an empty fallback" do
    document = render(&TestComponent.nameless/1)

    assert attr(fallback(document), "data-fallback") == ["none"]
    assert text(fallback(document)) == ""
  end

  test "initials keep only the first and last name parts" do
    assert FlintUI.Base.Avatar.initials("Jane Doe") == "JD"
    assert FlintUI.Base.Avatar.initials("Mary Jane Watson") == "MW"
    assert FlintUI.Base.Avatar.initials("Cher") == "C"
    assert FlintUI.Base.Avatar.initials("  ") == nil
    assert FlintUI.Base.Avatar.initials(nil) == nil
  end

  describe "metadata" do
    test "declares its parts and type" do
      assert %FlintUI.Meta{name: :avatar, type: :element, status: :draft} =
               FlintUI.Base.Avatar.meta()

      parts = FlintUI.Base.Avatar.parts_attrs()
      assert Enum.any?(parts.root, &(&1.name == "[data-element]"))
      assert Enum.any?(parts.root, &(&1.name == "[data-status]"))
      assert Enum.any?(parts.image, &(&1.name == "src"))
      assert Enum.any?(parts.fallback, &(&1.name == "[data-fallback]"))
    end
  end
end
