defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.CodeBlock
  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Markdown

  @part_order [:root, :tablist, :tab, :panel, :trigger, :content]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={@active} section={:components}>
      <div class="max-w-4xl">
        <DocsComponents.component_header
          title={@title}
          subtitle={@subtitle}
          meta={@meta}
          links={@links}
        />

        <Components.tabs
          id="component-sections"
          class="mt-8"
          value={@tab}
          label="Component sections"
          variant="minimal"
          gap="sm"
        >
          <:tab :let={attrs} value="styled" custom>
            <Components.button
              {attrs}
              variant={tab_variant(@tab, "styled")}
              depth={tab_depth(@tab, "styled")}
              patch={~p"/components/#{@active}"}
              style="--fl-control-shadow: 0 0 #0000;"
              size="xl"
            >
              <Components.icon name="lucide-box" /> Styled
            </Components.button>
          </:tab>
          <:tab :let={attrs} value="base" custom>
            <Components.button
              {attrs}
              patch={~p"/components/#{@active}?tab=base"}
              variant={tab_variant(@tab, "base")}
              depth={tab_depth(@tab, "base")}
              style="--fl-control-shadow: 0 0 #0000;"
              size="xl"
            >
              <Components.icon name="lucide-code-xml" /> Base
            </Components.button>
          </:tab>
          <:tab :let={attrs} value="css" custom>
            <Components.button
              {attrs}
              patch={~p"/components/#{@active}?tab=css"}
              variant={tab_variant(@tab, "css")}
              depth={tab_depth(@tab, "css")}
              style="--fl-control-shadow: 0 0 #0000;"
              size="xl"
            >
              <Components.icon name="lucide-palette" /> CSS
            </Components.button>
          </:tab>

          <:panel value="styled">
            <section :if={@tab == "styled"} class="flex flex-col gap-16">
              <section id="main-preview" class="scroll-mt-28">
                <Docs.render_main
                  name={@active}
                  id={"playground-#{@active}"}
                  state={
                    preview_state(@previews, @active, "playground-#{@active}", :main, layer: :styled)
                  }
                />
              </section>

              <DocsComponents.section :if={@styled_overview} title="Overview" id="overview">
                <Markdown.markdown content={@styled_overview} />
              </DocsComponents.section>

              <DocsComponents.section :if={@styled_features != []} title="Features" id="features">
                <DocsComponents.features features={@styled_features} />
              </DocsComponents.section>

              <DocsComponents.section :if={@styled_usage != []} title="Usage" id="usage">
                <DocsComponents.subsection
                  :for={section <- @styled_usage}
                  title={section.title}
                  id={"usage-#{section.id}"}
                >
                  <Markdown.markdown :if={section[:body]} content={section.body} />
                  <Docs.render_section
                    name={@active}
                    kind={:usage}
                    block={section.id}
                    id={"usage-#{@active}-#{section.id}"}
                    section={section}
                    state={
                      preview_state(
                        @previews,
                        @active,
                        "usage-#{@active}-#{section.id}",
                        :section,
                        kind: :usage,
                        block: section.id,
                        layer: :styled
                      )
                    }
                  />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section :if={@styled_examples != []} title="Examples" id="examples">
                <DocsComponents.subsection
                  :for={example <- @styled_examples}
                  title={example.title}
                  id={"example-#{@active}-#{example.id}-section"}
                >
                  <p :if={example[:description]} class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
                    {example[:description]}
                  </p>
                  <Docs.render_section
                    name={@active}
                    kind={:example}
                    block={example.id}
                    id={"example-#{@active}-#{example.id}"}
                    section={example}
                    state={
                      preview_state(
                        @previews,
                        @active,
                        "example-#{@active}-#{example.id}",
                        :section,
                        kind: :example,
                        block: example.id,
                        layer: :styled
                      )
                    }
                  />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section title="API Reference" id="api">
                <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
                  The generated wrapper exposes these attributes and slots. Data attributes,
                  events, and runtime CSS variables are documented on the <.link
                    patch={"#{~p"/components/#{@active}?tab=base"}#data-attributes"}
                    class="underline"
                  >
                Base tab
              </.link>.
                </p>

                <DocsComponents.subsection title="Attributes" id="attributes">
                  <p :if={@styled_attributes == []} class="mt-2 text-sm text-zinc-400">
                    No attributes documented.
                  </p>
                  <DocsComponents.attributes_table
                    :if={@styled_attributes != []}
                    rows={@styled_attributes}
                  />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="Slots" id="slots">
                  <p :if={@merged_slots == []} class="mt-2 text-sm text-zinc-400">
                    No slots documented.
                  </p>
                  <DocsComponents.slot_table :if={@merged_slots != []} slots={@merged_slots} />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section title="Setup" id="setup">
                <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                  Generate the styled wrapper into your app with:
                </p>
                <DocsComponents.code_block code={@install_command} lang={:shell} />
                <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
                  The wrapper is intentionally thin: it declares the styled props, maps them
                  onto <code class="font-mono">data-*</code>
                  hooks, forwards <code class="font-mono">class</code>
                  and the base attributes, and delegates behavior to the headless component.
                  You own and can edit this code.
                </p>
              </DocsComponents.section>
            </section>
          </:panel>

          <:panel value="base">
            <section :if={@tab == "base"}>
              <DocsComponents.section :if={@base_overview} title="Overview" id="overview">
                <Markdown.markdown content={@base_overview} />
              </DocsComponents.section>

              <DocsComponents.section :if={@anatomy || @structure} title="Anatomy" id="anatomy">
                <Markdown.markdown :if={@anatomy && @anatomy[:body]} content={@anatomy[:body]} />
                <DocsComponents.anatomy :if={@anatomy} nodes={@anatomy.nodes} />
                <DocsComponents.code_block :if={!@anatomy && @structure} code={@structure} />
              </DocsComponents.section>

              <DocsComponents.section
                :if={@base_features != [] || @accessibility || @keyboard != []}
                title="Features"
                id="features"
              >
                <DocsComponents.features features={@base_features} />
                <DocsComponents.subsection
                  :if={@accessibility}
                  title="Accessibility"
                  id="accessibility"
                >
                  <Markdown.markdown content={@accessibility} />
                </DocsComponents.subsection>
                <DocsComponents.subsection :if={@keyboard != []} title="Keyboard" id="keyboard">
                  <DocsComponents.keyboard_table keyboard={@keyboard} />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section :if={@architecture} title="Architecture" id="architecture">
                <DocsComponents.architecture architecture={@architecture} />
              </DocsComponents.section>

              <DocsComponents.section :if={@structure} title="Structure" id="structure">
                <DocsComponents.code_block code={@structure} />
              </DocsComponents.section>

              <DocsComponents.section :if={@base_usage != []} title="Usage" id="usage">
                <DocsComponents.subsection
                  :for={section <- @base_usage}
                  title={section.title}
                  id={"usage-#{section.id}"}
                >
                  <Markdown.markdown :if={section[:body]} content={section.body} />
                  <CodeBlock.code
                    :if={section[:code]}
                    id={"base-usage-#{@active}-#{section.id}-code"}
                    code={section[:code]}
                    class="mt-3 rounded-lg"
                  />
                  <CodeBlock.code
                    :for={{flavor, index} <- Enum.with_index(section[:codes] || [])}
                    id={"base-usage-#{@active}-#{section.id}-#{index}-code"}
                    code={flavor[:code]}
                    lang={flavor[:lang] || :heex}
                    class="mt-3 rounded-lg"
                  />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section :if={@base_examples != []} title="Examples" id="examples">
                <DocsComponents.subsection
                  :for={example <- @base_examples}
                  title={example.title}
                  id={"example-#{@active}-#{example.id}"}
                >
                  <p :if={example[:description]} class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
                    {example[:description]}
                  </p>
                  <CodeBlock.code
                    :if={example[:code]}
                    id={"base-example-#{@active}-#{example.id}-code"}
                    code={example[:code]}
                    class="mt-3 rounded-lg"
                  />
                  <CodeBlock.code
                    :for={{flavor, index} <- Enum.with_index(example[:codes] || [])}
                    id={"base-example-#{@active}-#{example.id}-#{index}-code"}
                    code={flavor[:code]}
                    lang={flavor[:lang] || :heex}
                    class="mt-3 rounded-lg"
                  />
                </DocsComponents.subsection>
              </DocsComponents.section>

              <DocsComponents.section title="API reference" id="api">
                <DocsComponents.subsection title="Attributes" id="attributes">
                  <p :if={@base_attributes == []} class="mt-2 text-sm text-zinc-400">
                    No attributes documented.
                  </p>
                  <DocsComponents.attributes_table
                    :if={@base_attributes != []}
                    rows={@base_attributes}
                  />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="Slots" id="slots">
                  <p :if={@slots == []} class="mt-2 text-sm text-zinc-400">No slots documented.</p>
                  <DocsComponents.slot_table :if={@slots != []} slots={@slots} />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="Events" id="events">
                  <p :if={@events == []} class="mt-2 text-sm text-zinc-400">No events documented.</p>
                  <DocsComponents.events_table :if={@events != []} events={@events} />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="Data attributes" id="data-attributes">
                  <p :if={@parts == []} class="mt-2 text-sm text-zinc-400">
                    No data attributes documented.
                  </p>
                  <DocsComponents.parts_tables :if={@parts != []} parts={@parts} />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="CSS variables" id="css-variables">
                  <p :if={@css_vars == []} class="mt-2 text-sm text-zinc-400">
                    No runtime CSS variables documented.
                  </p>
                  <DocsComponents.css_vars_table :if={@css_vars != []} css_vars={@css_vars} />
                </DocsComponents.subsection>
              </DocsComponents.section>
            </section>
          </:panel>

          <:panel value="css">
            <section :if={@tab == "css"}>
              <DocsComponents.section
                :if={@css_contract}
                title="Styling contract"
                id="styling-contract"
              >
                <Markdown.markdown :if={@css_contract[:body]} content={@css_contract[:body]} />
              </DocsComponents.section>

              <DocsComponents.section title="Public CSS variables" id="css-variables">
                <p :if={@style_vars == []} class="mt-2 text-sm text-zinc-400">
                  This component has no public CSS variables. Its appearance is
                  controlled by its props and the surrounding theme.
                </p>
                <DocsComponents.css_vars_table
                  :if={@style_vars != []}
                  css_vars={@style_vars}
                  show_default={true}
                />
              </DocsComponents.section>

              <DocsComponents.section title="Selectors and state hooks" id="selectors">
                <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                  The styled theme targets the component through these hooks. The headless
                  base sets the same <code class="font-mono">data-*</code>
                  attributes, so the selectors work without the generated wrapper too.
                </p>
                <DocsComponents.selectors_table selectors={@css_selectors} />
              </DocsComponents.section>

              <DocsComponents.section title="Theme tokens" id="theme">
                <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                  This component reads these token namespaces:
                </p>
                <ul :if={@entry && @entry.tokens != []} class="mt-3 flex flex-wrap gap-2">
                  <li
                    :for={token <- @entry.tokens}
                    class="rounded-md bg-zinc-100 px-2 py-1 font-mono text-xs dark:bg-zinc-800"
                  >
                    --fl-{token}-*
                  </li>
                </ul>
                <p class="mt-3 text-sm text-zinc-500">
                  See <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
                  for tokens and custom themes. For the headless base, see
                  <.link navigate={~p"/getting-started/styling"} class="underline">Styling</.link>
                  and this component's Base tab.
                </p>
              </DocsComponents.section>

              <DocsComponents.section
                :if={@css_contract && @css_contract[:snippets] not in [nil, []]}
                title="Customization"
                id="customization"
              >
                <div :for={snippet <- @css_contract[:snippets]} class="mt-4">
                  <p class="text-sm font-medium">{snippet.title}</p>
                  <p :if={snippet[:body]} class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
                    {snippet[:body]}
                  </p>
                  <DocsComponents.code_block code={snippet.code} lang={snippet[:lang] || :css} />
                </div>
              </DocsComponents.section>
            </section>
          </:panel>
        </Components.tabs>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, previews: %{})}
  end

  @impl true
  def handle_event("preview_change", %{"preview_id" => id} = params, socket) do
    controls = Docs.controls(socket.assigns.active)

    props =
      Enum.reduce(controls, %{}, fn control, acc ->
        case Map.fetch(params, Atom.to_string(control.key)) do
          {:ok, value} -> Map.put(acc, control.key, coerce(control, value))
          :error -> acc
        end
      end)

    {:noreply, update_preview(socket, id, &Map.put(&1, :props, props))}
  end

  def handle_event("preview_code", %{"id" => id, "index" => index}, socket) do
    {:noreply, update_preview(socket, id, &Map.put(&1, :code_index, String.to_integer(index)))}
  end

  def handle_event("preview_view", %{"id" => id, "view" => view}, socket)
      when view in ~w(code source) do
    {:noreply, update_preview(socket, id, &Map.put(&1, :code_view, view))}
  end

  # Example previews are documentation, not app code. A rendered example may
  # carry a real `phx-click` (e.g. the button's destructive-confirm recipe), so
  # swallow any event it emits instead of crashing the page.
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"name" => name} = params, _uri, socket) do
    case find_component(name) do
      nil ->
        {:noreply, push_navigate(socket, to: ~p"/components")}

      component ->
        socket =
          if socket.assigns[:active] == component do
            socket
          else
            assign_component(socket, component)
          end

        tab = normalize_tab(params["tab"])

        socket =
          if socket.assigns[:tab] == tab do
            socket
          else
            assign(socket, tab: tab, previews: %{})
          end

        {:noreply, socket}
    end
  end

  defp assign_component(socket, name) do
    entry = FlintUI.Styled.get(name)
    attrs = FlintUI.Docs.attrs(name)
    slots = FlintUI.Docs.slots(name)

    assign(socket,
      active: name,
      page_title: Docs.title(name),
      title: Docs.title(name),
      subtitle: Docs.subtitle(name),
      links: Docs.links(name),
      meta: FlintUI.Docs.meta(name),
      slots: slots,
      parts: order_parts(FlintUI.Docs.parts_attrs(name)),
      events: FlintUI.Docs.events(name),
      keyboard: FlintUI.Docs.keyboard(name),
      css_vars: public_css_vars(FlintUI.Docs.css_vars(name)),
      entry: entry,
      styled_usage: Docs.styled_usage(name),
      base_usage: Docs.base_usage(name),
      styled_examples: Docs.styled_examples(name),
      base_examples: Docs.base_examples(name),
      css_contract: Docs.css(name),
      style_vars: if(entry, do: public_css_vars(entry.vars), else: []),
      css_selectors: css_selectors(entry),
      install_command: (entry && entry.install) || "mix flint.add #{name}",
      anatomy: Docs.anatomy(name),
      structure: Docs.structure(name),
      styled_attributes: styled_attribute_rows(attrs, entry),
      base_attributes: base_attribute_rows(attrs),
      merged_slots: merged_slots(slots, entry),
      accessibility: Docs.accessibility(name),
      styled_overview: Docs.styled_overview(name),
      base_overview: Docs.base_overview(name),
      styled_features: Docs.styled_features(name),
      base_features: Docs.base_features(name),
      architecture: Docs.architecture(name),
      previews: %{}
    )
  end

  defp update_preview(socket, id, fun) do
    current = Map.get(socket.assigns.previews, id, %{})
    assign(socket, :previews, Map.put(socket.assigns.previews, id, fun.(current)))
  end

  defp preview_state(previews, name, id, callback, opts) do
    source = Docs.source(name, callback, opts)

    previews
    |> Map.get(id, %{})
    |> Map.put(:source, source)
  end

  defp coerce(%{type: :number, default: default}, value) do
    case Integer.parse(to_string(value)) do
      {int, _} -> int
      :error -> default
    end
  end

  defp coerce(%{type: :boolean}, value), do: value in [true, "true", "on", "1"]
  defp coerce(_control, value), do: value

  defp find_component(name) do
    Enum.find(FlintUI.components(), &(Atom.to_string(&1) == name))
  end

  defp normalize_tab("base"), do: "base"
  defp normalize_tab("css"), do: "css"
  defp normalize_tab("styles"), do: "css"
  defp normalize_tab("styled"), do: "styled"
  defp normalize_tab("api"), do: "styled"
  defp normalize_tab(_), do: "styled"

  defp tab_variant(tab, value), do: if(tab == value, do: "solid", else: "outline")
  defp tab_depth(tab, value), do: if(tab == value, do: true, else: false)

  defp order_parts(parts) do
    Enum.sort_by(parts, fn {part, _} ->
      Enum.find_index(@part_order, &(&1 == part)) || length(@part_order)
    end)
  end

  defp base_attribute_rows(attrs) do
    attrs
    |> Enum.reject(&(&1.name in [:rest, :class]))
    |> Enum.map(&base_attribute_row/1)
    |> Enum.sort_by(& &1.name)
  end

  defp styled_attribute_rows(attrs, entry) do
    styled = if entry, do: Enum.map(entry.props, &styled_attribute_row/1), else: []
    Enum.sort_by(base_attribute_rows(attrs) ++ styled, & &1.name)
  end

  defp base_attribute_row(attr) do
    %{
      name: attr[:name],
      type: attr[:type],
      values: attr_values(attr),
      default: attr[:default],
      required: attr[:required] || false,
      doc: attr[:doc]
    }
  end

  defp styled_attribute_row(prop) do
    %{
      name: prop.name,
      type: if(FlintUI.Styled.Prop.boolean?(prop), do: :boolean, else: :string),
      values: prop.values,
      default: prop.default,
      required: false,
      doc: prop.doc
    }
  end

  defp attr_values(attr) do
    case attr[:opts] do
      opts when is_list(opts) -> Keyword.get(opts, :values)
      _ -> nil
    end
  end

  defp merged_slots(slots, entry) do
    extra = if entry, do: entry.slots, else: []
    slots ++ extra
  end

  defp public_css_vars(vars) do
    Enum.reject(vars, fn var -> String.starts_with?(var.name, "--_") end)
  end

  defp css_selectors(nil), do: []

  defp css_selectors(entry) do
    root = ~s([data-element="#{entry.name}"])

    prop_selectors =
      Enum.map(entry.props, fn prop ->
        %{
          selector: root <> ~s([#{FlintUI.Styled.Prop.attribute(prop)}]),
          description: "Targets this component by its #{prop.name} value."
        }
      end)

    part_selectors =
      entry.name
      |> FlintUI.Docs.parts_attrs()
      |> Map.keys()
      |> Enum.reject(&(&1 == :root))
      |> Enum.map(fn part ->
        %{
          selector: root <> ~s( [data-part="#{part}"]),
          description: "Targets the #{part} part."
        }
      end)

    [
      %{selector: root, description: "Targets the component root."}
      | prop_selectors ++ part_selectors
    ]
  end
end
