defmodule FlintUIDocsWeb.Examples.Collapsible do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example

  @repo_list [
    "@elixir-lang/elixir",
    "@phoenixframework/phoenix",
    "@phoenixframework/phoenix_live_view"
  ]

  @impl true
  def controls do
    [
      %{key: :open, type: :boolean, default: false, label: "Open"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :hidden_until_found, type: :boolean, default: false, label: "Hidden until found"}
    ]
  end

  @impl true
  def variants do
    base = defaults()

    [
      {"Closed", base},
      {"Open", %{base | open: true}},
      {"Disabled", %{base | disabled: true}},
      {"Hidden until found", %{base | hidden_until_found: true}}
    ]
  end

  @impl true
  def structure do
    """
    <.collapsible id="repos">
      <:trigger :let={attrs}>
        <button {attrs}>Toggle repositories</button>
      </:trigger>
      <:content :let={attrs}>
        <ul {attrs}>
          <li>...</li>
        </ul>
      </:content>
    </.collapsible>
    """
    |> String.trim()
  end

  @impl true
  def render_example(assigns) do
    assigns = assign(assigns, :repos, @repo_list)

    ~H"""
    <.collapsible
      id={@id}
      open={@props.open}
      disabled={@props.disabled}
      hidden_until_found={@props.hidden_until_found}
      class="w-full max-w-sm rounded-lg border border-zinc-200 dark:border-zinc-800"
    >
      <:trigger :let={attrs}>
        <div class="flex items-center justify-between gap-4 px-4 py-3">
          <span class="text-sm font-medium">Starred repositories</span>
          <button
            {attrs}
            class="group grid size-7 place-items-center rounded-md text-zinc-500 transition-colors hover:bg-zinc-100 disabled:opacity-50 dark:hover:bg-zinc-800"
            aria-label="Toggle repositories"
          >
            <.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </div>
      </:trigger>
      <:content :let={attrs}>
        <div {attrs}>
          <ul class="flex flex-col gap-2 px-4 pt-1 pb-4">
            <li
              :for={repo <- @repos}
              class="rounded-md bg-zinc-100 px-3 py-2 font-mono text-xs dark:bg-zinc-900"
            >
              {repo}
            </li>
          </ul>
        </div>
      </:content>
    </.collapsible>
    """
  end
end
