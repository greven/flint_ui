defmodule FlintUIDocsWeb.MarkdownTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Markdown

  defp render_prose(content) do
    render_component(&Markdown.prose/1, content: content)
    |> LazyHTML.from_fragment()
  end

  defp count(document, selector), do: document |> LazyHTML.query(selector) |> Enum.count()

  defp text(document, selector) do
    document
    |> LazyHTML.query(selector)
    |> LazyHTML.text()
    |> String.trim()
  end

  test "renders links, emphasis, and inline code" do
    document = render_prose("See [theming](/guides/theming), **bold**, *italic*, and `code`.")

    assert count(
             document,
             "a[href='/guides/theming'][data-phx-link='redirect'][data-phx-link-state='push']"
           ) == 1

    assert text(document, "a[href='/guides/theming']") == "theming"
    assert text(document, "strong") == "bold"
    assert text(document, "em") == "italic"
    assert text(document, "code") == "code"
  end

  test "root-relative links navigate within the LiveView" do
    document =
      render_prose("See the [Card](/components/card) and the [guide](/guides/theming#colors).")

    for href <- ["/components/card", "/guides/theming#colors"] do
      assert count(
               document,
               "a[href='#{href}'][data-phx-link='redirect'][data-phx-link-state='push']"
             ) == 1
    end

    assert text(document, "a[href='/components/card']") == "Card"
    assert text(document, "a[href='/guides/theming#colors']") == "guide"
  end

  test "external, fragment, and protocol-relative links keep native navigation" do
    document =
      render_prose(
        "[site](https://example.com), [mail](mailto:hi@example.com), [jump](#usage), [cdn](//cdn.example.com/x)"
      )

    assert count(document, "a[data-phx-link]") == 0

    for href <- ["https://example.com", "mailto:hi@example.com", "#usage", "//cdn.example.com/x"] do
      assert count(document, "a[href='#{href}']") == 1
    end
  end

  test "an internal link keeps its title and nested inline markup" do
    document = render_prose(~S|[**Card** and `code`](/components/card "Card docs")|)

    link = "a[href='/components/card'][title='Card docs']"

    assert count(document, link) == 1
    assert text(document, "#{link} strong") == "Card"
    assert text(document, "#{link} code") == "code"
    assert text(document, link) == "Card and code"
  end

  test "renders ordered and unordered lists" do
    document = render_prose("- one\n- two\n\n1. first\n2. second")

    assert document |> LazyHTML.query("ul > li") |> Enum.map(&LazyHTML.text/1) == ["one", "two"]

    assert document |> LazyHTML.query("ol > li") |> Enum.map(&LazyHTML.text/1) == [
             "first",
             "second"
           ]
  end

  test "renders tables" do
    document = render_prose("| Name | Value |\n| --- | --- |\n| Color | Primary |")

    assert count(document, "table") == 1
    assert document |> LazyHTML.query("th") |> Enum.map(&LazyHTML.text/1) == ["Name", "Value"]
    assert document |> LazyHTML.query("td") |> Enum.map(&LazyHTML.text/1) == ["Color", "Primary"]
  end

  test "renders highlighted fenced code blocks" do
    document = render_prose("```elixir\n:ok\n```")

    assert count(document, "pre.highlight") == 1
    assert LazyHTML.text(LazyHTML.query(document, "pre.highlight")) =~ ":ok"
  end

  test "does not pass through raw HTML" do
    document = render_prose("<script>alert('x')</script>")

    assert count(document, "script") == 0
  end

  test "renders an HEEx inner block" do
    assigns = %{label: "inner_block"}

    document =
      rendered_to_string(~H"""
      <Markdown.prose>
        <p>Use the <code>{@label}</code> attribute.</p>
      </Markdown.prose>
      """)
      |> LazyHTML.from_fragment()

    assert text(document, "p") == "Use the inner_block attribute."
    assert text(document, "p code") == "inner_block"
  end
end
