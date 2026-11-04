defmodule FlintUIDocsWeb.Preview do
  @moduledoc """
  Preview card: rendered demo, optional controls, optional code panel.

  This is a function component rather than a LiveComponent so the demo can be a
  slot. Per-preview state (control props, active code flavor, source/code view,
  and the resize size) belongs to `FlintUIDocsWeb.ComponentLive` or to the
  browser. The card forwards `state` to those layers.

  A section render receives its context through `assigns`, so the shortest call
  is to forward the whole map:

      def render_section(%{section: :examples, id: :icon} = assigns) do
        ~H\"\"\"
        <.preview {assigns}>
          <Components.button>Save</Components.button>
        </.preview>
        \"\"\"
      end

  The preview inherits `:preview_id`, `:name`, `:controls`, `:state`, `:source`,
  and `:tab` from that map. `:code`, `:codes`, and `:preview_only` are section
  content, so pass them explicitly:

      <.preview {assigns} code={~s(<.button>Save</.button>)}>
        <Components.button>Save</Components.button>
      </.preview>

  A section can render more than one preview by overriding the inherited id:

      <.preview {assigns} preview_id={@preview_id <> "-grid"} preview_only>

  `code` and `codes` accept a string, a list of code flavors, or a 1-arity
  function that receives the current props. A flavor is either a map with
  `:label`, `:lang`, and `:code`, or a `{lang, code}` pair. Each flavor becomes a
  tab; the CSS tab is just another flavor:

      codes={[
        heex: "<.button color=\\"#009966\\">Common</.button>",
        css: "[data-element=\\"button\\"] { --fl-button-color: #009966; }"
      ]}

  The demo slot receives the same props.

  Set `collapsed` to start the code panel closed; it remains expandable. Set
  `resizable={false}` to remove the resize handle, and `canvas_class` to give the
  demo a surface other than the page background.
  """

  use FlintUIDocsWeb, :html

  alias FlintUIDocsWeb.CodeBlock
  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.Highlight

  attr :preview_id, :any, default: nil
  attr :id, :any, default: nil
  attr :name, :atom, default: nil
  attr :section, :atom, default: nil
  attr :tab, :atom, default: nil
  attr :controls, :list, default: []
  attr :state, :map, default: %{}
  attr :code, :any, default: nil
  attr :codes, :any, default: nil
  attr :source, :any, default: nil
  attr :code_lang, :atom, default: :heex
  attr :preview_only, :boolean, default: false
  attr :collapsible, :boolean, default: true
  attr :collapsed, :boolean, default: false
  attr :resizable, :boolean, default: true
  attr :canvas_class, :any, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def preview(assigns) do
    name = assigns[:name]
    preview_id = assigns[:preview_id] || assigns[:id]
    layer = if assigns[:tab] == :base, do: :base, else: :styled
    controls = controls_for(name, layer, assigns[:controls] || [])

    state =
      Map.merge(
        %{props: %{}, code_index: 0, code_view: "code", source: assigns[:source]},
        assigns[:state] || %{}
      )

    defaults = Map.new(controls, &{&1.key, &1.default})
    props = Map.merge(defaults, state.props)
    flavors = resolve_flavors(assigns, props)
    index = clamp_index(state.code_index, flavors)
    active_flavor = flavors && Enum.at(flavors, index)
    source = state.source
    code_view = if source && state.code_view == "source", do: "source", else: "code"
    show_code? = active_flavor != nil and not assigns.preview_only
    below? = controls != [] or show_code?
    tabs? = code_view == "code" and flavors != nil and length(flavors) > 1

    assigns =
      assign(assigns,
        preview_id: to_string(preview_id),
        name: name,
        layer: layer,
        state: state,
        props: props,
        controls: controls,
        flavors: flavors,
        code_index: index,
        active_flavor: active_flavor,
        source: source,
        code_view: code_view,
        show_code?: show_code?,
        below?: below?,
        tabs?: tabs?,
        display_code: display_code(active_flavor, source, code_view),
        display_lang: display_lang(active_flavor, code_view),
        code_caption: code_caption(source, code_view)
      )

    ~H"""
    <div
      id={@preview_id}
      class={@class}
      data-preview
      data-preview-id={@preview_id}
      phx-hook={if @resizable, do: ".PreviewResize"}
    >
      <div class="rounded-lg shadow-lg/3">
        <div
          data-preview-canvas
          class={[
            "group relative grid min-h-24 place-items-center overflow-auto border border-solid border-default bg-transparent p-6",
            if(@below?, do: "rounded-t-lg", else: "rounded-lg"),
            @canvas_class
          ]}
        >
          {render_slot(@inner_block, @props)}

          <button
            :if={@resizable}
            type="button"
            data-preview-resize-handle
            aria-label="Resize preview"
            title="Drag to resize. Use the arrow keys to resize, or double-click to reset."
            class="absolute right-2 bottom-2 z-10 inline-flex size-6 cursor-nwse-resize touch-none items-center justify-center rounded-md border border-default bg-surface/80 text-muted opacity-50 shadow-sm backdrop-blur transition-opacity hover:opacity-100 focus-visible:opacity-100"
          >
            <.icon name="lucide-move-diagonal-2" class="size-3.5" />
          </button>

          <span
            :if={@resizable}
            data-preview-size
            hidden
            class="pointer-events-none absolute bottom-2 left-2 rounded bg-surface/80 px-1.5 py-0.5 font-mono text-[10px] text-muted shadow-sm backdrop-blur"
          ></span>
        </div>

        <.controls
          :if={@controls != []}
          id={@preview_id}
          name={@name}
          layer={@layer}
          controls={@controls}
          props={@props}
          last={!@show_code?}
        />

        <div
          :if={@show_code?}
          data-preview-code
          class="overflow-hidden rounded-b-lg border-x border-b border-default"
        >
          <CodeBlock.code
            id={"#{@preview_id}-code"}
            copy_id={"#{@preview_id}-copy"}
            code={@display_code}
            lang={@display_lang}
            caption={@code_caption}
            collapsible={@collapsible}
            collapsed={@collapsed}
            bordered={false}
            rounded={false}
            panel_id={if @tabs?, do: "#{@preview_id}-code-tabpanel", else: nil}
            labelledby={if @tabs?, do: "#{@preview_id}-code-tab-#{@code_index}", else: nil}
          >
            <:tabs :if={@tabs?}>
              <div
                id={"#{@preview_id}-code-tabs"}
                role="tablist"
                aria-label="Code examples"
                phx-hook=".CodeTabs"
                class="flex min-w-0 items-center gap-0.5 overflow-x-auto rounded-md bg-foreground/5 p-0.5"
              >
                <button
                  :for={{flavor, i} <- Enum.with_index(@flavors)}
                  type="button"
                  id={"#{@preview_id}-code-tab-#{i}"}
                  role="tab"
                  aria-selected={to_string(i == @code_index)}
                  aria-controls={"#{@preview_id}-code-tabpanel"}
                  tabindex={if i == @code_index, do: "0", else: "-1"}
                  phx-click="preview_code"
                  phx-value-id={@preview_id}
                  phx-value-index={i}
                  class={code_tab(i == @code_index)}
                >
                  {flavor.label || Highlight.label(flavor.lang)}
                </button>
              </div>

              <script :type={Phoenix.LiveView.ColocatedHook} name=".CodeTabs">
                export default {
                  mounted() {
                    this.onKeydown = (event) => {
                      const keys = ["ArrowLeft", "ArrowRight", "Home", "End"]
                      if (!keys.includes(event.key)) return

                      const tabs = Array.from(this.el.querySelectorAll("[role='tab']"))
                      const current = tabs.indexOf(document.activeElement)
                      if (current === -1) return

                      let next = current
                      if (event.key === "ArrowLeft") next = (current - 1 + tabs.length) % tabs.length
                      if (event.key === "ArrowRight") next = (current + 1) % tabs.length
                      if (event.key === "Home") next = 0
                      if (event.key === "End") next = tabs.length - 1

                      event.preventDefault()
                      tabs[next].focus()
                      tabs[next].click()
                    }

                    this.el.addEventListener("keydown", this.onKeydown)
                  },
                  destroyed() {
                    this.el.removeEventListener("keydown", this.onKeydown)
                  }
                }
              </script>
            </:tabs>

            <:actions :if={@source}>
              <button
                type="button"
                id={"#{@preview_id}-source-toggle"}
                phx-click="preview_view"
                phx-value-id={@preview_id}
                phx-value-view={if @code_view == "source", do: "code", else: "source"}
                class="inline-flex items-center gap-1.5 rounded-md px-2 py-1 text-xs text-muted transition-colors hover:bg-foreground/5 hover:text-default"
              >
                <.icon
                  name={if @code_view == "source", do: "lucide-code", else: "lucide-file-code"}
                  class="size-3.5"
                />
                {if @code_view == "source", do: "Code", else: "Source"}
              </button>
            </:actions>
          </CodeBlock.code>
        </div>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".PreviewResize">
        export default {
          mounted() {
            this.canvas = this.el.querySelector("[data-preview-canvas]")
            this.handle = this.el.querySelector("[data-preview-resize-handle]")
            this.badge = this.el.querySelector("[data-preview-size]")
            if (!this.canvas || !this.handle) return

            this.key = "flint-preview-size:" + (this.el.dataset.previewId || this.el.id)
            this.size = this.read()
            this.apply()

            this.onPointerDown = (event) => {
              if (event.button !== 0) return

              const rect = this.canvas.getBoundingClientRect()
              this.drag = {x: event.clientX, y: event.clientY, width: rect.width, height: rect.height}
              this.handle.setPointerCapture(event.pointerId)
              event.preventDefault()

              this.onPointerMove = (moveEvent) => {
                if (!this.drag) return

                const width = this.clampWidth(this.drag.width + moveEvent.clientX - this.drag.x)
                const height = this.clampHeight(this.drag.height + moveEvent.clientY - this.drag.y)
                this.setSize(width, height)
              }

              this.onPointerUp = () => {
                this.drag = null
                this.save()
                window.removeEventListener("pointermove", this.onPointerMove)
                window.removeEventListener("pointerup", this.onPointerUp)
              }

              window.addEventListener("pointermove", this.onPointerMove)
              window.addEventListener("pointerup", this.onPointerUp)
            }

            this.onKeydown = (event) => {
              const step = event.shiftKey ? 64 : 16
              const current = this.currentSize()

              if (event.key === "ArrowLeft") this.setSize(this.clampWidth(current.width - step), current.height)
              else if (event.key === "ArrowRight") this.setSize(this.clampWidth(current.width + step), current.height)
              else if (event.key === "ArrowUp") this.setSize(current.width, this.clampHeight(current.height - step))
              else if (event.key === "ArrowDown") this.setSize(current.width, this.clampHeight(current.height + step))
              else if (event.key === "Home") this.reset()
              else return

              event.preventDefault()
              this.save()
            }

            this.onDoubleClick = () => this.reset()

            this.bindHandle()
          },

          updated() {
            this.canvas = this.el.querySelector("[data-preview-canvas]")
            this.handle = this.el.querySelector("[data-preview-resize-handle]")
            this.badge = this.el.querySelector("[data-preview-size]")
            if (!this.canvas || !this.handle) return

            this.bindHandle()
            this.apply()
          },

          bindHandle() {
            if (!this.handle) return

            // addEventListener de-duplicates identical listener pairs, so this is
            // safe on every update even when LiveView keeps the same node.
            this.handle.addEventListener("pointerdown", this.onPointerDown)
            this.handle.addEventListener("keydown", this.onKeydown)
            this.handle.addEventListener("dblclick", this.onDoubleClick)
          },

          destroyed() {
            this.handle?.removeEventListener("pointerdown", this.onPointerDown)
            this.handle?.removeEventListener("keydown", this.onKeydown)
            this.handle?.removeEventListener("dblclick", this.onDoubleClick)
            window.removeEventListener("pointermove", this.onPointerMove)
            window.removeEventListener("pointerup", this.onPointerUp)
          },

          read() {
            try {
              const value = JSON.parse(sessionStorage.getItem(this.key))
              return value && value.width ? value : null
            } catch (_error) {
              return null
            }
          },

          save() {
            try {
              if (this.size) sessionStorage.setItem(this.key, JSON.stringify(this.size))
              else sessionStorage.removeItem(this.key)
            } catch (_error) {
              // Storage can be unavailable in private browsing; resizing still works.
            }
          },

          apply() {
            if (this.size) {
              this.canvas.style.width = `${this.size.width}px`
              this.canvas.style.height = `${this.size.height}px`
            } else {
              this.canvas.style.removeProperty("width")
              this.canvas.style.removeProperty("height")
            }

            if (this.badge) {
              this.badge.hidden = !this.size
              this.badge.textContent = this.size
                ? `${Math.round(this.size.width)} × ${Math.round(this.size.height)}`
                : ""
            }
          },

          reset() {
            this.size = null
            this.save()
            this.apply()
          },

          setSize(width, height) {
            this.size = {width, height}
            this.apply()
          },

          currentSize() {
            const rect = this.canvas.getBoundingClientRect()
            return {width: rect.width, height: rect.height}
          },

          clampWidth(width) {
            return Math.max(240, Math.min(width, this.el.clientWidth || width))
          },

          clampHeight(height) {
            return Math.max(120, Math.min(height, 1200))
          }
        }
      </script>
    </div>
    """
  end

  ## Controls

  attr :id, :string, required: true
  attr :name, :atom, default: nil
  attr :layer, :atom, default: :styled
  attr :controls, :list, required: true
  attr :props, :map, required: true
  attr :last, :boolean, default: true

  defp controls(assigns) do
    ~H"""
    <div
      data-preview-controls
      class={[
        "overflow-x-auto border-x border-b border-default bg-foreground/2 px-3 py-2.5",
        "bg-[repeating-linear-gradient(135deg,rgba(0,0,0,0.03)_0,rgba(0,0,0,0.03)_1px,transparent_1px,transparent_6px)]",
        "dark:bg-[repeating-linear-gradient(135deg,rgba(255,255,255,0.03)_0,rgba(255,255,255,0.03)_1px,transparent_1px,transparent_6px)]",
        @last && "rounded-b-lg"
      ]}
    >
      <form
        id={"#{@id}-controls"}
        phx-change="preview_change"
        class="flex flex-wrap items-center gap-2.5"
      >
        <input type="hidden" name="preview_id" value={@id} />
        <%= for control <- @controls do %>
          <%= case control_kind(control) do %>
            <% :select -> %>
              <label class={addon_shell("w-44")}>
                <span class={addon_label()}>{control.label}</span>
                <span class="relative min-w-0 flex-1">
                  <select name={control.key} class={select_class()}>
                    <option
                      :for={value <- select_options(control, @name, @layer)}
                      value={value}
                      selected={to_string(Map.get(@props, control.key)) == value}
                    >
                      {value}
                    </option>
                  </select>
                  <.icon
                    name="lucide-chevron-down"
                    class="pointer-events-none absolute top-1/2 right-2 size-3.5 -translate-y-1/2 text-muted"
                  />
                </span>
              </label>
            <% :number -> %>
              <label class={addon_shell("w-40")}>
                <span class={addon_label()}>{control.label}</span>
                <input
                  type="number"
                  name={control.key}
                  value={Map.get(@props, control.key)}
                  {FlintUI.Autofill.ignore_attributes()}
                  class={input_class()}
                />
              </label>
            <% _ -> %>
              <label class={addon_shell("w-72")}>
                <span class={addon_label()}>{control.label}</span>
                <input
                  type="text"
                  name={control.key}
                  value={Map.get(@props, control.key)}
                  {FlintUI.Autofill.ignore_attributes()}
                  class={input_class()}
                />
              </label>
          <% end %>
        <% end %>
      </form>
    </div>
    """
  end

  ## Helpers

  defp controls_for(name, layer, controls) when is_list(controls) do
    if Enum.all?(controls, &is_atom/1) do
      name
      |> Docs.controls()
      |> Enum.filter(&(&1.key in controls))
      |> Enum.map(&Map.put(&1, :layer, layer))
    else
      Enum.map(controls, &Map.put(&1, :layer, layer))
    end
  end

  defp resolve_flavors(assigns, props) do
    cond do
      is_function(assigns[:codes], 1) -> assigns[:codes].(props) |> normalize_codes()
      assigns[:codes] not in [nil, []] -> normalize_codes(assigns[:codes])
      is_function(assigns[:code], 1) -> assigns[:code].(props) |> normalize_codes()
      is_binary(assigns[:code]) -> normalize_codes(assigns[:code])
      is_list(assigns[:code]) -> normalize_codes(assigns[:code])
      true -> nil
    end
  end

  defp display_code(_active_flavor, source, "source"), do: source.code
  defp display_code(active_flavor, _source, _view), do: active_flavor && active_flavor.code

  defp display_lang(_active_flavor, "source"), do: :heex
  defp display_lang(active_flavor, _view), do: (active_flavor && active_flavor.lang) || :heex

  defp code_caption(source, "source") do
    "#{source.callback} · #{source.path}:#{source.line}"
  end

  defp code_caption(_source, _view), do: nil

  defp normalize_codes(nil), do: nil
  defp normalize_codes(code) when is_binary(code), do: [flavor(%{code: code})]

  defp normalize_codes(codes) when is_list(codes) do
    Enum.map(codes, fn
      {lang, code} when is_atom(lang) and is_binary(code) ->
        flavor(%{lang: lang, code: code})

      %{} = code ->
        flavor(code)

      code when is_binary(code) ->
        flavor(%{code: code})
    end)
  end

  defp flavor(%{} = flavor) do
    lang = Map.get(flavor, :lang) || :heex

    %{
      label: Map.get(flavor, :label) || Highlight.label(lang),
      lang: lang,
      code: Map.get(flavor, :code)
    }
  end

  defp clamp_index(_index, nil), do: 0
  defp clamp_index(_index, []), do: 0
  defp clamp_index(index, flavors), do: min(max(index, 0), length(flavors) - 1)

  defp select_options(%{type: :boolean}, _name, _layer), do: ~w(true false)

  defp select_options(control, name, layer) do
    values = control[:values]

    if is_list(values) and values != [] do
      Enum.map(values, &to_string/1)
    else
      styled_values(control, name, layer) || base_attr_values(control, name)
    end
  end

  defp styled_values(%{key: key}, name, :styled) when is_atom(name) do
    case FlintUI.Styled.get(name) do
      %{props: props} ->
        case Enum.find(props, &(&1.name == key)) do
          nil -> nil
          prop -> Enum.map(prop.values, &to_string/1)
        end

      _ ->
        nil
    end
  end

  defp styled_values(_control, _name, _layer), do: nil

  defp base_attr_values(%{key: key}, name) when is_atom(name) do
    name
    |> FlintUI.Docs.attrs()
    |> Enum.find(&(&1.name == key))
    |> case do
      %{opts: opts} when is_list(opts) ->
        opts |> Keyword.get(:values, []) |> Enum.map(&to_string/1)

      _ ->
        []
    end
  end

  defp base_attr_values(_control, _name), do: []

  # Booleans render as a `true`/`false` select, so a single branch covers both.
  defp control_kind(%{type: type}) when type in [:select, :boolean], do: :select
  defp control_kind(%{type: type}), do: type

  ## CSS classes

  defp code_tab(true) do
    "rounded bg-surface px-2 py-0.5 text-[11px] font-medium whitespace-nowrap text-default shadow-sm"
  end

  defp code_tab(false) do
    "rounded px-2 py-0.5 text-[11px] font-medium whitespace-nowrap text-muted transition-colors hover:text-default"
  end

  defp addon_shell(width) do
    [
      "flex min-w-0 items-stretch overflow-hidden rounded-md border border-default bg-surface text-left transition-colors focus-within:border-accented focus-within:ring-2 focus-within:ring-accented focus-within:ring-inset focus-visible:outline-none",
      width
    ]
  end

  defp addon_label do
    "flex shrink-0 items-center border-r border-default bg-muted px-2 text-xs font-medium whitespace-nowrap text-muted"
  end

  defp input_class do
    "keeper-ignore min-w-0 flex-1 bg-transparent px-2.5 py-1.5 text-sm text-default outline-none"
  end

  defp select_class do
    "w-full appearance-none bg-transparent py-1.5 pr-7 pl-2.5 text-sm text-default outline-none"
  end
end
