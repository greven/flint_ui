defmodule FlintUIDocsWeb.Highlight do
  @moduledoc """
  Server-side syntax highlighting for the docs code blocks, backed by Makeup.

  `highlight/2` returns HTML that is safe to embed inside
  `<pre class="highlight">`. The token classes are styled in
  `assets/css/highlight.css` with the docs' semantic color tokens, so
  highlighting follows light/dark mode and the active `data-theme` preset. The
  `.highlight` background is transparent; the surrounding code panel supplies the
  surface.
  """

  import Phoenix.HTML, only: [html_escape: 1, raw: 1]

  @lexers %{
    heex: Makeup.Lexers.HEExLexer,
    eex: Makeup.Lexers.EExLexer,
    html: Makeup.Lexers.HTMLLexer,
    elixir: Makeup.Lexers.ElixirLexer,
    css: MakeupCSS.Lexer,
    shell: Makeup.Lexers.ElixirLexer
  }

  @default Makeup.Lexers.HEExLexer

  @languages %{
    "elixir" => :elixir,
    "ex" => :elixir,
    "exs" => :elixir,
    "css" => :css,
    "heex" => :heex,
    "html" => :html,
    "eex" => :eex,
    "shell" => :shell,
    "sh" => :shell,
    "bash" => :shell,
    "console" => :shell
  }

  @doc """
  Highlights `code` as `lang` (defaults to `:heex`), returning safe HTML.

  Falls back to escaped, unhighlighted text if a snippet cannot be lexed, so a
  malformed snippet never breaks a page.
  """
  def highlight(code, lang \\ :heex) when is_binary(code) do
    code
    |> Makeup.highlight_inner_html(lexer: lexer(lang))
    |> raw()
  rescue
    _ -> html_escape(code)
  end

  @doc """
  Maps a fenced-code info string (e.g. `"css"`) onto a supported language.
  Unknown languages fall back to `:heex`.
  """
  def language(info) when is_binary(info) do
    info
    |> String.trim()
    |> String.split(~r/\s+/, parts: 2)
    |> List.first()
    |> then(&Map.get(@languages, &1, :heex))
  end

  @doc """
  Returns the display label for a code language.
  """
  def label(:heex), do: "HEEx"
  def label(:eex), do: "EEX"
  def label(:html), do: "HTML"
  def label(:elixir), do: "Elixir"
  def label(:css), do: "CSS"
  def label(:shell), do: "Shell"
  def label(_lang), do: "Code"

  defp lexer(lang), do: Map.get(@lexers, lang, @default)
end
