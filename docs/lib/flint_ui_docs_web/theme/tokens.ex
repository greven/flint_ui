defmodule FlintUIDocsWeb.Theme.Tokens do
  @moduledoc false

  # The token guide pages. The sidebar and the Design Tokens navigation grid
  # both read this list, so a page cannot appear in one place and not the other.
  @pages [
    %{
      id: :theming_token_colors,
      action: :colors,
      label: "Colors",
      title: "Colors",
      path: "/guides/theming/tokens/colors",
      icon: "lucide-palette",
      summary: "Role, text, and tone variables.",
      subtitle:
        "The color variables behind every component: semantic roles, text tiers, and the tone hooks a color prop resolves to.",
      namespace: "--fl-color-*"
    },
    %{
      id: :theming_token_typography,
      action: :typography,
      label: "Typography",
      title: "Typography",
      path: "/guides/theming/tokens/typography",
      icon: "lucide-type",
      summary: "Families, size, leading, weight, and tracking.",
      subtitle:
        "The type scale and font tokens components inherit, from family and size to weight and tracking.",
      namespace: "--fl-font-*"
    },
    %{
      id: :theming_token_spacing,
      action: :spacing,
      label: "Spacing",
      title: "Spacing",
      path: "/guides/theming/tokens/spacing",
      icon: "lucide-ruler",
      summary: "Base unit, scale, breakpoints, and containers.",
      subtitle:
        "One base unit drives spacing, while breakpoints and containers keep layout breakpoints consistent.",
      namespace: "--fl-spacing-*"
    },
    %{
      id: :theming_token_radius,
      action: :radius,
      label: "Radius",
      title: "Radius",
      path: "/guides/theming/tokens/radius",
      icon: "lucide-circle",
      summary: "One base unit and a shared control radius.",
      subtitle:
        "Roundness starts from one base unit and a shared control radius, so every control keeps the same shape.",
      namespace: "--fl-radius-*"
    },
    %{
      id: :theming_token_borders,
      action: :borders,
      label: "Borders",
      title: "Borders",
      path: "/guides/theming/tokens/borders",
      icon: "lucide-square-dashed",
      summary: "Three ordered edge strengths.",
      subtitle:
        "Three edge strengths keep dividers, panels, and emphasis distinct without inventing per-component colors.",
      namespace: "--fl-color-border-*"
    },
    %{
      id: :theming_token_surfaces,
      action: :surfaces,
      label: "Surfaces",
      title: "Surfaces",
      path: "/guides/theming/tokens/surfaces",
      icon: "lucide-layers",
      summary: "Page, card, raised fills, and disabled opacity.",
      subtitle:
        "The chrome ladder: page, card, tonal fills, raised overlays, and the opacity used for disabled controls.",
      namespace: "--fl-color-surface-*"
    },
    %{
      id: :theming_token_shadows,
      action: :shadows,
      label: "Shadows",
      title: "Shadows",
      path: "/guides/theming/tokens/shadows",
      icon: "lucide-box",
      summary: "Elevation scale and shared control depth.",
      subtitle:
        "Shadows add elevation, while the shared control depth adds the highlight, inner line, and press movement.",
      namespace: "--fl-shadow-*"
    },
    %{
      id: :theming_token_focus,
      action: :focus,
      label: "Focus",
      title: "Focus",
      path: "/guides/theming/tokens/focus",
      icon: "lucide-scan",
      summary: "One outline geometry for every control.",
      subtitle:
        "Focus is one shared outline. Pick a geometry once and tune its color and opacity for every component.",
      namespace: "--fl-focus-*"
    },
    %{
      id: :theming_token_transitions,
      action: :transitions,
      label: "Transitions",
      title: "Transitions",
      path: "/guides/theming/tokens/transitions",
      icon: "lucide-timer",
      summary: "Durations, easings, and reduced motion.",
      subtitle:
        "Motion uses a small duration and easing scale, and every component respects the reader's reduced-motion setting.",
      namespace: "--fl-duration-*"
    }
  ]

  @doc "Returns every token guide page in sidebar order."
  def pages, do: @pages

  @doc "Returns the sidebar entries for the token guide pages."
  def nav_pages do
    Enum.map(@pages, &Map.take(&1, [:id, :label, :path]))
  end

  @doc "Fetches a token page by its live action."
  def get!(action) when is_atom(action) do
    Enum.find(@pages, &(&1.action == action)) ||
      raise ArgumentError, "unknown theme token page #{inspect(action)}"
  end
end
