defmodule FlintUIDocsWeb.StylingLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.ComponentDocs
  alias FlintUIDocsWeb.DocBlocks
  alias FlintUIDocsWeb.Markdown

  @impl true
  def mount(_params, _session, socket) do
    pages =
      FlintUI.components()
      |> Enum.sort()
      |> Enum.map(fn name -> {name, ComponentDocs.styling(name)} end)
      |> Enum.reject(fn {_name, styling} -> is_nil(styling) end)

    {:ok, assign(socket, page_title: "Styling", pages: pages)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:getting_started} page={:styling}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Styling</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          The headless base components ship behavior, not appearance. You style them
          with the <code class="font-mono">class</code>
          attribute and the <code class="font-mono">data-*</code>
          hooks they expose for state — plain CSS,
          your own design system, or Tailwind. No stylesheet is required.
        </p>

        <DocBlocks.section title="How it works" id="how">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Every base component forwards <code class="font-mono">class</code> and the rest
            of your attributes onto its root element and marks itself with <code class="font-mono">data-element</code>. Style the root, or any part it
            exposes, with a plain selector.
          </p>
          <DocBlocks.code_block code={snippet(:base)} />
        </DocBlocks.section>

        <DocBlocks.section title="Targeting state" id="state">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            State such as disabled, loading, open, or pressed is reflected as
            <code class="font-mono">data-*</code>
            attributes (and the matching ARIA
            attributes), so you can style it without tracking state yourself. Each
            component's Base tab documents the exact hooks it sets.
          </p>
          <DocBlocks.code_block code={snippet(:state)} lang={:css} />
        </DocBlocks.section>

        <DocBlocks.section title="By component" id="components">
          <DocBlocks.subsection
            :for={{name, styling} <- @pages}
            title={humanize(name)}
            id={to_string(name)}
          >
            <Markdown.markdown :if={styling[:body]} content={styling[:body]} />
            <div :for={snippet <- styling.snippets} class="mt-4">
              <p class="text-sm font-medium">{snippet.title}</p>
              <DocBlocks.code_block code={snippet.code} lang={:css} />
            </div>
          </DocBlocks.subsection>
        </DocBlocks.section>

        <p class="mt-8 text-sm text-zinc-500">
          Prefer a starting point? The generated styled layer ships an opinionated theme.
          See <.link navigate={~p"/guides/theming"} class="underline">Theming</.link>
          for tokens and custom themes.
        </p>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:base) do
    """
    <FlintUI.button class="my-button" phx-click="save">Save</FlintUI.button>

    [data-element="button"].my-button {
      padding: 0.5rem 1rem;
      border-radius: 0.5rem;
    }
    """
  end

  defp snippet(:state) do
    """
    [data-element="button"][data-disabled] { opacity: 0.5; }

    [data-element="toggle"][data-state="on"] { font-weight: 600; }

    [data-element="collapsible"] [data-part="content"][data-state="open"] {
      animation: expand 250ms ease;
    }
    """
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
