defmodule FlintUIDocsWeb.Examples.Loading do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example, component: :loading

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Examples.Snippet

  @variants ~w(ring ring-bg dots-fade dots-bounce)

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, values: @variants, default: "ring", label: "Variant"},
      %{key: :duration, type: :number, default: 600, label: "Duration (ms)"}
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
  def render_example(assigns) do
    ~H"""
    <.loading
      variant={variant(@props)}
      duration={duration(@props)}
      class={@props[:class] || "size-6 text-zinc-900 dark:text-zinc-100"}
    />
    """
  end

  @impl true
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

  @impl true
  def styled do
    %{
      description:
        "The generated wrapper forwards `variant` and adds a `size` prop mapped onto the `data-size` hook the theme targets.",
      code: """
      <.loading variant="ring" size="md" />
      <.loading variant="dots-fade" size="lg" />
      """
    }
  end

  @impl true
  def render_styled(assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <Components.loading variant="ring" size="sm" />
      <Components.loading variant="ring-bg" size="md" />
      <Components.loading variant="dots-fade" size="md" />
      <Components.loading variant="dots-bounce" size="lg" />
    </div>
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
