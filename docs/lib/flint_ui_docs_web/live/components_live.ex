defmodule FlintUIDocsWeb.ComponentsLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:components}>
      <div class="max-w-5xl">
        <h1 class="text-3xl font-semibold tracking-tight">Components</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          Accessible components for Phoenix LiveView, with a headless base and a
          generated styled layer you own.
        </p>

        <section :for={group <- @groups} id={"components-#{group.type}"} class="mt-10 first:mt-8">
          <h2 data-toc="section" class="text-xl font-semibold tracking-tight">{group.label}</h2>
          <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <.link
              :for={component <- group.components}
              navigate={~p"/components/#{component.name}"}
              class="group flex flex-col rounded-lg border border-zinc-200 p-5 transition-colors hover:border-zinc-300 hover:bg-zinc-50 dark:border-zinc-800 dark:hover:border-zinc-700 dark:hover:bg-zinc-900"
            >
              <div class="flex items-center justify-between gap-3">
                <span class="font-medium">{component.label}</span>
                <span class="rounded-full border border-zinc-200 px-2 py-0.5 text-xs text-zinc-500 dark:border-zinc-800 dark:text-zinc-400">
                  {to_string(component.meta.status)}
                </span>
              </div>
              <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                {component.description || "Accessible, unstyled component."}
              </p>
              <span class="mt-4 text-sm font-medium text-zinc-500 group-hover:text-zinc-900 dark:text-zinc-400 dark:group-hover:text-zinc-100">
                View docs
              </span>
            </.link>
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
