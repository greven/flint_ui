defmodule FlintUIDocsWeb.Markdown do
  @moduledoc """
  Renders a small, safe subset of Markdown used by the component docs.

  Supports blank-line separated paragraphs, inline code spans, fenced code
  blocks, and indented code blocks. Everything else is emitted as escaped text,
  so component prose can be authored inline in the docs modules without pulling
  in a full Markdown parser.
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Highlight

  import Phoenix.HTML, only: [html_escape: 1, raw: 1, safe_to_string: 1]

  attr(:content, :string, required: true)

  def markdown(assigns) do
    assigns = assign(assigns, :blocks, parse(assigns.content))

    ~H"""
    <div class="flex flex-col gap-3 text-sm leading-relaxed text-default">
      <%= for block <- @blocks do %>
        <%= case block do %>
          <% {:code, code, lang} -> %>
            <DocsComponents.code_block code={code} lang={lang} />
          <% {:p, text} -> %>
            <p>{text}</p>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp parse(nil), do: []

  defp parse(content) do
    content
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> collect([])
    |> Enum.reverse()
  end

  defp collect([], acc), do: acc

  defp collect([line | rest], acc) do
    cond do
      fenced?(line) ->
        lang = Highlight.language(fence_info(line))
        {code, remaining} = take_fenced(rest, [])
        collect(remaining, [{:code, code, lang} | acc])

      indented?(line) ->
        {code_lines, remaining} = take_indented([line | rest], [])
        collect(remaining, [{:code, dedent_code(code_lines), :heex} | acc])

      blank?(line) ->
        collect(rest, acc)

      true ->
        {paragraph, remaining} = take_paragraph([line | rest], [])
        collect(remaining, [{:p, inline(paragraph)} | acc])
    end
  end

  defp take_fenced([], acc), do: {join(acc), []}

  defp take_fenced([line | rest], acc) do
    if fenced?(line), do: {join(acc), rest}, else: take_fenced(rest, [line | acc])
  end

  defp take_indented([], acc), do: {Enum.reverse(acc), []}

  defp take_indented([line | rest], acc) do
    if indented?(line),
      do: take_indented(rest, [line | acc]),
      else: {Enum.reverse(acc), [line | rest]}
  end

  defp take_paragraph([], acc), do: {text(acc), []}

  defp take_paragraph([line | rest], acc) do
    if blank?(line) or indented?(line) or fenced?(line),
      do: {text(acc), [line | rest]},
      else: take_paragraph(rest, [line | acc])
  end

  defp join(lines), do: lines |> Enum.reverse() |> Enum.join("\n") |> String.trim()

  defp text(lines), do: lines |> Enum.reverse() |> Enum.map_join(" ", &String.trim/1)

  defp dedent_code(lines) do
    lines
    |> Enum.map(fn line ->
      line
      |> String.replace_prefix("    ", "")
      |> String.replace_prefix("\t", "")
    end)
    |> Enum.join("\n")
    |> String.trim_trailing()
  end

  defp fenced?(line), do: String.starts_with?(String.trim_leading(line), "```")

  defp fence_info(line) do
    line
    |> String.trim_leading()
    |> String.replace_prefix("```", "")
  end

  defp blank?(line), do: String.trim(line) == ""

  defp indented?(line), do: String.starts_with?(line, "    ") or String.starts_with?(line, "\t")

  defp inline(text) do
    text
    |> html_escape()
    |> safe_to_string()
    |> then(fn escaped ->
      Regex.replace(~r/`([^`]+)`/, escaped, fn _whole, code ->
        ~s(<code class="rounded bg-accented px-1 py-0.5 font-mono text-xs text-default">#{code}</code>)
      end)
    end)
    |> raw()
  end
end
