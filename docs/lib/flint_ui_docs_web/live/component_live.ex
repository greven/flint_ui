defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.ComponentDocs
  alias FlintUIDocsWeb.DocBlocks
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
            id="tab-docs"
            role="tab"
            aria-selected={to_string(@tab == "docs")}
            aria-controls="panel-docs"
            class={tab_class(@tab == "docs")}
          >
            Docs
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
            patch={~p"/components/#{@active}?tab=styles"}
            id="tab-styles"
            role="tab"
            aria-selected={to_string(@tab == "styles")}
            aria-controls="panel-styles"
            class={tab_class(@tab == "styles")}
          >
            Styles
          </.link>
        </div>

        <section
          :if={@tab == "docs"}
          id="panel-docs"
          role="tabpanel"
          aria-labelledby="tab-docs"
          tabindex="0"
        >
          <DocBlocks.section title="Usage" id="usage">
            <PreviewComponent.preview
              id={"playground-#{@active}"}
              kind={:playground}
              layer={:styled}
              name={@active}
              controls={@controls}
              defaults={@defaults}
            />

            <DocBlocks.subsection
              :for={section <- @usage}
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
                preview={section[:preview] != false}
              />
            </DocBlocks.subsection>
          </DocBlocks.section>

          <DocBlocks.section :if={@examples != []} title="Examples" id="examples">
            <PreviewComponent.preview
              :for={example <- @examples}
              id={"example-#{@active}-#{example.id}"}
              kind={:block}
              name={@active}
              block={example.id}
              code={example[:code]}
              codes={example[:codes]}
              title={example.title}
              description={example[:description]}
              preview={example[:preview] != false}
            />
          </DocBlocks.section>

          <DocBlocks.section title="API reference" id="api">
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

            <DocBlocks.subsection title="Attributes" id="attributes">
              <p :if={@attribute_rows == []} class="mt-2 text-sm text-zinc-400">
                No attributes documented.
              </p>
              <DocBlocks.attributes_table
                :if={@attribute_rows != []}
                rows={@attribute_rows}
              />
            </DocBlocks.subsection>

            <DocBlocks.subsection title="Slots" id="slots">
              <p :if={@merged_slots == []} class="mt-2 text-sm text-zinc-400">
                No slots documented.
              </p>
              <DocBlocks.slot_table :if={@merged_slots != []} slots={@merged_slots} />
            </DocBlocks.subsection>

            <DocBlocks.subsection title="Events" id="events">
              <p :if={@events == []} class="mt-2 text-sm text-zinc-400">No events documented.</p>
              <DocBlocks.events_table :if={@events != []} events={@events} />
            </DocBlocks.subsection>
          </DocBlocks.section>

          <DocBlocks.section title="Changelog" id="changelog">
            <p class="mt-2 text-sm text-zinc-500">
              Release notes for this component are coming soon.
            </p>
          </DocBlocks.section>
        </section>

        <section
          :if={@tab == "base"}
          id="panel-base"
          role="tabpanel"
          aria-labelledby="tab-base"
          tabindex="0"
        >
          <DocBlocks.section :if={@anatomy || @structure} title="Anatomy" id="anatomy">
            <Markdown.markdown :if={@anatomy && @anatomy[:body]} content={@anatomy[:body]} />
            <DocBlocks.anatomy :if={@anatomy} nodes={@anatomy.nodes} />
            <DocBlocks.code_block :if={!@anatomy && @structure} code={@structure} />
          </DocBlocks.section>

          <DocBlocks.section title="Usage" id="usage">
            <PreviewComponent.preview
              id={"playground-#{@active}"}
              kind={:playground}
              layer={:base}
              name={@active}
              controls={[]}
              defaults={@defaults}
            />

            <DocBlocks.subsection
              :for={section <- @base_usage}
              title={section.title}
              id={"usage-#{section.id}"}
            >
              <Markdown.markdown :if={section[:body]} content={section.body} />
              <PreviewComponent.preview
                id={"usage-#{@active}-#{section.id}"}
                kind={:usage}
                layer={:base}
                name={@active}
                block={section.id}
                code={section[:code]}
                codes={section[:codes]}
                preview={section[:preview] != false}
              />
            </DocBlocks.subsection>
          </DocBlocks.section>

          <DocBlocks.section
            :if={@accessibility || @keyboard != []}
            title="Accessibility"
            id="accessibility"
          >
            <Markdown.markdown :if={@accessibility} content={@accessibility} />
            <DocBlocks.subsection :if={@keyboard != []} title="Keyboard" id="keyboard">
              <DocBlocks.keyboard_table keyboard={@keyboard} />
            </DocBlocks.subsection>
          </DocBlocks.section>

          <DocBlocks.section title="API reference" id="api">
            <DocBlocks.subsection title="Attributes" id="attributes">
              <p :if={@attrs == []} class="mt-2 text-sm text-zinc-400">No attributes documented.</p>
              <DocBlocks.attr_table :if={@attrs != []} attrs={@attrs} />
            </DocBlocks.subsection>

            <DocBlocks.subsection title="Slots" id="slots">
              <p :if={@slots == []} class="mt-2 text-sm text-zinc-400">No slots documented.</p>
              <DocBlocks.slot_table :if={@slots != []} slots={@slots} />
            </DocBlocks.subsection>

            <DocBlocks.subsection title="Events" id="events">
              <p :if={@events == []} class="mt-2 text-sm text-zinc-400">No events documented.</p>
              <DocBlocks.events_table :if={@events != []} events={@events} />
            </DocBlocks.subsection>

            <DocBlocks.subsection title="Data attributes" id="data-attributes">
              <p :if={@parts == []} class="mt-2 text-sm text-zinc-400">
                No data attributes documented.
              </p>
              <DocBlocks.parts_tables :if={@parts != []} parts={@parts} />
            </DocBlocks.subsection>
          </DocBlocks.section>
        </section>

        <section
          :if={@tab == "styles"}
          id="panel-styles"
          role="tabpanel"
          aria-labelledby="tab-styles"
          tabindex="0"
        >
          <DocBlocks.section title="Theme" id="theme">
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
              for tokens and custom themes, or
              <.link navigate={~p"/getting-started/styling"} class="underline">Styling</.link>
              to style the headless base.
            </p>
          </DocBlocks.section>

          <DocBlocks.section title="CSS variables" id="css-variables">
            <p :if={@css_vars == []} class="mt-2 text-sm text-zinc-400">
              No CSS variables documented.
            </p>
            <DocBlocks.css_vars_table :if={@css_vars != []} css_vars={@css_vars} />
          </DocBlocks.section>
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
      usage: ComponentDocs.usage(name),
      base_usage: ComponentDocs.base_usage(name),
      examples: ComponentDocs.examples(name),
      anatomy: ComponentDocs.anatomy(name),
      structure: ComponentDocs.structure(name),
      attribute_rows: attribute_rows(attrs, entry),
      merged_slots: merged_slots(slots, entry),
      accessibility: ComponentDocs.accessibility(name),
      controls: ComponentDocs.controls(name),
      defaults: ComponentDocs.defaults(name)
    )
  end

  defp find_component(name) do
    Enum.find(FlintUI.components(), &(Atom.to_string(&1) == name))
  end

  defp normalize_tab("base"), do: "base"
  defp normalize_tab("styles"), do: "styles"
  defp normalize_tab(_), do: "docs"

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
          doc: attr[:doc]
        }
      end)

    styled = if entry, do: Enum.map(entry.props, &styled_attribute_row/1), else: []

    base ++ styled
  end

  defp styled_attribute_row(prop) do
    %{
      name: prop.name,
      type: :atom,
      values: prop.values,
      default: prop.default,
      data: FlintUI.Styled.Prop.attribute(prop),
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

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
