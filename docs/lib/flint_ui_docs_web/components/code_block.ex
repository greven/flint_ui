defmodule FlintUIDocsWeb.CodeBlock do
  @moduledoc """
  Syntax-highlighted code panel with a copy button.

  The panel owns the subtle tinted surface, the optional header, and the copy
  interaction. Callers shape it for their context with `class` (the docs preview
  uses it as the last, border-sharing section of a card; code-only sections use
  the default rounded panel).

  The header appears when there is a `:tabs` slot, an `:actions` slot, or a
  `caption`. It holds the tabs on the left and the actions plus copy button on the
  right. Without a header the copy button floats in the top-right corner.

  Code snippets are highlighted server-side by `FlintUIDocsWeb.Highlight`.
  """

  use FlintUIDocsWeb, :html

  alias FlintUIDocsWeb.Highlight

  attr :id, :string, required: true
  attr :copy_id, :string, default: nil
  attr :code, :string, required: true
  attr :lang, :atom, default: :heex
  attr :caption, :string, default: nil
  attr :class, :any, default: nil

  slot :tabs
  slot :actions

  def code(assigns) do
    assigns =
      assigns
      |> assign(:copy_id, assigns.copy_id || "#{assigns.id}-copy")
      |> assign(:header?, assigns.caption != nil or assigns.tabs != [] or assigns.actions != [])

    ~H"""
    <div class={[
      "relative overflow-hidden bg-black/3 dark:bg-white/3",
      @class || "rounded-lg"
    ]}>
      <div
        :if={@header?}
        class="flex items-center justify-between gap-3 border-b border-zinc-200 px-3 py-1.5 dark:border-white/10"
      >
        <div class="flex min-w-0 items-center gap-1">
          <div :if={@tabs != []} class="flex min-w-0 items-center gap-1">
            {render_slot(@tabs)}
          </div>
          <span
            :if={@caption}
            class="truncate px-1 font-mono text-xs text-zinc-400 dark:text-zinc-600"
            title={@caption}
          >
            {@caption}
          </span>
        </div>
        <div class="flex shrink-0 items-center gap-1.5">
          {render_slot(@actions)}
          <.copy_button id={@copy_id} target={@id} class="px-2 py-1" />
        </div>
      </div>

      <.copy_button
        :if={!@header?}
        id={@copy_id}
        target={@id}
        class="absolute top-2 right-2 border border-zinc-200 px-2 py-1 dark:border-white/10"
      />

      <pre class={[
        "highlight overflow-x-auto p-4 text-xs leading-relaxed",
        !@header? && "pr-16"
      ]}><code id={@id}>{Highlight.highlight(@code, @lang)}</code></pre>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".CopyCode">
        export default {
          mounted() {
            this.el.addEventListener("click", () => {
              const target = document.getElementById(this.el.dataset.copy)
              if (target) navigator.clipboard.writeText(target.textContent)

              this.el.dataset.copied = "true"
              clearTimeout(this.copiedTimeout)
              this.copiedTimeout = setTimeout(() => {
                delete this.el.dataset.copied
              }, 2000)
            })
          },
          destroyed() {
            clearTimeout(this.copiedTimeout)
          }
        }
      </script>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :target, :string, required: true
  attr :class, :any, default: nil

  defp copy_button(assigns) do
    ~H"""
    <button
      type="button"
      id={@id}
      phx-hook=".CopyCode"
      data-copy={@target}
      aria-label="Copy code"
      class={[
        "group inline-flex items-center gap-1.5 rounded-md text-xs text-zinc-500 transition-colors hover:bg-zinc-900/5 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-white/10 dark:hover:text-zinc-100",
        @class
      ]}
    >
      <span class="relative grid size-3.5 place-items-center">
        <.icon
          name="lucide-copy"
          class="col-start-1 row-start-1 size-3.5 transition-opacity duration-200 group-data-copied:opacity-0"
        />
        <.icon
          name="lucide-check"
          class="col-start-1 row-start-1 size-3.5 text-green-600 opacity-0 transition-opacity duration-200 group-data-copied:opacity-100 dark:text-green-400"
        />
      </span>
      Copy
    </button>
    """
  end
end
