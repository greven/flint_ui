defmodule FlintUIDocsWeb.PreviewComponent do
  @moduledoc """
  Reusable component preview card.

  Renders a live component, an optional panel of controls that mutate its
  props, and a syntax-highlighted Code tab. It is used for the Docs playground,
  every usage subsection preview, every example in the Examples section, and the
  Base playground, so all of them share one look and one set of interactions.

  Used as a function component:

      <PreviewComponent.preview
        id="playground-button"
        kind={:playground}
        layer={:styled}
        name={:button}
        controls={ComponentDocs.controls(:button)}
        defaults={ComponentDocs.defaults(:button)}
      />

  `kind` selects what is drawn:

    * `:playground` - the interactive playground; `layer` (`:base` or `:styled`)
      picks the rendered component and the generated code
    * `:usage` - one usage subsection preview; `block` is the usage entry id
      and `code` is shown as a fixed snippet
    * `:block` - an element of the Examples section

  Pass a `code` string (or a `codes` list of `%{label, lang, code, styles?}`
  flavors) to show fixed snippet(s) instead of asking the page module. When more
  than one flavor is given, the Code tab shows a switcher; a flavor's `styles`
  renders as a labelled CSS block beneath its code.

  Set `preview: false` for content that can only be shown as code (e.g. an
  example that triggers a server event). The card then renders the Code tab
  only, and the Preview/Code tab bar is hidden because it would offer a single
  option.
  """

  use FlintUIDocsWeb, :live_component

  alias FlintUIDocsWeb.ComponentDocs
  alias FlintUIDocsWeb.Highlight

  @tabs ~w(preview code)

  attr :id, :string, required: true
  attr :kind, :atom, default: :playground
  attr :layer, :atom, default: :base
  attr :name, :atom, default: nil
  attr :block, :atom, default: nil
  attr :controls, :list, default: []
  attr :defaults, :map, default: %{}
  attr :code, :string, default: nil
  attr :codes, :list, default: nil
  attr :code_lang, :atom, default: :heex
  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :preview, :boolean, default: true

  def preview(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      kind={@kind}
      layer={@layer}
      name={@name}
      block={@block}
      controls={@controls}
      defaults={@defaults}
      code={@code}
      codes={@codes}
      code_lang={@code_lang}
      title={@title}
      description={@description}
      preview={@preview}
    />
    """
  end

  @impl true
  def update(assigns, socket) do
    props =
      if socket.assigns[:name] == assigns.name and socket.assigns[:layer] == assigns.layer do
        socket.assigns[:props] || assigns.defaults
      else
        assigns.defaults
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:props, props)
      |> assign_new(:tab, fn -> "preview" end)
      |> assign_new(:code_index, fn -> 0 end)

    {:ok, socket}
  end

  @impl true
  def handle_event("tab", %{"tab" => tab}, socket) when tab in @tabs do
    {:noreply, assign(socket, :tab, tab)}
  end

  def handle_event("code", %{"index" => index}, socket) do
    {:noreply, assign(socket, :code_index, String.to_integer(index))}
  end

  def handle_event("toggle", %{"key" => key}, socket) do
    control = control!(socket, key)
    props = Map.update!(socket.assigns.props, control.key, &(!&1))
    {:noreply, assign(socket, :props, props)}
  end

  def handle_event("set", params, socket) do
    props =
      Enum.reduce(socket.assigns.controls, socket.assigns.props, fn control, acc ->
        case Map.fetch(params, Atom.to_string(control.key)) do
          {:ok, value} -> Map.put(acc, control.key, coerce(control, value))
          :error -> acc
        end
      end)

    {:noreply, assign(socket, :props, props)}
  end

  @impl true
  def render(assigns) do
    flavors = resolve_flavors(assigns)
    index = clamp_index(assigns[:code_index] || 0, flavors)
    tab = if assigns[:preview] == false, do: "code", else: assigns[:tab]

    assigns =
      assign(assigns,
        flavors: flavors,
        code_index: index,
        active_flavor: flavors && Enum.at(flavors, index),
        tab: tab
      )

    ~H"""
    <div id={@id} class="mt-6">
      <div :if={@title || @description} class="flex flex-col gap-1">
        <h4 :if={@title} class="text-sm font-semibold">{@title}</h4>
        <p :if={@description} class="text-sm text-zinc-600 dark:text-zinc-400">{@description}</p>
      </div>

      <.toolbar :if={@flavors} id={@id} tab={@tab} preview={@preview} myself={@myself} />

      <%= if @tab == "code" && @active_flavor do %>
        <.flavors
          :if={length(@flavors) > 1}
          id={@id}
          flavors={@flavors}
          index={@code_index}
          myself={@myself}
        />
        <div class="relative mt-3 overflow-hidden rounded-lg bg-zinc-900">
          <button
            type="button"
            id={"#{@id}-copy"}
            phx-hook=".CopyCode"
            data-copy={"#{@id}-code"}
            class="group absolute right-2 top-2 inline-flex items-center gap-1.5 rounded-md border border-white/10 px-2 py-1 text-xs text-zinc-400 transition-colors hover:bg-white/10 hover:text-zinc-100"
          >
            <span class="relative grid size-3.5 place-items-center">
              <.icon
                name="lucide-copy"
                class="col-start-1 row-start-1 size-3.5 transition-opacity duration-200 group-data-[copied]:opacity-0"
              />
              <.icon
                name="lucide-check"
                class="col-start-1 row-start-1 size-3.5 text-green-400 opacity-0 transition-opacity duration-200 group-data-[copied]:opacity-100"
              />
            </span>
            Copy
          </button>
          <pre class="highlight overflow-x-auto p-4 pr-16 text-xs leading-relaxed text-zinc-100"><code id={"#{@id}-code"}>{Highlight.highlight(@active_flavor.code, @active_flavor.lang)}</code></pre>

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
        <div :if={@active_flavor[:styles]} class="mt-3 overflow-hidden rounded-lg bg-zinc-900">
          <div class="border-b border-white/10 px-4 py-2 font-mono text-xs text-zinc-400">
            app.css
          </div>
          <pre class="highlight overflow-x-auto p-4 text-xs leading-relaxed text-zinc-100"><code id={"#{@id}-styles"}>{Highlight.highlight(@active_flavor.styles, :css)}</code></pre>
        </div>
      <% else %>
        <div class="mt-3 grid min-h-24 place-items-center rounded-lg border border-dashed border-zinc-300 bg-zinc-50 p-6 dark:border-zinc-700 dark:bg-zinc-900/40">
          <%= case @kind do %>
            <% :playground -> %>
              <ComponentDocs.render_playground
                name={@name}
                layer={@layer}
                props={@props}
                id={"#{@id}-canvas"}
              />
            <% :usage -> %>
              <ComponentDocs.render_usage
                name={@name}
                layer={@layer}
                block={@block}
                props={@props}
                id={"#{@id}-canvas"}
              />
            <% :block -> %>
              <ComponentDocs.render_block
                name={@name}
                block={@block}
                props={@props}
                id={"#{@id}-canvas"}
              />
          <% end %>
        </div>

        <.controls
          :if={@controls != [] && @preview}
          id={@id}
          name={@name}
          layer={@layer}
          controls={@controls}
          props={@props}
          myself={@myself}
        />
      <% end %>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :tab, :string, required: true
  attr :preview, :boolean, default: true
  attr :myself, :any, required: true

  defp toolbar(assigns) do
    ~H"""
    <div class="flex items-center justify-between gap-2">
      <div
        :if={@preview}
        class="inline-flex rounded-md border border-zinc-200 p-0.5 dark:border-zinc-800"
      >
        <button
          type="button"
          phx-click="tab"
          phx-target={@myself}
          phx-value-tab="preview"
          class={segment(@tab == "preview")}
        >
          <.icon name="lucide-eye" class="size-3.5" /> Preview
        </button>
        <button
          type="button"
          phx-click="tab"
          phx-target={@myself}
          phx-value-tab="code"
          class={segment(@tab == "code")}
        >
          <.icon name="lucide-code" class="size-3.5" /> Code
        </button>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :flavors, :list, required: true
  attr :index, :integer, required: true
  attr :myself, :any, required: true

  defp flavors(assigns) do
    ~H"""
    <div class="mt-3 inline-flex rounded-md border border-zinc-200 p-0.5 dark:border-zinc-800">
      <button
        :for={{flavor, i} <- Enum.with_index(@flavors)}
        type="button"
        phx-click="code"
        phx-target={@myself}
        phx-value-index={i}
        class={segment(i == @index)}
      >
        {flavor.label || "Code"}
      </button>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :name, :atom, default: nil
  attr :layer, :atom, default: :base
  attr :controls, :list, required: true
  attr :props, :map, required: true
  attr :myself, :any, required: true

  defp controls(assigns) do
    ~H"""
    <div class="mt-3 rounded-lg border border-zinc-200 p-4 dark:border-zinc-800">
      <form
        id={"#{@id}-controls"}
        phx-change="set"
        phx-target={@myself}
        class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3"
      >
        <label :for={control <- @controls} class="flex flex-col gap-1">
          <span class="text-xs text-zinc-500">{control.label}</span>
          <%= case control.type do %>
            <% :boolean -> %>
              <button
                type="button"
                phx-click="toggle"
                phx-target={@myself}
                phx-value-key={control.key}
                class={toggle_class(Map.get(@props, control.key))}
              >
                <span>{if Map.get(@props, control.key), do: "On", else: "Off"}</span>
              </button>
            <% :select -> %>
              <div class="relative">
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
                  class="pointer-events-none absolute top-1/2 right-2.5 size-4 -translate-y-1/2 text-zinc-400"
                />
              </div>
            <% :number -> %>
              <input
                type="number"
                name={control.key}
                value={Map.get(@props, control.key)}
                class={input_class()}
              />
            <% _ -> %>
              <input
                type="text"
                name={control.key}
                value={Map.get(@props, control.key)}
                autocomplete="off"
                class={input_class()}
              />
          <% end %>
        </label>
      </form>
    </div>
    """
  end

  defp resolve_flavors(assigns) do
    cond do
      is_list(assigns[:codes]) and assigns[:codes] != [] ->
        normalize_codes(assigns[:codes])

      is_binary(assigns[:code]) ->
        [flavor(%{code: assigns[:code], lang: assigns[:code_lang] || :heex})]

      assigns[:kind] == :playground ->
        ComponentDocs.render_code(%{
          name: assigns[:name],
          layer: assigns[:layer],
          props: assigns[:props],
          id: assigns[:id]
        })
        |> normalize_codes()

      true ->
        nil
    end
  end

  defp normalize_codes(nil), do: nil
  defp normalize_codes(code) when is_binary(code), do: [flavor(%{code: code})]
  defp normalize_codes(codes) when is_list(codes), do: Enum.map(codes, &flavor/1)

  defp flavor(%{} = flavor) do
    %{
      label: Map.get(flavor, :label),
      lang: Map.get(flavor, :lang) || :heex,
      code: Map.get(flavor, :code),
      styles: Map.get(flavor, :styles)
    }
  end

  defp clamp_index(_index, nil), do: 0
  defp clamp_index(_index, []), do: 0
  defp clamp_index(index, flavors), do: min(max(index, 0), length(flavors) - 1)

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

  defp coerce(%{type: :number, default: default}, value) do
    case Integer.parse(to_string(value)) do
      {int, _} -> int
      :error -> default
    end
  end

  defp coerce(%{type: :boolean}, value), do: value in [true, "true", "on", "1"]
  defp coerce(_control, value), do: value

  defp control!(socket, key) do
    Enum.find(socket.assigns.controls, &(Atom.to_string(&1.key) == key)) ||
      raise ArgumentError, "unknown preview control #{inspect(key)}"
  end

  ## CSS classes

  defp segment(true) do
    "inline-flex items-center gap-1.5 rounded bg-white px-2.5 py-1 text-xs font-medium text-zinc-900 shadow-sm dark:bg-zinc-800 dark:text-zinc-100"
  end

  defp segment(false) do
    "inline-flex items-center gap-1.5 rounded px-2.5 py-1 text-xs text-zinc-600 transition-colors hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
  end

  defp toggle_class(true) do
    "flex items-center justify-between rounded-md border border-zinc-900 bg-zinc-900 px-3 py-1.5 text-sm text-white transition-colors dark:border-white dark:bg-white dark:text-zinc-900"
  end

  defp toggle_class(false) do
    "flex items-center justify-between rounded-md border border-zinc-200 px-3 py-1.5 text-sm text-zinc-600 transition-colors hover:bg-zinc-50 dark:border-zinc-800 dark:text-zinc-400 dark:hover:bg-zinc-800"
  end

  defp input_class do
    "rounded-md border border-zinc-200 bg-white px-3 py-1.5 text-sm outline-none focus:border-zinc-400 dark:border-zinc-800 dark:bg-zinc-950"
  end

  defp select_class do
    input_class() <> " w-full appearance-none pr-8"
  end
end
