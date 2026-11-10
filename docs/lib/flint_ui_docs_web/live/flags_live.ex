defmodule FlintUIDocsWeb.FlagsLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocsComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Flags")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:flags}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Flags</h1>
        <p class="mt-3 text-default">
          <code class="font-mono">&lt;.flag&gt;</code>
          loads a copied SVG from <code class="font-mono">/images/flags</code>
          using <code class="font-mono">code</code>
          and <code class="font-mono">shape</code>. Because the URL is built at
          runtime, the code can be dynamic and the same markup works with
          Tailwind or plain CSS. No class scanning or safelist is involved.
        </p>

        <DocsComponents.section title="Install assets" id="install">
          <p class="text-sm text-default">
            Install Flag Icons with <code class="font-mono">--assets</code>. The
            task copies the 4:3 and 1:1 SVGs to <code class="font-mono">priv/static/images/flags</code>, which is
            already served by the default Phoenix <code class="font-mono">Plug.Static</code>
            allowlist.
          </p>
          <DocsComponents.code_block code={snippet(:install)} lang={:shell} />
          <p class="mt-3 text-sm text-default">
            The task adds the asset as a git dependency
            (<code class="font-mono">app: false</code>, <code class="font-mono">compile: false</code>)
            and runs <code class="font-mono">mix deps.get</code>. Re-run
            <code class="font-mono">mix flint.icons.copy_flags</code>
            after
            updating the dependency. Pass <code class="font-mono">--only pt,us</code>
            to copy a subset; pass <code class="font-mono">--dest</code>
            to copy
            elsewhere and set <code class="font-mono">config :flint_ui, flag_path: "/..."</code>
            to match.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Asset layout" id="assets">
          <p class="text-sm text-default">
            The component maps the shape to a file and the code to a filename:
          </p>
          <DocsComponents.code_block code={snippet(:assets)} lang={:text} />
          <p class="mt-3 text-sm text-default">
            The default base URL is <code class="font-mono">/images/flags</code>.
            Override it for the whole app with <code class="font-mono">config :flint_ui, flag_path: "/images/flags"</code>,
            or per instance with the <code class="font-mono">path</code> attribute.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Dynamic flags" id="dynamic">
          <p class="text-sm text-default">
            Pass the selected code directly. Changing the assign changes the
            image URL on the next render, so this works in a dropdown, table, or
            any data-driven list:
          </p>
          <DocsComponents.code_block code={snippet(:dynamic)} />
          <p class="mt-3 text-sm text-default">
            Give a meaningful flag a <code class="font-mono">label</code>; leave
            decorative flags unlabeled. A flag is not a language.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Shapes" id="shapes">
          <p class="text-sm text-default">
            <code class="font-mono">regular</code>
            uses the 4:3 file, <code class="font-mono">square</code>
            uses the 1:1 file, and <code class="font-mono">round</code>
            uses the 1:1 file with a full radius:
          </p>
          <DocsComponents.code_block code={snippet(:shapes)} />
        </DocsComponents.section>

        <DocsComponents.section title="Raw flag classes" id="classes">
          <p class="text-sm text-default">
            The <code class="font-mono">&lt;.flag&gt;</code>
            component does not
            need generated classes. If you also want the raw <code class="font-mono">flag-*</code>
            classes for direct use, install
            the set in Tailwind or plain CSS mode. Tailwind mode still writes a
            Flag Icons vendor plugin:
          </p>
          <DocsComponents.code_block code={snippet(:classes)} lang={:shell} />
          <DocsComponents.code_block code={snippet(:tailwind)} lang={:css} />
          <p class="mt-3 text-sm text-default">
            The plugin emits <code class="font-mono">flag-&lt;code&gt;</code>
            and <code class="font-mono">flag-&lt;code&gt;-square</code>
            when it finds
            those classes literally in source, so dynamic names still need a
            safelist. That limitation does not apply to <code class="font-mono">&lt;.flag&gt;</code>, which uses the copied
            SVGs instead.
          </p>
          <DocsComponents.code_block code={snippet(:class_usage)} />
        </DocsComponents.section>

        <DocsComponents.section title="Accessibility" id="accessibility">
          <p class="text-sm text-default">
            A flag is decorative by default and hidden from assistive technology.
            When it conveys meaning on its own, pass <code class="font-mono">label</code>
            to expose it as an image with an accessible name:
          </p>
          <DocsComponents.code_block code={snippet(:accessibility)} />
          <p class="mt-3 text-sm text-default">
            Use a text label for a language and only use a flag when it
            represents the country or region itself.
          </p>
        </DocsComponents.section>

        <DocsComponents.section title="Licenses" id="licenses">
          <p class="text-sm text-default">
            Flag Icons are fetched from their upstream repository and keep their
            original MIT license. Review the upstream notice before
            redistributing them.
          </p>
        </DocsComponents.section>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:install) do
    """
    mix flint.icons flags --assets
    mix flint.icons flags --assets --only pt,us,br
    mix flint.icons.copy_flags
    """
    |> String.trim()
  end

  defp snippet(:assets) do
    """
    /images/flags/pt.svg          # regular
    /images/flags/pt-square.svg   # square or round
    """
    |> String.trim()
  end

  defp snippet(:dynamic) do
    """
    <.flag code={@country} shape={@shape} label={@country_name} />
    """
    |> String.trim()
  end

  defp snippet(:shapes) do
    """
    <.flag code="pt" />
    <.flag code="pt" shape="square" />
    <.flag code="pt" shape="round" />
    """
    |> String.trim()
  end

  defp snippet(:classes) do
    """
    mix flint.icons flags --tailwind
    mix flint.icons flags --css --scan
    """
    |> String.trim()
  end

  defp snippet(:tailwind) do
    """
    @import "tailwindcss";
    @import "./flint.css";

    @plugin "../vendor/flag-icons";
    """
    |> String.trim()
  end

  defp snippet(:class_usage) do
    """
    <span class="flag-pt"></span>
    <span class="flag-pt-square"></span>
    """
    |> String.trim()
  end

  defp snippet(:accessibility) do
    """
    <.flag code="pt" label="Portugal" />
    """
    |> String.trim()
  end
end
