defmodule FlintUIDocsWeb.Examples.Button do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Examples.Snippet

  @base "inline-flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50"

  @solid "bg-zinc-900 text-white hover:bg-zinc-700 focus-visible:outline-zinc-900 dark:bg-white dark:text-zinc-900 dark:hover:bg-zinc-200 dark:focus-visible:outline-white"
  @outline "border border-zinc-300 text-zinc-900 hover:bg-zinc-100 focus-visible:outline-zinc-900 dark:border-zinc-700 dark:text-zinc-100 dark:hover:bg-zinc-800 dark:focus-visible:outline-white"
  @ghost "text-zinc-700 hover:bg-zinc-100 focus-visible:outline-zinc-900 dark:text-zinc-300 dark:hover:bg-zinc-800 dark:focus-visible:outline-white"

  @url "https://hexdocs.pm/phoenix_live_view"

  @impl true
  def controls do
    [
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :loading, type: :boolean, default: false, label: "Loading"}
    ]
  end

  @impl true
  def structure do
    """
    <.button>Save changes</.button>

    <.button type="submit" loading>
      <.loading class="hidden size-4 in-data-loading:inline-block" />
      Save changes
    </.button>

    <.button navigate={~p"/settings"}>Settings</.button>

    <.button href="https://example.com" target="_blank" rel="noopener">
      Visit
    </.button>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :disabled,
        title: "Disabled",
        body: """
        Set `disabled` to prevent interaction. A disabled action button is removed
        from the tab order and ignores pointer and keyboard input.
        """,
        code: """
        <.button disabled>Delete</.button>
        """
      },
      %{
        id: :loading,
        title: "Loading",
        body: """
        Set `loading` while an action is in progress. The button is disabled and
        marked with `aria-busy="true"` and `data-loading` instead of a visual
        change, so you are free to render your own indicator.
        """,
        code: """
        <.button loading>
          <.loading class="hidden size-4 in-data-loading:inline-block" />
          Save
        </.button>
        """
      },
      %{
        id: :link,
        title: "Links",
        body: """
        Pass `href`, `navigate`, or `patch` to render an anchor instead of a
        button. A disabled link keeps its place in the tab order and is marked
        with `aria-disabled`, so its state can still be discovered.
        """,
        code: """
        <.button navigate={~p"/settings"}>Settings</.button>

        <.button href="https://example.com" target="_blank" rel="noopener" disabled>
          Visit
        </.button>
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :icon,
        title: "With an icon",
        description: "Combine an icon with a text label.",
        code: """
        <.button class="#{class(:solid)}">
          <.icon name="lucide-plus" class="size-4" /> New project
        </.button>
        """
      },
      %{
        id: :loading,
        title: "Loading with a spinner",
        description: "Reveal a FlintUI loading indicator via the button's data-loading state.",
        code: """
        <.button loading class="#{class(:solid)}">
          <.loading class="hidden size-4 in-data-loading:inline-block" /> Save
        </.button>
        """
      },
      %{
        id: :link,
        title: "Link button",
        description: "Render an anchor that looks and behaves like a button.",
        code: """
        <.button href="https://hexdocs.pm/phoenix_live_view" target="_blank" rel="noopener" class="#{class(:outline)}">
          View docs <.icon name="lucide-arrow-up-right" class="size-4" />
        </.button>
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The button ships behavior, not appearance. Style it with `class` and target
      the data attributes it exposes for state. The generated component on the
      **Styled** tab adds an opinionated theme on top of this contract.
      """,
      snippets: [
        %{
          title: "Disabled",
          code: """
          [data-element="button"][data-disabled] {
            opacity: 0.5;
            pointer-events: none;
          }
          """
        },
        %{
          title: "Loading",
          code: """
          [data-element="button"][data-loading] .my-spinner {
            display: inline-block;
          }
          """
        },
        %{
          title: "Focus",
          code: """
          [data-element="button"]:focus-visible {
            outline: 2px solid var(--fl-color-ring);
            outline-offset: 2px;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_example(assigns) do
    ~H"""
    <.button
      disabled={@props.disabled}
      loading={@props.loading}
      class={classes(:solid)}
    >
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Button
    </.button>
    """
  end

  @impl true
  def render_code(%{props: props}) do
    Snippet.tag(
      ".button",
      [
        Snippet.flag("disabled", props.disabled),
        Snippet.flag("loading", props.loading)
      ],
      "Button"
    )
  end

  @impl true
  def render_block(%{block: :icon} = assigns) do
    ~H"""
    <.button class={classes(:solid)}>
      <.icon name="lucide-plus" class="size-4" /> New project
    </.button>
    """
  end

  def render_block(%{block: :loading} = assigns) do
    ~H"""
    <.button loading aria-label="Saving" class={classes(:solid)}>
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Save
    </.button>
    """
  end

  def render_block(%{block: :link} = assigns) do
    ~H"""
    <.button href={docs_url()} target="_blank" rel="noopener" class={classes(:outline)}>
      View docs <.icon name="lucide-arrow-up-right" class="size-4" />
    </.button>
    """
  end

  @impl true
  def styled do
    %{
      description:
        "The generated wrapper adds `variant` and `size` attributes and maps them onto the `data-variant` / `data-size` hooks the theme targets.",
      code: """
      <.button variant="solid">Save</.button>
      <.button variant="secondary">Preview</.button>
      <.button variant="outline">Cancel</.button>
      <.button variant="ghost">Edit</.button>
      <.button variant="destructive">Delete</.button>
      <.button variant="link">Learn more</.button>
      """
    }
  end

  @impl true
  def render_styled(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button variant="solid" size="md">Solid</Components.button>
      <Components.button variant="secondary" size="md">Secondary</Components.button>
      <Components.button variant="outline" size="md">Outline</Components.button>
      <Components.button variant="ghost" size="md">Ghost</Components.button>
      <Components.button variant="destructive" size="md">Destructive</Components.button>
      <Components.button variant="link" size="md">Link</Components.button>
    </div>
    <div class="mt-4 flex flex-wrap items-center gap-3">
      <Components.button variant="solid" size="sm">Small</Components.button>
      <Components.button variant="solid" size="md">Medium</Components.button>
      <Components.button variant="solid" size="lg">Large</Components.button>
    </div>
    <div class="mt-4 flex flex-wrap items-center gap-3">
      <Components.button variant="solid" size="md" disabled>Disabled</Components.button>
      <Components.button variant="solid" size="md" loading>Loading</Components.button>
    </div>
    """
  end

  defp classes(variant), do: [@base, variant_class(variant)]

  defp class(variant), do: Enum.join(classes(variant), " ")

  defp variant_class(:solid), do: @solid
  defp variant_class(:outline), do: @outline
  defp variant_class(:ghost), do: @ghost

  defp docs_url, do: @url
end
