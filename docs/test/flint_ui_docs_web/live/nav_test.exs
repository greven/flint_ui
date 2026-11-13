defmodule FlintUIDocsWeb.NavTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Nav

  test "every section page path is unique and routable", %{conn: conn} do
    pages =
      for section <- Nav.sections(),
          group <- section.groups,
          page <- flatten_pages(group.pages),
          do: page

    paths = Enum.map(pages, & &1.path)
    assert paths == Enum.uniq(paths)

    for path <- paths do
      assert {:ok, _view, _html} = live(conn, path), "expected #{path} to render"
    end
  end

  test "the components section mirrors the component registry" do
    groups =
      Nav.get!(:components).groups
      |> Map.new(fn group ->
        {group.label, group.pages |> flatten_pages() |> Enum.map(& &1.name)}
      end)

    expected =
      FlintUI.Docs.grouped_components()
      |> Map.new(fn {type, names} -> {type_label(type), names} end)

    assert groups == expected
  end

  test "related components can nest in their type group" do
    element = Enum.find(Nav.get!(:components).groups, &(&1.label == "Element"))
    avatar = Enum.find(element.pages, &(&1.name == :avatar))

    assert Enum.map(avatar.children, & &1.name) == [:avatar_group]
    refute Enum.any?(element.pages, &(&1.name == :avatar_group))
  end

  test "related components without a nav relation stay top-level" do
    action = Enum.find(Nav.get!(:components).groups, &(&1.label == "Action"))
    button = Enum.find(action.pages, &(&1.name == :button))

    assert button.children == []
    assert Enum.any?(action.pages, &(&1.name == :group))
  end

  test "breadcrumbs/2 builds the section and group trail", %{} do
    assert Nav.breadcrumbs(:getting_started, :installation) == [
             %{label: "Get Started", path: "/getting-started/introduction"},
             %{label: "Overview", path: "/getting-started/introduction"}
           ]

    assert Nav.breadcrumbs(:guides, :theming) == [
             %{label: "Guides", path: "/guides/theming"},
             %{label: "Theming", path: "/guides/theming"}
           ]
  end

  test "breadcrumbs/2 includes the component type", %{} do
    assert Nav.breadcrumbs(:components, :button) == [
             %{label: "Components", path: "/components"},
             %{label: "Action", path: "/components"}
           ]
  end

  test "breadcrumbs/2 finds a nested related component in its type group" do
    assert Nav.breadcrumbs(:components, :avatar_group) == [
             %{label: "Components", path: "/components"},
             %{label: "Element", path: "/components"}
           ]
  end

  test "every sidebar group declares a Lucide icon" do
    for section <- Nav.sections(), group <- section.groups do
      assert group.icon =~ ~r/^lucide-[a-z0-9-]+$/,
             "expected #{inspect(group.label)} to declare a Lucide icon"
    end
  end

  test "every component type has its own icon" do
    types = FlintUI.Meta.types()
    icons = Enum.map(types, &Nav.type_icon/1)

    assert length(icons) == length(Enum.uniq(icons))
    assert Enum.all?(icons, &(&1 =~ ~r/^lucide-/))
  end

  defp flatten_pages(pages) do
    Enum.flat_map(pages, fn page ->
      [page | flatten_pages(Map.get(page, :children, []))]
    end)
  end

  defp type_label(type) do
    type |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
