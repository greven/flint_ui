defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocBlocks
  alias FlintUIDocsWeb.Examples
  alias FlintUIDocsWeb.Markdown

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
            id="tab-base"
            role="tab"
            aria-selected={to_string(@tab == "base")}
            aria-controls="panel-base"
            class={tab_class(@tab == "base")}
          >
            Base
          </.link>
          <.link
            patch={~p"/components/#{@active}?tab=styled"}
            id="tab-styled"
            role="tab"
            aria-selected={to_string(@tab == "styled")}
            aria-controls="panel-styled"
            class={tab_class(@tab == "styled")}
          >
            Styled
          </.link>
          <.link
            patch={~p"/components/#{@active}?tab=api"}
            id="tab-api"
            role="tab"
            aria-selected={to_string(@tab == "api")}
            aria-controls="panel-api"
            class={tab_class(@tab == "api")}
          >
            API
          </.link>
        </div>

        <section
          :if={@tab == "base"}
          id="panel-base"
          role="tabpanel"
          aria-labelledby="tab-base"
          tabindex="0"
        >
          <DocBlocks.section title="Preview" id="preview">
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
          </DocBlocks.section>

          <DocBlocks.section title="Usage" id="usage">
            <DocBlocks.subsection :if={@structure} title="Anatomy" id="structure">
              <DocBlocks.code_block code={@structure} />
            </DocBlocks.subsection>

            <DocBlocks.subsection
              :for={section <- @usage}
              title={section.title}
              id={to_string(section.id)}
            >
              <Markdown.markdown :if={section[:body]} content={section.body} />
              <DocBlocks.code_block :if={section[:code]} code={section[:code]} />
            </DocBlocks.subsection>

            <DocBlocks.subsection :if={@accessibility} title="Accessibility" id="accessibility">
              <Markdown.markdown content={@accessibility} />
            </DocBlocks.subsection>

            <DocBlocks.subsection :if={@keyboard != []} title="Keyboard" id="keyboard">
              <DocBlocks.keyboard_table keyboard={@keyboard} />
            </DocBlocks.subsection>
          </DocBlocks.section>

          <DocBlocks.section :if={@examples != []} title="Examples" id="examples">
            <DocBlocks.example
              :for={example <- @examples}
              title={example.title}
              description={example[:description]}
              code={example[:code]}
            >
              {Examples.render_block(%{
                name: @active,
                block: example.id,
                props: @props,
                id: "example-#{@active}-#{example.id}"
              })}
            </DocBlocks.example>
          </DocBlocks.section>

          <DocBlocks.section :if={@styling} title="Styling the base" id="styling">
            <Markdown.markdown :if={@styling.body} content={@styling.body} />
            <DocBlocks.subsection :for={snippet <- @styling.snippets} title={snippet.title}>
              <DocBlocks.code_block code={snippet.code} />
            </DocBlocks.subsection>
            <p class="mt-6 text-sm text-zinc-500">
              The generated component on the
              <.link
                patch={~p"/components/#{@active}?tab=styled"}
                class="underline"
              >
                Styled
              </.link>
              tab ships an opinionated theme; see
              <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
              for the tokens it reads. The full data-attribute contract is under the
              <span class="font-medium">API</span>
              tab.
            </p>
          </DocBlocks.section>
        </section>

        <section
          :if={@tab == "api"}
          id="panel-api"
          role="tabpanel"
          aria-labelledby="tab-api"
          tabindex="0"
        >
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

            <DocBlocks.subsection title="CSS variables" id="css-variables">
              <p :if={@css_vars == []} class="mt-2 text-sm text-zinc-400">
                No CSS variables documented.
              </p>
              <DocBlocks.css_vars_table :if={@css_vars != []} css_vars={@css_vars} />
            </DocBlocks.subsection>

            <DocBlocks.subsection
              :if={@entry && @entry.props != []}
              title="Styled attributes"
              id="styled-attributes"
            >
              <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                Added by the generated styled component
                (<code>mix flint.add {@active}</code>) on top of the base attributes.
                Each attribute maps onto the data attribute the theme targets.
              </p>
              <DocBlocks.prop_table props={@entry.props} hooks={FlintUI.Styled.Entry.hooks(@entry)} />
            </DocBlocks.subsection>

            <DocBlocks.subsection
              :if={@entry && @entry.slots != []}
              title="Styled slots"
              id="styled-slots"
            >
              <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                Added by the generated styled component
                (<code>mix flint.add {@active}</code>) on top of the base slots.
              </p>
              <DocBlocks.slot_table slots={@entry.slots} />
            </DocBlocks.subsection>
          </DocBlocks.section>
        </section>

        <section
          :if={@tab == "styled"}
          id="panel-styled"
          role="tabpanel"
          aria-labelledby="tab-styled"
          tabindex="0"
        >
          <DocBlocks.section title="Generated component" id="styled">
            <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
              Beyond the headless component, FlintUI generates a styled wrapper into your
              app, so you own and can edit it. Styling is framework-agnostic and lives in <code>flint.css</code>.
            </p>

            <DocBlocks.code_block :if={@entry} code={@entry.install} />

            <DocBlocks.subsection :if={@styled} title="Preview" id="styled-preview">
              <p :if={@styled[:description]} class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                {@styled[:description]}
              </p>
              <div class="mt-4 rounded-lg border border-dashed border-zinc-300 bg-zinc-50 p-6 dark:border-zinc-700 dark:bg-zinc-900/40">
                {Examples.render_styled(%{name: @active, props: @props, id: "styled-preview"})}
              </div>
              <DocBlocks.code_block :if={@styled[:code]} code={@styled[:code]} />
            </DocBlocks.subsection>

            <DocBlocks.subsection
              :if={@entry && @entry.tokens != []}
              title="Theme tokens"
              id="styled-tokens"
            >
              <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                This component reads these token namespaces:
              </p>
              <ul class="mt-3 flex flex-wrap gap-2">
                <li
                  :for={token <- @entry.tokens}
                  class="rounded-md bg-zinc-100 px-2 py-1 font-mono text-xs dark:bg-zinc-800"
                >
                  --fl-{token}-*
                </li>
              </ul>
            </DocBlocks.subsection>

            <p class="mt-6 text-sm text-zinc-500">
              See <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
              for tokens and custom themes, or
              <.link navigate={~p"/getting-started/installation"} class="underline">e">
                Installation</.link>
              to install the styled layer.
            </p>
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
      usage: Examples.usage(name),
      examples: Examples.examples(name),
      styling: Examples.styling(name),
      styled: Examples.styled(name),
      entry: FlintUI.Styled.get(name),
      accessibility: Examples.accessibility(name),
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

  defp normalize_tab("api"), do: "api"
  defp normalize_tab("styled"), do: "styled"
  defp normalize_tab(_), do: "base"

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

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
