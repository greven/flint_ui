defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.CodeBlock
  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Markdown
  alias FlintUIDocsWeb.PreviewComponent

  @part_order [:root, :trigger, :content]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={@active} section={:components}>
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

        <div
          role="tablist"
          aria-label="Component sections"
          class="mt-8 flex gap-1 border-b border-zinc-200 dark:border-zinc-800"
        >
          <.link
            patch={~p"/components/#{@active}"}
            id="tab-styled"
            role="tab"
            aria-selected={to_string(@tab == "styled")}
            aria-controls="panel-styled"
            class={tab_class(@tab == "styled")}
          >
            Styled
          </.link>
          <.link
            patch={~p"/components/#{@active}?tab=base"}
            id="tab-base"
            role="tab"
            aria-selected={to_string(@tab == "base")}
            aria-controls="panel-base"
            class={tab_class(@tab == "base")}
          >
            Base
          </.link>
          <.link
            patch={~p"/components/#{@active}?tab=css"}
            id="tab-css"
            role="tab"
            aria-selected={to_string(@tab == "css")}
            aria-controls="panel-css"
            class={tab_class(@tab == "css")}
          >
            CSS
          </.link>
        </div>

        <section
          :if={@tab == "styled"}
          class="flex flex-col gap-16"
          id="panel-styled"
          role="tabpanel"
          aria-labelledby="tab-styled"
          tabindex="0"
        >
          <DocsComponents.section title="Usage" id="usage" class="mt-12">
            <PreviewComponent.preview
              id={"playground-#{@active}"}
              kind={:playground}
              layer={:styled}
              name={@active}
              controls={@controls}
              defaults={@defaults}
              class="mt-6"
            />

            <DocsComponents.subsection
              :for={section <- @styled_usage}
              title={section.title}
              id={"usage-#{section.id}"}
            >
              <Markdown.markdown :if={section[:body]} content={section.body} />
              <PreviewComponent.preview
                id={"usage-#{@active}-#{section.id}"}
                kind={:usage}
                layer={:styled}
                name={@active}
                block={section.id}
                code={section[:code]}
                codes={section[:codes]}
                preview_only={section[:preview_only] == true}
              />
            </DocsComponents.subsection>
          </DocsComponents.section>

          <DocsComponents.section :if={@base_usage != []} title="Base behavior" id="base-behavior">
            <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
              The generated component inherits these attributes from its headless
              base. Their behavior and accessible semantics are documented on the
              Base tab rather than repeated here.
            </p>
            <ul class="mt-3 flex flex-wrap gap-2">
              <li :for={section <- @base_usage}>
                <.link
                  patch={"#{~p"/components/#{@active}?tab=base"}#usage-#{section.id}"}
                  class="rounded-md border border-zinc-200 px-2.5 py-1 text-sm transition-colors hover:bg-zinc-50 dark:border-zinc-800 dark:hover:bg-zinc-900"
                >
                  {section.title}
                </.link>
              </li>
            </ul>
          </DocsComponents.section>

          <DocsComponents.section :if={@styled_examples != []} title="Examples" id="examples">
            <PreviewComponent.preview
              :for={example <- @styled_examples}
              id={"example-#{@active}-#{example.id}"}
              kind={:block}
              layer={:styled}
              name={@active}
              block={example.id}
              code={example[:code]}
              codes={example[:codes]}
              title={example.title}
              description={example[:description]}
              preview_only={example[:preview_only] == true}
            />
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
            <DocsComponents.code_block code={@wrapper_source} lang={:elixir} />
          </DocsComponents.section>

          <DocsComponents.section title="API Reference" id="api">
            <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
              The <code class="font-mono">data-*</code>
              hooks this component sets on its rendered markup are listed under
              <.link
                patch={"#{~p"/components/#{@active}?tab=base"}#data-attributes"}
                class="underline"
              >
                Data attributes
              </.link>
              on the Base tab.
            </p>

            <DocsComponents.subsection title="Attributes" id="attributes">
              <p :if={@attribute_rows == []} class="mt-2 text-sm text-zinc-400">
                No attributes documented.
              </p>
              <DocsComponents.attributes_table
                :if={@attribute_rows != []}
                rows={@attribute_rows}
              />
            </DocsComponents.subsection>

            <DocsComponents.subsection title="Slots" id="slots">
              <p :if={@merged_slots == []} class="mt-2 text-sm text-zinc-400">
                No slots documented.
              </p>
              <DocsComponents.slot_table :if={@merged_slots != []} slots={@merged_slots} />
            </DocsComponents.subsection>

            <DocsComponents.subsection title="Events" id="events">
              <p :if={@events == []} class="mt-2 text-sm text-zinc-400">No events documented.</p>
              <DocsComponents.events_table :if={@events != []} events={@events} />
            </DocsComponents.subsection>
          </DocsComponents.section>
        </section>

        <section
          :if={@tab == "base"}
          id="panel-base"
          role="tabpanel"
          aria-labelledby="tab-base"
          tabindex="0"
        >
          <div class="mt-6 rounded-lg border border-zinc-200 bg-zinc-50 p-4 dark:border-zinc-800 dark:bg-zinc-900/40">
            <p class="text-sm font-medium text-zinc-900 dark:text-zinc-100">
              These components are headless.
            </p>
            <p class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
              The examples below show the accessible markup and attribute contract,
              without styling or live previews. For an interactive demo, use the
              <.link patch={~p"/components/#{@active}"} class="font-medium underline">
                Styled
              </.link>
              tab.
            </p>
          </div>

          <DocsComponents.section :if={@anatomy || @structure} title="Anatomy" id="anatomy">
            <Markdown.markdown :if={@anatomy && @anatomy[:body]} content={@anatomy[:body]} />
            <DocsComponents.anatomy :if={@anatomy} nodes={@anatomy.nodes} />
            <DocsComponents.code_block :if={!@anatomy && @structure} code={@structure} />
          </DocsComponents.section>

          <DocsComponents.section title="Usage" id="usage">
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

          <DocsComponents.section
            :if={@accessibility || @keyboard != []}
            title="Accessibility"
            id="accessibility"
          >
            <Markdown.markdown :if={@accessibility} content={@accessibility} />
            <DocsComponents.subsection :if={@keyboard != []} title="Keyboard" id="keyboard">
              <DocsComponents.keyboard_table keyboard={@keyboard} />
            </DocsComponents.subsection>
          </DocsComponents.section>

          <DocsComponents.section title="API reference" id="api">
            <DocsComponents.subsection title="Attributes" id="attributes">
              <p :if={@attrs == []} class="mt-2 text-sm text-zinc-400">No attributes documented.</p>
              <DocsComponents.attr_table :if={@attrs != []} attrs={@attrs} />
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

        <section
          :if={@tab == "css"}
          id="panel-css"
          role="tabpanel"
          aria-labelledby="tab-css"
          tabindex="0"
        >
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
            <DocsComponents.css_vars_table :if={@style_vars != []} css_vars={@style_vars} />
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
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
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

        {:noreply, assign(socket, :tab, normalize_tab(params["tab"]))}
    end
  end

  defp assign_component(socket, name) do
    entry = FlintUI.Styled.get(name)
    attrs = FlintUI.Docs.attrs(name)
    slots = FlintUI.Docs.slots(name)

    assign(socket,
      active: name,
      page_title: humanize(name),
      description: FlintUI.Docs.description(name),
      meta: FlintUI.Docs.meta(name),
      attrs: attrs,
      slots: slots,
      parts: order_parts(FlintUI.Docs.parts_attrs(name)),
      events: FlintUI.Docs.events(name),
      keyboard: FlintUI.Docs.keyboard(name),
      css_vars: FlintUI.Docs.css_vars(name),
      entry: entry,
      styled_usage: Docs.styled_usage(name),
      base_usage: Docs.base_usage(name),
      styled_examples: Docs.styled_examples(name),
      base_examples: Docs.base_examples(name),
      css_contract: Docs.css(name),
      style_vars: if(entry, do: entry.vars, else: []),
      css_selectors: css_selectors(entry),
      install_command: (entry && entry.install) || "mix flint.add #{name}",
      wrapper_source: FlintUI.Generator.component_source(name),
      anatomy: Docs.anatomy(name),
      structure: Docs.structure(name),
      attribute_rows: attribute_rows(attrs, entry),
      merged_slots: merged_slots(slots, entry),
      accessibility: Docs.accessibility(name),
      controls: playground_controls(name),
      defaults: Docs.defaults(name)
    )
  end

  defp playground_controls(name) do
    controls = Docs.controls(name)

    case Docs.playground_controls(name) do
      nil -> controls
      keys -> Enum.filter(controls, &(&1.key in keys))
    end
  end

  defp find_component(name) do
    Enum.find(FlintUI.components(), &(Atom.to_string(&1) == name))
  end

  defp normalize_tab("base"), do: "base"
  defp normalize_tab("css"), do: "css"
  defp normalize_tab("styles"), do: "css"
  defp normalize_tab("styled"), do: "styled"
  defp normalize_tab("api"), do: "styled"
  defp normalize_tab(_), do: "styled"

  defp tab_class(true) do
    "-mb-px border-b-2 border-zinc-900 px-3 pb-2 text-sm font-medium text-zinc-900 dark:border-white dark:text-white"
  end

  defp tab_class(false) do
    "-mb-px border-b-2 border-transparent px-3 pb-2 text-sm text-zinc-500 transition-colors hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
  end

  defp order_parts(parts) do
    Enum.sort_by(parts, fn {part, _} ->
      Enum.find_index(@part_order, &(&1 == part)) || length(@part_order)
    end)
  end

  defp attribute_rows(attrs, entry) do
    base =
      Enum.map(attrs, fn attr ->
        %{
          name: attr[:name],
          type: attr[:type],
          values: attr_values(attr),
          default: attr[:default],
          data: nil,
          required: attr[:required],
          layer: :base,
          doc: attr[:doc]
        }
      end)

    styled = if entry, do: Enum.map(entry.props, &styled_attribute_row/1), else: []

    base ++ styled
  end

  defp styled_attribute_row(prop) do
    %{
      name: prop.name,
      type: if(FlintUI.Styled.Prop.boolean?(prop), do: :boolean, else: :string),
      values: prop.values,
      default: prop.default,
      data: FlintUI.Styled.Prop.attribute(prop),
      required: false,
      layer: :styled,
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

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
