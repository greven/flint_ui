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
    <div class="min-h-screen bg-default text-default antialiased">
      <%!-- One provider per document, mounted with the shared layout. --%>
      <FlintUI.sound_provider enabled={false} theme="default" />

      <.site_header sections={@sections} section={@section} page={@page} />

      <div class="mx-auto flex max-w-360 gap-10 px-4 sm:px-6 lg:px-8">
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

        <.toc :if={@section} />
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
            class="size-4 shrink-0 translate-y-px text-toned"
          />
          <.link
            :if={index < length(@crumbs) - 1}
            navigate={crumb.path}
            class="text-muted transition-colors hover:text-default"
          >
            {crumb.label}
          </.link>
          <span
            :if={index == length(@crumbs) - 1}
            class="font-medium text-default"
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
    <div class="sticky top-0 z-20 border-b border-default bg-default/85 backdrop-blur">
      <header>
        <div class="mx-auto grid h-14 max-w-360 grid-cols-[1fr_auto_1fr] items-center gap-2 px-4 sm:gap-4 sm:px-6 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-2 justify-self-start">
            <span class="grid size-6 place-items-center rounded-md bg-inverted text-xs font-bold text-inverted">
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
                  do: "text-default",
                  else: "text-toned hover:bg-muted"
                )
              ]}
            >
              Themes
            </.link>
          </nav>

          <nav class="flex items-center gap-1 justify-self-end">
            <a
              href="https://github.com/greven/flint_ui"
              class="rounded-md px-2 py-1.5 text-sm text-toned transition-colors hover:bg-muted sm:px-3"
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
    <div class="border-t border-default">
      <nav
        aria-label="Documentation sections"
        class="mx-auto flex max-w-360 items-center gap-6 px-4 sm:px-6 lg:px-8"
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
    "border-inverted text-default"
  end

  defp section_class(false) do
    "border-transparent text-muted hover:text-default"
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
        <div class="flex items-center gap-2.5 text-default">
          <.icon name={group.icon} class="size-4" />
          <p class="text-xs font-semibold tracking-wider uppercase">
            {group.label}
          </p>
        </div>
        <nav class="mt-2 ml-2 mr-2 flex flex-col gap-px border-l border-default">
          <.link
            :for={item <- group.pages}
            navigate={item.path}
            aria-current={if page_active?(item, @active, @page), do: "page", else: nil}
            class={[
              "group -ml-px pr-2 pl-1.5 border-l transition-colors hover:text-default",
              sidebar_item_class(page_active?(item, @active, @page))
            ]}
          >
            <div class="px-2 py-1.5 font-medium text-sm capitalize rounded-md group-hover:bg-foreground/5">
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
    do: "border-inverted text-default"

  defp sidebar_item_class(false), do: "border-transparent text-muted"

  @doc """
  Renders the "On this page" outline for the current page's sections.

  The list is built in the browser from the `[data-toc]` headings rendered by
  `DocsComponents.section/1` and `DocsComponents.subsection/1`.
  Scanning the rendered page keeps the outline in step with the Styled/Base/CSS
  tabs without duplicating each page's section structure here.
  """

  attr :title, :string, default: "On this page"

  def toc(assigns) do
    ~H"""
    <aside
      id="on-this-page"
      class="sticky top-24 hidden h-[calc(100vh-6rem)] w-56 shrink-0 overflow-y-auto py-8 pl-6 xl:block"
    >
      <div class="-ml-1 flex items-center gap-2.5 text-default">
        <.icon name="lucide-menu" class="size-4 text-current/50" />
        <p class="text-xs font-semibold tracking-wider uppercase">{@title}</p>
      </div>

      <nav
        id="on-this-page-nav"
        phx-hook=".OnThisPage"
        phx-update="ignore"
        aria-label="On this page"
        class="relative mt-6"
      >
        <ol
          data-toc-list
          class="flex flex-col gap-1.5 border-l border-default text-sm"
        >
        </ol>
      </nav>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".OnThisPage">
        export default {
          mounted() {
            this.main = document.querySelector("main")
            this.list = this.el.querySelector("[data-toc-list]")
            this.items = []
            this.active = null
            this.clicked = null
            this.clickedTimer = null
            this.scrollFrame = null
            this.buildFrame = null

            this.onScroll = () => this.scheduleActive()
            this.onClick = (event) => {
              const link = event.target.closest("[data-toc-link]")
              if (!link) return
              const item = this.items.find((entry) => entry.link === link)
              if (!item) return

              this.clicked = item
              this.setActive(item)
              clearTimeout(this.clickedTimer)
              this.clickedTimer = setTimeout(() => {
                this.clicked = null
              }, 800)
            }

            window.addEventListener("scroll", this.onScroll, {passive: true})
            window.addEventListener("resize", this.onScroll, {passive: true})
            this.list.addEventListener("click", this.onClick)

            this.observer = new MutationObserver(() => this.scheduleBuild())
            if (this.main) this.observer.observe(this.main, {childList: true, subtree: true})

            this.build()
          },

          updated() {
            this.scheduleBuild()
          },

          destroyed() {
            window.removeEventListener("scroll", this.onScroll)
            window.removeEventListener("resize", this.onScroll)
            this.list.removeEventListener("click", this.onClick)
            this.observer?.disconnect()
            clearTimeout(this.clickedTimer)
            if (this.scrollFrame) cancelAnimationFrame(this.scrollFrame)
            if (this.buildFrame) cancelAnimationFrame(this.buildFrame)
          },

          scheduleActive() {
            if (this.scrollFrame) return
            this.scrollFrame = requestAnimationFrame(() => {
              this.scrollFrame = null
              this.updateActive()
            })
          },

          scheduleBuild() {
            if (this.buildFrame) cancelAnimationFrame(this.buildFrame)
            this.buildFrame = requestAnimationFrame(() => {
              this.buildFrame = null
              this.build()
            })
          },

          build() {
            if (!this.main || !this.list) return

            const entries = this.entries()
            const signature = entries
              .map((entry) => `${entry.level}:${entry.id}:${entry.label}`)
              .join("|")

            if (signature === this.signature) return

            this.signature = signature
            this.items = []
            this.list.replaceChildren()
            this.active = null

            let currentSection = null

            for (const entry of entries) {
              const item = document.createElement("li")
              const link = this.link(entry)
              item.appendChild(link)

              if (entry.level === 2) {
                this.list.appendChild(item)
                currentSection = item
              } else if (currentSection) {
                let sublist = currentSection.querySelector(":scope > [data-toc-sublist]")

                if (!sublist) {
                  sublist = document.createElement("ol")
                  sublist.dataset.tocSublist = ""
                  sublist.className = "flex flex-col gap-1"
                  currentSection.appendChild(sublist)
                }

                sublist.appendChild(item)
              } else {
                this.list.appendChild(item)
              }

              this.items.push({element: entry.element, link})
            }

            this.updateActive()
          },

          entries() {
            if (!this.main) return []

            const seen = new Set()
            const entries = []

            for (const heading of this.main.querySelectorAll("[data-toc]")) {
              const target = heading.closest("[id]")
              if (!target || target === this.main || !this.main.contains(target)) continue
              if (!target.id || seen.has(target.id)) continue

              const label = (heading.textContent || "").trim()
              if (!label) continue

              seen.add(target.id)
              entries.push({
                id: target.id,
                label,
                level: heading.dataset.toc === "section" ? 2 : 3,
                element: target,
              })
            }

            return entries
          },

          link(entry) {
            const link = document.createElement("a")
            link.href = `#${entry.id}`
            link.dataset.tocLink = ""
            link.textContent = entry.label
            link.className = [
              "-ml-px block border-l py-1 pr-2 transition-colors",
              entry.level === 2 ? "pl-3" : "pl-7 text-[13px]",
              "border-transparent hover:text-default",
            ].join(" ")

            return link
          },

          updateActive() {
            if (this.items.length === 0 || this.clicked) return

            const threshold = 120
            let current = this.items[0]

            for (const item of this.items) {
              if (item.element.getBoundingClientRect().top <= threshold) current = item
              else break
            }

            const atBottom =
              window.innerHeight + window.scrollY >=
              document.documentElement.scrollHeight - 2
            if (atBottom) current = this.items[this.items.length - 1]

            this.setActive(current)
          },

          setActive(item) {
            if (!item) return

            if (this.active !== item) {
              const inactive = ["border-transparent", "text-muted"]
              const active = ["border-inverted", "text-default", "font-medium"]

              for (const entry of this.items) {
                if (entry === item) {
                  entry.link.classList.remove(...inactive)
                  entry.link.classList.add(...active)
                  entry.link.setAttribute("aria-current", "location")
                } else {
                  entry.link.classList.remove(...active)
                  entry.link.classList.add(...inactive)
                  entry.link.removeAttribute("aria-current")
                }
              }

              this.active = item
            }
          },
        }
      </script>
    </aside>
    """
  end

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
        class="rounded p-1 text-muted transition-colors hover:bg-muted"
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
        class="rounded-md border border-default px-2.5 py-1 text-xs font-medium text-default transition-colors hover:bg-muted"
        phx-click={JS.dispatch("phx:set-preset")}
        data-phx-preset={preset}
      >
        {preset}
      </button>
    </div>
    """
  end
end
