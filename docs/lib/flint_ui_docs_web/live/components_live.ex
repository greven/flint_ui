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
          Accessible, unstyled UI components for Phoenix LiveView. Bring your own styles.
        </p>

        <section :for={group <- @groups} id={"components-#{group.type}"} class="mt-10 first:mt-8">
          <h2 class="text-xl font-semibold tracking-tight">{group.label}</h2>
          <%!-- Preview grid placeholder; component thumbnails land here. --%>
          <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3" />
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    groups =
      FlintUI.Docs.grouped_components()
      |> Enum.map(fn {type, _components} ->
        %{type: type, label: FlintUIDocsWeb.Nav.type_label(type)}
      end)

    {:ok, assign(socket, groups: groups, page_title: "Components")}
  end
end
