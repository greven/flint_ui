defmodule FlintUIDocsWeb.Docs.Loading do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :loading

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @variants ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, values: @variants, default: "ring", label: "Variant"},
      %{key: :color, type: :select, default: "inherit", label: "Color"},
      %{key: :duration, type: :number, default: nil, label: "Duration (ms, blank = default)"},
      %{key: :weight, type: :number, default: nil, label: "Weight (blank = default)"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def playground_controls, do: [:variant, :color, :size]

  @impl true
  def structure do
    """
    <FlintUI.loading class="size-4" />

    <FlintUI.loading variant="ring-bg" class="size-6 text-zinc-500" />

    <FlintUI.loading variant="ring-dash" class="size-4" />

    <FlintUI.loading variant="dots-fade" duration={300} class="size-4" />

    <FlintUI.loading variant="bars-scale" class="size-4" />

    <FlintUI.loading variant="infinity" class="size-4" />

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
        `ring-dash`, `dots-fade`, `dots-bounce`, `bars-scale`, or `infinity`.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.loading
            :for={variant <- ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)}
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
        It defaults to 600, 2000 for `infinity` so the loop reads as ambient,
        or 1000 for `ring-dash`, which uses it for the dash morph and rotates
        the ring over 4/3 of it.
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
        id: :weight,
        title: "Weight",
        layer: :base,
        covers: [:weight],
        body: """
        `weight` sets the ring stroke width, the infinity loop stroke width, the
        dot radius, or the bar width, in SVG user units. It defaults to 2, or
        2.8 for `bars-scale`.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.loading variant="ring" weight={1} class="size-6" />
          <FlintUI.loading variant="ring" weight={2} class="size-6" />
          <FlintUI.loading variant="ring" weight={3} class="size-6" />
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
          <.loading
            :for={variant <- ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)}
            variant={variant}
          />
        </div>
        """
      },
      %{
        id: :color,
        title: "Color",
        layer: :styled,
        covers: [:color],
        body: """
        `color` maps the indicator onto a semantic role's text token. Leave it at
        the default `inherit` to follow the surrounding `currentColor`, which
        keeps a spinner inside a button or colored label in step with it. A
        custom color works the same way, because the shape paints with
        `currentColor`: set `style="color: …"` on the spinner.
        """,
        code: """
        <div class="flex items-center gap-6">
          <.loading />
          <.loading color="info" />
          <.loading color="success" variant="ring-bg" />
          <.loading color="warning" variant="ring-bg" />
          <.loading color="error" variant="ring-dash" />
          <.loading style="color: #6366f1" variant="ring-dash" />
        </div>
        """
      },
      %{
        id: :styled_duration,
        title: "Duration",
        layer: :styled,
        covers: [],
        body: """
        `duration` sets one animation cycle in milliseconds. It defaults to 600,
        2000 for `infinity`, or 1000 for `ring-dash`; the styled wrapper
        forwards it to the base.
        """,
        code: """
        <div class="flex items-center gap-6">
          <.loading duration={300} />
          <.loading duration={600} />
          <.loading variant="ring-dash" duration={1000} />
          <.loading variant="infinity" duration={2000} />
        </div>
        """
      },
      %{
        id: :styled_weight,
        title: "Weight",
        layer: :styled,
        covers: [],
        body: """
        `weight` controls the ring stroke, infinity loop stroke, dot radius, or
        bar width. It defaults to 2, or 2.8 for `bars-scale`.
        """,
        code: """
        <div class="flex items-center gap-6">
          <.loading variant="ring" weight={1} />
          <.loading variant="ring" weight={2} />
          <.loading variant="ring" weight={3} />
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
        description: "The built-in indicator shapes.",
        code: """
        <div class="flex items-center gap-6">
          <.loading variant="ring" class="size-6" />
          <.loading variant="ring-bg" class="size-6" />
          <.loading variant="ring-dash" class="size-6" />
          <.loading variant="dots-fade" class="size-6" />
          <.loading variant="dots-bounce" class="size-6" />
          <.loading variant="bars-scale" class="size-6" />
          <.loading variant="infinity" class="size-6" />
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
      `variant`; `duration` controls one animation cycle. The animated parts
      carry `data-part` hooks and publish the cycle length inline as
      `animation-duration`, so the theme's CSS keyframes drive them. The
      spinner is decorative by default, or a labeled image when `label` is set.
      """,
      nodes: [
        %{
          tag: "svg",
          selector: ~s([data-element="loading"][data-part="root"]),
          hooks: ["data-variant", "class"],
          attributes: ["viewBox", "role", "aria-label", "aria-hidden"],
          children: [
            %{
              tag: "circle",
              selector: ~s([data-part="track"]),
              note: "the static background track (`ring-bg`, `ring-dash`)",
              children: []
            },
            %{
              tag: "circle",
              selector: ~s([data-part="arc"]),
              note: "the animated arc (`ring`, `ring-bg`, `ring-dash`)",
              children: []
            },
            %{
              tag: "circle",
              selector: ~s([data-part="dot"]),
              note: "one of three staggered dots (`dots-fade`, `dots-bounce`)",
              children: []
            },
            %{
              tag: "rect",
              selector: ~s([data-part="bar"]),
              note: "one of five staggered bars (`bars-scale`)",
              children: []
            },
            %{
              tag: "path",
              selector: ~s([data-part="loop"]),
              note: "the dashed infinity loop (`infinity`)",
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
      The base spinner inherits `currentColor` and takes its size from `class`.
      It has no built-in Tailwind dependency. The animation is CSS keyframes
      shipped in `flint.css`; the base publishes `animation-duration` (and the
      `animation-delay` stagger) inline, so a headless setup only needs the
      keyframes and selectors for the shapes it uses.
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
        },
        %{
          title: "Animation",
          code: """
          @keyframes fl-loading-spin {
            to { transform: rotate(360deg); }
          }
          @keyframes fl-loading-fade {
            50% { opacity: 0.25; }
          }
          @keyframes fl-loading-bounce {
            50% { transform: translateY(-5px); }
          }
          @keyframes fl-loading-dash {
            0% { stroke-dasharray: 0 150; stroke-dashoffset: 0; }
            50% { stroke-dasharray: 42 150; stroke-dashoffset: -16; }
            100% { stroke-dasharray: 42 150; stroke-dashoffset: -59; }
          }
          @keyframes fl-loading-bar-scale {
            33.33% { transform: scaleY(1.8333); }
          }
          @keyframes fl-loading-infinity {
            to { stroke-dashoffset: 51.31778564453125; }
          }

          [data-element="loading"][data-variant="ring"] [data-part="arc"],
          [data-element="loading"][data-variant="ring-bg"] [data-part="arc"] {
            animation: fl-loading-spin 600ms linear infinite;
            transform-box: fill-box;
            transform-origin: center;
          }
          [data-element="loading"][data-variant="ring-dash"] [data-part="arc"] {
            animation:
              fl-loading-spin 1333ms linear infinite,
              fl-loading-dash 1000ms linear infinite;
            transform-box: fill-box;
            transform-origin: center;
          }
          [data-element="loading"][data-variant="dots-fade"] [data-part="dot"] {
            animation: fl-loading-fade 600ms ease-in-out infinite;
          }
          [data-element="loading"][data-variant="dots-bounce"] [data-part="dot"] {
            animation: fl-loading-bounce 600ms ease-in-out infinite;
          }
          [data-element="loading"][data-variant="bars-scale"] [data-part="bar"] {
            animation: fl-loading-bar-scale 600ms linear infinite;
            transform-box: fill-box;
            transform-origin: center;
          }
          [data-element="loading"][data-variant="infinity"] [data-part="loop"] {
            animation: fl-loading-infinity 2000ms linear infinite;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.loading
      variant={variant(@props)}
      color={@props.color}
      size={@props.size}
      duration={duration(@props)}
      weight={weight(@props)}
    />
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    variant = variant(props)

    Snippet.component(
      ".loading",
      [
        Snippet.attr("variant", variant, "ring"),
        Snippet.attr("color", props.color, "inherit"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("duration", duration(props), default_duration(variant)),
        Snippet.attr("weight", weight(props), default_weight(variant))
      ]
    )
  end

  @impl true
  def render_usage(%{block: :styled_variant} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading
        :for={variant <- ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)}
        variant={variant}
      />
    </div>
    """
  end

  def render_usage(%{block: :color} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading />
      <Components.loading color="info" />
      <Components.loading color="success" variant="ring-bg" />
      <Components.loading color="warning" variant="ring-bg" />
      <Components.loading color="error" variant="ring-dash" />
      <Components.loading style="color: #6366f1" variant="ring-dash" />
    </div>
    """
  end

  def render_usage(%{block: :weight} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <FlintUI.loading variant="ring" weight={1} class="size-6" />
      <FlintUI.loading variant="ring" weight={2} class="size-6" />
      <FlintUI.loading variant="ring" weight={3} class="size-6" />
    </div>
    """
  end

  def render_usage(%{block: :styled_duration} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading duration={300} />
      <Components.loading duration={600} />
      <Components.loading variant="ring-dash" duration={1000} />
      <Components.loading variant="infinity" duration={2000} />
    </div>
    """
  end

  def render_usage(%{block: :styled_weight} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <Components.loading variant="ring" weight={1} />
      <Components.loading variant="ring" weight={2} />
      <Components.loading variant="ring" weight={3} />
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
      comes from the generated `size` prop, `duration` publishes the cycle
      length inline, and the spinner inherits `currentColor` from its context.
      The shape keyframes ship in `flint.css`.
      """,
      snippets: [
        %{
          title: "Semantic color",
          body: "The styled `color` prop maps to the role's text token.",
          code: """
          [data-element="loading"][data-color="primary"] {
            color: var(--fl-color-primary-text);
          }
          """
        },
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

  defp default_duration(variant), do: FlintUI.Base.Loading.default_duration(variant)

  defp default_weight(variant), do: FlintUI.Base.Loading.default_weight(variant)

  defp weight(%{weight: value}) when is_number(value) and value > 0, do: value

  defp weight(props), do: default_weight(variant(props))

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> nil
    end
  end

  defp duration(props), do: default_duration(variant(props))
end
