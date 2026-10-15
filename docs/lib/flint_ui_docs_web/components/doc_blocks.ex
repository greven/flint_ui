defmodule FlintUIDocsWeb.DocBlocks do
  @moduledoc """
  Presentational building blocks shared by the component docs pages.
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Highlight

  @doc false

  attr :id, :string, default: nil
  attr :title, :string, default: nil
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section id={@id} class="mt-10 scroll-mt-20">
      <h2 :if={@title} class="text-lg font-semibold">{@title}</h2>
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc false

  attr :id, :string, default: nil
  attr :title, :string, required: true
  slot :inner_block, required: true

  def subsection(assigns) do
    ~H"""
    <div id={@id} class="mt-8 scroll-mt-20">
      <h3 class="text-base font-semibold">{@title}</h3>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc false

  attr :code, :string, required: true
  attr :lang, :atom, default: :heex

  def code_block(assigns) do
    ~H"""
    <pre class="highlight mt-3 overflow-x-auto rounded-lg bg-zinc-900 p-4 text-xs leading-relaxed text-zinc-100 dark:bg-zinc-900"><code>{Highlight.highlight(@code, @lang)}</code></pre>
    """
  end

  attr :attrs, :list, required: true

  def attr_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
      <thead class="text-xs tracking-wider text-zinc-400 uppercase">
        <tr>
          <th class="py-2 pr-4 font-medium">Attribute</th>
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
          <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">{attr_type(attr)}</td>
          <td class="py-2 pr-4"><code class="font-mono">{default_label(attr[:default])}</code></td>
          <td class="py-2 text-zinc-600 dark:text-zinc-400">{attr[:doc]}</td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc false

  attr :props, :list, required: true
  attr :hooks, :map, default: %{}

  def prop_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
      <thead class="text-xs tracking-wider text-zinc-400 uppercase">
        <tr>
          <th class="py-2 pr-4 font-medium">Attribute</th>
          <th class="py-2 pr-4 font-medium">Values</th>
          <th class="py-2 pr-4 font-medium">Default</th>
          <th class="py-2 pr-4 font-medium">Data attribute</th>
          <th class="py-2 font-medium">Description</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
        <tr :for={prop <- @props}>
          <td class="py-2 pr-4"><code class="font-mono">{prop.name}</code></td>
          <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">
            {Enum.map_join(prop.values, " | ", &to_string/1)}
          </td>
          <td class="py-2 pr-4"><code class="font-mono">{to_string(prop.default)}</code></td>
          <td class="py-2 pr-4"><code class="font-mono">{@hooks[prop.name] || "\u2014"}</code></td>
          <td class="py-2 text-zinc-600 dark:text-zinc-400">{prop.doc}</td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc false

  attr :slots, :list, required: true

  def slot_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
      <thead class="text-xs tracking-wider text-zinc-400 uppercase">
        <tr>
          <th class="py-2 pr-4 font-medium">Name</th>
          <th class="py-2 pr-4 font-medium">Required</th>
          <th class="py-2 font-medium">Description</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
        <tr :for={slot <- @slots}>
          <td class="py-2 pr-4"><code class="font-mono">{slot.name}</code></td>
          <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">
            {if slot.required, do: "yes", else: ""}
          </td>
          <td class="py-2 text-zinc-600 dark:text-zinc-400">{slot.doc}</td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc false

  attr :events, :list, required: true

  def events_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
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
    """
  end

  @doc false

  attr :parts, :list, required: true

  def parts_tables(assigns) do
    ~H"""
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
    """
  end

  @doc false

  attr :css_vars, :list, required: true

  def css_vars_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
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
    """
  end

  @doc false

  attr :keyboard, :list, required: true

  def keyboard_table(assigns) do
    ~H"""
    <table class="mt-3 w-full text-left text-sm">
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
    """
  end

  defp attr_type(attr) do
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
