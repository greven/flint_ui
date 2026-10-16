defmodule FlintUIDocsWeb.ComponentDocsTest do
  use ExUnit.Case, async: true

  alias FlintUIDocsWeb.ComponentDocs

  test "no component doc snippet uses a placeholder" do
    for {name, _module} <- ComponentDocs.modules(),
        {section, code} <- snippets(name) do
      refute String.contains?(code, "..."),
             "expected no `...` placeholder in the #{section} snippet of #{name}"
    end
  end

  defp snippets(name) do
    usage = entry_snippets("usage", ComponentDocs.usage(name))
    examples = entry_snippets("example", ComponentDocs.examples(name))

    structure =
      case ComponentDocs.structure(name) do
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
