defmodule FlintUIDocsWeb.NavTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Nav

  test "every section page path is unique and routable", %{conn: conn} do
    pages = for section <- Nav.sections(), group <- section.groups, page <- group.pages, do: page

    paths = Enum.map(pages, & &1.path)
    assert paths == Enum.uniq(paths)

    for path <- paths do
      assert {:ok, _view, _html} = live(conn, path), "expected #{path} to render"
    end
  end

  test "the components section mirrors the component registry" do
    groups =
      Nav.get!(:components).groups
      |> Map.new(fn group -> {group.label, Enum.map(group.pages, & &1.name)} end)

    expected =
      FlintUI.Docs.grouped_components()
      |> Map.new(fn {type, names} -> {type_label(type), names} end)

    assert groups == expected
  end

  test "breadcrumbs/2 builds the section and group trail", %{} do
    assert Nav.breadcrumbs(:getting_started, :installation) == [
             %{label: "Get Started", path: "/getting-started"},
             %{label: "Overview", path: "/getting-started/introduction"}
           ]

    assert Nav.breadcrumbs(:guides, :theming) == [
             %{label: "Guides", path: "/guides"},
             %{label: "Theming", path: "/guides/theming"}
           ]
  end

  test "breadcrumbs/2 includes the component type", %{} do
    assert Nav.breadcrumbs(:components, :button) == [
             %{label: "Components", path: "/components"},
             %{label: "Action", path: "/components"}
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

  defp type_label(type) do
    type |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
