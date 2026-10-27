defmodule FlintUI.Base.Loading do
  @moduledoc """
  Renders an animated loading indicator.

  Self-contained loading indicator with an inline SVG. Size and color come from
  `class`, and `variant` selects the shape:

      <.loading />
      <.loading variant="ring-bg" />
      <.loading variant="ring-dash" />
      <.loading variant="dots-fade" />
      <.loading variant="dots-bounce" />
      <.loading variant="bars-scale" />
      <.loading variant="infinity" />
      <.loading duration={300} class="size-4" />

  The shapes are animated with CSS keyframes shipped in `flint.css`. The base
  renders the geometry and publishes the cycle length inline, so a headless
  setup needs the same keyframes; see the component docs for the copyable
  snippet.

  ## Accessibility

  The spinner is decorative by default and hidden from assistive technology.
  Inside a component that already conveys the busy state leave it decorative:
  `FlintUI.Base.Button` with `loading` sets `aria-busy`, so the indicator needs no
  name of its own. For a standalone status, pass `label` to expose it as a
  labeled image:

      <.loading label="Loading" />

  ## Linking to a container

  A function component cannot see its parent, so a `<.loading>` placed inside
  another element does not know when to appear. Reveal it in one of two ways:

    * conditionally, e.g. `<.loading :if={@loading} />`; or
    * with CSS driven by a parent data attribute. `FlintUI.Base.Button` sets
      `[data-loading]` while loading, so the spinner can be exposed with a
      selector such as `[data-loading] [data-element="loading"]`, for example
      using Tailwind CSS: `class="hidden [[data-loading]_&]:inline-block"`.
  """

  use FlintUI.Component

  @variants ~w(ring ring-bg ring-dash dots-fade dots-bounce bars-scale infinity)

  @impl true
  def meta do
    %Meta{
      name: :loading,
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
          value: "loading",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-variant]",
          value: "ring | ring-bg | ring-dash | dots-fade | dots-bounce | bars-scale | infinity",
          description: "The selected `variant`."
        },
        %Meta.PartAttr{
          name: "[data-loading-indicator]",
          description:
            "Marks the element as a loading indicator so a parent can bind its visibility to its own loading state."
        }
      ],
      track: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "track",
          description: "The static background track, rendered by `ring-bg` and `ring-dash`."
        }
      ],
      arc: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "arc",
          description: "The animated arc, rendered by `ring`, `ring-bg`, and `ring-dash`."
        }
      ],
      dot: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "dot",
          description: "One of the three dots, rendered by `dots-fade` and `dots-bounce`."
        },
        %Meta.PartAttr{
          name: "[data-index]",
          value: "0 | 1 | 2",
          description: "The dot's position in the sequence; drives its animation delay."
        }
      ],
      bar: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "bar",
          description: "One of the five bars, rendered by `bars-scale`."
        },
        %Meta.PartAttr{
          name: "[data-index]",
          value: "0..4",
          description: "The bar's position in the sequence; drives its animation delay."
        }
      ],
      loop: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "loop",
          description: "The dashed infinity path, rendered by `infinity`."
        }
      ]
    }
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "loading",
        "data-part" => "root",
        "data-variant" => assigns.variant,
        "data-loading-indicator" => true
      },
      track: %{"data-part" => "track"},
      arc: %{"data-part" => "arc"},
      dot: %{"data-part" => "dot"},
      bar: %{"data-part" => "bar"},
      loop: %{"data-part" => "loop"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil

  attr :variant, :string,
    values: @variants,
    default: "ring",
    doc: "The indicator shape. One of `#{Enum.join(@variants, "`, `")}`."

  attr :duration, :integer,
    default: nil,
    doc:
      "Duration of one full animation cycle, in milliseconds. Defaults to 600, 2000 for `infinity`, or 1000 for `ring-dash`, which uses it for the dash morph and rotates over 4/3 of it."

  attr :weight, :any,
    default: nil,
    doc:
      "Stroke width for rings and the infinity loop, radius for dots, and bar width for bars, in SVG user units. Defaults to 2, or 2.8 for `bars-scale`."

  attr :class, :any,
    default: nil,
    doc: "Additional classes for sizing and color. The base component ships no size of its own."

  attr :label, :string,
    default: nil,
    doc: "An accessible name. When set, the spinner is exposed as a labeled image."

  attr :rest, :global, doc: "Additional HTML attributes."

  @impl true
  def render(assigns) do
    variant = variant!(assigns.variant)
    weight = weight!(assigns.weight || default_weight(variant))

    assigns =
      assigns
      |> assign(:variant, variant)
      |> assign(:duration, assigns.duration || default_duration(variant))
      |> assign(:weight, weight)

    ~H"""
    <svg
      {@rest}
      viewBox="0 0 24 24"
      fill="none"
      class={@class}
      role={@label && "img"}
      aria-label={@label}
      aria-hidden={is_nil(@label) && "true"}
      {@flint_parts[:root]}
    >
      <g :if={@variant in ["ring", "ring-bg"]}>
        <circle
          :if={@variant == "ring-bg"}
          {@flint_parts[:track]}
          cx="12"
          cy="12"
          r="9.5"
          stroke="currentColor"
          stroke-width={@weight}
          opacity="0.25"
        />
        <circle
          {@flint_parts[:arc]}
          cx="12"
          cy="12"
          r="9.5"
          stroke="currentColor"
          stroke-width={@weight}
          stroke-linecap="round"
          stroke-dasharray="44 16"
          style={timing(@duration, 0, 1)}
        />
      </g>

      <g :if={@variant == "ring-dash"}>
        <circle
          {@flint_parts[:track]}
          cx="12"
          cy="12"
          r="9.5"
          stroke="currentColor"
          stroke-width={@weight}
          opacity="0.1"
        />
        <circle
          {@flint_parts[:arc]}
          cx="12"
          cy="12"
          r="9.5"
          stroke="currentColor"
          stroke-width={@weight}
          stroke-linecap="round"
          stroke-dasharray="44 16"
          style={ring_dash_timing(@duration)}
        />
      </g>

      <g :if={@variant in ["dots-fade", "dots-bounce"]}>
        <circle
          :for={{x, index} <- Enum.with_index([6, 12, 18])}
          {@flint_parts[:dot]}
          data-index={index}
          cx={x}
          cy="12"
          r={@weight}
          fill="currentColor"
          style={timing(@duration, index, 3)}
        />
      </g>

      <g :if={@variant == "bars-scale"}>
        <rect
          :for={{x, index} <- Enum.with_index(bar_positions(@weight))}
          {@flint_parts[:bar]}
          data-index={index}
          x={x}
          y="6"
          width={@weight}
          height="12"
          fill="currentColor"
          style={timing(@duration, index, 9)}
        />
      </g>

      <g :if={@variant == "infinity"}>
        <%!-- The reference infinity path, scaled into this viewBox so `weight`
        reads like the other variants. --%>
        <path
          {@flint_parts[:loop]}
          d="M6.86 8C4.28 8 3 10.66 3 12s1.28 4 3.86 4c3.86 0 6.42-8 10.28-8C19.72 8 21 10.66 21 12s-1.28 4-3.86 4C13.28 16 10.72 8 6.86 8z"
          stroke="currentColor"
          stroke-width={@weight}
          stroke-linecap="round"
          stroke-dasharray="41.054228515625 10.26355712890625"
          style={timing(@duration, 0, 1)}
        />
      </g>
    </svg>
    """
  end

  defp timing(duration, 0, _steps), do: "animation-duration: #{duration}ms"

  defp timing(duration, index, steps) do
    "animation-duration: #{duration}ms; animation-delay: -#{div(duration * index, steps)}ms"
  end

  # The dash ring runs two animations on the same part: the spin, then the
  # dasharray/dashoffset morph. The order here must match the theme's
  # `animation` shorthand. The 4/3 ratio matches the reference spinner.
  defp ring_dash_timing(duration) do
    "animation-duration: #{div(duration * 4, 3)}ms, #{duration}ms"
  end

  @doc """
  The default animation cycle for a variant, in milliseconds.

  `ring-dash` defaults to 1000ms because its dash morph reads better slower;
  `infinity` defaults to 2000ms so the loop reads as ambient; the other
  variants default to 600ms.
  """
  def default_duration("infinity"), do: 2000
  def default_duration("ring-dash"), do: 1000
  def default_duration(variant) when variant in @variants, do: 600

  @doc """
  The default weight for a variant, in SVG user units.

  Bars default to 2.8 so the five bars stay chunky at their narrower width;
  rings and dots default to 2.
  """
  def default_weight("bars-scale"), do: 2.8
  def default_weight(variant) when variant in @variants, do: 2.0

  defp weight!(weight) when is_number(weight) and weight > 0, do: weight

  defp weight!(weight) do
    raise ArgumentError,
          "weight must be a positive number, got: #{inspect(weight)}"
  end

  # Five bars spread across the inner 22 units (1..23). Keep the gap even when
  # the bar width changes, so a heavier weight does not push them out of view.
  defp bar_positions(weight) do
    gap = max((22 - 5 * weight) / 4, 0)
    for index <- 0..4, do: 1 + index * (weight + gap)
  end

  defp variant!(variant) when variant in @variants, do: variant

  defp variant!(variant) do
    raise ArgumentError,
          "unknown loading variant #{inspect(variant)}; expected one of #{inspect(@variants)}"
  end
end
