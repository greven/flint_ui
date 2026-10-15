defmodule FlintUIDocsWeb.ComponentDocs.Collapsible do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :collapsible

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @repo_list [
    "@elixir-lang/elixir",
    "@phoenixframework/phoenix",
    "@phoenixframework/phoenix_live_view"
  ]

  @impl true
  def controls do
    [
      %{key: :open, type: :boolean, default: false, label: "Open"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :hidden_until_found, type: :boolean, default: false, label: "Hidden until found"},
      %{key: :variant, type: :select, default: "bordered", label: "Variant"}
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
        <ul {attrs}>
          <li>...</li>
        </ul>
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
        code: """
        <.collapsible id="repos" open>
          ...
        </.collapsible>
        """
      },
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        body: """
        Set `disabled` to prevent toggling. The trigger is marked with
        `data-disabled` and the content stays as it is.
        """,
        code: """
        <.collapsible id="repos" disabled>
          ...
        </.collapsible>
        """
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
        code: """
        <.collapsible id="repos" hidden_until_found>
          ...
        </.collapsible>
        """
      },
      %{
        id: :events,
        title: "Server events",
        layer: :base,
        body: """
        Set `open_event`, `close_event`, or `toggle_event` to push the resulting
        state to the server, or drive it from a `Phoenix.LiveView.JS` command
        with the provided helpers.
        """,
        code: """
        <.collapsible id="repos" toggle_event="toggle_repos">
          ...
        </.collapsible>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets.
        """,
        code: """
        <.collapsible variant="bordered" id="repos">
          <:trigger :let={attrs}>
            <button {attrs}>Toggle</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>Hidden content</p>
          </:content>
        </.collapsible>
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :faq,
        title: "FAQ",
        description: "A list of disclosures with rich trigger labels.",
        code: """
        <.collapsible id="faq-1" open>
          <:trigger :let={attrs}>
            <button {attrs}>What is FlintUI?</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>Accessible, unstyled components for Phoenix LiveView.</p>
          </:content>
        </.collapsible>
        """
      },
      %{
        id: :find_in_page,
        title: "Find in page",
        description: "Collapsed content that browser find-in-page can reveal.",
        code: """
        <.collapsible id="license" hidden_until_found>
          <:trigger :let={attrs}>
            <button {attrs}>Show the license</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>Released under the MIT License.</p>
          </:content>
        </.collapsible>
        """
      },
      %{
        id: :disabled,
        title: "Disabled",
        description: "A trigger that cannot be toggled.",
        code: """
        <.collapsible id="details" disabled>
          <:trigger :let={attrs}>
            <button {attrs}>Toggle details</button>
          </:trigger>
          <:content :let={attrs}>
            <p {attrs}>This content cannot be revealed.</p>
          </:content>
        </.collapsible>
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The trigger and content expose `data-state`, so you can style the open and
      closed states and animate the reveal. The theme ships a default reveal
      using the `--fl-collapsible-height` the hook measures.
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
            animation: expand 250ms ease;
          }

          [data-element="collapsible"] [data-part="content"][data-state="closed"] {
            animation: collapse 250ms ease;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    assigns = assign(assigns, :repos, @repo_list)

    ~H"""
    <Components.collapsible
      id={"#{@id}-styled"}
      variant={@props.variant}
      open={@props.open}
      disabled={@props.disabled}
      hidden_until_found={@props.hidden_until_found}
      class="w-full max-w-sm"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle repositories" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <ul class="flex flex-col gap-2 px-4 pt-1 pb-4">
            <li
              :for={repo <- @repos}
              class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900"
            >
              {repo}
            </li>
          </ul>
        </div>
      </:content>
    </Components.collapsible>
    """
  end

  def render_playground(assigns) do
    assigns = assign(assigns, :repos, @repo_list)

    ~H"""
    <.collapsible
      id={@id}
      open={@props.open}
      disabled={@props.disabled}
      hidden_until_found={@props.hidden_until_found}
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle repositories" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <ul class="flex flex-col gap-2 px-4 pt-1 pb-4">
            <li
              :for={repo <- @repos}
              class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900"
            >
              {repo}
            </li>
          </ul>
        </div>
      </:content>
    </.collapsible>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    attrs =
      [
        Snippet.attr("variant", props.variant, "bordered"),
        ~s(id="repos"),
        Snippet.flag("open", props.open),
        Snippet.flag("disabled", props.disabled),
        Snippet.flag("hidden_until_found", props.hidden_until_found)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.map_join("\n", &("  " <> &1))

    """
    <.collapsible
    #{attrs}
    >
      <:trigger :let={attrs}>
        <button {attrs}>Toggle repositories</button>
      </:trigger>
      <:content :let={attrs}>
        <ul {attrs}>
          <li>...</li>
        </ul>
      </:content>
    </.collapsible>
    """
    |> String.trim()
  end

  def render_code(%{props: props}) do
    attrs =
      [
        ~s(id="repos"),
        Snippet.flag("open", props.open),
        Snippet.flag("disabled", props.disabled),
        Snippet.flag("hidden_until_found", props.hidden_until_found)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.map_join("\n", &("  " <> &1))

    """
    <.collapsible
    #{attrs}
    >
      <:trigger :let={attrs}>
        <button {attrs}>Toggle repositories</button>
      </:trigger>
      <:content :let={attrs}>
        <ul {attrs}>
          <li>...</li>
        </ul>
      </:content>
    </.collapsible>
    """
    |> String.trim()
  end

  @impl true
  def render_usage(%{block: :open} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      open
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle repositories" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            Open on first render.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  def render_usage(%{block: :disabled} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      disabled
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle repositories" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            This content cannot be revealed.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  def render_usage(%{block: :hidden_until_found} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      hidden_until_found
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Show the license" text="License" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            Search this page for “MIT” to reveal it.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  def render_usage(%{block: :events} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle repositories" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            Server events fire on open and close.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col gap-4">
      <Components.collapsible
        :for={variant <- ~w(bordered minimal)}
        variant={variant}
        id={"#{@id}-#{variant}"}
      >
        <:trigger :let={attrs}>
          <button
            {attrs}
            class="group flex w-full items-center justify-between gap-4 px-4 py-3 text-left text-sm font-medium"
          >
            {variant}
            <Components.icon
              name="lucide-chevron-down"
              size="sm"
              class="transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
              A {variant} disclosure.
            </p>
          </div>
        </:content>
      </Components.collapsible>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :faq} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col divide-y divide-zinc-200 rounded-lg border border-zinc-200 dark:divide-zinc-800 dark:border-zinc-800">
      <.faq id={"#{@id}-1"} question="What is FlintUI?" open>
        Accessible, unstyled components for Phoenix LiveView. Bring your own styles.
      </.faq>
      <.faq id={"#{@id}-2"} question="Does it ship CSS?">
        No. Components render semantic markup and data attributes; you decide how they look.
      </.faq>
      <.faq id={"#{@id}-3"} question="Can I use it with Tailwind?">
        Yes — target the data attributes, such as `data-[state=open]`, with Tailwind classes.
      </.faq>
    </div>
    """
  end

  def render_block(%{block: :find_in_page} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      hidden_until_found
      class="w-full max-w-md rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Show the license" text="License" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            Released under the MIT License. Search the page for "MIT" and the browser
            will reveal this section.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  def render_block(%{block: :disabled} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      disabled
      class="w-full max-w-md rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <.trigger {attrs} label="Toggle details" text="Disabled" />
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <p class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            This content cannot be revealed because the trigger is disabled.
          </p>
        </div>
      </:content>
    </.collapsible>
    """
  end

  attr(:label, :string, required: true)
  attr(:text, :string, default: "Starred repositories")
  attr(:rest, :global)

  defp trigger(assigns) do
    ~H"""
    <div class="flex items-center justify-between gap-4 px-4 py-3">
      <span class="text-sm font-medium">{@text}</span>
      <button
        {@rest}
        class="group grid size-7 place-items-center rounded-md text-zinc-500 transition-colors hover:bg-zinc-100 disabled:opacity-50 dark:hover:bg-zinc-800"
        aria-label={@label}
      >
        <.icon
          name="lucide-chevron-down"
          class="size-4 transition-transform group-aria-expanded:rotate-180"
        />
      </button>
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:question, :string, required: true)
  attr(:open, :boolean, default: false)
  slot(:inner_block, required: true)

  defp faq(assigns) do
    ~H"""
    <.collapsible id={@id} open={@open}>
      <:trigger :let={attrs}>
        <button
          {attrs}
          class="group flex w-full items-center justify-between gap-4 px-4 py-3 text-left text-sm font-medium"
        >
          {@question}
          <.icon
            name="lucide-chevron-down"
            class="size-4 shrink-0 text-zinc-500 transition-transform group-aria-expanded:rotate-180"
          />
        </button>
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <div class="px-4 pb-4 text-sm text-zinc-600 dark:text-zinc-400">
            {render_slot(@inner_block)}
          </div>
        </div>
      </:content>
    </.collapsible>
    """
  end
end
