defmodule FlintUIDocsWeb.DocsUtilityClassesTest do
  use ExUnit.Case, async: true

  test "component doc pages only use emitted fl-* utility classes" do
    known = MapSet.new(FlintUI.Utilities.classes(), & &1.class)

    unknown =
      for path <- page_paths(),
          class <- utility_classes(File.read!(path)),
          not MapSet.member?(known, class),
          uniq: true do
        {Path.basename(path), class}
      end

    assert unknown == []
  end

  defp page_paths do
    Path.wildcard(Path.expand("../../lib/flint_ui_docs_web/docs/*.ex", __DIR__))
  end

  defp utility_classes(source) do
    ~r/class="([^"]*)"/
    |> Regex.scan(source, capture: :all_but_first)
    |> List.flatten()
    |> Enum.flat_map(&String.split/1)
    |> Enum.filter(&String.starts_with?(&1, "fl-"))
  end
end
