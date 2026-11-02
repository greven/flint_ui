defmodule FlintUIDocsWeb.Markdown do
  @moduledoc """
  Renders authored prose with MDEx (CommonMark plus the GFM extensions).

  The docs pages use `prose/1` for section copy.

  Pass Markdown through the `content` attribute; it renders links, emphasis,
  ordered and unordered lists, tables, autolinks, and highlighted code. Raw
  HTML is not passed through.

  An inner block is also supported, but it is rendered as HEEx, not parsed as
  Markdown. Use it when prose needs live components or route-checked `~p` links:

      <Markdown.prose>
        Use the <.link navigate={~p"/guides/theming"}>theming guide</.link>.
      </Markdown.prose>
  """

  use Phoenix.Component

  import Phoenix.HTML, only: [raw: 1, safe_to_string: 1]

  alias FlintUIDocsWeb.Highlight

  attr :content, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block

  def prose(assigns) do
    assigns = assign(assigns, :html, assigns.content && to_html(assigns.content))

    ~H"""
    <div :if={@html || @inner_block} class={["docs-prose", @class]}>
      <%= if @html do %>
        {raw(@html)}
      <% end %>
      <%= if @inner_block do %>
        {render_slot(@inner_block)}
      <% end %>
    </div>
    """
  end

  defp to_html(content) when is_binary(content) do
    MDEx.to_html!(content,
      extension: [table: true, strikethrough: true, autolink: true, tasklist: true],
      plugins: [&highlight_code_blocks/1],
      render: [unsafe: false]
    )
  end

  defp highlight_code_blocks(document) do
    MDEx.Document.append_steps(document, highlight_code: &update_code_blocks/1)
  end

  defp update_code_blocks(document) do
    MDEx.Document.update_nodes(document, MDEx.CodeBlock, fn node ->
      highlighted =
        node.literal
        |> Highlight.highlight(Highlight.language(node.info))
        |> safe_to_string()

      %MDEx.Raw{literal: ~s(<pre class="highlight"><code>#{highlighted}</code></pre>)}
    end)
  end
end
