defmodule FlintUI.Loading do
  @moduledoc """
  Renders an animated loading indicator.

  Self-contained loading indicator with an inline SVG animated with SMIL.
  Size and color come from `class`, and `variant` selects the shape:

      <.loading />
      <.loading variant="ring-bg" />
      <.loading variant="dots-fade" />
      <.loading variant="dots-bounce" />
      <.loading duration={300} class="size-4" />

  ## Accessibility

  The spinner is decorative by default and hidden from assistive technology.
  Inside a component that already conveys the busy state leave it decorative:
  `FlintUI.Button` with `loading` sets `aria-busy`, so the indicator needs no
  name of its own. For a standalone status, pass `label` to expose it as a
  labeled image:

      <.loading label="Loading" />

  ## Linking to a container

  A function component cannot see its parent, so a `<.loading>` placed inside
  another element does not know when to appear. Reveal it in one of two ways:

    * conditionally, e.g. `<.loading :if={@loading} />`; or
    * with CSS driven by a parent data attribute. `FlintUI.Button` sets
      `[data-loading]` while loading, so the spinner can be exposed with a
      selector such as `[data-loading] [data-element="loading"]`, for example
      using Tailwind CSS: `class="hidden [[data-loading]_&]:inline-block"`.
  """

  use FlintUI.Component

  @variants ~w(ring ring-bg dots-fade dots-bounce)

  @impl true
  def meta do
    %Meta{
      name: :loading,
      type: :element,
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
          value: "ring | ring-bg | dots-fade | dots-bounce",
          description: "The selected `variant`."
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
        "data-variant" => assigns.variant
      }
    }
  end

  @doc false

  attr(:flint_parts, :map, default: nil)

  attr(:variant, :string,
    values: @variants,
    default: "ring",
    doc: "The indicator shape. One of `#{Enum.join(@variants, "`, `")}`."
  )

  attr(:duration, :integer,
    default: 600,
    doc: "Duration of one full animation cycle, in milliseconds."
  )

  attr(:class, :any, default: "size-4", doc: "Additional classes for sizing and color.")

  attr(:label, :string,
    default: nil,
    doc: "An accessible name. When set, the spinner is exposed as a labeled image."
  )

  attr(:rest, :global, doc: "Additional HTML attributes.")

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:variant, variant!(assigns.variant))
      |> assign(:dot_delay, div(assigns.duration, 6))
      |> assign(:dot_delay2, div(assigns.duration, 3))

    ~H"""
    <svg
      viewBox="0 0 24 24"
      fill="none"
      class={@class}
      role={@label && "img"}
      aria-label={@label}
      aria-hidden={is_nil(@label) && "true"}
      {@flint_parts[:root]}
      {@rest}
    >
      <g :if={@variant in ["ring", "ring-bg"]}>
        <circle
          :if={@variant == "ring-bg"}
          cx="12"
          cy="12"
          r="9"
          stroke="currentColor"
          stroke-width="3"
          opacity="0.25"
        />
        <circle
          cx="12"
          cy="12"
          r="9"
          stroke="currentColor"
          stroke-width="3"
          stroke-linecap="round"
          stroke-dasharray="42 15"
        >
          <animateTransform
            attributeName="transform"
            type="rotate"
            from="0 12 12"
            to="360 12 12"
            dur={"#{@duration}ms"}
            repeatCount="indefinite"
          />
        </circle>
      </g>

      <g :if={@variant == "dots-fade"}>
        <circle cx="6" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="opacity"
            values="1;0.25;1"
            dur={"#{@duration}ms"}
            begin="0ms"
            repeatCount="indefinite"
          />
        </circle>
        <circle cx="12" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="opacity"
            values="1;0.25;1"
            dur={"#{@duration}ms"}
            begin={"#{@dot_delay}ms"}
            repeatCount="indefinite"
          />
        </circle>
        <circle cx="18" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="opacity"
            values="1;0.25;1"
            dur={"#{@duration}ms"}
            begin={"#{@dot_delay2}ms"}
            repeatCount="indefinite"
          />
        </circle>
      </g>

      <g :if={@variant == "dots-bounce"}>
        <circle cx="6" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="cy"
            values="12;7;12"
            dur={"#{@duration}ms"}
            begin="0ms"
            repeatCount="indefinite"
            calcMode="spline"
            keyTimes="0;0.5;1"
            keySplines="0.5 0 0.5 1;0.5 0 0.5 1"
          />
        </circle>
        <circle cx="12" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="cy"
            values="12;7;12"
            dur={"#{@duration}ms"}
            begin={"#{@dot_delay}ms"}
            repeatCount="indefinite"
            calcMode="spline"
            keyTimes="0;0.5;1"
            keySplines="0.5 0 0.5 1;0.5 0 0.5 1"
          />
        </circle>
        <circle cx="18" cy="12" r="2" fill="currentColor">
          <animate
            attributeName="cy"
            values="12;7;12"
            dur={"#{@duration}ms"}
            begin={"#{@dot_delay2}ms"}
            repeatCount="indefinite"
            calcMode="spline"
            keyTimes="0;0.5;1"
            keySplines="0.5 0 0.5 1;0.5 0 0.5 1"
          />
        </circle>
      </g>
    </svg>
    """
  end

  defp variant!(variant) when variant in @variants, do: variant

  defp variant!(variant) do
    raise ArgumentError,
          "unknown loading variant #{inspect(variant)}; expected one of #{inspect(@variants)}"
  end
end
