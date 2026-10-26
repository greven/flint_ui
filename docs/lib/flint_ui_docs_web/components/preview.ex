defmodule FlintUIDocsWeb.Preview do
  @moduledoc """
  Preview card: rendered demo, optional controls, optional code block.

  This is a function component rather than a LiveComponent so the demo can be a
  slot. Per-preview state (control props, active code flavor, and source/code
  view) belongs to `FlintUIDocsWeb.ComponentLive` and arrives through `state`.

  `code` and `codes` accept a string, a list of code flavors, or a 1-arity
  function that receives the current props. The demo slot receives the same
  props:

      <.preview id="..." name={:button} state={@state} controls={[:variant]}
        code={fn props -> ... end}>
        <Components.button variant={props.variant}>Button</Components.button>
      </.preview>

  A slot cannot carry raw source text (slots are rendered content), which is why
  the code is an attribute while the demo is the inner block.
  """

  use FlintUIDocsWeb, :html

  alias FlintUIDocsWeb.CodeBlock
  alias FlintUIDocsWeb.Docs

  attr :id, :string, required: true
  attr :name, :atom, required: true
  attr :layer, :atom, default: :styled
  attr :controls, :list, default: []
  attr :state, :map, default: %{}
  attr :code, :any, default: nil
  attr :codes, :any, default: nil
  attr :code_lang, :atom, default: :heex
  attr :preview_only, :boolean, default: false
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def preview(assigns) do
    defaults = Docs.defaults(assigns.name)

    state =
      Map.merge(%{props: %{}, code_index: 0, code_view: "code", source: nil}, assigns.state)

    props = Map.merge(defaults, state.props)
    controls = controls_for(assigns.name, assigns.layer, assigns.controls)
    flavors = resolve_flavors(assigns, props)
    index = clamp_index(state.code_index, flavors)
    active_flavor = flavors && Enum.at(flavors, index)
    source = state.source
    code_view = if source && state.code_view == "source", do: "source", else: "code"
    show_code? = active_flavor != nil and not assigns.preview_only
    below? = controls != [] or show_code?

    assigns =
      assign(assigns,
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
        display_code: display_code(active_flavor, source, code_view),
        display_lang: display_lang(active_flavor, code_view),
        code_caption: code_caption(source, code_view)
      )

    ~H"""
    <div id={@id} class={["mt-6", @class]}>
      <div class="mt-3 rounded-lg shadow-lg/3">
        <div
          data-preview-canvas
          class={[
            "grid min-h-24 place-items-center border border-solid border-zinc-200 bg-black/1 p-6 dark:border-zinc-800 dark:bg-white/1",
            if(@below?, do: "rounded-t-lg", else: "rounded-lg")
          ]}
        >
          {render_slot(@inner_block, @props)}
        </div>

        <.controls
          :if={@controls != []}
          id={@id}
          name={@name}
          layer={@layer}
          controls={@controls}
          props={@props}
          last={!@show_code?}
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
                phx-click="preview_code"
                phx-value-id={@id}
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
                phx-click="preview_view"
                phx-value-id={@id}
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
  attr :name, :atom, required: true
  attr :layer, :atom, default: :styled
  attr :controls, :list, required: true
  attr :props, :map, required: true
  attr :last, :boolean, default: true

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

  defp controls_for(name, layer, keys) do
    name
    |> Docs.controls()
    |> Enum.filter(&(&1.key in keys))
    |> Enum.map(&Map.put(&1, :layer, layer))
  end

  defp resolve_flavors(assigns, props) do
    cond do
      is_function(assigns.codes, 1) -> assigns.codes.(props) |> normalize_codes()
      assigns.codes not in [nil, []] -> normalize_codes(assigns.codes)
      is_function(assigns.code, 1) -> assigns.code.(props) |> normalize_codes()
      is_binary(assigns.code) -> normalize_codes(assigns.code)
      is_list(assigns.code) -> normalize_codes(assigns.code)
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
end
