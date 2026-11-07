defmodule FlintUIDocsWeb.CodeBlock do
  @moduledoc """
  A standalone syntax-highlighted code panel.

  The panel owns the surface, the optional header, the copy interaction, and the
  collapse disclosure. When a collapsible snippet is tall enough, the open panel
  ends with a quiet "Close Code" footer so it can be dismissed without scrolling
  back to the header. Callers shape it for their context with `class` and the
  `bordered`/`rounded` flags. The docs guides use it for standalone snippets; the
  preview uses it as the last, border-sharing section of a card.

  The header appears when there is a `:tabs` slot, an `:actions` slot, a
  `caption`, or the panel is collapsible. It holds the tabs/caption on the left
  and the actions, copy button, and collapse trigger on the right. Without a
  header the copy button floats vertically centered on the right, so a one-line
  snippet still has a properly centered action.

  Code is highlighted server-side by `FlintUIDocsWeb.Highlight`; the token
  colours follow the docs' semantic tokens in `assets/css/highlight.css`.
  """

  use FlintUIDocsWeb, :html

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Highlight

  # The close footer only helps once the snippet is tall enough to push it out
  # of view. Nine lines is roughly 200px at the panel's `text-xs`/
  # `leading-relaxed` typography plus the `p-4` frame. `pre` does not wrap, so
  # line count is a reliable height proxy.
  @close_footer_min_lines 9

  attr :id, :string,
    default: nil,
    doc: "The id of the code element. Derived from the source when omitted."

  attr :copy_id, :string, default: nil, doc: "The id of the copy button."

  attr :code, :string, required: true
  attr :lang, :atom, default: :heex
  attr :caption, :string, default: nil

  attr :collapsible, :boolean,
    default: true,
    doc: "Whether the panel exposes a disclosure trigger."

  attr :collapsed, :boolean,
    default: false,
    doc: "Whether the panel starts collapsed."

  attr :copy, :boolean, default: true, doc: "Whether the panel exposes a copy button."

  attr :bordered, :boolean, default: true, doc: "Whether the panel draws its own border."

  attr :rounded, :boolean, default: true, doc: "Whether the panel draws its own corner radius."

  attr :panel_id, :string,
    default: nil,
    doc: "The id of the tab panel when the code is controlled by a tab list."

  attr :labelledby, :string,
    default: nil,
    doc: "The id of the active tab that labels the panel."

  attr :class, :any, default: nil, doc: "Additional classes for the outer wrapper."

  slot :tabs, doc: "Tab triggers rendered in the header, usually one per code flavor."
  slot :actions, doc: "Actions rendered before the copy button in the header."

  def code(assigns) do
    id = assigns[:id] || generated_id(assigns)
    header? = assigns.caption != nil or assigns.tabs != [] or assigns.actions != []
    header? = header? or assigns.collapsible

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:copy_id, assigns[:copy_id] || "#{id}-copy")
      |> assign(:header?, header?)

    ~H"""
    <div data-code-block class={@class}>
      <%= if @header? do %>
        <%= if @collapsible do %>
          <Components.collapsible
            id={"#{@id}-collapse"}
            open={not @collapsed}
            class={panel_class(assigns)}
          >
            <:trigger :let={attrs}>
              <.code_header
                id={@id}
                copy_id={@copy_id}
                lang={@lang}
                caption={@caption}
                tabs={@tabs}
                actions={@actions}
                copy={@copy}
                collapsible={@collapsible}
                trigger_attrs={attrs}
              />
            </:trigger>
            <:content :let={attrs}>
              <.body
                id={@id}
                code={@code}
                lang={@lang}
                panel_id={@panel_id}
                labelledby={@labelledby}
                content_attrs={attrs}
                collapsible
              />
            </:content>
          </Components.collapsible>
        <% else %>
          <div class={panel_class(assigns)}>
            <.code_header
              id={@id}
              copy_id={@copy_id}
              lang={@lang}
              caption={@caption}
              tabs={@tabs}
              actions={@actions}
              copy={@copy}
              collapsible={@collapsible}
              trigger_attrs={nil}
            />
            <.body
              id={@id}
              code={@code}
              lang={@lang}
              panel_id={@panel_id}
              labelledby={@labelledby}
              content_attrs={nil}
            />
          </div>
        <% end %>
      <% else %>
        <div class={panel_class(assigns)}>
          <.body
            id={@id}
            code={@code}
            lang={@lang}
            panel_id={@panel_id}
            labelledby={@labelledby}
            content_attrs={nil}
            class="pr-16"
          />
          <div class="absolute inset-y-0 right-2 flex items-center">
            <.copy_button :if={@copy} id={@copy_id} target={@id} />
          </div>
        </div>
      <% end %>

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

      <script :type={Phoenix.LiveView.ColocatedHook} name=".CodeHeader">
        export default {
          mounted() {
            this.onClick = (event) => {
              const root = this.el.closest("[data-element='collapsible']")
              if (!root || root.dataset.state !== "closed") return
              if (event.target.closest("button, a, input, select, textarea, [role='tab']")) return

              root.dispatchEvent(new CustomEvent("fl:collapsible:toggle", {bubbles: true}))
            }

            this.el.addEventListener("click", this.onClick)
          },
          destroyed() {
            this.el.removeEventListener("click", this.onClick)
          }
        }
      </script>
    </div>
    """
  end

  ## Header

  attr :id, :string, required: true
  attr :copy_id, :string, required: true
  attr :lang, :atom, required: true
  attr :caption, :string, default: nil
  attr :tabs, :list, default: []
  attr :actions, :list, default: []
  attr :copy, :boolean, default: true
  attr :collapsible, :boolean, default: true
  attr :trigger_attrs, :any, default: nil

  defp code_header(assigns) do
    ~H"""
    <div
      id={"#{@id}-header"}
      data-code-header
      phx-hook=".CodeHeader"
      class={[
        "relative flex items-center justify-between gap-3 px-3 py-1.5",
        "bg-neutral-500/5 border-b border-default",
        "group-data-[state=closed]:cursor-pointer group-data-[state=closed]:border-b-0"
      ]}
    >
      <div class="flex min-w-0 items-center gap-1.5">
        <%= if @tabs != [] do %>
          {render_slot(@tabs)}
        <% else %>
          <span
            class="truncate px-1 font-mono text-xs text-muted"
            title={@caption || Highlight.label(@lang)}
          >
            {@caption || Highlight.label(@lang)}
          </span>
        <% end %>
      </div>

      <span
        data-code-expand
        aria-hidden="true"
        class="pointer-events-none absolute inset-0 hidden items-center justify-center whitespace-nowrap text-xs font-medium text-muted group-data-[state=closed]:flex"
      >
        Expand Code
      </span>

      <div class="flex shrink-0 items-center gap-1">
        {render_slot(@actions)}
        <.copy_button :if={@copy} id={@copy_id} target={@id} />

        <Components.button
          :if={@collapsible}
          {@trigger_attrs || %{}}
          data-code-collapse
          aria-label="Toggle code"
          variant="ghost"
          size="xs"
          square
        >
          <Components.icon name="lucide-chevron-down" class="size-3.5" />
        </Components.button>
      </div>
    </div>
    """
  end

  ## Body

  attr :id, :string, required: true
  attr :code, :string, required: true
  attr :lang, :atom, required: true
  attr :panel_id, :string, default: nil
  attr :labelledby, :string, default: nil
  attr :content_attrs, :any, default: nil
  attr :collapsible, :boolean, default: false
  attr :class, :any, default: nil

  defp body(assigns) do
    ~H"""
    <div {@content_attrs || %{}} data-code-body>
      <pre
        id={@panel_id}
        role={@panel_id && "tabpanel"}
        aria-labelledby={@labelledby}
        tabindex={@panel_id && "0"}
        class={[
          "highlight overflow-x-auto p-4 text-xs leading-relaxed",
          @class
        ]}
      ><code id={@id}>{Highlight.highlight(@code, @lang)}</code></pre>

      <Components.button
        :if={@collapsible and tall_code?(@code)}
        type="button"
        id={"#{@id}-close"}
        data-code-close
        phx-click={close_collapsible("#{@id}-collapse")}
        variant="soft"
        size="xs"
        wide
        radius="none"
        class="text-muted hover:text-default"
      >
        Close Code
      </Components.button>
    </div>
    """
  end

  ## Copy

  attr :id, :string, required: true
  attr :target, :string, required: true

  defp copy_button(assigns) do
    ~H"""
    <Components.button
      type="button"
      id={@id}
      phx-hook=".CopyCode"
      data-copy={@target}
      aria-label="Copy code"
      variant="ghost"
      size="xs"
      class="group"
    >
      <span class="relative grid size-3.5 place-items-center">
        <Components.icon
          name="lucide-copy"
          class="col-start-1 row-start-1 size-3.5 transition-opacity duration-200 group-data-copied:opacity-0"
        />
        <Components.icon
          name="lucide-check"
          class="col-start-1 row-start-1 size-3.5 text-green-600 opacity-0 transition-opacity duration-200 group-data-copied:opacity-100 dark:text-green-400"
        />
      </span>
      Copy
    </Components.button>
    """
  end

  ## Helpers

  defp tall_code?(code) do
    code
    |> String.trim_trailing("\n")
    |> String.split("\n")
    |> length()
    |> Kernel.>=(@close_footer_min_lines)
  end

  defp panel_class(assigns) do
    [
      "group relative overflow-hidden bg-neutral-50/1",
      assigns.bordered && "border border-default",
      assigns.rounded && "rounded-lg"
    ]
  end

  defp generated_id(assigns) do
    hash =
      :crypto.hash(:sha256, "#{assigns.lang}:#{assigns.caption}:#{assigns.code}")
      |> Base.encode16(case: :lower)
      |> binary_part(0, 10)

    "code-#{hash}"
  end
end
