defmodule FlintUIDocsWeb.IconsLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUI.Icons
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
        <DocsComponents.page_header title="Icons">
          <:description>
            <code class="docs-code font-mono">&lt;.icon&gt;</code>
            applies <code class="docs-code font-mono">name</code>
            verbatim as a CSS class. FlintUI does not ship icon assets, so this
            guide installs one or more icon sets and wires them for Tailwind or
            plain CSS. Flags have their own guide because they load copied SVG
            files instead of CSS classes.
          </:description>
        </DocsComponents.page_header>

        <DocsComponents.section title="Install assets" id="install">
          <DocsComponents.content_paragraph>
            Icons use <code class="docs-code font-mono">--tailwind</code>
            or <code class="docs-code font-mono">--css</code>. Without a mode flag the task
            detects Tailwind from <code class="docs-code font-mono">assets/css/app.css</code>.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:install)} lang={:shell} />
          <DocsComponents.content_paragraph class="mt-3">
            The task adds the asset as a git dependency
            (<code class="docs-code font-mono">app: false</code>, <code class="docs-code font-mono">compile: false</code>)
            and runs <code class="docs-code font-mono">mix deps.get</code>. The downloaded
            SVGs stay in <code class="docs-code font-mono">deps/</code>; FlintUI's package
            does not redistribute them. With <code class="docs-code font-mono">--css --scan</code>
            the task also installs the <code class="docs-code font-mono">:flint_icons</code>
            compiler, which refreshes the generated CSS on <code class="docs-code font-mono">mix compile</code>.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Supported sets" id="sets">
          <DocsComponents.content_paragraph>
            These are the class prefixes and upstream versions the task installs.
            Each link points at the exact tag the task installs, or at the
            repository root for a set that tracks an untagged commit.
          </DocsComponents.content_paragraph>
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
                <tr :for={{set, meta} <- icon_sets()}>
                  <td class="py-2 pr-4 font-mono">{meta.cli}</td>
                  <td class="py-2 pr-4 font-mono">{meta.classes}</td>
                  <td class="py-2 whitespace-nowrap">
                    <a
                      href={Icons.source_url(set)}
                      target="_blank"
                      rel="noopener"
                      class="docs-link"
                    >
                      {meta.label} {Icons.version_label(set)}
                    </a>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </DocsComponents.section>

        <DocsComponents.section title="Phosphor weights" id="weights">
          <DocsComponents.content_paragraph>
            Phosphor draws each weight as its own SVG geometry, so the weight is
            part of the class name rather than a stroke setting. The regular
            weight has no suffix; the other five do. All six share the 24px box
            and read <code class="docs-code font-mono">--fl-icon-size</code> like every other set.
          </DocsComponents.content_paragraph>
          <div class="mt-4 flex flex-wrap items-end gap-6 [--fl-icon-size:2rem]">
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house text-primary"></span>
              <span class="text-xs text-muted">regular</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house-thin text-primary"></span>
              <span class="text-xs text-muted">thin</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house-light text-primary"></span>
              <span class="text-xs text-muted">light</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house-bold text-primary"></span>
              <span class="text-xs text-muted">bold</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house-fill text-primary"></span>
              <span class="text-xs text-muted">fill</span>
            </div>
            <div class="flex flex-col items-center gap-2">
              <span class="ph-house-duotone text-primary"></span>
              <span class="text-xs text-muted">duotone</span>
            </div>
          </div>
          <DocsComponents.code_block code={snippet(:weights)} />
          <DocsComponents.content_paragraph class="mt-3">
            A duotone icon keeps its second tone because the mask reads the
            path's opacity as alpha, so the fill is a translucent <code class="docs-code font-mono">currentColor</code>. Tint it like
            any other icon:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:duotone)} />
        </DocsComponents.section>

        <DocsComponents.section title="Tailwind" id="tailwind">
          <DocsComponents.content_paragraph>
            Tailwind mode writes a plugin to <code class="docs-code font-mono">assets/vendor/</code>
            and adds the matching <code class="docs-code font-mono">@plugin</code>
            line. Tailwind then emits a class when it finds that class literally
            in your source.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:tailwind)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            A name built at runtime is invisible to the scanner. Safelist only the
            icons you use, or choose them from a fixed list. Restart
            <code class="docs-code font-mono">mix assets.watch</code>
            or <code class="docs-code font-mono">mix phx.server</code>
            if it is already running.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Plain CSS" id="css">
          <DocsComponents.content_paragraph>
            Plain CSS mode generates
            <code class="docs-code font-mono">assets/css/flint-&lt;set&gt;.css</code>
            from the downloaded SVGs and imports it from your app stylesheet.
            Add <code class="docs-code font-mono">--scan</code>
            to emit only the classes found in your source. Without
            <code class="docs-code font-mono">--scan</code>
            every icon in the set is emitted.
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:css)} lang={:css} />
          <DocsComponents.content_paragraph class="mt-3">
            Re-run
            <code class="docs-code font-mono">mix flint.icons.generate &lt;set&gt; --scan</code>
            after updating an asset dependency or adding new icons. Names built
            at runtime are invisible to the scanner; add them with
            <code class="docs-code font-mono">--safelist</code>
            or <code class="docs-code font-mono">config :flint_ui, icon_safelist: [...]</code>.
            The compiler follows the <code class="docs-code font-mono">@import</code>
            lines in <code class="docs-code font-mono">app.css</code>
            and regenerates those files on compile. The generated classes read <code class="docs-code font-mono">--fl-icon-size</code>, so they work with the
            styled icon or with any element that sets that variable.
          </DocsComponents.content_paragraph>
          <DocsComponents.content_paragraph class="mt-3">
            Scanned CSS stays small because only used classes are written. Full-set
            CSS embeds every SVG as a data URI; that is convenient but heavy for
            Heroicons, Phosphor, and Simple Icons. Prefer
            <code class="docs-code font-mono">--scan</code>
            for production, or use Tailwind mode.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>

        <DocsComponents.section title="Use the icons" id="usage">
          <DocsComponents.content_paragraph>
            Icons use the generated class name. The styled
            <code class="docs-code font-mono">&lt;.icon&gt;</code>
            owns the icon box and exposes <code class="docs-code font-mono">size</code>:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:usage)} />
        </DocsComponents.section>

        <DocsComponents.section title="Accessibility" id="accessibility">
          <DocsComponents.content_paragraph>
            Icons are decorative by default and hidden from assistive technology.
            When an icon is the only content, pass <code class="docs-code font-mono">label</code>
            to expose it as an image with an accessible name:
          </DocsComponents.content_paragraph>
          <DocsComponents.code_block code={snippet(:accessibility)} />
        </DocsComponents.section>

        <DocsComponents.section title="Licenses" id="licenses">
          <DocsComponents.content_paragraph>
            The assets are fetched from their upstream repositories and keep
            their original licenses: Heroicons (MIT), Lucide (ISC), Phosphor
            (MIT), and Simple Icons (CC0-1.0). Review the upstream notice before redistributing
            them.
          </DocsComponents.content_paragraph>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end

  # The sets this guide installs as classes; flags have their own guide because
  # they copy SVGs instead of generating mask rules.
  defp icon_sets do
    for set <- Icons.sets(), set != :flag_icons, do: {set, Icons.get!(set)}
  end

  defp snippet(:install) do
    """
    # Tailwind
    mix flint.icons lucide --tailwind
    mix flint.icons phosphor --tailwind
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
    @plugin "../vendor/phosphor";
    @plugin "../vendor/simple-icons";
    """
    |> String.trim()
  end

  defp snippet(:css) do
    """
    @import "./flint.css";
    @import "./flint-heroicons.css";
    @import "./flint-lucide.css";
    @import "./flint-phosphor.css";
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
    <.icon name="ph-house" />
    <.icon name="ph-house-duotone" />
    <.icon name="si-github" />
    """
    |> String.trim()
  end

  defp snippet(:weights) do
    """
    <.icon name="ph-house" />
    <.icon name="ph-house-thin" />
    <.icon name="ph-house-light" />
    <.icon name="ph-house-bold" />
    <.icon name="ph-house-fill" />
    <.icon name="ph-house-duotone" />
    """
    |> String.trim()
  end

  defp snippet(:duotone) do
    """
    <.icon name="ph-shield-check-duotone" class="size-5 text-info" />
    """
    |> String.trim()
  end

  defp snippet(:accessibility) do
    """
    <.icon name="lucide-circle-exclamation-point" label="Error" />
    """
    |> String.trim()
  end
end
