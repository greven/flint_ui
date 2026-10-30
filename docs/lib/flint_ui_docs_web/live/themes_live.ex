defmodule FlintUIDocsWeb.ThemesLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Themes")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:themes}>
      <div class="mx-auto max-w-2xl py-10">
        <h1 class="text-3xl font-semibold tracking-tight">Themes</h1>
        <p class="mt-3 text-default">
          A visual theme editor is on the way. For now, the
          <.link navigate={~p"/guides/theming"} class="underline">Theming guide</.link>
          covers tokens, presets, and full color scales.
        </p>
      </div>
    </Layouts.app>
    """
  end
end
