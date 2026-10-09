defmodule FlintUIDocsWeb.Layouts do
  @moduledoc """
  Layouts and shared shell for the FlintUI docs site.
  """
  use FlintUIDocsWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates("layouts/*")

  @doc """
  Renders the docs shell: header, component sidebar, and content area.

  ## Examples

      <Layouts.app flash={@flash} active={@active}>
        <h1>Content</h1>
      </Layouts.app>
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:active, :atom, default: nil, doc: "the active component, highlighted in the sidebar")

  attr(:current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"
  )

  slot(:inner_block, required: true)

  def app(assigns) do
    assigns = assign(assigns, :component_groups, FlintUI.Docs.grouped_components())

    ~H"""
    <div class="min-h-screen bg-white text-zinc-900 antialiased dark:bg-zinc-950 dark:text-zinc-100">
      <header class="sticky top-0 z-20 border-b border-zinc-200 bg-white/85 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/85">
        <div class="mx-auto flex h-14 max-w-7xl items-center justify-between gap-4 px-4 sm:px-6 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-2">
            <span class="grid size-6 place-items-center rounded-md bg-zinc-900 text-xs font-bold text-white dark:bg-white dark:text-zinc-900">
              F
            </span>
            <span class="font-semibold tracking-tight">FlintUI</span>
            <span class="hidden text-xs text-zinc-400 sm:inline">
              unstyled components for LiveView
            </span>
          </.link>

          <nav class="flex items-center gap-1">
            <a
              href="https://github.com/greven/flint_ui"
              class="rounded-md px-3 py-1.5 text-sm text-zinc-600 transition-colors hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-800"
            >
              GitHub
            </a>
            <.theme_toggle />
          </nav>
        </div>
      </header>

      <div class="mx-auto flex max-w-7xl gap-10 px-4 sm:px-6 lg:px-8">
        <aside class="sticky top-14 hidden h-[calc(100vh-3.5rem)] w-52 shrink-0 overflow-y-auto py-8 lg:block">
          <p class="px-2 text-xs font-semibold tracking-wider text-zinc-400 uppercase">
            Components
          </p>
          <nav class="mt-2 flex flex-col gap-4">
            <div :for={{type, components} <- @component_groups} class="flex flex-col gap-0.5">
              <p class="px-2 pb-0.5 text-xs font-medium tracking-wider text-zinc-400 uppercase">
                {type_label(type)}
              </p>
              <.link
                :for={name <- components}
                navigate={~p"/components/#{name}"}
                class={[
                  "rounded-md px-2 py-1.5 text-sm capitalize transition-colors",
                  "hover:bg-zinc-100 dark:hover:bg-zinc-800",
                  @active == name && "bg-zinc-100 font-medium dark:bg-zinc-800",
                  @active != name && "text-zinc-600 dark:text-zinc-400"
                ]}
              >
                {name}
              </.link>
            </div>
          </nav>
        </aside>

        <main class="min-w-0 flex-1 py-8">
          {render_slot(@inner_block)}
        </main>
      </div>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  defp type_label(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="lucide-refresh-cw" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="lucide-refresh-cw" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides a light/dark/system theme toggle.

  The selected theme is applied by the inline script in root.html.heex, which
  listens for the `phx:set-theme` event and reflects it onto `data-theme`.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center rounded-md border border-zinc-200 p-0.5 dark:border-zinc-800">
      <button
        :for={
          {theme, icon} <- [
            {"system", "lucide-monitor"},
            {"light", "lucide-sun"},
            {"dark", "lucide-moon"}
          ]
        }
        type="button"
        class="rounded p-1 text-zinc-500 transition-colors hover:bg-zinc-100 dark:hover:bg-zinc-800"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme={theme}
        aria-label={"Use #{theme} theme"}
      >
        <.icon name={icon} class="size-4" />
      </button>
    </div>
    """
  end
end
