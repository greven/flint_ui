defmodule FlintUIDocsWeb.Docs.Collapsible do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :collapsible

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet
  alias FlintUIDocsWeb.DocsComponents

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
    <FlintUI.collapsible id="repos">
      <:trigger :let={attrs}>
        <button {attrs}>Toggle repositories</button>
      </:trigger>
      <:content :let={attrs}>
        <p {attrs}>Hidden content</p>
      </:content>
    </FlintUI.collapsible>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :id,
        title: "Required id",
        layer: :base,
        covers: [:id],
        body: """
        `id` identifies the root and derives the content element's id. It is
        required because the trigger needs a stable `aria-controls` target.
        """,
        code: base_code(~s(id="repos"))
      },
      %{
        id: :as,
        title: "Root element",
        layer: :base,
        covers: [:as],
        body: """
        Choose the root element with `as`. The default is a plain `div`; use a
        semantic element when the disclosure's structure calls for it.
        """,
        code: base_code(~s(id="repos" as="section"))
      },
      %{
        id: :open,
        title: "Open by default",
        layer: :base,
        covers: [:open],
        body: """
        Set `open` to show the content on first render. The trigger's
        `aria-expanded` and the content's `data-state` reflect the state.
        """,
        code: base_code(~s(id="repos" open))
      },
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        covers: [:disabled],
        body: """
        Set `disabled` to prevent toggling. The trigger is marked with
        `data-disabled` and the content stays as it is.
        """,
        code: base_code(~s(id="repos" disabled))
      },
      %{
        id: :hidden_until_found,
        title: "Find in page",
        layer: :base,
        covers: [:hidden_until_found],
        body: """
        With `hidden_until_found`, the collapsed content is hidden with
        `hidden="until-found"`: browser find-in-page can reveal it and the
        disclosure reopens through a `beforematch` event.
        """,
        code: base_code(~s(id="repos" hidden_until_found))
      },
      %{
        id: :open_event,
        title: "Open event",
        layer: :base,
        covers: [:open_event],
        body: """
        Set `open_event` to push a server event when the collapsible opens. The
        payload contains the component's `id` and `open` state.
        """,
        code: base_code(~s(id="repos" open_event="repos_opened"))
      },
      %{
        id: :close_event,
        title: "Close event",
        layer: :base,
        covers: [:close_event],
        body: """
        Set `close_event` to push a server event when the collapsible closes. The
        payload contains the component's `id` and `open` state.
        """,
        code: base_code(~s(id="repos" close_event="repos_closed"))
      },
      %{
        id: :toggle_event,
        title: "Toggle event",
        layer: :base,
        covers: [:toggle_event],
        body: """
        Set `toggle_event` to push a server event on every change. The payload
        contains the component's `id` and `open` state.
        """,
        code: base_code(~s(id="repos" toggle_event="repos_toggled"))
      },
      %{
        id: :reveal,
        title: "Reveal transition",
        layer: :styled,
        covers: [],
        body: """
        The generated component adds the themed reveal: the content clips itself
        and animates open and closed using the `--_fl-collapsible-height` the hook
        measures. Customize the timing with the `--fl-collapsible-duration` and
        `--fl-collapsible-easing` custom properties. This preview runs at `400ms`
        with an overshoot easing.
        """,
        code: styled_code(~s|style="#{@reveal_style}"|)
      }
    ]
  end

  defp base_code(attrs) do
    """
    <FlintUI.collapsible #{attrs}>
      <:trigger :let={attrs}>
        <button {attrs}>Open</button>
      </:trigger>
      <:content :let={attrs}>
        <p {attrs}>Content</p>
      </:content>
    </FlintUI.collapsible>
    """
    |> String.trim()
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
        description: "A full-bleed trigger on a card section, revealing a list of repositories.",
        codes: [
          %{
            label: "Tailwind",
            lang: :heex,
            code: """
            <.card padded={false} class="w-full max-w-74">
              <:section>
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
              </:section>
            </.card>
            """
          },
          %{
            label: "CSS",
            lang: :heex,
            code: """
            <.card padded={false} class="repo-card">
              <:section>
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
              </:section>
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
      },
      %{
        id: :base_disclosure,
        title: "Native disclosure",
        layer: :base,
        description: "The headless component supplies the trigger attributes and hidden content.",
        code: """
        <FlintUI.collapsible id="shipping">
          <:trigger :let={attrs}>
            <button {attrs}>Shipping details</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>Orders ship within two business days.</p>
          </:content>
        </FlintUI.collapsible>
        """
      },
      %{
        id: :base_faq,
        title: "FAQ stack",
        layer: :base,
        description: "Several disclosures rendered as a list, with the first one open.",
        code: """
        <div class="flex w-full max-w-74 flex-col gap-3">
          <FlintUI.collapsible id="faq-what" open>
            <:trigger :let={attrs}>
              <button {attrs}>What is FlintUI?</button>
            </:trigger>
            <:content :let={attrs}>
              <p {attrs}>Accessible, unstyled components for Phoenix LiveView.</p>
            </:content>
          </FlintUI.collapsible>
          <FlintUI.collapsible id="faq-css">
            <:trigger :let={attrs}>
              <button {attrs}>Does it ship CSS?</button>
            </:trigger>
            <:content :let={attrs}>
              <p {attrs}>The styled layer does; the base layer does not.</p>
            </:content>
          </FlintUI.collapsible>
        </div>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The collapsible renders a root and two required slots. The trigger must be
      a native `<button>` and the content must be an element that receives the
      hidden and state attributes.
      """,
      nodes: [
        %{
          tag: "div",
          selector: ~s([data-element="collapsible"][data-part="root"]),
          hooks: [
            "id",
            "phx-hook",
            "data-state",
            "data-disabled",
            "data-open-event",
            "data-close-event",
            "data-toggle-event"
          ],
          attributes: ["class", "as"],
          children: [
            %{
              tag: "button",
              selector: ~s([data-part="trigger"]),
              hooks: [
                "type",
                "disabled",
                "data-state",
                "data-disabled",
                "aria-controls",
                "aria-expanded",
                "aria-disabled"
              ],
              children: []
            },
            %{
              tag: "div",
              selector: ~s([data-part="content"]),
              hooks: ["id", "hidden", "data-state", "data-disabled"],
              children: []
            }
          ]
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The base collapsible is structural: the trigger is a native button and the
      content is the element you provide. Both expose `data-state`, so you can
      style the open and closed states yourself.
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
          title: "Style the state",
          code: """
          [data-element="collapsible"] [data-part="content"][data-state="closed"] {
            display: none;
          }

          [data-element="collapsible"] [data-part="trigger"][data-state="open"] {
            font-weight: 600;
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
            <DocsComponents.content_placeholder class="h-40" />
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(".collapsible", code_attrs(props), styled_code_body())
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

  @impl true
  def render_usage(%{block: :reveal} = assigns) do
    ~H"""
    <.usage_demo id={"#{@id}-reveal"} style={reveal_style()} />
    """
  end

  defp reveal_style, do: @reveal_style

  attr :id, :string, required: true
  attr :style, :string, default: nil

  defp usage_demo(assigns) do
    ~H"""
    <div class="w-full max-w-74 self-start">
      <Components.collapsible
        id={@id}
        class="flex flex-col gap-2"
        style={@style}
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
            <DocsComponents.content_placeholder class="h-40" />
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :repos} = assigns) do
    ~H"""
    <Components.card padded={false} class="w-full max-w-74">
      <:section>
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
      </:section>
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

  @impl true
  def css do
    %{
      body: """
      The styled collapsible adds only the reveal transition and a couple of
      cursor rules. The trigger and content remain composition: put a generated
      button in the trigger slot and wrap the content however you like.
      """,
      snippets: [
        %{
          title: "Customize the timing",
          body: "Set the duration and easing on the instance.",
          code: """
          .fast-disclosure {
            --fl-collapsible-duration: 150ms;
            --fl-collapsible-easing: ease-out;
          }
          """
        },
        %{
          title: "Keep content free of padding",
          body:
            "The reveal measures the content box; put padding and borders on a child instead.",
          code: """
          [data-element="collapsible"] [data-part="content"] > div {
            padding: 0.75rem 1rem;
          }
          """
        }
      ]
    }
  end
end
