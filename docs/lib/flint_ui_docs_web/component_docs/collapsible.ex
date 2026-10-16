defmodule FlintUIDocsWeb.ComponentDocs.Collapsible do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :collapsible

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet
  alias FlintUIDocsWeb.DocBlocks

  @reveal_style "--fl-collapsible-duration: 400ms; --fl-collapsible-easing: cubic-bezier(0.34, 1.56, 0.64, 1)"

  @impl true
  def controls do
    [
      %{key: :open, type: :boolean, default: false, label: "Open"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :hidden_until_found, type: :boolean, default: false, label: "Hidden until found"}
    ]
  end

  @impl true
  def structure do
    """
    <.collapsible id="repos">
      <:trigger :let={attrs}>
        <button {attrs}>Toggle repositories</button>
      </:trigger>
      <:content :let={attrs}>
        <p {attrs}>Hidden content</p>
      </:content>
    </.collapsible>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :open,
        title: "Open by default",
        layer: :base,
        body: """
        Set `open` to show the content on first render. The trigger's
        `aria-expanded` and the content's `data-state` reflect the state.
        """,
        code: styled_code("open")
      },
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        body: """
        Set `disabled` to prevent toggling. The trigger is marked with
        `data-disabled` and the content stays as it is.
        """,
        code: styled_code("disabled")
      },
      %{
        id: :hidden_until_found,
        title: "Find in page",
        layer: :base,
        body: """
        With `hidden_until_found`, the collapsed content is hidden with
        `hidden="until-found"`: browser find-in-page can reveal it and the
        disclosure reopens through a `beforematch` event.
        """,
        code: styled_code("hidden_until_found")
      },
      %{
        id: :events,
        title: "Server events",
        layer: :base,
        preview: false,
        body: """
        Set `open_event`, `close_event`, or `toggle_event` to push the resulting
        state to the server, or drive it from a `Phoenix.LiveView.JS` command
        with the provided helpers. There is no live preview here: the pushed
        event belongs to your LiveView.
        """,
        code: styled_code(~s/toggle_event="toggle_repos"/)
      },
      %{
        id: :reveal,
        title: "Reveal transition",
        layer: :styled,
        body: """
        The generated component adds the themed reveal: the content clips itself
        and animates open and closed using the `--fl-collapsible-height` the hook
        measures. Customize the timing with the `--fl-collapsible-duration` and
        `--fl-collapsible-easing` custom properties. This preview runs at `400ms`
        with an overshoot easing.
        """,
        code: styled_code(~s|style="#{@reveal_style}"|)
      }
    ]
  end

  defp styled_code(attrs) do
    """
    <.collapsible id="repos" class="flex flex-col gap-2"#{attr_suffix(attrs)}>
      <:trigger :let={attrs}>
        <.button {attrs} variant="outline" class="group w-full justify-between">
          Open
          <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
        </.button>
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p>Content</p>
        </div>
      </:content>
    </.collapsible>
    """
    |> String.trim()
  end

  defp attr_suffix(""), do: ""
  defp attr_suffix(attrs), do: " " <> attrs

  @impl true
  def examples do
    [
      %{
        id: :repos,
        title: "Expanding card",
        description: "A full-bleed trigger on a flush card, revealing a list of repositories.",
        codes: [
          %{
            label: "Tailwind",
            lang: :heex,
            code: """
            <.card flush class="w-full max-w-74">
              <.collapsible id="repos">
                <:trigger :let={attrs}>
                  <button {attrs} class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium">
                    Starred repositories
                    <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
                      <li class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900">@elixir-lang/elixir</li>
                      <li class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900">@phoenixframework/phoenix</li>
                    </ul>
                  </div>
                </:content>
              </.collapsible>
            </.card>
            """
          },
          %{
            label: "CSS",
            lang: :heex,
            code: """
            <.card flush class="repo-card">
              <.collapsible id="repos">
                <:trigger :let={attrs}>
                  <button {attrs} class="repo-card__trigger">
                    Starred repositories
                    <.icon name="lucide-chevron-down" class="repo-card__chevron" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <ul class="repo-list">
                      <li class="repo">@elixir-lang/elixir</li>
                      <li class="repo">@phoenixframework/phoenix</li>
                    </ul>
                  </div>
                </:content>
              </.collapsible>
            </.card>
            """,
            styles: """
            .repo-card {
              max-width: 300px;
            }

            .repo-card__trigger {
              display: flex;
              align-items: center;
              justify-content: space-between;
              gap: 0.5rem;
              width: 100%;
              padding: 0.75rem 1rem;
              border-radius: 0;
              font-size: 0.875rem;
              font-weight: 500;
              text-align: left;
            }

            .repo-card__chevron {
              transition: transform 150ms ease;
            }

            [aria-expanded="true"] .repo-card__chevron {
              transform: rotate(180deg);
            }

            .repo-list {
              display: flex;
              flex-direction: column;
              gap: 0.5rem;
              padding: 0.75rem 1rem;
              border-top: 1px solid var(--fl-color-border);
            }

            .repo {
              padding: 0.5rem 0.75rem;
              border-radius: var(--fl-radius-md);
              background: var(--fl-color-muted);
              font-family: ui-monospace, monospace;
              font-size: 0.75rem;
            }
            """
          }
        ]
      },
      %{
        id: :faq,
        title: "FAQ",
        description: "A list of disclosures separated by dividers.",
        codes: [
          %{
            label: "Tailwind",
            lang: :heex,
            code: """
            <div class="w-full max-w-74 divide-y divide-zinc-200 rounded-lg border border-zinc-200 dark:divide-zinc-800 dark:border-zinc-800">
              <.collapsible id="faq-1" open>
                <:trigger :let={attrs}>
                  <button {attrs} class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium">
                    What is FlintUI?
                    <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
                      Accessible, unstyled components for Phoenix LiveView.
                    </p>
                  </div>
                </:content>
              </.collapsible>
              <.collapsible id="faq-2">
                <:trigger :let={attrs}>
                  <button {attrs} class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium">
                    Does it ship CSS?
                    <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
                      A theme ships, but styling is always yours to change.
                    </p>
                  </div>
                </:content>
              </.collapsible>
            </div>
            """
          },
          %{
            label: "CSS",
            lang: :heex,
            code: """
            <div class="faq">
              <.collapsible id="faq-1" open>
                <:trigger :let={attrs}>
                  <button {attrs} class="faq__trigger">
                    What is FlintUI?
                    <.icon name="lucide-chevron-down" class="faq__chevron" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="faq__answer">Accessible, unstyled components for Phoenix LiveView.</p>
                  </div>
                </:content>
              </.collapsible>
              <.collapsible id="faq-2">
                <:trigger :let={attrs}>
                  <button {attrs} class="faq__trigger">
                    Does it ship CSS?
                    <.icon name="lucide-chevron-down" class="faq__chevron" />
                  </button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="faq__answer">A theme ships, but styling is always yours to change.</p>
                  </div>
                </:content>
              </.collapsible>
            </div>
            """,
            styles: """
            .faq {
              max-width: 300px;
              border: 1px solid var(--fl-color-border);
              border-radius: var(--fl-radius-lg);
              overflow: hidden;
            }

            .faq > * + * {
              border-top: 1px solid var(--fl-color-border);
            }

            .faq__trigger {
              display: flex;
              align-items: center;
              justify-content: space-between;
              gap: 0.5rem;
              width: 100%;
              padding: 0.75rem 1rem;
              border-radius: 0;
              font-size: 0.875rem;
              font-weight: 500;
              text-align: left;
            }

            .faq__chevron {
              transition: transform 150ms ease;
            }

            [aria-expanded="true"] .faq__chevron {
              transform: rotate(180deg);
            }

            .faq__answer {
              padding: 0 1rem 1rem;
              color: var(--fl-color-muted-foreground);
              font-size: 0.875rem;
            }
            """
          }
        ]
      },
      %{
        id: :find_in_page,
        title: "Find in page",
        description: "Collapsed content that browser find-in-page can reveal.",
        codes: [
          %{
            label: "Tailwind",
            lang: :heex,
            code: """
            <div class="w-full max-w-74">
              <.collapsible id="license" class="flex flex-col gap-2" hidden_until_found>
                <:trigger :let={attrs}>
                  <.button {attrs} variant="outline" class="self-start">Show the license</.button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="px-2 py-3 text-sm text-zinc-600 dark:text-zinc-400">
                      Released under the MIT License.
                    </p>
                  </div>
                </:content>
              </.collapsible>
            </div>
            """
          },
          %{
            label: "CSS",
            lang: :heex,
            code: """
            <div class="license-block">
              <.collapsible id="license" class="license-disclosure" hidden_until_found>
                <:trigger :let={attrs}>
                  <.button {attrs} variant="outline" class="license-disclosure__trigger">
                    Show the license
                  </.button>
                </:trigger>
                <:content :let={attrs}>
                  <div {attrs}>
                    <p class="license">Released under the MIT License.</p>
                  </div>
                </:content>
              </.collapsible>
            </div>
            """,
            styles: """
            .license-block {
              max-width: 300px;
            }

            .license-disclosure {
              display: flex;
              flex-direction: column;
              gap: 0.5rem;
            }

            .license-disclosure__trigger {
              align-self: flex-start;
            }

            .license {
              padding: 0.75rem 1rem;
              color: var(--fl-color-muted-foreground);
              font-size: 0.875rem;
            }
            """
          }
        ]
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The trigger and content expose `data-state`, so you can style the open and
      closed states. The styled layer ships a default reveal built on the
      `--fl-collapsible-height` the hook measures; customize its timing with the
      `--fl-collapsible-duration` and `--fl-collapsible-easing` custom properties.
      """,
      snippets: [
        %{
          title: "Clip the content",
          code: """
          [data-element="collapsible"] [data-part="content"] {
            overflow: hidden;
          }
          """
        },
        %{
          title: "Reveal",
          code: """
          [data-element="collapsible"] [data-part="content"][data-state="open"] {
            animation: expand var(--fl-collapsible-duration, 250ms) ease;
          }

          [data-element="collapsible"] [data-part="content"][data-state="closed"] {
            animation: collapse var(--fl-collapsible-duration, 250ms) ease;
          }
          """
        },
        %{
          title: "Customize the timing",
          code: """
          .my-collapsible {
            --fl-collapsible-duration: 400ms;
            --fl-collapsible-easing: cubic-bezier(0.4, 0, 0.2, 1);
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <div class="w-full max-w-74 self-start">
      <Components.collapsible
        id={"#{@id}-styled"}
        class="flex flex-col gap-2"
        open={@props.open}
        disabled={@props.disabled}
        hidden_until_found={@props.hidden_until_found}
      >
        <:trigger :let={attrs}>
          <Components.button {attrs} variant="outline" class="group w-full justify-between">
            Open
            <Components.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </Components.button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <DocBlocks.content_placeholder class="h-40" />
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end

  def render_playground(assigns) do
    ~H"""
    <div class="w-full max-w-74 self-start">
      <.collapsible
        id={@id}
        class="flex flex-col gap-2"
        open={@props.open}
        disabled={@props.disabled}
        hidden_until_found={@props.hidden_until_found}
      >
        <:trigger :let={attrs}>
          <button {attrs}>Open</button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <DocBlocks.content_placeholder class="h-40" />
          </div>
        </:content>
      </.collapsible>
    </div>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(".collapsible", code_attrs(props), styled_code_body())
  end

  def render_code(%{props: props}) do
    Snippet.tag(".collapsible", code_attrs(props), base_code_body())
  end

  defp code_attrs(props) do
    [
      ~s(id="repos"),
      ~s(class="flex flex-col gap-2"),
      Snippet.flag("open", props.open),
      Snippet.flag("disabled", props.disabled),
      Snippet.flag("hidden_until_found", props.hidden_until_found)
    ]
  end

  defp styled_code_body do
    """
    <:trigger :let={attrs}>
      <.button {attrs} variant="outline" class="group w-full justify-between">
        Open
        <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
      </.button>
    </:trigger>
    <:content :let={attrs}>
      <div {attrs}>
        <p>Content</p>
      </div>
    </:content>
    """
    |> String.trim()
  end

  defp base_code_body do
    """
    <:trigger :let={attrs}>
      <button {attrs}>Open</button>
    </:trigger>
    <:content :let={attrs}>
      <p {attrs}>Content</p>
    </:content>
    """
    |> String.trim()
  end

  @impl true
  def render_usage(%{block: :open} = assigns) do
    ~H"""
    <.usage_demo id={"#{@id}-open"} layer={@layer} open />
    """
  end

  def render_usage(%{block: :disabled} = assigns) do
    ~H"""
    <.usage_demo id={"#{@id}-disabled"} layer={@layer} disabled />
    """
  end

  def render_usage(%{block: :hidden_until_found} = assigns) do
    ~H"""
    <.usage_demo id={"#{@id}-find"} layer={@layer} hidden_until_found />
    """
  end

  def render_usage(%{block: :reveal} = assigns) do
    ~H"""
    <.usage_demo id={"#{@id}-reveal"} layer={@layer} style={reveal_style()} />
    """
  end

  def render_usage(%{block: :events}), do: nil

  defp reveal_style, do: @reveal_style

  attr :id, :string, required: true
  attr :layer, :atom, default: :base
  attr :open, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :hidden_until_found, :boolean, default: false
  attr :style, :string, default: nil

  defp usage_demo(assigns) do
    ~H"""
    <div class="w-full max-w-74 self-start">
      <%= if @layer == :styled do %>
        <Components.collapsible
          id={@id}
          class="flex flex-col gap-2"
          style={@style}
          open={@open}
          disabled={@disabled}
          hidden_until_found={@hidden_until_found}
        >
          <:trigger :let={attrs}>
            <Components.button {attrs} variant="outline" class="group w-full justify-between">
              Open
              <Components.icon
                name="lucide-chevron-down"
                class="size-4 transition-transform group-aria-expanded:rotate-180"
              />
            </Components.button>
          </:trigger>
          <:content :let={attrs}>
            <div {attrs}>
              <DocBlocks.content_placeholder class="h-40" />
            </div>
          </:content>
        </Components.collapsible>
      <% else %>
        <.collapsible
          id={@id}
          class="flex flex-col gap-2"
          open={@open}
          disabled={@disabled}
          hidden_until_found={@hidden_until_found}
        >
          <:trigger :let={attrs}>
            <button {attrs}>Open</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>Hidden content</p>
          </:content>
        </.collapsible>
      <% end %>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :repos} = assigns) do
    ~H"""
    <Components.card flush class="w-full max-w-74">
      <Components.collapsible id={"#{@id}-repos"}>
        <:trigger :let={attrs}>
          <button
            {attrs}
            class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium"
          >
            Starred repositories
            <Components.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
              <li class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900">
                @elixir-lang/elixir
              </li>
              <li class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900">
                @phoenixframework/phoenix
              </li>
            </ul>
          </div>
        </:content>
      </Components.collapsible>
    </Components.card>
    """
  end

  def render_block(%{block: :faq} = assigns) do
    ~H"""
    <div class="w-full max-w-74 divide-y divide-zinc-200 rounded-lg border border-zinc-200 dark:divide-zinc-800 dark:border-zinc-800">
      <Components.collapsible id={"#{@id}-faq-1"} open>
        <:trigger :let={attrs}>
          <button
            {attrs}
            class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium"
          >
            What is FlintUI?
            <Components.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
              Accessible, unstyled components for Phoenix LiveView.
            </p>
          </div>
        </:content>
      </Components.collapsible>
      <Components.collapsible id={"#{@id}-faq-2"}>
        <:trigger :let={attrs}>
          <button
            {attrs}
            class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium"
          >
            Does it ship CSS?
            <Components.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
              A theme ships, but styling is always yours to change.
            </p>
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end

  def render_block(%{block: :find_in_page} = assigns) do
    ~H"""
    <div class="w-full max-w-74 self-start">
      <Components.collapsible
        id={"#{@id}-license"}
        class="flex flex-col gap-2"
        hidden_until_found
      >
        <:trigger :let={attrs}>
          <Components.button {attrs} variant="outline" class="self-start">
            Show the license
          </Components.button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <p class="px-2 py-3 text-sm text-zinc-600 dark:text-zinc-400">
              Released under the MIT License.
            </p>
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end
end
