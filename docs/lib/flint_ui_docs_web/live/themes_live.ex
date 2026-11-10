defmodule FlintUIDocsWeb.ThemesLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Themes")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} page={:themes}>
      <div class="mx-auto max-w-2xl py-10">
        <DocsComponents.page_header title="Themes">
          <:description>
            A visual theme editor is on the way. For now, the
            <.link navigate={~p"/guides/theming"} class="docs-link">Theming guide</.link>
            covers tokens, presets, and full color scales.
          </:description>
        </DocsComponents.page_header>
      </div>
    </Layouts.app>
    """
  end
end
