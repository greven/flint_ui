defmodule FlintUIDocsWeb.HomeLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components

  @sections [
    %{
      title: "Get Started",
      description: "Install FlintUI and generate your first styled component.",
      path: "/getting-started/introduction"
    },
    %{
      title: "Guides",
      description: "Theming, icons, and how the styled layer fits together.",
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
            <Components.button
              navigate="/getting-started/introduction"
              variant="solid"
              size="lg"
            >
              Get started
            </Components.button>
            <Components.button navigate="/components" variant="surface" size="lg">
              Browse components
            </Components.button>
          </div>
        </section>

        <section class="grid gap-4 sm:grid-cols-3">
          <Components.card
            :for={{section, index} <- Enum.with_index(@sections)}
            navigate={section.path}
            title_id={"home-section-#{index}"}
            spacing="sm"
            class="h-full"
          >
            <:title>{section.title}</:title>
            <:description>{section.description}</:description>
          </Components.card>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
