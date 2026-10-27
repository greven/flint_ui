defmodule FlintUI.Base.LoadingText do
  @moduledoc """
  Renders text with a text-only loading animation.

  `variant` selects the animation:

      <.loading_text text="Saving" />
      <.loading_text text="Syncing" variant="dots" dots={5} />
      <.loading_text text="Thinking" variant="blink" />
      <.loading_text text="Generating" variant="shimmer" />
      <.loading_text text="Uploading" variant="wave" duration={1200} />

  `dots` sets how many marks the `dots` variant appends (default 3). The other
  variants animate the whole copy: `blink` pulses its opacity, `shimmer` moves a
  highlight across it, and `wave` lifts each character in sequence. `wave`
  splits `text` into graphemes, so it is intended for short status copy.

  The animations are CSS keyframes shipped in `flint.css`. The base renders the
  parts and publishes the cycle length (and the dot or character stagger) inline
  as `animation-duration` and `animation-delay`, so a headless setup needs the
  same keyframes; see the component docs for the copyable snippet.

  ## Accessibility

  The copy is real, readable text. The appended dots are decorative and hidden
  from assistive technology, so screen readers announce `"Saving"`, not
  `"Saving dot dot dot"`. For a standalone live status, pass `role="status"`
  through the global attributes so assistive technology announces the copy when
  it changes:

      <.loading_text text="Saving" variant="dots" role="status" />

  Inside a container that already conveys the busy state, such as
  `FlintUI.Base.Button` with `loading`, leave the root plain.

  The animations run entirely in CSS. `flint.css` removes them under
  `prefers-reduced-motion`.
  """

  use FlintUI.Component

  @variants ~w(dots blink shimmer wave)

  @impl true
  def meta do
    %Meta{
      name: :loading_text,
      type: :feedback,
      since: "0.1.0",
      status: :stable
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "loading_text",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-variant]",
          value: "dots | blink | shimmer | wave",
          description: "The selected `variant`."
        },
        %Meta.PartAttr{
          name: "[data-loading-indicator]",
          description:
            "Marks the element as a loading indicator so a parent can bind its visibility to its own loading state."
        }
      ],
      text: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "text",
          description:
            "The status copy. Rendered as plain text, or as one child per character for `wave`."
        }
      ],
      dots: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "dots",
          description:
            "The appended ellipsis, rendered by `dots`. Hidden from assistive technology."
        }
      ],
      dot: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "dot",
          description: "One appended dot, rendered by `dots`."
        },
        %Meta.PartAttr{
          name: "[data-index]",
          value: "0..n-1",
          description: "The dot's position in the sequence; drives its animation delay."
        }
      ],
      char: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "char",
          description: "One grapheme, rendered by `wave`."
        },
        %Meta.PartAttr{
          name: "[data-index]",
          value: "0..n-1",
          description: "The character's position in the copy; drives its animation delay."
        }
      ]
    }
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "loading_text",
        "data-part" => "root",
        "data-variant" => assigns.variant,
        "data-loading-indicator" => true
      },
      text: %{"data-part" => "text"},
      dots: %{"data-part" => "dots", "aria-hidden" => "true"},
      dot: %{"data-part" => "dot"},
      char: %{"data-part" => "char"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :text, :string,
    required: true,
    doc: "The status copy."

  attr :variant, :string,
    values: @variants,
    default: "dots",
    doc: "The text animation. One of `#{Enum.join(@variants, "`, `")}`."

  attr :duration, :integer,
    default: nil,
    doc:
      "Duration of one animation cycle, in milliseconds. Defaults to 1400 for `dots`, 2000 for `blink` and `shimmer`, and 1000 per character for `wave`."

  attr :dots, :integer,
    default: 3,
    doc: "The number of dots appended by the `dots` variant. Values below 1 are treated as 1."

  attr :class, :any,
    default: nil,
    doc:
      "Additional classes for typography and color. The base component ships no size of its own."

  attr :rest, :global, doc: "Additional HTML attributes."

  @impl true
  def render(assigns) do
    variant = variant!(assigns.variant)
    graphemes = String.graphemes(assigns.text)
    duration = assigns.duration || default_duration(variant)
    dots = max(assigns.dots, 1)
    char_count = length(graphemes)
    parts = assigns.flint_parts || %{}

    assigns =
      assigns
      |> assign(:variant, variant)
      |> assign(:duration, duration)
      |> assign(:dots, dots)
      |> assign(:text_attrs, text_attrs(parts[:text], variant, duration))
      |> assign(:char_nodes, char_nodes(parts[:char], variant, graphemes, duration, char_count))
      |> assign(:dot_nodes, dot_nodes(parts[:dot], variant, dots, duration))

    ~H"""
    <span {@rest} class={@class} {@flint_parts[:root]}>
      <span :if={@variant == "wave"} {@text_attrs}>
        <span :for={{char, attrs} <- @char_nodes} {attrs}>{char}</span>
      </span>
      <span :if={@variant != "wave"} {@text_attrs}>{@text}</span>
      <span :if={@variant == "dots"} {@flint_parts[:dots]}>
        <span :for={{dot, attrs} <- @dot_nodes} {attrs}>{dot}</span>
      </span>
    </span>
    """
  end

  defp text_attrs(part, variant, duration) do
    Map.merge(part || %{}, text_style(variant, duration))
  end

  defp text_style(variant, duration) when variant in ["blink", "shimmer"] do
    %{"style" => "animation-duration: #{duration}ms"}
  end

  defp text_style(_variant, _duration), do: %{}

  defp char_nodes(part, "wave", graphemes, duration, count) do
    graphemes
    |> Enum.with_index()
    |> Enum.map(fn {char, index} ->
      attrs =
        Map.merge(part || %{}, %{
          "data-index" => Integer.to_string(index),
          "style" => wave_timing(duration, index, count)
        })

      {char, attrs}
    end)
  end

  defp char_nodes(_part, _variant, _graphemes, _duration, _count), do: []

  defp dot_nodes(part, "dots", dots, duration) do
    for index <- 0..(dots - 1) do
      attrs =
        Map.merge(part || %{}, %{
          "data-index" => Integer.to_string(index),
          "style" => dot_timing(duration, index)
        })

      {".", attrs}
    end
  end

  defp dot_nodes(_part, _variant, _dots, _duration), do: []

  # Each dot starts one seventh of the cycle after the previous one, so the
  # ellipsis fills in from left to right. The theme keeps the dots hidden until
  # their delayed animation starts.
  defp dot_timing(duration, index) do
    "animation-duration: #{duration}ms; animation-delay: #{div(duration * index, 7)}ms"
  end

  # Characters start a fraction of the per-character duration apart, so the
  # highlight travels across the copy.
  defp wave_timing(duration, index, count) do
    "animation-duration: #{duration}ms; animation-delay: #{div(duration * index, count)}ms"
  end

  @doc """
  The default animation cycle for a variant, in milliseconds.

  `dots` defaults to 1400ms, `blink` and `shimmer` to 2000ms, and `wave` to
  1000ms per character.
  """
  def default_duration("dots"), do: 1400
  def default_duration("blink"), do: 2000
  def default_duration("shimmer"), do: 2000
  def default_duration("wave"), do: 1000
  def default_duration(variant) when variant in @variants, do: 2000

  defp variant!(variant) when variant in @variants, do: variant

  defp variant!(variant) do
    raise ArgumentError,
          "unknown loading text variant #{inspect(variant)}; expected one of #{inspect(@variants)}"
  end
end
