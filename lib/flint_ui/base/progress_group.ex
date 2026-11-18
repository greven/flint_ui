defmodule FlintUI.Base.ProgressGroup do
  @moduledoc """
  Shows several related values as segments of one progress bar.

  Use a progress group when a total breaks down into parts: storage by
  category, a build by phase, bandwidth by service. Each `:segment` is a share
  of `max`; the bar draws them end to end, and the legend names each segment
  with its color or icon and its percentage.

      <FlintUI.progress_group label="Storage" max={128} show_status>
        <:segment label="Compute" value={42} />
        <:segment label="Storage" value={18} color="info" />
        <:segment label="Bandwidth" value={9} color="warning" />
      </FlintUI.progress_group>

  The segments can leave free track, so a total below `max` still shows the
  remaining capacity. Values are clamped at zero. When the segments add up to
  more than `max`, their widths scale by their sum so the bar stays full and no
  segment is clipped; the root value still caps at `max`.

  ## Legend

  The legend renders when at least one segment has a `label`, an `icon`, or an
  inner block, and it lists every segment: the color dot (or the icon), the
  label when there is one, and the segment's rounded share of the track. Labels
  truncate, and the percentage sits at the inline end.

  An `icon` replaces the dot. Icons are CSS classes, following
  `FlintUI.Base.Icon`: pass `lucide-database`, for example, and let the host
  supply the class. A custom inner block on a segment replaces its label text in
  the legend.

  ## Status

  `show_status` prints the summed rounded percentage above the bar, with the
  label aligned to the end of the last segment rather than the end of the
  track. Pass a `:status` slot to replace the percentage with custom content;
  the slot renders even when `show_status` is false and stays readable to
  assistive technology. The default percentage is decorative, because the root
  already announces the total.

  ## Accessibility

  The root is the only `progressbar`. It carries `aria-valuemin`,
  `aria-valuemax` from `max`, `aria-valuenow` with the summed value capped at
  `max`, and `aria-valuetext` with the rounded total percentage. Give it an
  accessible name with `label`, or pass `aria-labelledby` when a visible
  heading already names it.

  The segments, the dots, and the icons are decorative. The legend is readable
  text, so assistive technology hears the breakdown after the total. Never rely
  on color alone: keep the labels meaningful, and use the legend to name every
  part.

  ## Keyboard

  The progress group is not interactive and adds no keyboard behavior. It is
  never focusable.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :progress_group,
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
          value: "progress_group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the group root, which carries the progressbar role."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("progressbar"),
          description: "Exposes the summed value as a progress bar."
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
          description: "The summed segment value, capped at `max`."
        },
        %Meta.PartAttr{
          name: "aria-valuetext",
          value: "string",
          description: "The summed value as a rounded percentage, such as `54%`."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name, set from `label`."
        },
        %Meta.PartAttr{
          name: "aria-orientation",
          value: "vertical",
          description: "Present only on a vertical group; horizontal is the progressbar default."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The layout direction the theme uses."
        }
      ],
      status: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "status",
          description:
            "The summed rounded percentage above the bar, or custom content from the `:status` slot."
        },
        %Meta.PartAttr{
          name: "style",
          value: "string",
          description:
            "The horizontal status width, which ends at the last segment. Omitted on a vertical group."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description:
            "Present when the status is the default percentage, which repeats the value the root announces. A custom status is readable."
        }
      ],
      track: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "track",
          description: "The visual rail that bounds the segments."
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
          description: "One segment of the bar, sized from its `value` share of `max`."
        },
        %Meta.PartAttr{
          name: "[data-color]",
          value: "string",
          description:
            "The semantic color set on the segment. Absent when the segment inherits the group color."
        },
        %Meta.PartAttr{
          name: "style",
          value: "string",
          description:
            "The server-rendered size, as `inline-size` for a horizontal bar or `block-size` for a vertical bar, plus a raw color's CSS input."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The segment is decorative; the root carries the value."
        }
      ],
      legend: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "legend",
          description:
            "The list of segment labels, colors or icons, and percentages. Rendered when at least one segment has a label, icon, or inner block."
        }
      ],
      item: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "One legend row."
        },
        %Meta.PartAttr{
          name: "[data-color]",
          value: "string",
          description:
            "The semantic color of this segment. Absent when the row inherits the group color."
        },
        %Meta.PartAttr{
          name: "style",
          value: "string",
          description: "A raw color's CSS input for this row's dot or icon."
        }
      ],
      dot: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "dot",
          description: "The segment's color swatch. Replaced by `icon` when the segment sets one."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The dot is decorative; the label names the part."
        }
      ],
      icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "icon",
          description: "The segment's icon, which replaces the dot."
        },
        %Meta.PartAttr{
          name: "class",
          value: "string",
          description: "The icon CSS class, from the segment's `icon`."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The icon is decorative; the label names the part."
        }
      ],
      label: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "label",
          description: "The segment's name in the legend, or its custom inner block."
        }
      ],
      value: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "value",
          description: "The segment's rounded percentage, aligned to the inline end."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    derived = resolve(assigns)
    custom_status = custom_status?(assigns)

    root = %{
      "data-element" => "progress_group",
      "data-part" => "root",
      "role" => "progressbar",
      "aria-valuemin" => "0",
      "aria-valuemax" => format_number(derived.max),
      "aria-valuenow" => format_number(derived.used),
      "aria-valuetext" => derived.percent_label,
      "aria-label" => Map.get(assigns, :label),
      "aria-orientation" => if(derived.orientation == "vertical", do: "vertical"),
      "data-orientation" => derived.orientation
    }

    status =
      %{
        "data-part" => "status",
        "style" => status_style(derived)
      }
      |> then(fn attrs ->
        if custom_status, do: attrs, else: Map.put(attrs, "aria-hidden", "true")
      end)

    %{
      root: root,
      status: status,
      track: %{
        "data-part" => "track",
        "aria-hidden" => "true"
      },
      segment: %{
        "data-part" => "segment",
        "aria-hidden" => "true"
      },
      legend: %{
        "data-part" => "legend"
      },
      item: %{
        "data-part" => "item"
      },
      dot: %{
        "data-part" => "dot",
        "aria-hidden" => "true"
      },
      icon: %{
        "data-part" => "icon",
        "aria-hidden" => "true"
      },
      label: %{
        "data-part" => "label"
      },
      value: %{
        "data-part" => "value"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  # The styled wrapper puts its presentational hooks and the raw color's inline
  # input on the group root. This connector is internal.
  attr :root_attrs, :map, default: %{}, doc: false

  attr :max, :any,
    default: 100,
    doc:
      "The value the segments add up to. Accepts a number or a numeric string. Values above it are capped for the aria value, and a non-positive maximum falls back to 100."

  attr :label, :string,
    default: nil,
    doc:
      "An accessible name for the group. Use it when no visible heading names the breakdown; when a heading already does, pass `aria-labelledby` through the rest attributes instead."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc:
      "The layout direction. A vertical group fills from the bottom, places the legend to the right of the bar, and defaults to ten rems tall."

  attr :show_status, :boolean,
    default: false,
    doc:
      "Whether to show the summed rounded percentage above the bar, aligned with the end of the last segment. A `:status` slot replaces the percentage."

  attr :class, :any, default: nil, doc: "Additional classes for the group root."

  attr :rest, :global, doc: "Additional HTML attributes, rendered on the group root."

  slot :status,
    doc:
      "Custom content for the status above the bar. Replaces the summed percentage and renders even when `show_status` is false."

  slot :segment,
    required: true,
    doc:
      "One share of the bar. May be repeated. The inner block, when present, replaces the label text in the legend." do
    attr :value, :any,
      required: true,
      doc: "The part of `max` this segment takes up. Values below zero count as zero."

    attr :label, :string, doc: "The segment's name in the legend."

    attr :icon, :string,
      doc:
        "An icon CSS class that replaces the legend dot, such as `lucide-database`. The host supplies the class."

    attr :color, :string,
      doc:
        "The segment's color. Overrides the group color. The generated component also accepts a raw color here."

    attr :class, :any, doc: "Additional classes for this segment's bar slice."

    attr :style, :any,
      doc:
        "Inline style for this segment. The generated component uses it to publish a raw color."
  end

  @impl true
  def render(assigns) do
    derived = resolve(assigns)
    custom_status = custom_status?(assigns)
    status_text = if assigns.show_status, do: derived.percent_label

    assigns =
      assigns
      |> assign(:custom_status, custom_status)
      |> assign(:status_text, status_text)
      |> assign(:show_status?, custom_status or assigns.show_status)
      |> assign(:orientation, derived.orientation)
      |> assign(:segments, derived.segments)
      |> assign(:legend, derived.legend)

    ~H"""
    <div {@rest} {@flint_parts[:root]} {@root_attrs} class={@class}>
      <div :if={@show_status?} {@flint_parts[:status]}>
        <%= if @custom_status do %>
          {render_slot(@status)}
        <% else %>
          {@status_text}
        <% end %>
      </div>
      <div {@flint_parts[:track]}>
        <div
          :for={segment <- @segments}
          {@flint_parts[:segment]}
          data-color={segment.color}
          style={segment_style(@orientation, segment)}
          class={segment.class}
        >
        </div>
      </div>
      <div :if={@legend} {@flint_parts[:legend]}>
        <div
          :for={segment <- @segments}
          {@flint_parts[:item]}
          data-color={segment.color}
          style={segment.color_style}
        >
          <span :if={segment.icon} {@flint_parts[:icon]} class={segment.icon}></span>
          <span :if={is_nil(segment.icon)} {@flint_parts[:dot]}></span>
          <span :if={segment.inner_block || segment.label} {@flint_parts[:label]}>
            {if segment.inner_block, do: render_slot(segment.slot), else: segment.label}
          </span>
          <span {@flint_parts[:value]}>{segment.percent_label}</span>
        </div>
      </div>
    </div>
    """
  end

  # Everything the markup needs, resolved once from assigns.
  defp resolve(assigns) do
    max = max_value(Map.get(assigns, :max))

    segments =
      assigns
      |> Map.get(:segment, [])
      |> Enum.map(&segment/1)

    total = Enum.reduce(segments, 0, &(&1.value + &2))
    denominator = max(max, total)
    used = min(total, max)

    segments =
      Enum.map(segments, fn segment ->
        percent = segment.value / denominator * 100

        %{
          segment
          | percent: percent,
            percent_label: percent_label(percent)
        }
      end)

    %{
      max: max,
      used: used,
      orientation: Map.get(assigns, :orientation, "horizontal"),
      segments: segments,
      legend: Enum.any?(segments, &(&1.label || &1.icon || &1.inner_block)),
      percent_label: percent_label(used / max * 100)
    }
  end

  defp segment(slot) do
    %{
      slot: slot,
      value: slot |> Map.get(:value) |> number(0) |> max(0),
      label: blank_to_nil(Map.get(slot, :label)),
      icon: blank_to_nil(Map.get(slot, :icon)),
      color: Map.get(slot, :color),
      class: Map.get(slot, :class),
      color_style: Map.get(slot, :style),
      inner_block: Map.get(slot, :inner_block),
      percent: 0.0,
      percent_label: "0%"
    }
  end

  defp blank_to_nil(value) when value in [nil, ""], do: nil
  defp blank_to_nil(value), do: value

  defp custom_status?(assigns) do
    Map.get(assigns, :status, []) not in [nil, []]
  end

  defp status_style(%{orientation: "vertical"}), do: nil

  defp status_style(%{used: used, max: max}) do
    "inline-size: #{format_number(used / max * 100)}%"
  end

  defp segment_style(orientation, segment) do
    [width(orientation, segment.percent), segment.color_style]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join("; ")
    |> case do
      "" -> nil
      style -> style
    end
  end

  defp width("vertical", percent), do: "block-size: #{format_number(percent)}%"
  defp width(_orientation, percent), do: "inline-size: #{format_number(percent)}%"

  defp max_value(value) do
    case number(value, 100) do
      max when max > 0 -> max
      _ -> 100
    end
  end

  defp percent_label(percent), do: "#{round(percent)}%"

  defp number(nil, default), do: default
  defp number(value, _default) when is_integer(value), do: value

  defp number(value, _default) when is_float(value) do
    normalize_number(value)
  end

  defp number(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> normalize_number(number)
      _ -> default
    end
  end

  defp number(_value, default), do: default

  defp normalize_number(value) when is_float(value) do
    if value == trunc(value), do: trunc(value), else: value
  end

  defp normalize_number(value), do: value

  defp format_number(value) when is_integer(value), do: Integer.to_string(value)

  defp format_number(value) when is_float(value) do
    value = Float.round(value, 6)

    if value == trunc(value) do
      Integer.to_string(trunc(value))
    else
      Float.to_string(value)
    end
  end
end
