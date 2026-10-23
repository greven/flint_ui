defmodule FlintUIDocsWeb.PreviewComponent do
  @moduledoc """
  Stacked component preview card: rendered demo, optional controls, code.

  The demo is always visible. When controls are given they sit directly beneath
  it, and the code block sits beneath those, all sharing one border. There is no
  Preview/Code tab bar; the code is part of the card.

  The code block is a `FlintUIDocsWeb.CodeBlock`. In development it also gets a
  Source toggle next to its copy button: the toggle swaps the public snippet for
  the actual `~H` body of the preview's `render_*` callback, read automatically
  by `FlintUIDocsWeb.Docs.Source`. The toggle is hidden in every other
  environment.

  Set `preview_only: true` for a card whose value is purely the rendered demo,
  such as a full variant/color matrix. It renders the demo with no code section.
  """

  use FlintUIDocsWeb, :live_component

  alias FlintUIDocsWeb.CodeBlock
  alias FlintUIDocsWeb.Docs

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
  attr :preview_only, :boolean, default: false
  attr :class, :any, default: nil

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
      preview_only={@preview_only}
      class={@class}
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
      |> assign_new(:source, fn ->
        if assigns[:preview_only], do: nil, else: preview_source(assigns)
      end)
      |> assign_new(:code_view, fn -> "code" end)
      |> assign_new(:code_index, fn -> 0 end)

    {:ok, socket}
  end

  @impl true
  def handle_event("code_view", %{"view" => view}, socket) when view in ~w(code source) do
    {:noreply, assign(socket, :code_view, view)}
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
    active_flavor = flavors && Enum.at(flavors, index)
    source = assigns[:source]

    code_view =
      if source && assigns[:code_view] == "source", do: "source", else: "code"

    show_code? = active_flavor != nil and not assigns[:preview_only]
    below? = assigns[:controls] != [] or show_code?

    assigns =
      assign(assigns,
        flavors: flavors,
        code_index: index,
        active_flavor: active_flavor,
        code_view: code_view,
        show_code?: show_code?,
        below?: below?,
        display_code: display_code(active_flavor, source, code_view),
        display_lang: display_lang(active_flavor, code_view),
        code_caption: code_caption(source, code_view)
      )

    ~H"""
    <div id={@id} class={["mt-6", @class]}>
      <div :if={@title || @description} class="flex flex-col gap-1">
        <h4 :if={@title} class="text-sm font-semibold">{@title}</h4>
        <p :if={@description} class="text-sm text-zinc-600 dark:text-zinc-400">{@description}</p>
      </div>

      <div class="mt-3 rounded-lg shadow-lg/3">
        <div
          data-preview-canvas
          class={[
            "grid min-h-24 place-items-center border border-solid border-zinc-200 bg-black/1 p-6 dark:border-zinc-800 dark:bg-white/1",
            if(@below?, do: "rounded-t-lg", else: "rounded-lg")
          ]}
        >
          <%= case @kind do %>
            <% :playground -> %>
              <Docs.render_playground
                name={@name}
                layer={@layer}
                props={@props}
                id={"#{@id}-canvas"}
              />
            <% :usage -> %>
              <Docs.render_usage
                name={@name}
                layer={@layer}
                block={@block}
                props={@props}
                id={"#{@id}-canvas"}
              />
            <% :block -> %>
              <Docs.render_block
                name={@name}
                layer={@layer}
                block={@block}
                props={@props}
                id={"#{@id}-canvas"}
              />
          <% end %>
        </div>

        <.controls
          :if={@controls != []}
          id={@id}
          name={@name}
          layer={@layer}
          controls={@controls}
          props={@props}
          last={!@show_code?}
          myself={@myself}
        />

        <div
          :if={@show_code?}
          data-preview-code
          class="overflow-hidden rounded-b-lg border-x border-b border-zinc-200 dark:border-zinc-800"
        >
          <CodeBlock.code
            id={"#{@id}-code"}
            copy_id={"#{@id}-copy"}
            code={@display_code}
            lang={@display_lang}
            caption={@code_caption}
            class="rounded-none"
          >
            <:tabs :if={@code_view == "code" && length(@flavors) > 1}>
              <button
                :for={{flavor, i} <- Enum.with_index(@flavors)}
                type="button"
                phx-click="code"
                phx-target={@myself}
                phx-value-index={i}
                class={code_tab(i == @code_index)}
              >
                {flavor.label || "Code"}
              </button>
            </:tabs>

            <:actions :if={@source}>
              <button
                type="button"
                id={"#{@id}-source-toggle"}
                phx-click="code_view"
                phx-target={@myself}
                phx-value-view={if @code_view == "source", do: "code", else: "source"}
                class="inline-flex items-center gap-1.5 rounded-md px-2 py-1 text-xs text-zinc-500 transition-colors hover:bg-zinc-900/5 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-white/10 dark:hover:text-zinc-100"
              >
                <.icon
                  name={if @code_view == "source", do: "lucide-code", else: "lucide-file-code"}
                  class="size-3.5"
                />
                {if @code_view == "source", do: "Code", else: "Source"}
              </button>
            </:actions>
          </CodeBlock.code>

          <div
            :if={@code_view == "code" && @active_flavor[:styles]}
            class="border-t border-zinc-200 dark:border-zinc-800"
          >
            <CodeBlock.code
              id={"#{@id}-styles"}
              code={@active_flavor.styles}
              lang={:css}
              caption="app.css"
              class="rounded-none"
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## Controls

  attr :id, :string, required: true
  attr :name, :atom, default: nil
  attr :layer, :atom, default: :base
  attr :controls, :list, required: true
  attr :props, :map, required: true
  attr :last, :boolean, default: true
  attr :myself, :any, required: true

  defp controls(assigns) do
    ~H"""
    <div
      data-preview-controls
      class={[
        "overflow-x-auto border-x border-b border-zinc-200 bg-black/2 px-3 py-2.5 dark:border-zinc-800 dark:bg-white/2",
        "bg-[repeating-linear-gradient(135deg,rgba(0,0,0,0.03)_0,rgba(0,0,0,0.03)_1px,transparent_1px,transparent_6px)]",
        "dark:bg-[repeating-linear-gradient(135deg,rgba(255,255,255,0.03)_0,rgba(255,255,255,0.03)_1px,transparent_1px,transparent_6px)]",
        @last && "rounded-b-lg"
      ]}
    >
      <form
        id={"#{@id}-controls"}
        phx-change="set"
        phx-target={@myself}
        class="flex flex-wrap items-center gap-2.5"
      >
        <%= for control <- @controls do %>
          <%= case control.type do %>
            <% :boolean -> %>
              <button
                type="button"
                phx-click="toggle"
                phx-target={@myself}
                phx-value-key={control.key}
                aria-pressed={to_string(Map.get(@props, control.key) == true)}
                class={addon_shell("w-48")}
              >
                <span class={addon_label()}>{control.label}</span>
                <span class="flex flex-1 items-center justify-end px-2.5">
                  <span class={switch_track(Map.get(@props, control.key))}>
                    <span class={switch_thumb(Map.get(@props, control.key))} />
                  </span>
                </span>
              </button>
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
                    class="pointer-events-none absolute top-1/2 right-2 size-3.5 -translate-y-1/2 text-zinc-400"
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

  defp display_code(_active_flavor, source, "source"), do: source.code
  defp display_code(active_flavor, _source, _view), do: active_flavor && active_flavor.code

  defp display_lang(_active_flavor, "source"), do: :heex
  defp display_lang(active_flavor, _view), do: (active_flavor && active_flavor.lang) || :heex

  defp code_caption(source, "source") do
    "#{source.callback} · #{source.path}:#{source.line}"
  end

  defp code_caption(_source, _view), do: nil

  defp resolve_flavors(assigns) do
    cond do
      is_list(assigns[:codes]) and assigns[:codes] != [] ->
        normalize_codes(assigns[:codes])

      is_binary(assigns[:code]) ->
        [flavor(%{code: assigns[:code], lang: assigns[:code_lang] || :heex})]

      assigns[:kind] == :playground ->
        Docs.render_code(%{
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

  defp preview_source(%{name: name, kind: kind} = assigns)
       when is_atom(name) and kind in [:playground, :usage, :block] do
    Docs.source(name, kind, block: assigns[:block], layer: assigns[:layer])
  end

  defp preview_source(_assigns), do: nil

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

  defp code_tab(true) do
    "rounded bg-zinc-900/5 px-2 py-1 text-xs font-medium text-zinc-900 dark:bg-white/10 dark:text-zinc-100"
  end

  defp code_tab(false) do
    "rounded px-2 py-1 text-xs text-zinc-500 transition-colors hover:bg-zinc-900/5 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-white/5 dark:hover:text-zinc-100"
  end

  defp addon_shell(width) do
    [
      "flex min-w-0 items-stretch overflow-hidden rounded-md border border-zinc-200 bg-white text-left transition-colors focus-within:border-zinc-300 focus-within:ring-2 focus-within:ring-zinc-300 focus-within:ring-inset focus-visible:outline-none dark:border-zinc-800 dark:bg-zinc-950 dark:focus-within:border-zinc-700 dark:focus-within:ring-zinc-700",
      width
    ]
  end

  defp addon_label do
    "flex shrink-0 items-center border-r border-zinc-200 bg-zinc-50 px-2 text-xs font-medium whitespace-nowrap text-zinc-500 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-400"
  end

  defp input_class do
    "keeper-ignore min-w-0 flex-1 bg-transparent px-2.5 py-1.5 text-sm text-zinc-900 outline-none dark:text-zinc-100"
  end

  defp select_class do
    "w-full appearance-none bg-transparent py-1.5 pr-7 pl-2.5 text-sm text-zinc-900 outline-none dark:text-zinc-100"
  end

  defp switch_track(true) do
    "relative inline-flex h-4 w-7 items-center rounded-full bg-zinc-900 transition-colors dark:bg-zinc-100"
  end

  defp switch_track(false) do
    "relative inline-flex h-4 w-7 items-center rounded-full bg-zinc-200 transition-colors dark:bg-zinc-700"
  end

  defp switch_thumb(true) do
    "inline-block size-3 translate-x-3.5 rounded-full bg-white transition-transform dark:bg-zinc-900"
  end

  defp switch_thumb(false) do
    "inline-block size-3 translate-x-0.5 rounded-full bg-white transition-transform dark:bg-zinc-400"
  end
end
