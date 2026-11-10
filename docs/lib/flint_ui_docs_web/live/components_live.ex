defmodule FlintUIDocsWeb.ComponentsLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:components}>
      <div class="max-w-5xl">
        <DocsComponents.page_header
          title="Components"
          subtitle="Accessible components for Phoenix LiveView, with a headless base and a generated styled layer you own."
        />

        <section :for={group <- @groups} id={"components-#{group.type}"} class="mt-10">
          <h2 data-toc="section" class="text-xl font-semibold tracking-tight">
            <DocsComponents.heading_link
              title={group.label}
              id={"components-#{group.type}"}
            />
          </h2>
          <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <Components.card
              :for={component <- group.components}
              navigate={~p"/components/#{component.name}"}
              title_id={"component-#{component.name}"}
              spacing="sm"
              class="group h-full"
            >
              <:title>{component.label}</:title>
              <:description>
                {component.description || "Accessible, unstyled component."}
              </:description>
              <:header_actions>
                <DocsComponents.status_badge status={component.meta.status} />
              </:header_actions>
              <span class="text-sm font-medium text-muted group-hover:text-default">
                View docs
              </span>
            </Components.card>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    groups =
      FlintUI.Docs.grouped_components()
      |> Enum.map(fn {type, names} ->
        %{
          type: type,
          label: FlintUIDocsWeb.Nav.type_label(type),
          components:
            Enum.map(names, fn name ->
              %{
                name: name,
                label: humanize(name),
                description: FlintUI.Docs.description(name),
                meta: FlintUI.Docs.meta(name)
              }
            end)
        }
      end)

    {:ok, assign(socket, groups: groups, page_title: "Components")}
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
