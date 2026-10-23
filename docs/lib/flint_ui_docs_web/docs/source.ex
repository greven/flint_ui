defmodule FlintUIDocsWeb.Docs.Source do
  @moduledoc """
  Reads the render callback that produced a preview card.

  The component docs keep the public Code snippet separate from the markup that
  actually renders the preview. In development the code block can therefore offer
  a Source toggle showing the real `~H` body from the page module, so the two never
  have to be kept in sync by hand.

  `:playground` maps to `render_playground/1`, `:usage` to `render_usage/1`, and
  `:block` to `render_block/1`. The matching clause is selected by the literal
  `block` (and, when given, `layer`) in its argument pattern.

  Extraction is gated by the `:dev_tools` application environment flag. When it
  is off, `get/3` returns `nil` and the code block hides the Source toggle.
  """

  @cache_key {__MODULE__, :source_ast}

  @type source :: %{
          code: String.t(),
          path: String.t(),
          line: pos_integer(),
          callback: String.t()
        }

  @doc """
  Extracts the source for `kind` from `module`'s render callback.

  Returns `{:ok, source}` or `:error`. Options:

    * `:block` - the usage/example id whose clause should be read
    * `:layer` - `:styled` or `:base`, matched only when the clause names it
  """
  @spec extract(module(), :playground | :usage | :block, keyword()) ::
          {:ok, source()} | :error
  def extract(module, kind, opts \\ []) do
    with function when is_atom(function) <- callback(kind),
         {:ok, {ast, path}} <- module_ast(module),
         {:ok, {line, code}} <- find_clause(ast, function, opts) do
      {:ok,
       %{
         code: code,
         path: Path.relative_to_cwd(path),
         line: line,
         callback: "#{function}/1"
       }}
    else
      _ -> :error
    end
  end

  @doc """
  Returns the extracted source when dev tools are enabled, otherwise `nil`.
  """
  @spec get(module(), :playground | :usage | :block, keyword()) :: source() | nil
  def get(module, kind, opts \\ []) do
    if enabled?() do
      case extract(module, kind, opts) do
        {:ok, source} -> source
        :error -> nil
      end
    end
  end

  @doc "Whether the dev-only Source toggle is enabled for this build."
  def enabled?, do: Application.get_env(:flint_ui_docs, :dev_tools, false)

  defp callback(:playground), do: :render_playground
  defp callback(:usage), do: :render_usage
  defp callback(:block), do: :render_block
  defp callback(_kind), do: nil

  defp module_ast(module) do
    with true <- Code.ensure_loaded?(module),
         path when is_binary(path) <- module_source(module),
         {:ok, stat} <- File.stat(path, time: :posix) do
      key = {@cache_key, path}

      case :persistent_term.get(key, nil) do
        {mtime, ast} when mtime == stat.mtime ->
          {:ok, {ast, path}}

        _ ->
          with {:ok, text} <- File.read(path),
               {:ok, ast} <- Code.string_to_quoted(text, columns: true, token_metadata: true) do
            :persistent_term.put(key, {stat.mtime, ast})
            {:ok, {ast, path}}
          else
            _ -> :error
          end
      end
    else
      _ -> :error
    end
  end

  defp module_source(module) do
    case module.module_info(:compile)[:source] do
      nil -> nil
      source -> to_string(source)
    end
  rescue
    _ -> nil
  end

  defp find_clause(ast, function, opts) do
    clauses =
      ast
      |> collect_defs(function)
      |> Enum.filter(fn {_line, head, _body} -> block_match?(head, Keyword.get(opts, :block)) end)
      |> prefer_layer(Keyword.get(opts, :layer))

    Enum.find_value(clauses, :error, fn {line, _head, body} ->
      case extract_body(body) do
        {:ok, code} -> {:ok, {line, code}}
        :error -> nil
      end
    end)
  end

  defp collect_defs(ast, function) do
    {_ast, clauses} =
      Macro.prewalk(ast, [], fn
        {:def, meta, [{^function, _, [arg | _]}, [do: body]]} = node, acc ->
          {node, [{meta[:line], arg, body} | acc]}

        node, acc ->
          {node, acc}
      end)

    Enum.reverse(clauses)
  end

  # A generic clause without `layer` is still a candidate. When several clauses
  # match the block, prefer the one that names the requested layer.
  defp prefer_layer(clauses, nil), do: clauses

  defp prefer_layer(clauses, layer) do
    case Enum.filter(clauses, fn {_line, head, _body} -> pattern_value(head, :layer) == layer end) do
      [] -> clauses
      matched -> matched
    end
  end

  defp block_match?(_head, nil), do: true
  defp block_match?(head, block), do: pattern_value(head, :block) == block

  defp pattern_value(head, key) do
    head
    |> pattern_map()
    |> Keyword.get(key)
  end

  defp pattern_map({:=, _, [pattern, _assigns]}), do: pattern_map(pattern)

  defp pattern_map({:%{}, _, pairs}) when is_list(pairs) do
    Enum.filter(pairs, fn
      {key, value} when is_atom(key) and is_atom(value) -> true
      _ -> false
    end)
  end

  defp pattern_map(_head), do: []

  defp extract_body({:sigil_H, _, [{:<<>>, _, [text]}, _modifiers]}) when is_binary(text) do
    {:ok, String.trim(text)}
  end

  defp extract_body(body) do
    code =
      body
      |> Macro.to_string()
      |> String.trim()
      |> strip_sigil()

    if code == "", do: :error, else: {:ok, code}
  end

  defp strip_sigil(code) do
    case Regex.run(~r/\A~H"""\n(.*)\n"""\z/s, code) do
      [_, inner] -> inner
      _ -> code
    end
  end
end
