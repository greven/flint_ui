defmodule FlintUIDocsWeb.IconsLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Icons")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:icons}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Icons</h1>
        <p class="mt-3 text-default">
          <code class="font-mono">&lt;.icon&gt;</code>
          applies <code class="font-mono">name</code>
          verbatim as a CSS class. FlintUI does not ship icon assets, so this
          guide installs one or more icon sets and wires them for Tailwind or
          plain CSS. Flags have their own guide because they load copied SVG
          files instead of CSS classes.
        </p>

        <DocsComponents.section title="Install assets" id="install">
          <p class="text-sm text-default">
            Icons use <code class="font-mono">--tailwind</code>
            or <code class="font-mono">--css</code>. Without a mode flag the task
            detects Tailwind from <code class="font-mono">assets/css/app.css</code>.
          </p>
          <DocsComponents.code_block code={snippet(:install)} lang={:shell} />
          <p class="mt-3 text-sm text-default">
            The task adds the asset as a git dependency
            (<code class="font-mono">app: false</code>, <code class="font-mono">compile: false</code>)
            and runs <code class="font-mono">mix deps.get</code>. The downloaded
            SVGs stay in <code class="font-mono">deps/</code>; FlintUI's package
            does not redistribute them. With <code class="font-mono">--css --scan</code>
            the task also installs the <code class="font-mono">:flint_icons</code>
            compiler, which refreshes the generated CSS on <code class="font-mono">mix compile</code>.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Supported sets" id="sets">
          <p class="text-sm text-default">
            These are the class prefixes and upstream versions the task installs.
          </p>
          <div class="mt-3 overflow-x-auto">
            <table class="w-full text-left text-sm">
              <thead class="text-xs tracking-wider text-muted uppercase">
                <tr>
                  <th class="py-2 pr-4 font-medium">Set</th>
                  <th class="py-2 pr-4 font-medium">Classes</th>
                  <th class="py-2 font-medium">Source</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-default">
                <tr>
                  <td class="py-2 pr-4 font-mono">heroicons</td>
                  <td class="py-2 pr-4 font-mono">
                    hero-&lt;name&gt;, hero-&lt;name&gt;-solid, hero-&lt;name&gt;-mini, hero-&lt;name&gt;-micro
                  </td>
                  <td class="py-2 text-toned">Heroicons v2.2.0</td>
                </tr>
                <tr>
                  <td class="py-2 pr-4 font-mono">lucide</td>
                  <td class="py-2 pr-4 font-mono">lucide-&lt;name&gt;</td>
                  <td class="py-2 text-toned">Lucide 1.30.0</td>
                </tr>
                <tr>
                  <td class="py-2 pr-4 font-mono">simple_icons</td>
                  <td class="py-2 pr-4 font-mono">si-&lt;name&gt;</td>
                  <td class="py-2 text-toned">Simple Icons 16.9.0</td>
                </tr>
              </tbody>
            </table>
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Tailwind" id="tailwind">
          <p class="text-sm text-default">
            Tailwind mode writes a plugin to <code class="font-mono">assets/vendor/</code>
            and adds the matching <code class="font-mono">@plugin</code>
            line. Tailwind then emits a class when it finds that class literally
            in your source.
          </p>
          <DocsComponents.code_block code={snippet(:tailwind)} lang={:css} />
          <p class="mt-3 text-sm text-default">
            A name built at runtime is invisible to the scanner. Safelist only the
            icons you use, or choose them from a fixed list. Restart
            <code class="font-mono">mix assets.watch</code>
            or <code class="font-mono">mix phx.server</code>
            if it is already running.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Plain CSS" id="css">
          <p class="text-sm text-default">
            Plain CSS mode generates <code class="font-mono">assets/css/flint-&lt;set&gt;.css</code>
            from the downloaded SVGs and imports it from your app stylesheet.
            Add <code class="font-mono">--scan</code>
            to emit only the classes found in your source. Without
            <code class="font-mono">--scan</code>
            every icon in the set is emitted.
          </p>
          <DocsComponents.code_block code={snippet(:css)} lang={:css} />
          <p class="mt-3 text-sm text-default">
            Re-run <code class="font-mono">mix flint.icons.generate &lt;set&gt; --scan</code>
            after updating an asset dependency or adding new icons. Names built
            at runtime are invisible to the scanner; add them with
            <code class="font-mono">--safelist</code>
            or <code class="font-mono">config :flint_ui, icon_safelist: [...]</code>.
            The compiler follows the <code class="font-mono">@import</code>
            lines in <code class="font-mono">app.css</code>
            and regenerates those files on compile. The generated classes read <code class="font-mono">--fl-icon-size</code>, so they work with the
            styled icon or with any element that sets that variable.
          </p>
          <p class="mt-3 text-sm text-default">
            Scanned CSS stays small because only used classes are written. Full-set
            CSS embeds every SVG as a data URI; that is convenient but heavy for
            Heroicons and Simple Icons. Prefer <code class="font-mono">--scan</code>
            for production, or use Tailwind mode.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Use the icons" id="usage">
          <p class="text-sm text-default">
            Icons use the generated class name. The styled
            <code class="font-mono">&lt;.icon&gt;</code>
            owns the icon box and exposes <code class="font-mono">size</code>:
          </p>
          <DocsComponents.code_block code={snippet(:usage)} />
        </DocsComponents.section>

        <DocsComponents.section title="Accessibility" id="accessibility">
          <p class="text-sm text-default">
            Icons are decorative by default and hidden from assistive technology.
            When an icon is the only content, pass <code class="font-mono">label</code>
            to expose it as an image with an accessible name:
          </p>
          <DocsComponents.code_block code={snippet(:accessibility)} />
        </DocsComponents.section>

        <DocsComponents.section title="Licenses" id="licenses">
          <p class="text-sm text-default">
            The assets are fetched from their upstream repositories and keep
            their original licenses: Heroicons (MIT), Lucide (ISC), and Simple
            Icons (CC0-1.0). Review the upstream notice before redistributing
            them.
          </p>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:install) do
    """
    # Tailwind
    mix flint.icons lucide --tailwind
    mix flint.icons heroicons simple_icons --tailwind

    # Plain CSS
    mix flint.icons lucide --css
    mix flint.icons lucide --css --scan
    mix flint.icons lucide --css --scan --safelist lucide-wifi
    """
    |> String.trim()
  end

  defp snippet(:tailwind) do
    """
    @import "tailwindcss";
    @import "./flint.css";

    @plugin "../vendor/heroicons";
    @plugin "../vendor/lucide";
    @plugin "../vendor/simple-icons";
    """
    |> String.trim()
  end

  defp snippet(:css) do
    """
    @import "./flint.css";
    @import "./flint-heroicons.css";
    @import "./flint-lucide.css";
    @import "./flint-simple-icons.css";
    """
    |> String.trim()
  end

  defp snippet(:usage) do
    """
    <.icon name="hero-x-mark" />
    <.icon name="hero-x-mark-solid" />
    <.icon name="hero-x-mark-mini" />
    <.icon name="hero-x-mark-micro" />

    <.icon name="lucide-house" />
    <.icon name="si-github" />
    """
    |> String.trim()
  end

  defp snippet(:accessibility) do
    """
    <.icon name="lucide-circle-alert" label="Error" />
    """
    |> String.trim()
  end
end
