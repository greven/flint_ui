defmodule FlintUIDocsWeb.ComponentDocs.Button do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @base "inline-flex items-center justify-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  @outline "border border-zinc-300 text-zinc-900 hover:bg-zinc-100 focus-visible:outline-zinc-900 dark:border-zinc-700 dark:text-zinc-100 dark:hover:bg-zinc-800 dark:focus-visible:outline-white"

  @impl true
  def controls do
    [
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :loading, type: :boolean, default: false, label: "Loading"},
      %{key: :variant, type: :select, default: "solid", label: "Variant"},
      %{key: :color, type: :select, default: "neutral", label: "Color"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def usage do
    [
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
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
        layer: :base,
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
        id: :links,
        title: "Links",
        layer: :base,
        body: """
        Pass `href`, `navigate`, or `patch` to render an anchor instead of a
        button. A disabled link keeps its place in the tab order and is marked
        with `aria-disabled`, so its state can still be discovered.
        """,
        code: """
        <div class="flex flex-col items-start gap-3">
          <.button navigate="/settings">Settings</.button>
          <.button href="https://example.com" target="_blank" rel="noopener" disabled>Visit</.button>
        </div>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button :for={variant <- ~w(solid subtle outline ghost dashed link)} variant={variant}>
            {variant}
          </.button>
        </div>
        """
      },
      %{
        id: :color,
        title: "Color",
        layer: :styled,
        body: """
        The generated component adds a `color` attribute mapped onto the
        `data-color` hook the theme targets. `color` and `variant` compose
        freely: the same palette drives every variant.
        """,
        code: """
        <div class="flex flex-col gap-3">
          <div class="flex flex-wrap items-center gap-3">
            <.button :for={color <- ~w(primary secondary success info warning error neutral)} color={color}>
              {color}
            </.button>
          </div>
          <div class="flex flex-wrap items-center gap-3">
            <.button
              :for={color <- ~w(primary secondary success info warning error neutral)}
              variant="outline"
              color={color}
            >
              {color}
            </.button>
          </div>
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button :for={size <- ~w(xs sm md lg xl)} size={size}>{size}</.button>
        </div>
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
        <.button variant="solid">
          <.icon name="lucide-plus" class="size-4" /> New project
        </.button>
        """
      },
      %{
        id: :loading,
        title: "Loading with a spinner",
        description: "Reveal a FlintUI loading indicator via the button's data-loading state.",
        code: """
        <.button variant="solid" loading>
          <.loading class="hidden size-4 in-data-loading:inline-block" /> Save
        </.button>
        """
      },
      %{
        id: :link,
        title: "Link button",
        description: "Render an anchor that looks and behaves like a button.",
        code: """
        <.button href="https://hexdocs.pm/phoenix_live_view" target="_blank" rel="noopener" class="#{outline_class()}">
          View docs <.icon name="lucide-arrow-up-right" class="size-4" />
        </.button>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      A button renders a single `<button>` (or `<a>` when `href`, `navigate`, or
      `patch` is set). Its content is the `:inner_block` slot — normally the label,
      and the accessible name. Interaction state is exposed as `data-*` attributes
      so you can style it without extra classes.

      The generated component adds `:leading` and `:trailing` slots around the
      label; those are listed in the Docs tab's API reference, not here.
      """,
      nodes: [
        %{
          tag: "button",
          selector: ~s([data-element="button"]),
          hooks: ["data-disabled", "data-loading"],
          attributes: ["type", "aria-busy", "aria-disabled"],
          children: [
            %{
              tag: ":inner_block",
              note: "the button's content (label, icon, or both)",
              children: []
            }
          ]
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The button ships behavior, not appearance. Style it with `class` and target
      the data attributes it exposes for state.
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
          /* The base layer gives every component a focus ring:
           * outline: var(--fl-focus-ring-width) solid var(--fl-focus-ring-color);
           * outline-offset: var(--fl-focus-ring-offset);
           * Retint it per component by overriding the color token. */
          [data-element="button"] {
            --fl-focus-ring-color: var(--fl-color-primary);
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.button
      variant={@props.variant}
      color={@props.color}
      size={@props.size}
      disabled={@props.disabled}
      loading={@props.loading}
    >
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Button
    </Components.button>
    """
  end

  def render_playground(assigns) do
    ~H"""
    <.button disabled={@props.disabled} loading={@props.loading}>
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Button
    </.button>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".button",
      [
        Snippet.attr("variant", props.variant, "solid"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.flag("disabled", props.disabled),
        Snippet.flag("loading", props.loading)
      ],
      "Button"
    )
  end

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
  def render_usage(%{block: :disabled} = assigns) do
    ~H"""
    <.button disabled>Delete</.button>
    """
  end

  def render_usage(%{block: :loading} = assigns) do
    ~H"""
    <.button loading>
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Save
    </.button>
    """
  end

  def render_usage(%{block: :links} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-3">
      <.button navigate="/settings">Settings</.button>
      <.button href="https://example.com" target="_blank" rel="noopener" disabled>Visit</.button>
    </div>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button
        :for={variant <- ~w(solid subtle outline ghost dashed link)}
        variant={variant}
      >
        {variant}
      </Components.button>
    </div>
    """
  end

  def render_usage(%{block: :color} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          :for={color <- ~w(primary secondary success info warning error neutral)}
          color={color}
        >
          {color}
        </Components.button>
      </div>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          :for={color <- ~w(primary secondary success info warning error neutral)}
          variant="outline"
          color={color}
        >
          {color}
        </Components.button>
      </div>
    </div>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button :for={size <- ~w(xs sm md lg xl)} size={size}>{size}</Components.button>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :icon} = assigns) do
    ~H"""
    <Components.button variant="solid">
      <Components.icon name="lucide-plus" class="size-4" /> New project
    </Components.button>
    """
  end

  def render_block(%{block: :loading} = assigns) do
    ~H"""
    <Components.button variant="solid" loading>
      <Components.loading class="hidden size-4 in-data-loading:inline-block" /> Save
    </Components.button>
    """
  end

  def render_block(%{block: :link} = assigns) do
    ~H"""
    <.button href={docs_url()} target="_blank" rel="noopener" class={classes()}>
      View docs <.icon name="lucide-arrow-up-right" class="size-4" />
    </.button>
    """
  end

  defp classes, do: [@base, @outline]
  defp outline_class, do: Enum.join(classes(), " ")

  defp docs_url, do: "https://hexdocs.pm/phoenix_live_view"
end
