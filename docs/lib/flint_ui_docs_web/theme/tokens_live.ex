defmodule FlintUIDocsWeb.Theme.TokensLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents
  alias FlintUIDocsWeb.Theme.{Snippets, Tokens}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Design Tokens", token_pages: Tokens.pages())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming_tokens}>
      <div class="max-w-3xl">
        <DocsComponents.page_header
          title="Design Tokens"
          subtitle="Tokens are the styling API. Override a token once and every component that reads it follows, in both color schemes."
        />

        <DocsComponents.section title="Token groups" id="groups">
          <DocsComponents.content_paragraph class="mt-3">
            Each page owns one family of tokens: the visual demo, the variables
            behind it, and the override pattern. Pick the family you need.
          </DocsComponents.content_paragraph>
          <div class="mt-4 grid gap-3 sm:grid-cols-2">
            <Components.card
              :for={{page, index} <- Enum.with_index(@token_pages)}
              navigate={page.path}
              title_id={"token-card-#{index}"}
              class="h-full"
            >
              <:title>
                <span class="flex items-center gap-2">
                  <FlintUI.icon name={page.icon} class="size-4 text-muted" />
                  {page.label}
                </span>
              </:title>
              <:description>{page.summary}</:description>
              <code class="docs-code font-mono text-xs">{page.namespace}</code>
            </Components.card>
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Component inputs" id="component-inputs">
          <DocsComponents.content_paragraph class="mt-3">
            The tokens on these pages are shared theme inputs. Components also
            expose a few narrow per-instance inputs, such as
            <code class="docs-code font-mono">--fl-control-*</code>
            for buttons and <code class="docs-code font-mono">--fl-field-*</code>
            for fields. Those belong to the component or primitive that reads
            them, so they are documented there instead of here.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-center gap-3">
            <Components.button navigate={~p"/components/button"} variant="surface" size="sm">
              Button inputs
            </Components.button>
            <Components.button navigate={~p"/components/input"} variant="surface" size="sm">
              Input inputs
            </Components.button>
            <Components.button
              navigate={~p"/getting-started/styling"}
              variant="ghost"
              size="sm"
              icon="lucide-arrow-up-right"
            >
              Styling guide
            </Components.button>
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Override a token" id="override">
          <DocsComponents.content_paragraph class="mt-3">
            Override the shared variables in your app stylesheet, after the
            FlintUI import. Start with the token that owns the decision, not the
            component that happens to show it.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={Snippets.snippet(:token_override)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            For color-specific work, start from
            <.link
              navigate={~p"/guides/theming/color"}
              class="docs-link"
            >Color</.link>
            or the recipes in <.link
              navigate={~p"/guides/theming/customizing"}
              class="docs-link"
            >Customizing</.link>.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end
end
