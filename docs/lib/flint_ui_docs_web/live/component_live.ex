defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Examples

  @part_order [:root, :trigger, :content]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={@active}>
      <div class="max-w-4xl">
        <header class="border-b border-zinc-200 pb-6 dark:border-zinc-800">
          <h1 class="text-3xl font-semibold tracking-tight">{humanize(@active)}</h1>
          <p :if={@description} class="mt-3 text-zinc-600 dark:text-zinc-400">{@description}</p>
          <div class="mt-4 flex flex-wrap gap-2">
            <span class="rounded-full border border-zinc-200 px-2.5 py-0.5 text-xs text-zinc-600 dark:border-zinc-800 dark:text-zinc-400">
              {to_string(@meta.type)}
            </span>
            <span class="rounded-full border border-zinc-200 px-2.5 py-0.5 text-xs text-zinc-600 dark:border-zinc-800 dark:text-zinc-400">
              {to_string(@meta.status)}
            </span>
            <span class="rounded-full border border-zinc-200 px-2.5 py-0.5 text-xs text-zinc-600 dark:border-zinc-800 dark:text-zinc-400">
              since {@meta.since}
            </span>
          </div>
        </header>

        <section id="preview" class="mt-10">
          <h2 class="text-lg font-semibold">Preview</h2>

          <div class="mt-4 grid place-items-center rounded-lg border border-dashed border-zinc-300 bg-zinc-50 p-8 dark:border-zinc-700 dark:bg-zinc-900/40">
            <Examples.render_example name={@active} props={@props} id="preview-example" />
          </div>

          <div
            :if={@controls != []}
            class="mt-4 rounded-lg border border-zinc-200 p-4 dark:border-zinc-800"
          >
            <form phx-change="set" class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              <label :for={control <- @controls} class="flex flex-col gap-1">
                <span class="text-xs text-zinc-500">{control.label}</span>
                <%= if control.type == :boolean do %>
                  <button
                    type="button"
                    phx-click="toggle"
                    phx-value-key={control.key}
                    class={[
                      "flex items-center justify-between rounded-md border px-3 py-1.5 text-sm transition-colors",
                      Map.get(@props, control.key) &&
                        "border-zinc-900 bg-zinc-900 text-white dark:border-white dark:bg-white dark:text-zinc-900",
                      !Map.get(@props, control.key) &&
                        "border-zinc-200 text-zinc-600 hover:bg-zinc-50 dark:border-zinc-800 dark:text-zinc-400 dark:hover:bg-zinc-800"
                    ]}
                  >
                    <span>{if Map.get(@props, control.key), do: "On", else: "Off"}</span>
                  </button>
                <% else %>
                  <input
                    type="text"
                    name={control.key}
                    value={Map.get(@props, control.key)}
                    autocomplete="off"
                    class="rounded-md border border-zinc-200 bg-white px-3 py-1.5 text-sm outline-none focus:border-zinc-400 dark:border-zinc-800 dark:bg-zinc-950"
                  />
                <% end %>
              </label>
            </form>
          </div>
        </section>

        <section :if={@structure} id="structure" class="mt-10">
          <h2 class="text-lg font-semibold">Structure</h2>
          <pre class="mt-4 overflow-x-auto rounded-lg bg-zinc-900 p-4 text-xs leading-relaxed text-zinc-100 dark:bg-zinc-900"><code>{@structure}</code></pre>
        </section>

        <section :if={@variants != []} id="examples" class="mt-10">
          <h2 class="text-lg font-semibold">Examples</h2>
          <div class="mt-4 grid gap-6 sm:grid-cols-2">
            <div :for={{label, props} <- @variants} class="flex flex-col gap-3">
              <p class="text-xs font-medium tracking-wider text-zinc-400 uppercase">{label}</p>
              <div class="grid flex-1 place-items-center rounded-lg border border-dashed border-zinc-300 bg-zinc-50 p-6 dark:border-zinc-700 dark:bg-zinc-900/40">
                <Examples.render_example name={@active} props={props} id={"variant-#{slug(label)}"} />
              </div>
            </div>
          </div>
        </section>

        <section :if={@keyboard != []} id="keyboard" class="mt-10">
          <h2 class="text-lg font-semibold">Keyboard</h2>
          <table class="mt-4 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Keys</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={kbd <- @keyboard}>
                <td class="py-2 pr-4"><code class="font-mono">{kbd.keys}</code></td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{kbd.description}</td>
              </tr>
            </tbody>
          </table>
        </section>

        <section id="api" class="mt-10">
          <h2 class="text-lg font-semibold">API reference</h2>

          <h3 class="mt-6 text-sm font-semibold">Attributes</h3>
          <p :if={@attrs == []} class="mt-2 text-sm text-zinc-400">No attributes documented.</p>
          <table :if={@attrs != []} class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Property</th>
                <th class="py-2 pr-4 font-medium">Type</th>
                <th class="py-2 pr-4 font-medium">Default</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={attr <- @attrs}>
                <td class="py-2 pr-4">
                  <code class="font-mono">@{attr[:name]}</code>
                  <span :if={attr[:required]} class="ml-1 text-xs text-zinc-400">required</span>
                </td>
                <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">{type_label(attr)}</td>
                <td class="py-2 pr-4">
                  <code class="font-mono">{default_label(attr[:default])}</code>
                </td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{attr[:doc]}</td>
              </tr>
            </tbody>
          </table>

          <h3 class="mt-6 text-sm font-semibold">Slots</h3>
          <p :if={@slots == []} class="mt-2 text-sm text-zinc-400">No slots documented.</p>
          <table :if={@slots != []} class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Name</th>
                <th class="py-2 pr-4 font-medium">Required</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={slot <- @slots}>
                <td class="py-2 pr-4"><code class="font-mono">{slot[:name]}</code></td>
                <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">
                  {if slot[:required], do: "yes", else: ""}
                </td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{slot[:doc]}</td>
              </tr>
            </tbody>
          </table>

          <h3 class="mt-6 text-sm font-semibold">Events</h3>
          <p :if={@events == []} class="mt-2 text-sm text-zinc-400">No events documented.</p>
          <table :if={@events != []} class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Name</th>
                <th class="py-2 pr-4 font-medium">Source</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={event <- @events}>
                <td class="py-2 pr-4"><code class="font-mono">{event.name}</code></td>
                <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">{to_string(event.source)}</td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{event.doc}</td>
              </tr>
            </tbody>
          </table>

          <h3 :if={@css_vars != []} class="mt-6 text-sm font-semibold">CSS variables</h3>
          <table :if={@css_vars != []} class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Name</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={css_var <- @css_vars}>
                <td class="py-2 pr-4"><code class="font-mono">{css_var.name}</code></td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{css_var.description}</td>
              </tr>
            </tbody>
          </table>

          <h3 :if={@parts != []} class="mt-6 text-sm font-semibold">Data attributes</h3>
          <div :for={{part, part_attrs} <- @parts} class="mt-4">
            <p class="text-xs font-semibold tracking-wider text-zinc-400 uppercase">{part}</p>
            <table class="mt-2 w-full text-left text-sm">
              <thead class="text-xs tracking-wider text-zinc-400 uppercase">
                <tr>
                  <th class="py-2 pr-4 font-medium">Attribute</th>
                  <th class="py-2 pr-4 font-medium">Value</th>
                  <th class="py-2 font-medium">Description</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
                <tr :for={part_attr <- part_attrs}>
                  <td class="py-2 pr-4"><code class="font-mono">{part_attr.name}</code></td>
                  <td class="py-2 pr-4"><code class="font-mono">{part_attr.value}</code></td>
                  <td class="py-2 text-zinc-600 dark:text-zinc-400">{part_attr.description}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"name" => name}, _uri, socket) do
    case find_component(name) do
      nil -> {:noreply, push_navigate(socket, to: ~p"/")}
      component -> {:noreply, assign_component(socket, component)}
    end
  end

  @impl true
  def handle_event("toggle", %{"key" => key}, socket) do
    key = find_control!(socket.assigns.active, key).key
    props = Map.update!(socket.assigns.props, key, &(!&1))
    {:noreply, assign(socket, :props, props)}
  end

  def handle_event("set", params, socket) do
    props =
      Enum.reduce(Examples.controls(socket.assigns.active), socket.assigns.props, fn control,
                                                                                     acc ->
        case Map.fetch(params, Atom.to_string(control.key)) do
          {:ok, value} -> Map.put(acc, control.key, value)
          :error -> acc
        end
      end)

    {:noreply, assign(socket, :props, props)}
  end

  defp assign_component(socket, name) do
    assign(socket,
      active: name,
      page_title: humanize(name),
      description: FlintUI.Docs.description(name),
      structure: Examples.structure(name),
      meta: FlintUI.Docs.meta(name),
      attrs: FlintUI.Docs.attrs(name),
      slots: FlintUI.Docs.slots(name),
      parts: order_parts(FlintUI.Docs.parts_attrs(name)),
      events: FlintUI.Docs.events(name),
      keyboard: FlintUI.Docs.keyboard(name),
      css_vars: FlintUI.Docs.css_vars(name),
      variants: Examples.variants(name),
      controls: Examples.controls(name),
      props: Examples.defaults(name)
    )
  end

  defp find_component(name) do
    Enum.find(FlintUI.components(), &(Atom.to_string(&1) == name))
  end

  defp find_control!(component, key) do
    Enum.find(Examples.controls(component), &(Atom.to_string(&1.key) == key)) ||
      raise ArgumentError, "unknown control #{key} for #{component}"
  end

  defp order_parts(parts) do
    Enum.sort_by(parts, fn {part, _} ->
      Enum.find_index(@part_order, &(&1 == part)) || length(@part_order)
    end)
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp slug(label) do
    label
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  defp type_label(attr) do
    type = to_string(attr[:type])

    case values_for(attr) do
      values when is_list(values) and values != [] -> "#{type} \u2014 #{Enum.join(values, " | ")}"
      _ -> type
    end
  end

  defp values_for(attr) do
    case attr[:opts] do
      opts when is_list(opts) -> Keyword.get(opts, :values)
      _ -> nil
    end
  end

  defp default_label(nil), do: "\u2014"
  defp default_label(value), do: inspect(value)
end
