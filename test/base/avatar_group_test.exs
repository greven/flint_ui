defmodule FlintUI.Base.AvatarGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def plain(assigns) do
      ~H"""
      <FlintUI.avatar_group>
        <FlintUI.avatar alt="Jane Doe" />
        <FlintUI.avatar alt="John Smith" />
      </FlintUI.avatar_group>
      """
    end

    def labelled(assigns) do
      ~H"""
      <FlintUI.avatar_group label="Project members" as="div">
        <FlintUI.avatar alt="Jane Doe" />
      </FlintUI.avatar_group>
      """
    end

    def role_wins(assigns) do
      ~H"""
      <FlintUI.avatar_group label="Project members" role="list">
        <FlintUI.avatar alt="Jane Doe" />
      </FlintUI.avatar_group>
      """
    end
  end

  defp render(fun) do
    render_component(fun, %{}) |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="avatar_group"]))
  defp attr(node, name), do: LazyHTML.attribute(node, name)

  test "renders a plain span container with both avatars" do
    document = render(&TestComponent.plain/1)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert attr(root(document), "data-part") == ["root"]
    assert attr(root(document), "role") == []

    text =
      document
      |> LazyHTML.query(~s([data-element="avatar"] [data-part="fallback"]))
      |> LazyHTML.text()

    assert text =~ "JD"
    assert text =~ "JS"
  end

  test "a label exposes a named group and as chooses the root" do
    document = render(&TestComponent.labelled/1)

    assert LazyHTML.tag(root(document)) == ["div"]
    assert attr(root(document), "role") == ["group"]
    assert attr(root(document), "aria-label") == ["Project members"]
  end

  test "an explicit role wins over the labelled default" do
    document = render(&TestComponent.role_wins/1)

    assert attr(root(document), "role") == ["list"]
    assert attr(root(document), "aria-label") == ["Project members"]
  end

  test "declares its parts and type" do
    assert %FlintUI.Meta{name: :avatar_group, type: :element, status: :draft} =
             FlintUI.Base.AvatarGroup.meta()

    parts = FlintUI.Base.AvatarGroup.parts_attrs()
    assert Enum.any?(parts.root, &(&1.name == "[data-element]"))
    assert Enum.any?(parts.root, &(&1.name == "role"))
  end
end
