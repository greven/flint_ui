defmodule FlintUIDocsWeb.Docs.LoadingText do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :loading_text

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @variants ~w(dots blink shimmer wave)

  @impl true
  def controls do
    [
      %{key: :text, type: :string, default: "Saving", label: "Text"},
      %{key: :variant, type: :select, values: @variants, default: "dots", label: "Variant"},
      %{key: :color, type: :select, default: "inherit", label: "Color"},
      %{key: :dots, type: :number, default: 3, label: "Dots"},
      %{key: :duration, type: :number, default: nil, label: "Duration (ms, blank = default)"}
    ]
  end

  @impl true
  def structure do
    """
    <FlintUI.loading_text text="Loading" />

    <FlintUI.loading_text text="Syncing" variant="dots" dots={5} />

    <FlintUI.loading_text text="Thinking" variant="blink" />

    <FlintUI.loading_text text="Generating" variant="shimmer" />

    <FlintUI.loading_text text="Uploading" variant="wave" />

    <%!-- Reveal inside a FlintUI button via its [data-loading] attribute. Keep
    the component's `inline-flex` display so the dots stay tight to the copy. --%>
    <FlintUI.button loading>
      <FlintUI.loading_text
        text="Saving"
        variant="dots"
        class="hidden in-data-loading:inline-flex"
      />
    </FlintUI.button>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :text,
        title: "Text",
        layer: :base,
        covers: [:text],
        body: """
        Pass the status copy as `text`. It is rendered as ordinary, escaped
        text, so it follows the surrounding typography and color.
        """,
        code: """
        <FlintUI.loading_text text="Loading" />
        """
      },
      %{
        id: :variant,
        title: "Variants",
        layer: :base,
        covers: [:variant],
        body: """
        `variant` chooses the animation: `dots` appends an animated ellipsis,
        `blink` pulses the copy, `shimmer` moves a highlight across it, and
        `wave` lifts each character in sequence.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text
            :for={variant <- ~w(dots blink shimmer wave)}
            text="Loading"
            variant={variant}
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
        `duration` sets one animation cycle in milliseconds. It defaults to
        1400 for `dots`, 2000 for `blink` and `shimmer`, and 1000 per character
        for `wave`.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text text="Saving" variant="dots" duration={700} />
          <FlintUI.loading_text text="Thinking" variant="blink" duration={1000} />
          <FlintUI.loading_text text="Generating" variant="shimmer" duration={1000} />
          <FlintUI.loading_text text="Uploading" variant="wave" duration={500} />
        </div>
        """
      },
      %{
        id: :dots,
        title: "Dot count",
        layer: :base,
        covers: [:dots],
        body: """
        `dots` sets how many marks the `dots` variant appends. The marks fill in
        from left to right. The default is three; values below 1 are treated as
        1.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text text="Loading" dots={1} />
          <FlintUI.loading_text text="Loading" dots={3} />
          <FlintUI.loading_text text="Loading" dots={5} />
        </div>
        """
      },
      %{
        id: :class,
        title: "Typography and color",
        layer: :base,
        covers: [:class],
        body: """
        The base ships no font size or color of its own. Size and weight come
        from `class`, and the animation paints from `currentColor`.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text text="Saving" class="text-sm text-zinc-500" />
          <FlintUI.loading_text text="Saving" class="text-lg font-medium" />
        </div>
        """
      },
      %{
        id: :styled_variant,
        title: "Variant",
        layer: :styled,
        covers: [:variant],
        body: """
        The generated component accepts the same variants and maps them onto
        the `data-variant` hook the theme targets.
        """
      },
      %{
        id: :color,
        title: "Color",
        layer: :styled,
        covers: [:color],
        body: """
        `color` maps the copy onto a semantic role's text token. Leave it at
        the default `inherit` to follow the surrounding `currentColor`; the
        shimmer and wave animations derive their highlight from that color too.
        """
      },
      %{
        id: :styled_dots,
        title: "Dot count",
        layer: :styled,
        covers: [],
        body: """
        The styled wrapper forwards `dots` to the headless component, so the
        `dots` variant keeps its configurable ellipsis.
        """
      },
      %{
        id: :styled_duration,
        title: "Duration",
        layer: :styled,
        covers: [],
        body: """
        `duration` is forwarded to the base. Shorten it for active work and
        lengthen it for ambient background status.
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
        description: "The text animations, side by side."
      },
      %{
        id: :colors,
        title: "Semantic colors",
        description: "The copy and its animation share the selected theme color."
      },
      %{
        id: :inline,
        title: "Inline status",
        description: "A compact status that sits in a sentence or helper row."
      },
      %{
        id: :button,
        title: "Button",
        description:
          "Use the text animation when the action label itself is the loading state. The theme hides any `[data-loading-indicator]` child until the button is loading."
      },
      %{
        id: :base_variants,
        title: "Headless variants",
        layer: :base,
        description: "The same variants without the generated wrapper.",
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text text="Saving" variant="dots" />
          <FlintUI.loading_text text="Thinking" variant="blink" />
          <FlintUI.loading_text text="Generating" variant="shimmer" />
          <FlintUI.loading_text text="Uploading" variant="wave" />
        </div>
        """
      },
      %{
        id: :base_dots,
        title: "Dot count",
        layer: :base,
        description: "Append exactly as many marks as the status needs.",
        code: """
        <div class="flex flex-wrap items-center gap-6">
          <FlintUI.loading_text text="Loading" dots={1} />
          <FlintUI.loading_text text="Loading" dots={5} />
        </div>
        """
      },
      %{
        id: :base_status,
        title: "Live status",
        layer: :base,
        description: "A standalone status with an accessible live region.",
        code: """
        <FlintUI.loading_text text="Saving" variant="dots" role="status" />
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The loading text renders a span root containing the status copy and,
      for `dots`, an appended ellipsis. The copy is ordinary text; `wave`
      replaces it with one span per grapheme so each character can animate.
      The dots are hidden from assistive technology. Animations are CSS
      keyframes driven by the `data-variant` hook; the base publishes the cycle
      length and stagger inline. The root also marks itself with
      `data-loading-indicator`, so a parent can hide it while idle (the button
      theme does this).
      """,
      nodes: [
        %{
          tag: "span",
          selector: ~s([data-element="loading_text"][data-part="root"]),
          hooks: ["data-variant", "data-loading-indicator", "class"],
          attributes: ["role"],
          children: [
            %{
              tag: "span",
              selector: ~s([data-part="text"]),
              note: "the status copy, or one child per grapheme for `wave`",
              children: [
                %{
                  tag: "span",
                  selector: ~s([data-part="char"]),
                  note: "one animated grapheme (`wave`)",
                  children: []
                }
              ]
            },
            %{
              tag: "span",
              selector: ~s([data-part="dots"]),
              note: "the appended ellipsis (`dots`), hidden from assistive technology",
              children: [
                %{
                  tag: "span",
                  selector: ~s([data-part="dot"]),
                  note: "one animated dot (`dots`)",
                  children: []
                }
              ]
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
      The base text inherits typography and `currentColor`; it has no font size
      or color of its own. The animations are CSS keyframes shipped in
      `flint.css`; the base publishes `animation-duration` and the dot or
      character stagger inline, so a headless setup only needs the keyframes and
      selectors for the variants it uses.
      """,
      snippets: [
        %{
          title: "Dots",
          code: """
          @keyframes fl-loading-text-dot {
            0%, 100% { opacity: 0; }
            50% { opacity: 1; }
          }

          [data-element="loading_text"][data-variant="dots"] [data-part="dots"] {
            display: inline-flex;
          }
          [data-element="loading_text"][data-variant="dots"] [data-part="dot"] {
            opacity: 0;
            animation: fl-loading-text-dot 1400ms linear infinite;
          }
          """
        },
        %{
          title: "Blink",
          code: """
          @keyframes fl-loading-text-blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.45; }
          }

          [data-element="loading_text"][data-variant="blink"] [data-part="text"] {
            animation: fl-loading-text-blink 2000ms ease-in-out infinite;
          }
          """
        },
        %{
          title: "Shimmer",
          code: """
          @keyframes fl-loading-text-shimmer {
            to { background-position: 0% center; }
          }

          [data-element="loading_text"][data-variant="shimmer"] [data-part="text"] {
            background-image: linear-gradient(
              90deg,
              color-mix(in oklab, currentColor 55%, transparent) 0%,
              color-mix(in oklab, currentColor 55%, transparent) 46%,
              currentColor 50%,
              color-mix(in oklab, currentColor 55%, transparent) 54%,
              color-mix(in oklab, currentColor 55%, transparent) 100%
            );
            background-position: 100% center;
            background-repeat: no-repeat;
            background-size: 250% 100%;
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: fl-loading-text-shimmer 2000ms linear infinite;
          }
          """
        },
        %{
          title: "Wave",
          code: """
          @keyframes fl-loading-text-wave {
            0%, 100% {
              transform: translate3d(0, 0, 0) scale(1) rotateY(0);
              color: color-mix(in oklab, currentColor 55%, transparent);
            }
            50% {
              transform: translate3d(2px, -2px, 10px) scale(1.1) rotateY(10deg);
              color: currentColor;
            }
          }

          [data-element="loading_text"][data-variant="wave"] [data-part="text"] {
            display: inline-flex;
            align-items: baseline;
            perspective: 500px;
          }
          [data-element="loading_text"][data-variant="wave"] [data-part="char"] {
            display: inline-block;
            color: color-mix(in oklab, currentColor 55%, transparent);
            white-space: pre;
            transform-style: preserve-3d;
            animation: fl-loading-text-wave 1000ms ease-in-out infinite;
          }
          """
        },
        %{
          title: "Reduced motion",
          code: """
          @media (prefers-reduced-motion: reduce) {
            [data-element="loading_text"],
            [data-element="loading_text"] [data-part="dot"],
            [data-element="loading_text"] [data-part="text"],
            [data-element="loading_text"] [data-part="char"] {
              animation: none;
            }
            [data-element="loading_text"][data-variant="shimmer"] [data-part="text"] {
              background: none;
              -webkit-text-fill-color: currentColor;
            }
            [data-element="loading_text"][data-variant="dots"] [data-part="dot"] {
              opacity: 1;
            }
            [data-element="loading_text"][data-variant="wave"] [data-part="char"] {
              color: inherit;
              transform: none;
            }
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_main(assigns) do
    ~H"""
    <.preview
      :let={props}
      id={@id}
      name={:loading_text}
      state={@state}
      controls={[:text, :variant, :color]}
      code={&main_code/1}
    >
      <Components.loading_text
        text={props.text}
        variant={variant(props)}
        color={props.color}
        dots={dots(props)}
        duration={duration(props)}
      />
    </.preview>
    """
  end

  defp main_code(props) do
    variant = variant(props)

    Snippet.component(".loading_text", [
      Snippet.attr("text", props.text, nil),
      Snippet.attr("variant", variant, "dots"),
      Snippet.attr("color", props.color, "inherit"),
      dots_attr(variant, props),
      Snippet.attr("duration", duration(props), default_duration(variant))
    ])
  end

  @impl true
  def render_section(%{kind: :usage, block: :styled_variant} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:styled_variant)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text
          :for={variant <- ~w(dots blink shimmer wave)}
          text="Loading"
          variant={variant}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :color} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:color)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text text="Saving" />
        <Components.loading_text text="Syncing" color="info" variant="dots" />
        <Components.loading_text text="Thinking" color="success" variant="blink" />
        <Components.loading_text text="Generating" color="warning" variant="shimmer" />
        <Components.loading_text text="Uploading" color="error" variant="wave" />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :styled_dots} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:styled_dots)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text text="Loading" dots={1} />
        <Components.loading_text text="Loading" dots={3} />
        <Components.loading_text text="Loading" dots={5} />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :styled_duration} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:styled_duration)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text text="Saving" variant="dots" duration={700} />
        <Components.loading_text text="Thinking" variant="blink" duration={3000} />
        <Components.loading_text text="Generating" variant="shimmer" duration={1000} />
        <Components.loading_text text="Uploading" variant="wave" duration={500} />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :variants} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:variants)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text
          :for={variant <- ~w(dots blink shimmer wave)}
          text="Loading"
          variant={variant}
        />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :colors} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:colors)}>
      <div class="flex flex-wrap items-center gap-6">
        <Components.loading_text text="Info" color="info" />
        <Components.loading_text text="Success" color="success" />
        <Components.loading_text text="Warning" color="warning" />
        <Components.loading_text text="Error" color="error" />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :inline} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:inline)}>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        <Components.loading_text text="Syncing 3 files" variant="dots" />
      </p>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :button} = assigns) do
    ~H"""
    <.preview id={@id} name={:loading_text} state={@state} code={code(:button)}>
      <Components.button variant="solid" loading>
        <Components.loading_text text="Saving" variant="dots" />
      </Components.button>
    </.preview>
    """
  end

  defp code(:styled_variant) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text
        :for={variant <- ~w(dots blink shimmer wave)}
        text="Loading"
        variant={variant}
      />
    </div>
    """
  end

  defp code(:color) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text text="Saving" />
      <.loading_text text="Syncing" color="info" variant="dots" />
      <.loading_text text="Thinking" color="success" variant="blink" />
      <.loading_text text="Generating" color="warning" variant="shimmer" />
      <.loading_text text="Uploading" color="error" variant="wave" />
    </div>
    """
  end

  defp code(:styled_dots) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text text="Loading" dots={1} />
      <.loading_text text="Loading" dots={3} />
      <.loading_text text="Loading" dots={5} />
    </div>
    """
  end

  defp code(:styled_duration) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text text="Saving" variant="dots" duration={700} />
      <.loading_text text="Thinking" variant="blink" duration={3000} />
      <.loading_text text="Generating" variant="shimmer" duration={1000} />
      <.loading_text text="Uploading" variant="wave" duration={500} />
    </div>
    """
  end

  defp code(:variants) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text text="Saving" variant="dots" />
      <.loading_text text="Thinking" variant="blink" />
      <.loading_text text="Generating" variant="shimmer" />
      <.loading_text text="Uploading" variant="wave" />
    </div>
    """
  end

  defp code(:colors) do
    ~S"""
    <div class="flex flex-wrap items-center gap-6">
      <.loading_text text="Info" color="info" />
      <.loading_text text="Success" color="success" />
      <.loading_text text="Warning" color="warning" />
      <.loading_text text="Error" color="error" />
    </div>
    """
  end

  defp code(:inline) do
    ~S"""
    <p class="text-sm text-zinc-600 dark:text-zinc-400">
      <.loading_text text="Syncing 3 files" variant="dots" />
    </p>
    """
  end

  defp code(:button) do
    ~S"""
    <.button variant="solid" loading>
      <.loading_text text="Saving" variant="dots" />
    </.button>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The styled loading text has no public variables of its own. The `color`
      prop sets the copy's semantic text token; the shimmer gradient and the
      wave highlight derive from that same `currentColor`. Typography is
      inherited, so size and weight come from the surrounding text or `class`.
      The animations ship in `flint.css`.
      """,
      snippets: [
        %{
          title: "Semantic color",
          body: "The styled `color` prop maps to the role's text token.",
          code: """
          [data-element="loading_text"][data-color="primary"] {
            color: var(--fl-color-primary-text);
          }
          """
        },
        %{
          title: "In context",
          body: "Style the copy with the surrounding typography or a class.",
          code: """
          .loading-copy {
            font-weight: 500;
            letter-spacing: 0.01em;
          }
          """
        }
      ]
    }
  end

  defp dots_attr("dots", props), do: Snippet.attr("dots", dots(props), 3)
  defp dots_attr(_variant, _props), do: nil

  defp variant(%{variant: value}) when value in @variants, do: value
  defp variant(_), do: "dots"

  defp dots(%{dots: value}) when is_integer(value) and value > 0, do: value

  defp dots(%{dots: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> 3
    end
  end

  defp dots(_), do: 3

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> nil
    end
  end

  defp duration(_), do: nil

  defp default_duration(variant), do: FlintUI.Base.LoadingText.default_duration(variant)
end
