defmodule FlintUIDocsWeb.HighlightTest do
  use ExUnit.Case, async: true

  alias FlintUIDocsWeb.Highlight

  defp to_html(safe), do: Phoenix.HTML.safe_to_string(safe)

  test "highlights HEEx into token spans" do
    html = to_html(Highlight.highlight(~s(<.button disabled>Save</.button>), :heex))

    assert html =~ ~s(<span class=")
    assert html =~ "&lt;"
    refute html =~ "<.button disabled>"
  end

  test "highlights CSS" do
    html = to_html(Highlight.highlight(~s([data-element="button"] { color: red; }), :css))

    assert html =~ ~s(<span class=")
  end

  test "unknown languages fall back to the HEEx lexer" do
    html = to_html(Highlight.highlight(~s(<.button>Save</.button>), :nope))

    assert html =~ ~s(<span class=")
  end

  test "language/1 maps fenced info strings" do
    assert Highlight.language("css") == :css
    assert Highlight.language("elixir") == :elixir
    assert Highlight.language("shell") == :shell
    assert Highlight.language("bash") == :shell
    assert Highlight.language("") == :heex
    assert Highlight.language("unknown-lang") == :heex
  end
end
