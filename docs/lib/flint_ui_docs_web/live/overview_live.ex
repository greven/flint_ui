defmodule FlintUIDocsWeb.OverviewLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={nil}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">FlintUI</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          Accessible, unstyled UI components for Phoenix LiveView. Bring your own styles.
        </p>

        <div class="mt-8 grid gap-4 sm:grid-cols-2">
          <.link
            :for={component <- @components}
            navigate={~p"/components/#{component.name}"}
            class="group rounded-lg border border-zinc-200 p-4 transition-colors hover:border-zinc-300 hover:bg-zinc-50 dark:border-zinc-800 dark:hover:border-zinc-700 dark:hover:bg-zinc-900"
          >
            <div class="flex items-center justify-between">
              <span class="font-medium capitalize">{component.name}</span>
              <span class="text-xs text-zinc-400">{component.meta.status}</span>
            </div>
            <p class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
              {component.description}
            </p>
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    components =
      FlintUI.components()
      |> Enum.sort()
      |> Enum.map(fn name ->
        %{
          name: name,
          meta: FlintUI.Docs.meta(name),
          description: FlintUI.Docs.description(name)
        }
      end)

    {:ok, assign(socket, components: components, page_title: "Overview")}
  end
end
