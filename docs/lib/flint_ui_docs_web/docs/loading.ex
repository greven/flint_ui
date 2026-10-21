defmodule FlintUIDocsWeb.Docs.Loading do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :loading

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

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
    <FlintUI.loading class="size-4" />

    <FlintUI.loading variant="ring-bg" class="size-6 text-zinc-500" />

    <FlintUI.loading variant="dots-fade" duration={300} class="size-4" />

    <%!-- Reveal inside a FlintUI button via its [data-loading] attribute --%>
    <FlintUI.button loading>
      <FlintUI.loading class="hidden size-4 in-data-loading:inline-block" />
      Saving
    </FlintUI.button>
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
        covers: [:variant],
        body: """
        Choose the indicator shape with `variant`: `ring`, `ring-bg`,
        `dots-fade`, or `dots-bounce`.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.loading
            :for={variant <- ~w(ring ring-bg dots-fade dots-bounce)}
            variant={variant}
            class="size-4"
          />
        </div>
        """
      },
      %{
        id: :duration,
        title: "Speed",
        layer: :base,
        covers: [:duration],
        body: """
        `duration` sets how long one full animation cycle takes, in milliseconds.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.loading duration={300} class="size-4" />
          <FlintUI.loading duration={600} class="size-4" />
          <FlintUI.loading duration={1200} class="size-4" />
        </div>
        """
      },
      %{
        id: :class,
        title: "Sizing and color",
        layer: :base,
        covers: [:class],
        body: """
        The base spinner ships no size of its own. Size it with `class`; color
        comes from `currentColor`, so set `color` on the spinner or its parent.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.loading class="size-4" />
          <FlintUI.loading class="size-6 text-zinc-500" />
        </div>
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        layer: :base,
        covers: [:label],
        body: """
        The spinner is decorative by default. For a standalone status, pass
        `label` to expose it as a labeled image. Inside a button that already
        sets `aria-busy`, leave it decorative.
        """,
        code: """
        <FlintUI.loading label="Loading" class="size-6" />
        """
      },
      %{
        id: :container,
        title: "Linking to a container",
        layer: :base,
        covers: [],
        body: """
        A function component cannot see its parent, so reveal the spinner either
        conditionally or through a parent's data attribute. `FlintUI.Base.Button` sets
        `data-loading` while loading, which the spinner can key off.
        """,
        code: """
        <FlintUI.button loading>
          <FlintUI.loading class="hidden size-4 in-data-loading:inline-block" />
          Saving
        </FlintUI.button>
        """
      },
      %{
        id: :styled_variant,
        title: "Variant",
        layer: :styled,
        covers: [:variant],
        body: """
        The generated component accepts the same `variant` values and maps
        `size` onto the theme's icon-scale box.
        """,
        code: """
        <div class="flex items-center gap-6">
          <.loading :for={variant <- ~w(ring ring-bg dots-fade dots-bounce)} variant={variant} />
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        covers: [:size],
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets.
        """,
        code: """
        <div class="flex items-center gap-6">
          <.loading :for={size <- ~w(sm md lg)} variant="ring" size={size} />
        </div>
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
      },
      %{
        id: :base_status,
        title: "Labeled status",
        layer: :base,
        description: "A standalone spinner with a screen-reader name.",
        code: """
        <FlintUI.loading label="Loading" class="size-6" />
        """
      },
      %{
        id: :base_inline,
        title: "Inline with text",
        layer: :base,
        description: "A decorative spinner next to a status message.",
        code: """
        <p class="flex items-center gap-2">
          <FlintUI.loading class="size-4" /> Saving changes
        </p>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The loading indicator renders an inline SVG. The shape is selected by
      `variant`; `duration` controls one animation cycle. It is decorative by
      default, or a labeled image when `label` is set.
      """,
      nodes: [
        %{
          tag: "svg",
          selector: ~s([data-element="loading"][data-part="root"]),
          hooks: ["data-variant", "class"],
          attributes: ["viewBox", "role", "aria-label", "aria-hidden"],
          children: []
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The base spinner inherits `currentColor` and takes its size from `class`.
      It has no built-in Tailwind dependency. The generated styled component's
      `data-size` contract is documented on the CSS tab.
      """,
      snippets: [
        %{
          title: "Size",
          code: """
          [data-element="loading"] {
            width: 1rem;
            height: 1rem;
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

  @impl true
  def render_usage(%{block: :styled_variant} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading
        :for={variant <- ~w(ring ring-bg dots-fade dots-bounce)}
        variant={variant}
      />
    </div>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading :for={size <- ~w(sm md lg)} variant="ring" size={size} />
    </div>
    """
  end

  @impl true
  def render_block(%{block: :variants} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <.loading :for={v <- all_variants()} variant={v} class="size-6" />
    </div>
    """
  end

  def render_block(%{block: :sizes} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <.loading class="size-4" />
      <.loading class="size-6" />
      <.loading class="size-8" />
    </div>
    """
  end

  def render_block(%{block: :labeled} = assigns) do
    ~H"""
    <.loading label="Loading" class="size-6" />
    """
  end

  @impl true
  def css do
    %{
      body: """
      The styled loading indicator has no public variables of its own. Size
      comes from the generated `size` prop, and the spinner inherits
      `currentColor` from its context.
      """,
      snippets: [
        %{
          title: "Recolor a spinner",
          body: "Set the color on the spinner or its parent.",
          code: """
          .muted-spinner {
            color: var(--fl-color-muted-foreground);
          }
          """
        }
      ]
    }
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
