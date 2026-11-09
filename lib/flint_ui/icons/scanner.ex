defmodule FlintUI.Icons.Scanner do
  @moduledoc false

  @default_globs [
    "lib/**/*.{ex,exs,heex,eex,leex}",
    "assets/js/**/*.{js,ts,tsx}",
    "priv/**/*.{heex,eex}"
  ]

  @icon_re ~r/\b(?:hero|lucide|si|flag)-[a-z0-9-]+\b/

  @doc "The source globs scanned when no explicit globs are given."
  def default_globs, do: @default_globs

  @doc """
  Scans source files for literal icon class names.

  Returns a `MapSet` of class names. Dynamic names cannot be found; pass them
  through `:safelist`.
  """
  def scan(globs \\ @default_globs, opts \\ []) do
    safelist =
      opts[:safelist]
      |> List.wrap()
      |> Enum.map(&to_string/1)

    globs
    |> List.wrap()
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.reduce(MapSet.new(safelist), fn path, acc ->
      if File.regular?(path) and not skip?(path) do
        path
        |> File.read!()
        |> then(&Regex.scan(@icon_re, &1))
        |> List.flatten()
        |> Enum.reduce(acc, &MapSet.put(&2, &1))
      else
        acc
      end
    end)
  end

  defp skip?(path) do
    String.contains?(path, ["deps/", "_build/", "node_modules/", "priv/static/"])
  end
end
