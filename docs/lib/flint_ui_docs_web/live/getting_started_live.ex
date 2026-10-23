defmodule FlintUIDocsWeb.GettingStartedLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @commands [
    {"mix flint.setup",
     "Create the components module, install the theme, and register the JS hooks."},
    {"mix flint.setup --tailwind", "Also map tokens onto Tailwind utilities."},
    {"mix flint.add <name>", "Generate a styled component wrapper."},
    {"mix flint.add --all", "Generate every registered component."},
    {"mix flint.theme", "Refresh the theme stylesheet from the library."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Installation", commands: @commands)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:getting_started} page={:installation}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Installation</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          FlintUI ships accessible, unstyled components, plus a styled layer you generate
          into your own app. Theming is plain CSS, so Tailwind is optional.
        </p>

        <DocsComponents.section title="1. Add the dependency" id="install">
          <DocsComponents.code_block code={snippet(:dependency)} lang={:elixir} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Then run <code class="font-mono">mix deps.get</code>.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="2. Set up the theme" id="setup">
          <DocsComponents.code_block code="mix flint.setup" lang={:shell} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            This creates <code class="font-mono">MyAppWeb.Components</code>, copies the
            theme stylesheet to <code class="font-mono">assets/css/flint.css</code>, imports
            it, wires the components module into your HTML helpers, and registers FlintUI's
            LiveView hooks in <code class="font-mono">assets/js/app.js</code>.
          </p>
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Using Tailwind? Pass <code class="font-mono">--tailwind</code>
            to also map the
            FlintUI tokens onto utilities (<code class="font-mono">bg-primary</code>, <code class="font-mono">border-border</code>, …).
            Pass <code class="font-mono">--no-js</code>
            if you wire <code class="font-mono">app.js</code>
            yourself.
          </p>
          <DocsComponents.code_block code="mix flint.setup --tailwind" lang={:shell} />
        </DocsComponents.section>

        <DocsComponents.section title="3. Generate components" id="generate">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Generate the styled wrappers you need. They are written into your app, so you
            own and can edit them.
          </p>
          <DocsComponents.code_block code={snippet(:add)} lang={:shell} />
        </DocsComponents.section>

        <DocsComponents.section title="4. Use a component" id="usage">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Generated components are imported from <code class="font-mono">MyAppWeb.Components</code>, so you use them with the
            familiar tag syntax:
          </p>
          <DocsComponents.code_block code={snippet(:usage)} />
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            The headless base stays available explicitly — useful when you want full
            control and no default styling:
          </p>
          <DocsComponents.code_block code={snippet(:headless)} />
        </DocsComponents.section>

        <DocsComponents.section title="Commands" id="commands">
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
        </DocsComponents.section>

        <p class="mt-8 text-sm text-zinc-500">
          Next: browse the <.link navigate="/components" class="underline">components</.link>
          or read about <.link navigate="/guides/theming" class="underline">theming</.link>.
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
