defmodule FlintUIDocsWeb.MarkdownTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Markdown

  test "renders links, emphasis, and inline code" do
    html =
      render_component(&Markdown.prose/1,
        content: "See [theming](/guides/theming), **bold**, *italic*, and `code`."
      )

    assert html =~
             ~s(<a href="/guides/theming" data-phx-link="redirect" data-phx-link-state="push">theming</a>)

    assert html =~ "<strong>bold</strong>"
    assert html =~ "<em>italic</em>"
    assert html =~ "<code>code</code>"
  end

  test "root-relative links navigate within the LiveView" do
    html =
      render_component(&Markdown.prose/1,
        content: "See the [Card](/components/card) and the [guide](/guides/theming#colors)."
      )

    assert html =~
             ~s(<a href="/components/card" data-phx-link="redirect" data-phx-link-state="push">Card</a>)

    assert html =~
             ~s(<a href="/guides/theming#colors" data-phx-link="redirect" data-phx-link-state="push">guide</a>)
  end

  test "external, fragment, and protocol-relative links keep native navigation" do
    html =
      render_component(&Markdown.prose/1,
        content:
          "[site](https://example.com), [mail](mailto:hi@example.com), [jump](#usage), [cdn](//cdn.example.com/x)"
      )

    refute html =~ "data-phx-link"
  end

  test "an internal link keeps its title and nested inline markup" do
    html =
      render_component(&Markdown.prose/1,
        content: ~S|[**Card** and `code`](/components/card "Card docs")|
      )

    assert html =~
             ~s(<a href="/components/card" title="Card docs" data-phx-link="redirect" data-phx-link-state="push"><strong>Card</strong> and <code>code</code></a>)
  end

  test "renders ordered and unordered lists" do
    html = render_component(&Markdown.prose/1, content: "- one\n- two\n\n1. first\n2. second")

    assert html =~ "<ul>"
    assert html =~ "<li>one</li>"
    assert html =~ "<ol>"
    assert html =~ "<li>first</li>"
  end

  test "renders tables" do
    html =
      render_component(&Markdown.prose/1,
        content: "| Name | Value |\n| --- | --- |\n| Color | Primary |"
      )

    assert html =~ "<table>"
    assert html =~ "<th>Name</th>"
    assert html =~ "<td>Primary</td>"
  end

  test "renders highlighted fenced code blocks" do
    html = render_component(&Markdown.prose/1, content: "```elixir\n:ok\n```")

    assert html =~ ~s(<pre class="highlight">)
    assert html =~ ":ok"
  end

  test "does not pass through raw HTML" do
    html = render_component(&Markdown.prose/1, content: "<script>alert('x')</script>")

    refute html =~ "<script>"
  end

  test "renders an HEEx inner block" do
    assigns = %{label: "inner_block"}

    html =
      rendered_to_string(~H"""
      <Markdown.prose>
        <p>Use the <code>{@label}</code> attribute.</p>
      </Markdown.prose>
      """)

    assert html =~ "docs-prose"
    assert html =~ "<p>Use the <code>inner_block</code> attribute.</p>"
  end
end
