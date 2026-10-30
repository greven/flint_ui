defmodule FlintUIDocsWeb.HomeLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  @sections [
    %{
      title: "Get Started",
      description: "Install FlintUI and generate your first styled component.",
      path: "/getting-started/introduction"
    },
    %{
      title: "Guides",
      description: "Theming, tokens, and how the styled layer fits together.",
      path: "/guides/theming"
    },
    %{
      title: "Components",
      description: "Browse the accessible, unstyled building blocks.",
      path: "/components"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "FlintUI", sections: @sections)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-4xl">
        <section class="py-12 sm:py-20">
          <p class="text-sm font-medium tracking-wider text-muted uppercase">FlintUI</p>
          <h1 class="mt-3 text-4xl font-semibold tracking-tight sm:text-5xl">
            Accessible, unstyled UI for Phoenix LiveView
          </h1>
          <p class="mt-4 max-w-2xl text-lg text-default">
            Headless components you import, plus a styled layer you generate into your
            own app. Theming is plain CSS, so Tailwind is optional.
          </p>
          <div class="mt-8 flex flex-wrap gap-3">
            <.link
              navigate="/getting-started/introduction"
              class="rounded-md bg-inverted px-4 py-2 text-sm font-medium text-inverted transition-colors hover:bg-inverted/90"
            >
              Get started
            </.link>
            <.link
              navigate="/components"
              class="rounded-md border border-default px-4 py-2 text-sm font-medium text-default transition-colors hover:bg-surface-soft"
            >
              Browse components
            </.link>
          </div>
        </section>

        <section class="grid gap-4 sm:grid-cols-3">
          <.link
            :for={section <- @sections}
            navigate={section.path}
            class="group rounded-lg border border-default p-5 transition-colors hover:border-accented hover:bg-surface-soft"
          >
            <span class="font-medium">{section.title}</span>
            <p class="mt-1 text-sm text-toned">{section.description}</p>
          </.link>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
