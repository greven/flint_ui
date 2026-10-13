defmodule FlintUIDocsWeb.ThemeLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.DocBlocks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Theming", token_groups: token_groups())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:theming}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Theming</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          Themes are plain CSS. Components read prefixed <code class="font-mono">--fl-*</code>
          custom properties, so FlintUI works with or without Tailwind.
        </p>

        <DocBlocks.section title="How it works" id="how">
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Tokens live on <code class="font-mono">:root</code>
            and switch automatically
            with the user's color scheme through <code class="font-mono">color-scheme</code>
            and <code class="font-mono">light-dark()</code>. No JavaScript is required.
          </p>
          <DocBlocks.code_block code={snippet(:how)} />
        </DocBlocks.section>

        <DocBlocks.section title="Tokens" id="tokens">
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Every component reads from these namespaces. Override any of them to change
            the look.
          </p>
          <div :for={{namespace, tokens} <- @token_groups} class="mt-5">
            <p class="text-xs font-semibold tracking-wider text-zinc-400 uppercase">
              {namespace}
            </p>
            <ul class="mt-2 flex flex-wrap gap-2">
              <li
                :for={token <- tokens}
                class="rounded-md bg-zinc-100 px-2 py-1 font-mono text-xs dark:bg-zinc-800"
              >
                {token}
              </li>
            </ul>
          </div>
        </DocBlocks.section>

        <DocBlocks.section title="Light and dark" id="light-dark">
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Light and dark are automatic. To force a theme, set
            <code class="font-mono">data-theme</code>
            on the <code class="font-mono">&lt;html&gt;</code>
            element — the header's theme toggle does this.
          </p>
          <DocBlocks.code_block code={snippet(:light_dark)} />
        </DocBlocks.section>

        <DocBlocks.section title="Custom themes" id="custom">
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            Add a <code class="font-mono">[data-theme="…"]</code>
            block that overrides the tokens you want, then select it via <code class="font-mono">data-theme</code>.
          </p>
          <DocBlocks.code_block code={snippet(:custom)} />
        </DocBlocks.section>

        <DocBlocks.section title="Tailwind (optional)" id="tailwind">
          <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
            To use tokens as Tailwind utilities, map them in your own <code class="font-mono">@theme</code>.
            <code class="font-mono">mix flint.setup --tailwind</code>
            writes this for you.
          </p>
          <DocBlocks.code_block code={snippet(:tailwind)} />
        </DocBlocks.section>
      </div>
    </Layouts.app>
    """
  end

  defp snippet(:how) do
    """
    :root {
      color-scheme: light dark;
      --fl-color-primary: light-dark(oklch(0.205 0 0), oklch(0.922 0 0));
    }
    """
  end

  defp snippet(:light_dark) do
    """
    <!-- Force a theme -->
    <html data-theme="dark">
    """
  end

  defp snippet(:custom) do
    """
    [data-theme="pastel"] {
      color-scheme: light;
      --fl-color-primary: oklch(0.66 0.14 290);
      --fl-radius-md: 0.625rem;
    }
    """
  end

  defp snippet(:tailwind) do
    """
    @theme inline {
      --color-primary: var(--fl-color-primary);
      --radius-md: var(--fl-radius-md);
    }
    """
  end

  defp token_groups do
    FlintUI.Generator.theme_source()
    |> then(&Regex.scan(~r/--fl-[a-z0-9-]+/, &1))
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.group_by(fn token ->
      token |> String.replace_prefix("--fl-", "") |> String.split("-") |> hd()
    end)
    |> Enum.sort_by(fn {namespace, _} -> namespace end)
  end
end
