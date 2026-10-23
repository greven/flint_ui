defmodule FlintUIDocsWeb.DocsComponents do
  @moduledoc """
  Presentational building blocks shared by the component docs pages.
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Highlight

  @doc false

  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :title, :string, default: nil
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section id={@id} class={[@class, "scroll-mt-20"]}>
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
    <pre class={[
      "highlight mt-3 overflow-x-auto rounded-lg border border-zinc-200 bg-black/3 p-4 text-xs leading-relaxed",
      "dark:border-zinc-800 dark:bg-white/3"
    ]}><code>{Highlight.highlight(@code, @lang)}</code></pre>
    """
  end

  @doc """
  A dashed, diagonally-hatched box that stands in for content in a preview.

  Pass `class` for sizing (e.g. `class="h-48"`) and an optional `:inner_block`
  for centered content. Set `border={false}` and/or `rounded={false}` when the
  surrounding layout already provides a frame, so the placeholder does not
  double it up.
  """

  attr :class, :any, default: nil
  attr :border, :boolean, default: true
  attr :rounded, :boolean, default: true
  slot :inner_block

  def content_placeholder(assigns) do
    ~H"""
    <div class={[
      "grid place-items-center text-sm text-zinc-400",
      @rounded && "rounded-md",
      @border && "border border-dashed border-zinc-300 dark:border-zinc-700",
      "bg-[repeating-linear-gradient(45deg,var(--color-zinc-200)_0,var(--color-zinc-200)_1px,transparent_1px,transparent_8px)]",
      "dark:bg-[repeating-linear-gradient(45deg,var(--color-zinc-900)_0,var(--color-zinc-900)_1px,transparent_1px,transparent_8px)]",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :attrs, :list, required: true

  def attr_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-xl text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Attr</th>
            <th class="py-3 pr-6 font-medium">Type</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={attr <- @attrs} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {attr[:name]}
              </code>
              <span :if={attr[:required]} class="ml-1.5 text-xs text-zinc-400">required</span>
            </td>
            <td class="py-4 pr-6 leading-6 text-zinc-600 dark:text-zinc-400">
              <.type_cell item={attr} />
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
              <.attribute_description doc={attr[:doc]} default={attr[:default]} />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc false

  attr :rows, :list, required: true

  def attributes_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-176 text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Attr</th>
            <th class="py-3 pr-6 font-medium">Layer</th>
            <th class="py-3 pr-6 font-medium">Type</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={row <- @rows} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {row.name}
              </code>
              <span :if={row.required} class="ml-1.5 text-xs text-zinc-400">required</span>
            </td>
            <td class="py-4 pr-6 whitespace-nowrap leading-6 text-zinc-600 dark:text-zinc-400">
              {layer_label(row.layer)}
            </td>
            <td class="py-4 pr-6 leading-6 text-zinc-600 dark:text-zinc-400">
              <.type_cell item={row} />
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
              <.attribute_description doc={row.doc} data={row.data} default={row.default} />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @tone_zinc %{
    rail: "border-l-zinc-300 dark:border-l-zinc-700",
    part:
      "bg-zinc-100 text-zinc-700 ring-zinc-200 dark:bg-zinc-800 dark:text-zinc-300 dark:ring-zinc-700",
    selector:
      "bg-zinc-50 text-zinc-600 ring-zinc-200 dark:bg-zinc-900 dark:text-zinc-400 dark:ring-zinc-800"
  }

  @tone_blue %{
    rail: "border-l-blue-300 dark:border-l-blue-700",
    part:
      "bg-blue-50 text-blue-700 ring-blue-200 dark:bg-blue-950/50 dark:text-blue-300 dark:ring-blue-900",
    selector:
      "bg-blue-50/70 text-blue-700 ring-blue-200 dark:bg-blue-950/30 dark:text-blue-300 dark:ring-blue-900"
  }

  @tone_emerald %{
    rail: "border-l-emerald-300 dark:border-l-emerald-700",
    part:
      "bg-emerald-50 text-emerald-700 ring-emerald-200 dark:bg-emerald-950/50 dark:text-emerald-300 dark:ring-emerald-900",
    selector:
      "bg-emerald-50/70 text-emerald-700 ring-emerald-200 dark:bg-emerald-950/30 dark:text-emerald-300 dark:ring-emerald-900"
  }

  @tone_rose %{
    rail: "border-l-rose-300 dark:border-l-rose-700",
    part:
      "bg-rose-50 text-rose-700 ring-rose-200 dark:bg-rose-950/50 dark:text-rose-300 dark:ring-rose-900",
    selector:
      "bg-rose-50/70 text-rose-700 ring-rose-200 dark:bg-rose-950/30 dark:text-rose-300 dark:ring-rose-900"
  }

  @tone_violet %{
    rail: "border-l-violet-300 dark:border-l-violet-700",
    part:
      "bg-violet-50 text-violet-700 ring-violet-200 dark:bg-violet-950/50 dark:text-violet-300 dark:ring-violet-900",
    selector:
      "bg-violet-50/70 text-violet-700 ring-violet-200 dark:bg-violet-950/30 dark:text-violet-300 dark:ring-violet-900"
  }

  @anatomy_tones %{
    "root" => @tone_zinc,
    "trigger" => @tone_blue,
    "content" => @tone_emerald,
    "body" => @tone_emerald,
    "header" => @tone_rose,
    "footer" => @tone_rose,
    "title" => @tone_violet,
    "description" => @tone_violet,
    "action" => @tone_violet,
    "header-content" => @tone_violet
  }

  attr :nodes, :list, required: true

  def anatomy(assigns) do
    assigns =
      assign(assigns, :legend, %{
        tag: anatomy_tag_class(),
        part: @tone_zinc.part,
        selector: @tone_zinc.selector,
        data: anatomy_attr_class(:data),
        aria: anatomy_attr_class(:aria),
        html: anatomy_attr_class(:html)
      })

    ~H"""
    <div class="mt-4" data-anatomy>
      <ul class="mt-4 space-y-4">
        <.anatomy_node :for={node <- @nodes} node={node} />
      </ul>

      <div class="mt-6 flex flex-wrap items-center gap-1.5" data-anatomy-legend>
        <span class="mr-1 text-[10px] font-semibold tracking-wider text-zinc-400 uppercase">
          Legend
        </span>
        <span class={["rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset", @legend.tag]}>
          Tag
        </span>
        <span class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          @legend.part
        ]}>
          Part
        </span>
        <span class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          @legend.selector
        ]}>
          Selector
        </span>
        <span class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          @legend.data
        ]}>
          Data
        </span>
        <span class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          @legend.aria
        ]}>
          ARIA
        </span>
        <span class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          @legend.html
        ]}>
          HTML
        </span>
      </div>
    </div>
    """
  end

  attr :node, :map, required: true

  defp anatomy_node(assigns) do
    part = anatomy_part(assigns.node)
    tone = Map.get(@anatomy_tones, part, @tone_zinc)

    assigns =
      assigns
      |> assign(:part, part)
      |> assign(:tone, tone)
      |> assign(:groups, anatomy_groups(assigns.node))

    ~H"""
    <li
      class={["border-l-2 py-1 pl-3", @tone.rail]}
      data-anatomy-node
      data-anatomy-part={@part}
    >
      <div class="flex flex-wrap items-center gap-1.5">
        <code class={[
          "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
          anatomy_tag_class()
        ]}>
          {@node[:tag]}
        </code>
        <span class={[
          "rounded-md px-1.5 py-0.5 text-[10px] font-medium ring-1 ring-inset",
          @tone.part
        ]}>
          {@part}
        </span>
        <code
          :if={@node[:selector]}
          class={[
            "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
            @tone.selector
          ]}
        >
          {@node[:selector]}
        </code>
      </div>

      <p :if={@node[:note]} class="mt-1 text-xs text-zinc-500">{@node[:note]}</p>

      <div :if={@groups != []} class="mt-2 grid gap-1">
        <div
          :for={{kind, attrs} <- @groups}
          class="flex flex-wrap items-start gap-x-2 gap-y-1"
          data-anatomy-group={kind}
        >
          <span class="w-12 shrink-0 pt-0.5 text-[10px] font-semibold tracking-wider text-zinc-400 uppercase">
            {anatomy_group_label(kind)}
          </span>
          <div class="flex min-w-0 flex-1 flex-wrap gap-1.5">
            <span
              :for={attr <- attrs}
              class={[
                "rounded-md px-1.5 py-0.5 font-mono text-[11px] ring-1 ring-inset",
                anatomy_attr_class(kind)
              ]}
            >
              {attr}
            </span>
          </div>
        </div>
      </div>

      <ul
        :if={@node[:children] && @node[:children] != []}
        class="mt-2 space-y-3 pl-2"
      >
        <.anatomy_node :for={child <- @node[:children]} node={child} />
      </ul>
    </li>
    """
  end

  defp anatomy_part(node) do
    selector = node[:selector] || ""

    case Regex.run(~r/data-part="([^"]+)"/, selector) do
      [_, part] -> part
      _ -> "root"
    end
  end

  defp anatomy_attrs(node) do
    ((node[:hooks] || []) ++ (node[:attributes] || []))
    |> Enum.uniq()
  end

  defp anatomy_groups(node) do
    groups =
      node
      |> anatomy_attrs()
      |> Enum.group_by(&anatomy_attr_kind/1)

    for kind <- [:data, :aria, :html],
        attrs = groups[kind],
        attrs not in [nil, []],
        do: {kind, attrs}
  end

  defp anatomy_attr_kind(attr) do
    cond do
      String.starts_with?(attr, "data-") -> :data
      String.starts_with?(attr, "[data-") -> :data
      String.starts_with?(attr, "aria-") -> :aria
      attr == "role" -> :aria
      true -> :html
    end
  end

  defp anatomy_group_label(:data), do: "Data"
  defp anatomy_group_label(:aria), do: "ARIA"
  defp anatomy_group_label(:html), do: "HTML"

  defp anatomy_tag_class do
    "bg-zinc-900 text-zinc-100 ring-zinc-900 dark:bg-zinc-100 dark:text-zinc-900 dark:ring-zinc-100"
  end

  defp anatomy_attr_class(:data) do
    "bg-sky-50 text-sky-700 ring-sky-200 dark:bg-sky-950/40 dark:text-sky-300 dark:ring-sky-900"
  end

  defp anatomy_attr_class(:aria) do
    "bg-violet-50 text-violet-700 ring-violet-200 dark:bg-violet-950/40 dark:text-violet-300 dark:ring-violet-900"
  end

  defp anatomy_attr_class(:html) do
    "text-zinc-600 ring-zinc-200 dark:text-zinc-400 dark:ring-zinc-800"
  end

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
          <td class="py-2 pr-4">
            <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
              {prop.name}
            </code>
          </td>
          <td class="py-2 pr-4 text-zinc-600 dark:text-zinc-400">
            {Enum.map_join(prop.values, " | ", &to_string/1)}
          </td>
          <td class="py-2 pr-4">
            <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
              {to_string(prop.default)}
            </code>
          </td>
          <td class="py-2 pr-4">
            <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
              {@hooks[prop.name] || "\u2014"}
            </code>
          </td>
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
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-xl text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Name</th>
            <th class="py-3 pr-6 font-medium">Required</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={slot <- @slots} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {slot.name}
              </code>
            </td>
            <td class="py-4 pr-6 leading-6 text-zinc-600 dark:text-zinc-400">
              {if slot.required, do: "yes", else: ""}
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
              <p>{slot.doc}</p>
              <p
                :if={Map.get(slot, :attrs, []) != []}
                class="mt-1 text-xs text-zinc-500"
              >
                Attributes: {Enum.map_join(Map.get(slot, :attrs, []), ", ", & &1.name)}
              </p>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc false

  attr :events, :list, required: true

  def events_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-xl text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Name</th>
            <th class="py-3 pr-6 font-medium">Source</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={event <- @events} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {event.name}
              </code>
            </td>
            <td class="py-4 pr-6 leading-6 text-zinc-600 dark:text-zinc-400">
              {to_string(event.source)}
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">{event.doc}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc false

  attr :parts, :list, required: true

  def parts_tables(assigns) do
    ~H"""
    <div :for={{part, part_attrs} <- @parts} class="mt-6 first:mt-4">
      <p class="text-xs font-semibold tracking-wider text-zinc-400 uppercase">{part}</p>
      <div class="mt-2 overflow-x-auto">
        <table class="w-full min-w-xl text-left text-sm">
          <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
            <tr>
              <th class="py-3 pr-6 font-medium">Attribute</th>
              <th class="py-3 pr-6 font-medium">Value</th>
              <th class="py-3 font-medium">Description</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
            <tr :for={part_attr <- part_attrs} class="align-top">
              <td class="py-4 pr-6 whitespace-nowrap">
                <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                  {part_attr_label(part_attr.name)}
                </code>
              </td>
              <td class="py-4 pr-6 leading-6">
                <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                  {part_attr.value}
                </code>
              </td>
              <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
                {part_attr.description}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp part_attr_label("[" <> rest) do
    if String.starts_with?(rest, "data-") and String.ends_with?(rest, "]") do
      String.trim_trailing(rest, "]")
    else
      "[" <> rest
    end
  end

  defp part_attr_label(name), do: name

  @doc false

  attr :css_vars, :list, required: true

  def css_vars_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-160 text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Name</th>
            <th class="py-3 pr-6 font-medium">Default</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={css_var <- @css_vars} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {css_var.name}
              </code>
            </td>
            <td class="py-4 pr-6 leading-6">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {css_var_default(css_var)}
              </code>
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
              {css_var_description(css_var)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp css_var_default(css_var) do
    case Map.get(css_var, :default) do
      nil -> "\u2014"
      default -> default
    end
  end

  defp css_var_description(css_var) do
    Map.get(css_var, :description) || Map.get(css_var, :doc)
  end

  @doc false

  attr :selectors, :list, required: true

  def selectors_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-xl text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Selector</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={selector <- @selectors} class="align-top">
            <td class="py-4 pr-6 leading-6">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {selector.selector}
              </code>
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">
              {selector.description}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc false

  attr :keyboard, :list, required: true

  def keyboard_table(assigns) do
    ~H"""
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-xl text-left text-sm">
        <thead class="border-b border-zinc-200 text-xs tracking-wider text-zinc-400 uppercase dark:border-zinc-800">
          <tr>
            <th class="py-3 pr-6 font-medium">Keys</th>
            <th class="py-3 font-medium">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
          <tr :for={kbd <- @keyboard} class="align-top">
            <td class="py-4 pr-6 whitespace-nowrap">
              <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
                {kbd.keys}
              </code>
            </td>
            <td class="py-4 leading-6 text-zinc-600 dark:text-zinc-400">{kbd.description}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc false

  attr :doc, :string, default: nil
  attr :data, :string, default: nil
  attr :default, :any, default: nil

  def attribute_description(assigns) do
    ~H"""
    <div class="space-y-1">
      <p :if={@doc}>{@doc}</p>
      <div :if={@data || @default != nil} class="space-y-1 text-xs">
        <p :if={@data}>
          Data attribute:
          <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
            {@data}
          </code>
        </p>
        <p :if={@default != nil}>
          Default:
          <code class="rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
            {default_label(@default)}
          </code>
        </p>
      </div>
    </div>
    """
  end

  @doc false

  attr :item, :map, required: true

  def type_cell(assigns) do
    values = type_values(assigns.item)
    type = if values == [], do: to_string(assigns.item[:type]), else: nil
    assigns = assign(assigns, values: values, type: type)

    ~H"""
    <code :if={@type} class={code_class()}>{@type}</code>
    <%= for {value, index} <- Enum.with_index(@values) do %>
      <span :if={index > 0} class="mx-1 text-zinc-400">|</span>
      <code class={code_class()}>{"'#{value}'"}</code>
    <% end %>
    """
  end

  defp type_values(%{type: type}) when type in [:boolean, "boolean"], do: []
  defp type_values(%{values: values}) when is_list(values) and values != [], do: values

  defp type_values(attr) do
    case values_for(attr) do
      values when is_list(values) and values != [] -> values
      _ -> []
    end
  end

  defp values_for(attr) do
    case attr[:opts] do
      opts when is_list(opts) -> Keyword.get(opts, :values)
      _ -> nil
    end
  end

  defp layer_label(layer), do: layer |> to_string() |> String.capitalize()

  defp code_class do
    "rounded bg-zinc-100 px-1 py-0.5 font-mono text-xs text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200"
  end

  defp default_label(value), do: inspect(value)
end
