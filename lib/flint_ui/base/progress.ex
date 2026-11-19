defmodule FlintUI.Base.Progress do
  @moduledoc """
  Shows how far along a task or operation has progressed.

  The bar fills by the ratio of `value` to `max`. `max` defaults to 100, and the
  component clamps `value` to the range, so a server-side count can be passed
  directly:

      <.progress value={@completed} max={@total} label="Files processed" show_status />

  Omit `value` to render an indeterminate bar, for work that has started but
  cannot report a percentage:

      <.progress label="Uploading" />

  The root is a `div` with the `progressbar` role rather than a native
  `<progress>` element, so the track and status can be themed consistently. The
  ARIA value attributes keep the same semantics.

  ## Steps

  `max` also accepts a list of step labels. The last label is the maximum, so
  the labels spread evenly from 0% to 100%: five labels run from 0 to 4, so
  `value={3}` fills 75% and shows the fourth label under the bar:

      <.progress
        value={@step}
        max={["Waiting", "Cloning", "Migrating", "Deploying", "Done"]}
        label="Deployment"
      />

  The active label replaces the percentage in `aria-valuetext`, so assistive
  technology hears the current step instead of a ratio the labels already
  describe. The labels are decorative and hidden from assistive technology.
  Fractional values sit in the step they have reached, so `3.9` still shows the
  fourth label. Steps are shown only while the value is known.

  ## Status

  `show_status` renders the rounded percentage above the bar. The root also
  exposes `aria-valuetext` with the same percentage, so assistive technology
  hears "40%" even when `max` is not 100. The visible status is decorative and
  hidden from assistive technology, since the progressbar already announces its
  value.

  ## Orientation

  `orientation="vertical"` puts the track on its side, filling from the bottom.
  The default height is ten rems; set a height with `class` or `style` when the
  surrounding layout needs a different length.

  The styled theme is CSS-only. On the generated component, `striped` adds a
  static diagonal pattern and `animated` scrolls it; `animated` implies the
  pattern. The `indeterminate` prop chooses the motion for a value-less bar:
  carousel (the default), swing, or elastic. The theme respects
  `prefers-reduced-motion`: the motion becomes a static full bar and the stripes
  stop scrolling.

  ## Accessibility

  The root is a `progressbar` with `aria-valuemin`, `aria-valuemax`, and
  `aria-valuenow`; `aria-valuetext` carries the percentage, or the active step
  label when `max` is a list. An indeterminate bar omits `aria-valuenow` and
  `aria-valuetext`. The track, segment, status, and steps are decorative.

  Give the bar an accessible name with `label`, or pass `aria-labelledby` when a
  visible heading already names the task. Never rely on color alone to show the
  value: keep the label or surrounding text meaningful, and show the status when
  the percentage matters.

  ## Keyboard

  The progress bar is not interactive and adds no keyboard behavior. It is never
  focusable.
  """

  use FlintUI.Component

  alias FlintUI.ProgressScale

  @impl true
  def meta do
    %Meta{
      name: :progress,
      type: :feedback,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "progress",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the progress root, which carries the progressbar role."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("progressbar"),
          description: "Exposes the value as a progress bar."
        },
        %Meta.PartAttr{
          name: "aria-valuemin",
          value: "0",
          description: "The bottom of the scale."
        },
        %Meta.PartAttr{
          name: "aria-valuemax",
          value: "number",
          description: "The value that represents completion, from `max`."
        },
        %Meta.PartAttr{
          name: "aria-valuenow",
          value: "number",
          description: "The current value. Omitted while the bar is indeterminate."
        },
        %Meta.PartAttr{
          name: "aria-valuetext",
          value: "string",
          description:
            "The current value as a rounded percentage, such as `40%`, or the active step label when `max` is a list. Omitted while the bar is indeterminate."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name, set from `label`."
        },
        %Meta.PartAttr{
          name: "aria-orientation",
          value: "vertical",
          description: "Present only on a vertical bar; horizontal is the progressbar default."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The layout direction the theme uses."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: "indeterminate",
          description: "Present only while no `value` is set."
        }
      ],
      status: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "status",
          description:
            "The rounded percentage shown above the bar when `show_status` is set and the value is known."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The status repeats the percentage the progressbar already announces."
        }
      ],
      track: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "track",
          description: "The visual rail that bounds the fill."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The rail is decorative; the root carries the value."
        }
      ],
      segment: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "segment",
          description: "The filled part of the rail."
        },
        %Meta.PartAttr{
          name: "style",
          value: "string",
          description:
            "The server-rendered fill size, as `inline-size` for a horizontal bar or `block-size` for a vertical bar. Omitted while indeterminate."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The fill is decorative; the root carries the value."
        }
      ],
      steps: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "steps",
          description: "The row of step labels under the bar, rendered only when `max` is a list."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The labels repeat the step the progressbar announces as its value text."
        }
      ],
      step: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "step",
          description:
            "One step label. The theme shows the active label and keeps the rest for the crossfade."
        },
        %Meta.PartAttr{
          name: "[data-active]",
          value: "boolean",
          description: "Present only on the label for the step that contains the current value."
        }
      ]
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "indeterminate",
        description: "No value is known, so the bar animates instead of filling.",
        selector: ~s([data-element="progress"][data-state="indeterminate"])
      },
      %Meta.State{
        name: "active step",
        description: "Marks the step label that contains the current value.",
        selector: ~s([data-element="progress"] [data-part="step"][data-active])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    derived = resolve(assigns)

    value_attrs =
      if derived.indeterminate do
        %{}
      else
        %{
          "aria-valuenow" => ProgressScale.format_number(derived.value),
          "aria-valuetext" => derived.value_text
        }
      end

    root =
      Map.merge(
        %{
          "data-element" => "progress",
          "data-part" => "root",
          "role" => "progressbar",
          "aria-valuemin" => "0",
          "aria-valuemax" => ProgressScale.format_number(derived.max),
          "aria-label" => Map.get(assigns, :label),
          "aria-orientation" => if(derived.orientation == "vertical", do: "vertical"),
          "data-orientation" => derived.orientation,
          "data-state" => if(derived.indeterminate, do: "indeterminate")
        },
        value_attrs
      )

    %{
      root: root,
      status: %{
        "data-part" => "status",
        "aria-hidden" => "true"
      },
      track: %{
        "data-part" => "track",
        "aria-hidden" => "true"
      },
      segment: %{
        "data-part" => "segment",
        "style" => derived.segment_style,
        "aria-hidden" => "true"
      },
      steps: %{
        "data-part" => "steps",
        "aria-hidden" => "true"
      },
      step: %{
        "data-part" => "step"
      }
    }
  end

  # The public attrs are also the docs API, so keep `doc: false` on internal
  # connectors only.
  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks and the raw color's inline
  # input on the progress root. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :value, :any,
    doc:
      "The current value, from `0` to `max`. Accepts a number or a numeric string. Omit it to render an indeterminate bar."

  attr :max, :any,
    default: 100,
    doc:
      "The value that represents completion. Accepts a number, a numeric string, or a list of step labels. With a list, the last label is the maximum: the labels spread from 0% to 100%, and the active label becomes the value text. Values above the scale are clamped, and a non-positive maximum falls back to 100."

  attr :label, :string,
    default: nil,
    doc:
      "An accessible name for the bar. Use it when no visible heading names the task; when a heading already does, pass `aria-labelledby` through the rest attributes instead."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc:
      "The layout direction. A vertical bar fills from the bottom and defaults to ten rems tall."

  attr :show_status, :boolean,
    default: false,
    doc:
      "Whether to show the rounded percentage above the bar. Hidden while the bar is indeterminate."

  attr :class, :any, default: nil, doc: "Additional classes for the progress root."

  attr :rest, :global, doc: "Additional HTML attributes, rendered on the progress root."

  @impl true
  def render(assigns) do
    derived = resolve(assigns)
    status = if assigns.show_status and not derived.indeterminate, do: derived.percent_label

    assigns =
      assigns
      |> assign(:status, status)
      |> assign(:steps, derived.steps)
      |> assign(:active_step, derived.active_step)

    ~H"""
    <div {@rest} {@flint_parts[:root]} {@root_attrs} class={@class}>
      <div :if={@status} {@flint_parts[:status]}>{@status}</div>
      <div {@flint_parts[:track]}>
        <div {@flint_parts[:segment]}></div>
      </div>
      <div :if={@steps} {@flint_parts[:steps]}>
        <div
          :for={{label, index} <- Enum.with_index(@steps)}
          {@flint_parts[:step]}
          data-active={index == @active_step}
        >
          {label}
        </div>
      </div>
    </div>
    """
  end

  # Everything the markup needs, resolved once from assigns.
  defp resolve(assigns) do
    orientation = Map.get(assigns, :orientation, "horizontal")
    derived = ProgressScale.resolve(Map.get(assigns, :value), Map.get(assigns, :max))

    Map.merge(derived, %{
      orientation: orientation,
      segment_style: segment_style(orientation, derived.percent)
    })
  end

  defp segment_style(_orientation, nil), do: nil

  defp segment_style("vertical", percent),
    do: "block-size: #{ProgressScale.format_number(percent)}%"

  defp segment_style(_orientation, percent),
    do: "inline-size: #{ProgressScale.format_number(percent)}%"
end
