defmodule FlintUIDocsWeb.Markdown do
  @moduledoc """
  Renders authored prose with MDEx (CommonMark plus the GFM extensions).

  The docs pages use `prose/1` for section copy.

  Pass Markdown through the `content` attribute; it renders links, emphasis,
  ordered and unordered lists, tables, autolinks, and highlighted code. Raw
  HTML is not passed through.

  A root-relative Markdown link, such as `[Card](/components/card)`, navigates
  within the running LiveView instead of remounting the page. External URLs,
  `mailto:` links, and `#section` fragments keep native browser navigation, so
  use an absolute URL for another site and a fragment for a jump on the same
  page.

  An inner block is also supported, but it is rendered as HEEx, not parsed as
  Markdown. Use it when prose needs live components or route-checked `~p` links:

      <Markdown.prose>
        Use the <.link navigate={~p"/guides/theming"}>theming guide</.link>.
      </Markdown.prose>
  """

  use Phoenix.Component

  import Phoenix.HTML, only: [attributes_escape: 1, raw: 1, safe_to_string: 1]

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
      plugins: [&highlight_code_blocks/1, &navigate_internal_links/1],
      render: [unsafe: false]
    )
  end

  # MDEx emits node attributes only in unsafe mode, and the docs keep raw HTML
  # off. Rendering an internal link as `MDEx.Raw` instead keeps the same two
  # attributes `.link navigate` emits, so LiveView intercepts the click. The URL
  # and title are escaped here because `MDEx.Raw` is never sanitized.
  defp navigate_internal_links(document) do
    MDEx.Document.append_steps(document, navigate_internal_links: &rewrite_internal_links/1)
  end

  defp rewrite_internal_links(document) do
    MDEx.Document.update_nodes(document, MDEx.Link, &live_view_link/1)
  end

  defp live_view_link(%MDEx.Link{url: url} = link) when is_binary(url) do
    if live_view_path?(url), do: %MDEx.Raw{literal: anchor_html(link)}, else: link
  end

  defp live_view_link(link), do: link

  # Only root-relative paths are docs routes. A leading `//` is a
  # protocol-relative external URL, and `#fragment` stays a same-page jump.
  defp live_view_path?("/" <> path), do: not String.starts_with?(path, "/")
  defp live_view_path?(_url), do: false

  defp anchor_html(%MDEx.Link{} = link) do
    attributes =
      attributes_escape(
        href: link.url,
        title: blank_to_nil(link.title),
        "data-phx-link": "redirect",
        "data-phx-link-state": "push"
      )
      |> safe_to_string()

    inner = MDEx.to_html!(%MDEx.Document{nodes: link.nodes})

    "<a#{attributes}>#{inner}</a>"
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

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
