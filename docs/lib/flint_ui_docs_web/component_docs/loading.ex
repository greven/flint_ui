defmodule FlintUIDocsWeb.ComponentDocs.Loading do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :loading

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @variants ~w(ring ring-bg dots-fade dots-bounce)

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, values: @variants, default: "ring", label: "Variant"},
      %{key: :duration, type: :number, default: 600, label: "Duration (ms)"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def structure do
    """
    <.loading />

    <.loading variant="ring-bg" class="size-6 text-zinc-500" />

    <.loading variant="dots-fade" duration={300} class="size-4" />

    <%!-- Reveal inside a FlintUI button via its [data-loading] attribute --%>
    <.button loading>
      <.loading class="hidden size-4 in-data-loading:inline-block" />
      Saving
    </.button>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :variant,
        title: "Variants",
        layer: :base,
        body: """
        Choose the indicator shape with `variant`: `ring`, `ring-bg`,
        `dots-fade`, or `dots-bounce`.
        """,
        code: """
        <.loading variant="ring-bg" />
        """
      },
      %{
        id: :duration,
        title: "Speed",
        layer: :base,
        body: """
        `duration` sets how long one full animation cycle takes, in milliseconds.
        """,
        code: """
        <.loading duration={300} />
        """
      },
      %{
        id: :container,
        title: "Linking to a container",
        layer: :base,
        body: """
        A function component cannot see its parent, so reveal the spinner either
        conditionally or through a parent's data attribute. `FlintUI.Base.Button` sets
        `data-loading` while loading, which the spinner can key off.
        """,
        code: """
        <.button loading>
          <.loading class="hidden size-4 in-data-loading:inline-block" />
          Saving
        </.button>
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
        <.loading variant="ring" size="md" />
        <.loading variant="dots-fade" size="lg" />
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :variants,
        title: "All variants",
        description: "The four built-in indicator shapes.",
        code: """
        <div class="flex items-center gap-6">
          <.loading variant="ring" class="size-6" />
          <.loading variant="ring-bg" class="size-6" />
          <.loading variant="dots-fade" class="size-6" />
          <.loading variant="dots-bounce" class="size-6" />
        </div>
        """
      },
      %{
        id: :sizes,
        title: "Sizes",
        description: "Size comes from the `class` you pass.",
        code: """
        <div class="flex items-center gap-6">
          <.loading class="size-4" />
          <.loading class="size-6" />
          <.loading class="size-8" />
        </div>
        """
      },
      %{
        id: :labeled,
        title: "Standalone status",
        description: "Pass `label` to expose the spinner as a labeled image.",
        code: """
        <.loading label="Loading" class="size-6" />
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The spinner inherits `currentColor` and takes its size from the `class` you
      pass. Style it with plain CSS or utilities — no theme tokens required.
      """,
      snippets: [
        %{
          title: "Size",
          code: """
          [data-element="loading"][data-size="md"] {
            width: 1.5rem;
            height: 1.5rem;
          }
          """
        },
        %{
          title: "Color",
          code: """
          [data-element="loading"] {
            color: currentColor;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.loading variant={variant(@props)} size={@props.size} duration={duration(@props)} />
    """
  end

  def render_playground(assigns) do
    ~H"""
    <.loading
      variant={variant(@props)}
      duration={duration(@props)}
      class={@props[:class] || "size-6 text-zinc-900 dark:text-zinc-100"}
    />
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.component(
      ".loading",
      [
        Snippet.attr("variant", variant(props), "ring"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("duration", duration(props), 600)
      ]
    )
  end

  def render_code(%{props: props}) do
    Snippet.component(
      ".loading",
      [
        Snippet.attr("variant", variant(props), "ring"),
        Snippet.attr("duration", duration(props), 600)
      ]
    )
  end

  @impl true
  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <.loading :for={variant <- all_variants()} variant={variant} class="size-6" />
    </div>
    """
  end

  def render_usage(%{block: :duration} = assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <.loading duration={300} class="size-6" />
      <.loading duration={600} class="size-6" />
      <.loading duration={1200} class="size-6" />
    </div>
    """
  end

  def render_usage(%{block: :container} = assigns) do
    ~H"""
    <.button
      loading
      class="inline-flex items-center gap-2 rounded-md bg-zinc-900 px-4 py-2 text-sm font-medium text-white"
    >
      <.loading class="hidden size-4 in-data-loading:inline-block" /> Saving
    </.button>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <Components.loading :for={size <- ~w(sm md lg)} variant="ring" size={size} />
    </div>
    """
  end

  @impl true
  def render_block(%{block: :variants} = assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <.loading :for={v <- all_variants()} variant={v} class="size-6" />
    </div>
    """
  end

  def render_block(%{block: :sizes} = assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <.loading class="size-4" />
      <.loading class="size-6" />
      <.loading class="size-8" />
    </div>
    """
  end

  def render_block(%{block: :labeled} = assigns) do
    ~H"""
    <.loading label="Loading" class="size-6 text-zinc-900 dark:text-zinc-100" />
    """
  end

  defp all_variants, do: @variants

  defp variant(%{variant: value}) when value in @variants, do: value
  defp variant(_), do: "ring"

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> 600
    end
  end

  defp duration(_), do: 600
end
