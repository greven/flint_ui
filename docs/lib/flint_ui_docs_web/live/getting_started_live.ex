defmodule FlintUIDocsWeb.GettingStartedLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocBlocks

  @commands [
    {"mix flint.setup", "Create the components module and install the theme."},
    {"mix flint.setup --tailwind", "Also map tokens onto Tailwind utilities."},
    {"mix flint.add <name>", "Generate a styled component wrapper."},
    {"mix flint.add --all", "Generate every registered component."},
    {"mix flint.theme", "Refresh the theme stylesheet from the library."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Getting started", commands: @commands)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={nil}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Getting started</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          FlintUI ships accessible, unstyled components, plus a styled layer you generate
          into your own app. Theming is plain CSS, so Tailwind is optional.
        </p>

        <DocBlocks.section title="1. Add the dependency" id="install">
          <DocBlocks.code_block code={snippet(:dependency)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Then run <code class="font-mono">mix deps.get</code>.
          </p>
        </DocBlocks.section>

        <DocBlocks.section title="2. Set up the theme" id="setup">
          <DocBlocks.code_block code="mix flint.setup" />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            This creates <code class="font-mono">MyAppWeb.Components</code>, copies the
            theme stylesheet to <code class="font-mono">assets/css/flint.css</code>, imports
            it, and wires the components module into your HTML helpers.
          </p>
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Using Tailwind? Pass <code class="font-mono">--tailwind</code> to also map the
            FlintUI tokens onto utilities (<code class="font-mono">bg-primary</code>, <code class="font-mono">border-border</code>, …).
          </p>
          <DocBlocks.code_block code="mix flint.setup --tailwind" />
        </DocBlocks.section>

        <DocBlocks.section title="3. Generate components" id="generate">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Generate the styled wrappers you need. They are written into your app, so you
            own and can edit them.
          </p>
          <DocBlocks.code_block code={snippet(:add)} />
        </DocBlocks.section>

        <DocBlocks.section title="4. Use a component" id="usage">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Generated components are imported from <code class="font-mono">MyAppWeb.Components</code>, so you use them with the
            familiar tag syntax:
          </p>
          <DocBlocks.code_block code={snippet(:usage)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            The headless base stays available explicitly — useful when you want full
            control and no default styling:
          </p>
          <DocBlocks.code_block code={snippet(:headless)} />
        </DocBlocks.section>

        <DocBlocks.section title="Commands" id="commands">
          <table class="mt-2 w-full text-left text-sm">
            <thead class="text-xs tracking-wider text-zinc-400 uppercase">
              <tr>
                <th class="py-2 pr-4 font-medium">Command</th>
                <th class="py-2 font-medium">Description</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-200 dark:divide-zinc-800">
              <tr :for={{command, description} <- @commands}>
                <td class="py-2 pr-4"><code class="font-mono">{command}</code></td>
                <td class="py-2 text-zinc-600 dark:text-zinc-400">{description}</td>
              </tr>
            </tbody>
          </table>
        </DocBlocks.section>

        <p class="mt-8 text-sm text-zinc-500">
          Next: browse the <.link navigate={~p"/"} class="underline">components</.link>
          or read about <.link navigate={~p"/theming"} class="underline">theming</.link>.
        </p>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:dependency), do: ~s({:flint_ui, "~> 0.1"})

  defp snippet(:add) do
    """
    mix flint.add button
    mix flint.add toggle

    # or every component
    mix flint.add --all
    """
  end

  defp snippet(:usage) do
    """
    <.button variant="solid" phx-click="save">Save</.button>

    <.toggle pressed>Bold</.toggle>
    """
  end

  defp snippet(:headless) do
    """
    <FlintUI.button class="my-own-class">Save</FlintUI.button>
    """
  end
end
