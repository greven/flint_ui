defmodule FlintUIDocsWeb.Layouts do
  @moduledoc """
  Layouts and shared shell for the FlintUI docs site.
  """
  use FlintUIDocsWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates("layouts/*")

  @doc """
  Renders the docs shell: header, section bar, sidebar, and content area.

  ## Examples

      <Layouts.app flash={@flash} active={@active}>
        <h1>Content</h1>
      </Layouts.app>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :active, :atom, default: nil, doc: "the active component, highlighted in the sidebar"
  attr :section, :atom, default: nil, doc: "the active top-level documentation section"
  attr :page, :atom, default: nil, doc: "the active page id, highlighted in the sidebar"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    assigns =
      assigns
      |> assign(:sections, FlintUIDocsWeb.Nav.sections())
      |> assign(:breadcrumbs, breadcrumb_trail(assigns))

    ~H"""
    <div class="min-h-screen bg-white text-zinc-900 antialiased dark:bg-zinc-950 dark:text-zinc-100">
      <%!-- One provider per document, mounted with the shared layout. --%>
      <FlintUI.sound_provider enabled={false} theme="default" />

      <.site_header sections={@sections} section={@section} page={@page} />

      <div class="mx-auto flex max-w-7xl gap-10 px-4 sm:px-6 lg:px-8">
        <.sidebar
          :if={@section}
          active={@active}
          page={@page}
          section={FlintUIDocsWeb.Nav.get!(@section)}
          class="sticky top-24"
        />

        <main class="min-w-0 flex-1 py-8">
          <.breadcrumbs :if={@breadcrumbs != []} crumbs={@breadcrumbs} />
          {render_slot(@inner_block)}
        </main>
      </div>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  defp breadcrumb_trail(%{section: nil}), do: []
  defp breadcrumb_trail(%{section: :components, active: nil}), do: []

  defp breadcrumb_trail(%{section: :components, active: active}) do
    FlintUIDocsWeb.Nav.breadcrumbs(:components, active)
  end

  defp breadcrumb_trail(%{section: section, page: page}) do
    FlintUIDocsWeb.Nav.breadcrumbs(section, page)
  end

  @doc """
  Renders the section/group breadcrumb trail shown above a page title.

  Ancestor crumbs are links; the final crumb is the current context and is
  rendered in the accent colour.
  """
  attr :crumbs, :list, required: true, doc: "the trail from `FlintUIDocsWeb.Nav.breadcrumbs/2`"

  def breadcrumbs(assigns) do
    ~H"""
    <nav aria-label="Breadcrumb" class="mb-4">
      <ol class="flex flex-wrap items-center gap-1.5 text-sm">
        <li :for={{crumb, index} <- Enum.with_index(@crumbs)} class="flex items-center gap-1.5">
          <.icon
            :if={index > 0}
            name="lucide-chevron-right"
            class="size-4 shrink-0 translate-y-px text-zinc-300 dark:text-zinc-600"
          />
          <.link
            :if={index < length(@crumbs) - 1}
            navigate={crumb.path}
            class="text-zinc-500 transition-colors hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
          >
            {crumb.label}
          </.link>
          <span
            :if={index == length(@crumbs) - 1}
            class="font-medium text-zinc-900 dark:text-white"
          >
            {crumb.label}
          </span>
        </li>
      </ol>
    </nav>
    """
  end

  @doc """
  Renders the sticky docs header: the brand bar and the section switcher.
  """

  attr :sections, :list, required: true, doc: "the sections from `FlintUIDocsWeb.Nav.sections/0`"
  attr :section, :atom, default: nil, doc: "the active section id"
  attr :page, :atom, default: nil, doc: "the active page id"

  def site_header(assigns) do
    ~H"""
    <div class="sticky top-0 z-20 border-b border-zinc-200 bg-white/85 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/85">
      <header>
        <div class="mx-auto grid h-14 max-w-7xl grid-cols-[1fr_auto_1fr] items-center gap-2 px-4 sm:gap-4 sm:px-6 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-2 justify-self-start">
            <span class="grid size-6 place-items-center rounded-md bg-zinc-900 text-xs font-bold text-white dark:bg-white dark:text-zinc-900">
              F
            </span>
            <span class="font-semibold tracking-tight">FlintUI</span>
          </.link>

          <nav aria-label="Primary" class="justify-self-center">
            <.link
              navigate={~p"/themes"}
              aria-current={if @page == :themes, do: "page", else: nil}
              class={[
                "rounded-md px-2 py-1.5 text-sm font-medium whitespace-nowrap transition-colors sm:px-3",
                if(@page == :themes,
                  do: "text-zinc-900 dark:text-white",
                  else: "text-zinc-600 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-800"
                )
              ]}
            >
              Themes
            </.link>
          </nav>

          <nav class="flex items-center gap-1 justify-self-end">
            <a
              href="https://github.com/greven/flint_ui"
              class="rounded-md px-2 py-1.5 text-sm text-zinc-600 transition-colors hover:bg-zinc-100 sm:px-3 dark:text-zinc-400 dark:hover:bg-zinc-800"
              aria-label="FlintUI on GitHub"
            >
              <.icon name="lucide-github" class="size-4 sm:hidden" />
              <span class="hidden sm:inline">GitHub</span>
            </a>
            <.theme_toggle />
          </nav>
        </div>
      </header>

      <.section_nav sections={@sections} section={@section} />
    </div>
    """
  end

  @doc """
  Renders the section switcher shown beneath the brand bar.
  """
  attr :sections, :list, required: true, doc: "the sections from `FlintUIDocsWeb.Nav.sections/0`"
  attr :section, :atom, default: nil, doc: "the active section id"

  def section_nav(assigns) do
    ~H"""
    <div class="border-t border-zinc-200 dark:border-zinc-800">
      <nav
        aria-label="Documentation sections"
        class="mx-auto flex max-w-7xl items-center gap-6 px-4 sm:px-6 lg:px-8"
      >
        <.link
          :for={section <- @sections}
          navigate={FlintUIDocsWeb.Nav.first_page_path(section)}
          id={section_dom_id(section.id)}
          aria-current={if @section == section.id, do: "page", else: nil}
          class={[
            "-mb-px border-b-2 font-medium py-2.5 text-sm transition-colors",
            section_class(@section == section.id)
          ]}
        >
          {section.label}
        </.link>
      </nav>
    </div>
    """
  end

  defp section_dom_id(id) do
    "section-" <> (id |> Atom.to_string() |> String.replace("_", "-"))
  end

  defp section_class(true) do
    "border-zinc-900 text-zinc-900 dark:border-white dark:text-white"
  end

  defp section_class(false) do
    "border-transparent text-zinc-500 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
  end

  @doc false

  attr :class, :string, default: nil
  attr :active, :atom, default: nil
  attr :page, :atom, default: nil
  attr :section, :map, required: true

  def sidebar(assigns) do
    ~H"""
    <aside class={[
      @class,
      "hidden h-[calc(100vh-6rem)] w-52 shrink-0 overflow-y-auto py-8 lg:block"
    ]}>
      <div :for={group <- @section.groups} class="mb-6 last:mb-0">
        <div class="flex items-center gap-2.5 text-zinc-800 dark:text-zinc-100">
          <.icon name={group.icon} class="size-4" />
          <p class="text-xs font-semibold tracking-wider uppercase">
            {group.label}
          </p>
        </div>
        <nav class="mt-2 ml-2 mr-2 flex flex-col gap-px border-l border-zinc-200 dark:border-zinc-800">
          <.link
            :for={item <- group.pages}
            navigate={item.path}
            aria-current={if page_active?(item, @active, @page), do: "page", else: nil}
            class={[
              "group -ml-px pr-2 pl-1.5 border-l transition-colors hover:text-zinc-800 dark:hover:text-zinc-100",
              sidebar_item_class(page_active?(item, @active, @page))
            ]}
          >
            <div class="px-2 py-1.5 font-medium text-sm capitalize rounded-md group-hover:bg-zinc-400/5 dark:group-hover:bg-zinc-50/5">
              {item.label}
            </div>
          </.link>
        </nav>
      </div>
    </aside>
    """
  end

  defp page_active?(%{name: name}, active, _page) when not is_nil(name), do: active == name
  defp page_active?(item, _active, page), do: page == item.id

  defp sidebar_item_class(true),
    do: "border-zinc-900 text-zinc-900 dark:border-white dark:text-white"

  defp sidebar_item_class(false), do: "border-transparent text-zinc-500 dark:text-zinc-400"

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

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
  Provides a light/dark/system scheme toggle.

  The selected scheme is applied by the inline script in root.html.heex, which
  listens for the `phx:set-scheme` event and reflects it onto `data-color-scheme`.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center p-0.5">
      <button
        :for={
          {scheme, icon} <- [
            {"system", "lucide-monitor"},
            {"light", "lucide-sun"},
            {"dark", "lucide-moon"}
          ]
        }
        type="button"
        class="rounded p-1 text-zinc-500 transition-colors hover:bg-zinc-100 dark:hover:bg-zinc-800"
        phx-click={JS.dispatch("phx:set-scheme")}
        data-phx-scheme={scheme}
        aria-label={"Use #{scheme} scheme"}
      >
        <.icon name={icon} class="size-4" />
      </button>
    </div>
    """
  end

  @doc """
  Provides a theme preset picker.

  Selecting a preset dispatches `phx:set-preset`, which the inline script in
  root.html.heex reflects onto `data-theme`.
  """
  attr :themes, :list, required: true
  attr :class, :any, default: nil

  def theme_preset_picker(assigns) do
    ~H"""
    <div class={["flex flex-wrap gap-1.5", @class]}>
      <button
        :for={preset <- @themes}
        type="button"
        class="rounded-md border border-zinc-200 px-2.5 py-1 text-xs font-medium text-zinc-700 transition-colors hover:bg-zinc-100 dark:border-zinc-800 dark:text-zinc-300 dark:hover:bg-zinc-800"
        phx-click={JS.dispatch("phx:set-preset")}
        data-phx-preset={preset}
      >
        {preset}
      </button>
    </div>
    """
  end
end
