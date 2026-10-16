defmodule FlintUIDocsWeb.ComponentDocs.Card do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :card

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, default: "outline", label: "Variant"},
      %{key: :size, type: :select, default: "md", label: "Size"},
      %{key: :flush, type: :boolean, default: false, label: "Flush"}
    ]
  end

  @impl true
  def usage do
    [
      %{
        id: :root,
        title: "Root element",
        layer: :base,
        body: """
        The card renders a root element with `data-part` hooks for each region.
        Body content goes in the default slot; the `title`, `description`,
        `action`, `header` and `footer` slots are optional. Choose the root
        element with `as` when a landmark or list item is appropriate.
        """,
        code: """
        <.card as="section">
          <:title>Deployments</:title>
          <p>Your latest deployment is live.</p>
        </.card>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets: `outline`, `solid` or `subtle`.
        """,
        code: """
        <div class="flex flex-col gap-4">
          <.card :for={variant <- ~w(outline solid subtle)} variant={variant}>
            <:title>{variant}</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        body: """
        `size` sets the internal spacing through `--fl-card-spacing`.
        """,
        code: """
        <div class="flex flex-col gap-4">
          <.card :for={size <- ~w(sm md lg)} size={size}>
            <:title>{size}</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :flush,
        title: "Flush",
        layer: :base,
        body: """
        Set `flush` to remove the card's internal spacing so the content manages
        its own inset, for example a full-bleed collapsible. It overrides `size`.
        """,
        code: """
        <.card flush>
          <p>Full-bleed content</p>
        </.card>
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :sectioned,
        title: "Header, body and footer",
        description: "A card with a title, description, action, body and footer.",
        code: """
        <.card class="w-full max-w-md">
          <:title>Deployments</:title>
          <:description>Manage your project's deployments.</:description>
          <:action>
            <.button variant="ghost" size="sm">Edit</.button>
          </:action>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Your latest deployment is live.
          </p>
          <:footer>
            <.button variant="outline" size="sm">View logs</.button>
          </:footer>
        </.card>
        """
      },
      %{
        id: :collapsible,
        title: "Expanding card",
        description: "A flush card wrapping a collapsible, with a full-bleed trigger.",
        code: """
        <.card flush class="w-full max-w-md">
          <.collapsible id="repos">
            <:trigger :let={attrs}>
              <button {attrs} class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium">
                Starred repositories
                <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
              </button>
            </:trigger>
            <:content :let={attrs}>
              <div {attrs}>
                <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
                  <li>flint_ui</li>
                  <li>phoenix_live_view</li>
                </ul>
              </div>
            </:content>
          </.collapsible>
        </.card>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The card renders a root element containing up to three regions. The header
      is rendered only when a `title`, `description`, `action` or `header` slot is
      given; the footer only when a `footer` slot is given. The body is always
      rendered.
      """,
      nodes: [
        %{
          tag: "div",
          selector: ~s([data-element="card"][data-part="root"]),
          hooks: ["data-variant", "data-size", "data-flush"],
          attributes: ["class", "as"],
          children: [
            %{
              tag: "div",
              selector: ~s([data-part="header"]),
              children: [
                %{tag: "div", selector: ~s([data-part="title"]), children: []},
                %{tag: "div", selector: ~s([data-part="description"]), children: []},
                %{tag: "div", selector: ~s([data-part="action"]), children: []},
                %{tag: "div", selector: ~s([data-part="header-content"]), children: []}
              ]
            },
            %{tag: "div", selector: ~s([data-part="body"]), children: []},
            %{tag: "div", selector: ~s([data-part="footer"]), children: []}
          ]
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The card ships a themed surface through the `data-variant` hook and spacing
      through `--fl-card-spacing`. `data-flush` zeroes that spacing so content can
      manage its own inset. The headless base renders only the structure, so you
      can style the `data-part` regions yourself.
      """,
      snippets: [
        %{
          title: "Surface",
          code: """
          [data-element="card"][data-variant="outline"] {
            border: 1px solid var(--fl-color-border);
            background: var(--fl-color-card);
            border-radius: var(--fl-radius-xl);
          }
          """
        },
        %{
          title: "Spacing",
          code: """
          [data-element="card"] {
            --fl-card-spacing: 1.25rem;
            padding-block: var(--fl-card-spacing);
            gap: var(--fl-card-spacing);
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.card variant={@props.variant} size={@props.size} flush={@props.flush}>
      <:title>Starred repositories</:title>
      <:description>Updated just now</:description>
      <p>Reorder or remove the repositories you follow.</p>
      <:footer>3 repositories</:footer>
    </Components.card>
    """
  end

  def render_playground(assigns) do
    ~H"""
    <.card flush={@props.flush}>
      <:title>Starred repositories</:title>
      <:description>Updated just now</:description>
      <p>Reorder or remove the repositories you follow.</p>
      <:footer>3 repositories</:footer>
    </.card>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".card",
      [
        Snippet.attr("variant", props.variant, "outline"),
        Snippet.attr("size", props.size, "md"),
        Snippet.flag("flush", props.flush)
      ],
      body_code()
    )
  end

  def render_code(%{props: props}) do
    Snippet.tag(".card", [Snippet.flag("flush", props.flush)], body_code())
  end

  defp body_code do
    """
    <:title>Starred repositories</:title>
    <:description>Updated just now</:description>
    <p>Reorder or remove the repositories you follow.</p>
    <:footer>3 repositories</:footer>
    """
    |> String.trim()
  end

  @impl true
  def render_usage(%{block: :root} = assigns) do
    ~H"""
    <.card as="section">
      <:title>Deployments</:title>
      <p>Your latest deployment is live.</p>
    </.card>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col gap-4">
      <Components.card :for={variant <- ~w(outline solid subtle)} variant={variant}>
        <:title>{variant}</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col gap-4">
      <Components.card :for={size <- ~w(sm md lg)} size={size}>
        <:title>{size}</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :flush} = assigns) do
    ~H"""
    <Components.card flush>
      <p>Full-bleed content</p>
    </Components.card>
    """
  end

  @impl true
  def render_block(%{block: :sectioned} = assigns) do
    ~H"""
    <Components.card class="w-full max-w-md">
      <:title>Deployments</:title>
      <:description>Manage your project's deployments.</:description>
      <:action>
        <Components.button variant="ghost" size="sm">Edit</Components.button>
      </:action>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Your latest deployment is live.
      </p>
      <:footer>
        <Components.button variant="outline" size="sm">View logs</Components.button>
      </:footer>
    </Components.card>
    """
  end

  def render_block(%{block: :collapsible} = assigns) do
    ~H"""
    <Components.card flush class="w-full max-w-md">
      <Components.collapsible id={"#{@id}-collapsible"}>
        <:trigger :let={attrs}>
          <button
            {attrs}
            class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium"
          >
            Starred repositories
            <Components.icon
              name="lucide-chevron-down"
              class="size-4 transition-transform group-aria-expanded:rotate-180"
            />
          </button>
        </:trigger>
        <:content :let={attrs}>
          <div {attrs}>
            <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
              <li>flint_ui</li>
              <li>phoenix_live_view</li>
            </ul>
          </div>
        </:content>
      </Components.collapsible>
    </Components.card>
    """
  end
end
