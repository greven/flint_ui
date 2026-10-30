defmodule FlintUIDocsWeb.IntroductionLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Introduction")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:getting_started} page={:introduction}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Introduction</h1>
        <p class="mt-3 text-soft">
          FlintUI gives Phoenix LiveView the two layers modern component libraries ship:
          a headless base you import, and a styled layer you generate into your own app
          and own outright.
        </p>

        <DocsComponents.section title="Headless base" id="base">
          <p class="text-sm text-soft">
            Base components (<code class="font-mono">FlintUI.button/1</code>, …) are
            accessible and unstyled. They render semantic markup with the ARIA roles,
            states, and keyboard behavior the pattern requires, and forward the rest of
            your attributes. Styling is entirely up to you.
          </p>
          <DocsComponents.code_block code={snippet(:base)} />
        </DocsComponents.section>

        <DocsComponents.section title="Styled layer" id="styled">
          <p class="text-sm text-soft">
            Prefer a starting point? Generate a styled wrapper into your app. It stays
            thin — it declares a few presentational attributes, maps them onto
            <code class="font-mono">data-*</code>
            hooks, and delegates behavior to the base. Adjust or delete it freely; you
            own the code.
          </p>
          <DocsComponents.code_block code={snippet(:styled)} />
        </DocsComponents.section>

        <DocsComponents.section title="Framework-agnostic theming" id="theming">
          <p class="text-sm text-soft">
            The theme is plain CSS built from prefixed <code class="font-mono">--fl-*</code>
            tokens, with automatic light and dark support. Tailwind is optional — map the
            tokens onto utilities only if you want to.
          </p>
        </DocsComponents.section>

        <p class="mt-8 text-sm text-muted">
          Next: <.link navigate="/getting-started/installation" class="underline">
            install FlintUI
          </.link>, or jump straight to the <.link
            navigate="/components"
            class="underline"
          >components</.link>.
        </p>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:base) do
    """
    <FlintUI.button class="my-button" phx-click="save">Save</FlintUI.button>
    """
  end

  defp snippet(:styled) do
    """
    <.button variant="solid" phx-click="save">Save</.button>
    """
  end
end
