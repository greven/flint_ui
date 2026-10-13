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

  defp type_label(type) do
    type |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
