defmodule FlintUIDocsWeb.DocsTest do
  use ExUnit.Case, async: true

  alias FlintUIDocsWeb.Docs

  @ignored_attrs [:rest, :class, :flint_parts]

  test "no component doc snippet uses a placeholder" do
    for {name, _module} <- Docs.modules(),
        {section, code} <- snippets(name) do
      refute String.contains?(code, "..."),
             "expected no `...` placeholder in the #{section} snippet of #{name}"
    end
  end

  test "every public attribute is covered by a usage entry" do
    for {name, _module} <- Docs.modules() do
      for {layer, attrs} <- public_attrs(name) do
        covered =
          name
          |> Docs.usage()
          |> Enum.filter(&(&1.layer == layer))
          |> Enum.flat_map(&Map.get(&1, :covers, []))

        for attr <- attrs do
          assert attr in covered,
                 "expected #{name} #{layer} attribute #{inspect(attr)} to have a usage entry"
        end
      end
    end
  end

  test "every component has styled and base examples" do
    for {name, _module} <- Docs.modules() do
      assert Docs.styled_examples(name) != [],
             "expected #{name} to have at least one styled example"

      assert Docs.base_examples(name) != [],
             "expected #{name} to have at least one base example"
    end
  end

  test "every component has a CSS contract" do
    for {name, _module} <- Docs.modules() do
      assert %{body: body, snippets: snippets} = Docs.css(name)
      assert is_binary(body) and body != ""
      assert is_list(snippets) and snippets != []
    end
  end

  test "every base example is tagged as base and every styled example is tagged as styled" do
    for {name, _module} <- Docs.modules() do
      for example <- Docs.examples(name) do
        assert example[:layer] in [nil, :base, :styled],
               "expected #{name}.#{example.id} to have a valid layer"

        if example[:layer] == :base do
          assert Docs.base_examples(name) |> Enum.any?(&(&1.id == example.id))
        else
          assert Docs.styled_examples(name) |> Enum.any?(&(&1.id == example.id))
        end
      end
    end
  end

  defp public_attrs(name), do: [base: base_attrs(name), styled: styled_attrs(name)]

  defp base_attrs(name) do
    name
    |> FlintUI.Docs.attrs()
    |> Enum.map(& &1.name)
    |> Enum.reject(&(&1 in @ignored_attrs))
  end

  defp styled_attrs(name) do
    case FlintUI.Styled.get(name) do
      nil -> []
      entry -> Enum.map(entry.props, & &1.name)
    end
  end

  defp snippets(name) do
    usage = entry_snippets("usage", Docs.usage(name))
    examples = entry_snippets("example", Docs.examples(name))

    structure =
      case Docs.structure(name) do
        nil -> []
        code -> [{"structure", code}]
      end

    usage ++ examples ++ structure
  end

  defp entry_snippets(label, entries) do
    for entry <- entries, snippet <- entry_codes(entry) do
      {"#{label} #{entry.id}", snippet}
    end
  end

  defp entry_codes(entry) do
    single = if entry[:code], do: [entry.code], else: []

    multi =
      for flavor <- entry[:codes] || [], snippet <- [flavor[:code], flavor[:styles]], snippet do
        snippet
      end

    single ++ multi
  end
end
