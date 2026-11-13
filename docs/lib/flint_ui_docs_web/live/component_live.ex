defmodule FlintUIDocsWeb.ComponentLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Markdown

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
          value={@tab}
          label="Component sections"
          variant="minimal"
          style="--fl-tabs-gap: 10px;"
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
            <section :if={@tab == "styled"} class="flex flex-col">
              <.doc_group
                :for={group <- @styled_groups}
                group={group}
                name={@active}
                previews={@previews}
              />

              <DocsComponents.section title="Setup" id="setup">
                <DocsComponents.content_paragraph class="mt-2">
                  Generate the styled wrapper into your app with:
                </DocsComponents.content_paragraph>
                <DocsComponents.code_block code={@install_command} lang={:shell} />
                <DocsComponents.content_paragraph class="mt-4">
                  The wrapper is intentionally thin: it declares the styled props, maps them
                  onto <code class="docs-code font-mono">data-*</code>
                  hooks, forwards <code class="docs-code font-mono">class</code>
                  and the base attributes, and delegates behavior to the headless component.
                  You own and can edit this code.
                </DocsComponents.content_paragraph>
              </DocsComponents.section>

              <DocsComponents.section title="API" id="api">
                <DocsComponents.content_paragraph class="mt-4">
                  The generated wrapper exposes these attributes and slots. Data attributes
                  and events are documented on the <.link
                    patch={~p"/components/#{@active}?tab=base#data-attributes"}
                    class="docs-link"
                  >
                Base tab
              </.link>; CSS variables and parts on the <.link
                    patch={~p"/components/#{@active}?tab=css"}
                    class="docs-link"
                  >
                CSS tab
              </.link>.
                </DocsComponents.content_paragraph>

                <DocsComponents.subsection title="Attributes" id="attributes">
                  <p :if={@styled_attributes == []} class="mt-2 text-sm text-muted">
                    No attributes documented.
                  </p>
                  <DocsComponents.attributes_table
                    :if={@styled_attributes != []}
                    rows={@styled_attributes}
                  />
                </DocsComponents.subsection>

                <DocsComponents.subsection title="Slots" id="slots">
                  <p :if={@merged_slots == []} class="mt-2 text-sm text-muted">
                    No slots documented.
                  </p>
                  <DocsComponents.slot_table :if={@merged_slots != []} slots={@merged_slots} />
                </DocsComponents.subsection>

                <DocsComponents.subsection
                  :if={@dependencies != []}
                  title="Dependencies"
                  id="dependencies"
                >
                  <p class="text-sm text-toned">
                    This component makes use of the following components as part of its implementation.
                  </p>
                  <DocsComponents.component_links components={@dependencies} />
                </DocsComponents.subsection>

                <DocsComponents.subsection
                  :if={@related != []}
                  title="Related"
                  id="related"
                >
                  <p class="text-sm text-toned">
                    Components that are commonly used or must be used with this one.
                  </p>
                  <DocsComponents.component_links components={@related} />
                </DocsComponents.subsection>
              </DocsComponents.section>
            </section>
          </:panel>

          <:panel value="base">
            <section :if={@tab == "base"}>
              <DocsComponents.section
                :for={group <- @base_groups}
                title={group.title}
                id={group.id}
              >
                <Markdown.prose :if={group[:body]} content={group.body} />

                <%= if group[:system] == :api do %>
                  <.base_api {assigns} />
                <% end %>

                <%= if group[:system] == :anatomy do %>
                  <Markdown.prose
                    :if={@anatomy && @anatomy[:body]}
                    content={@anatomy[:body]}
                  />
                  <DocsComponents.anatomy :if={@anatomy} nodes={@anatomy.nodes} />
                <% end %>

                <%= if group[:system] == :keyboard do %>
                  <DocsComponents.keyboard_table :if={@keyboard != []} keyboard={@keyboard} />
                <% end %>

                <.doc_section
                  :for={section <- group.sections}
                  section={section}
                  name={@active}
                  previews={@previews}
                  subsection?={true}
                />
              </DocsComponents.section>
            </section>
          </:panel>

          <:panel value="css">
            <section :if={@tab == "css"}>
              <.doc_group
                :for={group <- @css_before}
                group={group}
                name={@active}
                previews={@previews}
              />

              <DocsComponents.css_parts
                :if={@parts != []}
                id="css-parts"
                preview_id={"css-parts-#{@active}"}
                component={@active}
                parts={@parts}
                preview={@parts_preview}
              />

              <DocsComponents.section title="CSS Variables" id="css-variables">
                <p :if={@css_vars != []} class="mt-2 text-sm text-toned">
                  The styled layer exposes these <code class="docs-code font-mono">--fl-*</code>
                  CSS variables. Rows marked as runtime are values published by the component's JavaScript,
                  not inputs you set.
                </p>
                <p :if={@css_vars == []} class="mt-2 text-sm text-muted">
                  This component has no CSS variables. Its appearance is controlled
                  by its props and the surrounding theme.
                </p>
                <DocsComponents.css_vars_table
                  :if={@css_vars != []}
                  css_vars={@css_vars}
                  show_default={true}
                />
                <p class="mt-4 text-sm text-muted">
                  Theme tokens and scales are shared by every component; see <.link
                    navigate={~p"/guides/theming"}
                    class="docs-link"
                  >Theming</.link>.
                  For the headless layer, see <.link
                    navigate={~p"/getting-started/styling"}
                    class="docs-link"
                  >Styling</.link>.
                </p>
              </DocsComponents.section>

              <DocsComponents.section title="Selectors" id="selectors">
                <p class="mt-2 text-sm text-toned">
                  Root, prop, and state hooks. The styled theme targets the component
                  through these selectors. The headless base sets the same
                  <code class="docs-code font-mono">data-*</code>
                  attributes, so they work without the generated wrapper too. Part
                  selectors live in <.link href="#css-parts" class="docs-link">CSS Parts</.link>.
                </p>
                <p :if={@css_selectors == []} class="mt-2 text-sm text-muted">
                  This component has no styled selectors.
                </p>
                <DocsComponents.selectors_table
                  :if={@css_selectors != []}
                  selectors={@css_selectors}
                />
              </DocsComponents.section>

              <DocsComponents.section
                :if={@state_selectors != []}
                title="State Selectors"
                id="state-selectors"
              >
                <p class="mt-2 text-sm text-toned">
                  State is exposed as <code class="docs-code font-mono">data-*</code>
                  hooks, not a custom-element <code class="docs-code font-mono">:state()</code>
                  pseudo-class. Use these attribute selectors to target the component
                  while it is in a given state. The styled theme uses the same selectors,
                  and the headless base sets the same attributes.
                </p>
                <DocsComponents.states_table states={@state_selectors} />
              </DocsComponents.section>

              <.doc_group
                :for={group <- @css_after}
                group={group}
                name={@active}
                previews={@previews}
              />
            </section>
          </:panel>
        </Components.tabs>
      </div>
    </Layouts.app>
    """
  end

  ## Section rendering

  attr :group, :map, required: true
  attr :name, :atom, required: true
  attr :previews, :map, required: true

  defp doc_group(assigns) do
    first = List.first(assigns.group.sections)
    assigns = assign(assigns, subsections?: not is_nil(first[:group_title]))

    ~H"""
    <DocsComponents.section title={@group.title} id={@group.id}>
      <.doc_section
        :for={{section, index} <- Enum.with_index(@group.sections)}
        section={section}
        name={@name}
        previews={@previews}
        subsection?={index > 0 || @subsections?}
      />
    </DocsComponents.section>
    """
  end

  attr :section, :map, required: true
  attr :name, :atom, required: true
  attr :previews, :map, required: true
  attr :subsection?, :boolean, default: true

  defp doc_section(assigns) do
    section = assigns.section
    preview_id = Docs.preview_id(assigns.name, section)
    state = Map.get(assigns.previews, preview_id, %{})
    anchor = Docs.section_anchor(assigns.name, section)
    title = section[:title]

    rendered =
      Docs.render_section(assigns.name, section_assigns(assigns.name, section, preview_id, state))

    assigns = assign(assigns, rendered: rendered, anchor: anchor, title: title)

    ~H"""
    <DocsComponents.subsection :if={@subsection? && @title} title={@title} id={@anchor}>
      <.doc_section_content rendered={@rendered} />
    </DocsComponents.subsection>

    <div :if={@subsection? && !@title} id={@anchor} class="mt-8 scroll-mt-28">
      <.doc_section_content rendered={@rendered} />
    </div>

    <.doc_section_content :if={!@subsection?} rendered={@rendered} />
    """
  end

  attr :rendered, :any, required: true

  defp doc_section_content(assigns) do
    ~H"""
    <div :if={@rendered} class="text-toned text-pretty">
      {@rendered}
    </div>
    """
  end

  defp section_assigns(name, section, preview_id, state) do
    %{
      name: name,
      tab: Map.get(section, :tab, :styled),
      section: section.section,
      id: section[:id],
      title: section[:title],
      controls: section[:controls] || [],
      preview_id: preview_id,
      state: state,
      source: Docs.source(name, section.section, section[:id])
    }
  end

  ## Base API

  defp base_api(assigns) do
    ~H"""
    <DocsComponents.subsection title="Attributes" id="attributes">
      <p :if={@base_attributes == []} class="mt-2 text-sm text-muted">
        No attributes documented.
      </p>
      <DocsComponents.attributes_table :if={@base_attributes != []} rows={@base_attributes} />
    </DocsComponents.subsection>

    <DocsComponents.subsection title="Slots" id="slots">
      <p :if={@slots == []} class="mt-2 text-sm text-muted">
        No slots documented.
      </p>
      <DocsComponents.slot_table :if={@slots != []} slots={@slots} />
    </DocsComponents.subsection>

    <DocsComponents.subsection title="Events" id="events">
      <p :if={@events == []} class="mt-2 text-sm text-muted">
        No events documented.
      </p>
      <DocsComponents.events_table :if={@events != []} events={@events} />
    </DocsComponents.subsection>

    <DocsComponents.subsection title="Data Attributes" id="data-attributes">
      <p :if={@part_attrs == []} class="mt-2 text-sm text-muted">
        No data attributes documented.
      </p>
      <DocsComponents.parts_tables
        :if={@part_attrs != []}
        component_name={component_name(@active)}
        parts={@part_attrs}
      />
    </DocsComponents.subsection>
    """
  end

  ## Lifecycle

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, previews: %{})}
  end

  @impl true
  def handle_event("preview_change", %{"preview_id" => id} = params, socket) do
    controls = Map.get(socket.assigns.preview_controls, id, [])

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
    {css_before, css_after} = Docs.css_groups(name)

    assign(socket,
      active: name,
      page_title: Docs.title(name),
      title: Docs.title(name),
      subtitle: Docs.subtitle(name),
      links: Docs.links(name),
      meta: Docs.meta(name),
      slots: slots,
      parts: FlintUI.Docs.parts(name),
      part_attrs: FlintUI.Docs.parts_attrs(name),
      parts_preview: Docs.parts_demo(name, %{parts_id: "css-parts-#{name}"}),
      events: FlintUI.Docs.events(name),
      keyboard: FlintUI.Docs.keyboard(name),
      css_vars: css_var_rows(entry, name),
      css_selectors: css_selectors(entry),
      state_selectors: FlintUI.Docs.states(name),
      install_command: (entry && entry.install) || "mix flint.add #{name}",
      styled_attributes: styled_attribute_rows(attrs, entry),
      base_attributes: base_attribute_rows(attrs),
      merged_slots: FlintUI.Generator.wrapper_slots(name),
      related: component_links(FlintUI.Docs.related(name)),
      dependencies: component_links(FlintUI.Docs.dependencies(name)),
      anatomy: Docs.anatomy(name),
      styled_groups: Docs.groups(name, :styled),
      base_groups: Docs.base_groups(name),
      css_before: css_before,
      css_after: css_after,
      preview_controls: Docs.preview_controls(name),
      previews: %{}
    )
  end

  defp update_preview(socket, id, fun) do
    current = Map.get(socket.assigns.previews, id, %{})
    assign(socket, :previews, Map.put(socket.assigns.previews, id, fun.(current)))
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

  defp tab_variant(tab, value), do: if(tab == value, do: "solid", else: "surface")
  defp tab_depth(tab, value), do: if(tab == value, do: true, else: false)

  defp base_attribute_rows(attrs) do
    attrs
    |> Enum.reject(&(&1.name in [:rest, :class]))
    |> Enum.map(&base_attribute_row/1)
    |> Enum.sort_by(& &1.name)
  end

  defp styled_attribute_rows(attrs, entry) do
    styled = if entry, do: Enum.map(entry.props, &styled_attribute_row/1), else: []
    content = if entry, do: Enum.map(entry.content_attrs, &content_attribute_row/1), else: []
    Enum.sort_by(base_attribute_rows(attrs) ++ styled ++ content, & &1.name)
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
      number: prop.type == :any,
      default: prop.default,
      required: false,
      doc: prop.doc
    }
  end

  defp content_attribute_row(attr) do
    %{
      name: attr.name,
      type: attr.type,
      values: nil,
      default: attr.default,
      required: false,
      doc: attr.doc
    }
  end

  defp attr_values(attr) do
    case attr[:opts] do
      opts when is_list(opts) -> Keyword.get(opts, :values)
      _ -> nil
    end
  end

  defp css_var_rows(entry, name) do
    inputs =
      if entry do
        Enum.map(entry.vars, fn var ->
          %{
            name: var.name,
            default: var.default,
            description: var.doc,
            runtime: false
          }
        end)
      else
        []
      end

    runtime =
      Enum.map(FlintUI.Docs.css_vars(name), fn var ->
        %{
          name: var.name,
          default: nil,
          description: var.description,
          runtime: true
        }
      end)

    inputs ++ runtime
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

    attrs = FlintUI.Docs.parts_attrs(entry.name)

    state_selectors =
      attrs
      |> Keyword.get(:root, [])
      |> Enum.filter(&String.starts_with?(&1.name, "[data-"))
      |> Enum.reject(&(&1.name in ["[data-element]", "[data-part]"]))
      |> Enum.map(fn attr ->
        %{
          selector: root <> attr.name,
          description: "Targets the component when #{attr.name} is present."
        }
      end)

    [
      %{selector: root, description: "Targets the component root."}
      | prop_selectors ++ state_selectors
    ]
  end

  defp component_name(name) do
    name
    |> FlintUI.API.component_module()
    |> Module.split()
    |> List.last()
  end

  defp component_links(names) do
    Enum.map(names, fn name ->
      %{name: name, label: Docs.title(name), path: "/components/#{name}"}
    end)
  end
end
