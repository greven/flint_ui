defmodule FlintUIDocsWeb.PreviewComponent do
  @moduledoc """
  Reusable component preview card.

  Renders a live component, an optional panel of controls that mutate its
  props, and a syntax-highlighted Code tab showing the HEEx for the current
  props. It is used for the main playground, every example in the Examples
  section, and the styled-layer preview, so all three share one look and one
  set of interactions.

  Used as a function component:

      <PreviewComponent.preview
        id="playground-button"
        name={:button}
        controls={Examples.controls(:button)}
        defaults={Examples.defaults(:button)}
      />

  `kind` selects what is drawn: `:example` (the interactive playground, whose
  code comes from `Examples.render_code/1`), `:block` (an element of the
  Examples section), or `:styled` (the generated styled component). Pass a
  `code` string to show a fixed snippet instead of asking the example module.
  """

  use FlintUIDocsWeb, :live_component

  alias FlintUIDocsWeb.Examples
  alias FlintUIDocsWeb.Highlight

  @tabs ~w(preview code)

  attr :id, :string, required: true
  attr :kind, :atom, default: :example
  attr :name, :atom, default: nil
  attr :block, :atom, default: nil
  attr :controls, :list, default: []
  attr :defaults, :map, default: %{}
  attr :code, :string, default: nil
  attr :code_lang, :atom, default: :heex
  attr :title, :string, default: nil
  attr :description, :string, default: nil

  def preview(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      kind={@kind}
      name={@name}
      block={@block}
      controls={@controls}
      defaults={@defaults}
      code={@code}
      code_lang={@code_lang}
      title={@title}
      description={@description}
    />
    """
  end

  @impl true
  def update(assigns, socket) do
    props =
      if socket.assigns[:name] == assigns.name do
        socket.assigns[:props] || assigns.defaults
      else
        assigns.defaults
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:props, props)
      |> assign_new(:tab, fn -> "preview" end)

    {:ok, socket}
  end

  @impl true
  def handle_event("tab", %{"tab" => tab}, socket) when tab in @tabs do
    {:noreply, assign(socket, :tab, tab)}
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
    assigns = assign(assigns, :resolved_code, resolve_code(assigns))

    ~H"""
    <div id={@id} class="mt-6">
      <div :if={@title || @description} class="flex flex-col gap-1">
        <h4 :if={@title} class="text-sm font-semibold">{@title}</h4>
        <p :if={@description} class="text-sm text-zinc-600 dark:text-zinc-400">{@description}</p>
      </div>

      <.toolbar :if={@resolved_code} id={@id} tab={@tab} myself={@myself} />

      <%= if @tab == "code" && @resolved_code do %>
        <div class="mt-3 overflow-hidden rounded-lg bg-zinc-900">
          <pre class="highlight overflow-x-auto p-4 text-xs leading-relaxed text-zinc-100"><code id={"#{@id}-code"}>{Highlight.highlight(@resolved_code, @code_lang)}</code></pre>
        </div>
      <% else %>
        <div class="mt-3 grid min-h-24 place-items-center rounded-lg border border-dashed border-zinc-300 bg-zinc-50 p-6 dark:border-zinc-700 dark:bg-zinc-900/40">
          <%= case @kind do %>
            <% :example -> %>
              <Examples.render_example name={@name} props={@props} id={"#{@id}-canvas"} />
            <% :block -> %>
              <Examples.render_block name={@name} block={@block} props={@props} id={"#{@id}-canvas"} />
            <% :styled -> %>
              <Examples.render_styled name={@name} props={@props} id={"#{@id}-canvas"} />
          <% end %>
        </div>

        <.controls
          :if={@controls != []}
          id={@id}
          name={@name}
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
  attr :myself, :any, required: true

  defp toolbar(assigns) do
    ~H"""
    <div class="flex items-center justify-between gap-2">
      <div class="inline-flex rounded-md border border-zinc-200 p-0.5 dark:border-zinc-800">
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
      <button
        :if={@tab == "code"}
        type="button"
        id={"#{@id}-copy"}
        phx-hook=".CopyCode"
        data-copy={"#{@id}-code"}
        class="inline-flex items-center gap-1.5 rounded-md border border-zinc-200 px-2 py-1 text-xs text-zinc-600 transition-colors hover:bg-zinc-100 dark:border-zinc-800 dark:text-zinc-400 dark:hover:bg-zinc-800"
      >
        <.icon name="lucide-copy" class="size-3.5" /> Copy
      </button>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CopyCode">
      export default {
        mounted() {
          this.el.addEventListener("click", () => {
            const target = document.getElementById(this.el.dataset.copy)
            if (target) navigator.clipboard.writeText(target.textContent)
          })
        }
      }
    </script>
    """
  end

  attr :id, :string, required: true
  attr :name, :atom, default: nil
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
                    :for={value <- select_options(control, @name)}
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

  defp resolve_code(%{code: code}) when is_binary(code), do: code

  defp resolve_code(%{kind: :example, name: name} = assigns) do
    Examples.render_code(%{name: name, props: assigns.props, id: assigns.id})
  end

  defp resolve_code(_assigns), do: nil

  defp select_options(control, name) do
    values = control[:values]

    if is_list(values) and values != [] do
      Enum.map(values, &to_string/1)
    else
      attr_values(control, name)
    end
  end

  defp attr_values(%{key: key}, name) when is_atom(name) do
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

  defp attr_values(_control, _name), do: []

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
